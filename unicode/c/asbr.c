/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.

 * Manipulation of unicodepoints, and of character classes (sets of
 * unicodepoints) represented by Alternate Sequences of Byte Ranges
 * (ASBR).
 */

#include <to_utf.h>
#include <scr_int.h>
#include <asbr_int.h>
#include <unidata.h> /* UNI_MAX */

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Internal support
 */

typedef struct ccSBR {
    unsigned char closed; /* Bool flag. True stops further merging */
    struct ccSBR* next;   /* Next item in the stack */
    SBR           sbr;    /* SBR to handle */
} ccSBR;

typedef struct ASBRState {
    ccSBR* top;
    int    depth;
} ASBRState;
    
static void merge    (ASBRState* state, SBR* current);
static int  merge2   (ASBRState* state);
static int  merging  (SBR* prev, SBR* top);
static void push     (ASBRState* state, SBR* current);
static void finalize (ASBRState* state);

/*
 * Internal debug support
 */

#ifdef CRITCL_TRACER
static void __SBR_DUMP   (const char* msg, SBR*   sbr);
static void __CCSBR_DUMP (const char* msg, ccSBR* ccsbr);
static void __ASBR_DUMP  (const char* msg, ASBR*  asbr);

#define SBR_DUMP(sbr)     __SBR_DUMP(__func__,sbr)
#define CCSBR_DUMP(ccsbr) __CCSBR_DUMP(__func__,ccsbr)
#define ASBR_DUMP(asbr)   __ASBR_DUMP(__func__,asbr)
#else

#define SBR_DUMP(sbr)
#define CCSBR_DUMP(ccsbr)
#define ASBR_DUMP(asbr)
#endif

/*
 * ASBR
 * - construct
 * - destroy
 */

void
marpatcl_asbr_destroy (ASBR* asbr) {
    /*
     * Trivial because the alternates are allocated as part of the
     * structure
     */
    TRACE_FUNC ("(asbr %p)", asbr);
    FREE (asbr);
    TRACE_RETURN_VOID;
}
    
/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

ASBR*
marpatcl_asbr_new (SCR* scr, int flags) {
    ASBRState state;
    SBR    current;
    int i, lastcode, codepoint;
    CR* cr;
    ASBR* asbr;
    ccSBR* next;

    state.top   = NULL;
    state.depth = 0;
	
    TRACE_FUNC ("(scr %p)", scr);

    marpatcl_scr_norm (scr);
    SCR_DUMP ("marpatcl_asbr_new", scr);
	
    for (cr = &scr->cr[0], i = 0, lastcode = 0;
	 i < scr->n;
	 cr++, i++)	{
	for (codepoint = cr->start;
	     codepoint <= cr->end;
	     codepoint ++) {
	    /* Reject the codepoints for surrogates */
	    if ((0xD7FF < codepoint) && (codepoint < 0xE000)) continue;
	    if (codepoint > (lastcode+1)) {
		/* Gap between codes, prevent merging */
		finalize(&state);
	    }
	    marpatcl_to_utf (&current, codepoint, flags);
	    merge (&state, &current);
	    lastcode = codepoint;
	}
    }

    CCSBR_DUMP (state.top);
    TRACE ("ccsbr = %p /%d", state.top, state.depth);
	
    /*
     * Convert state to asbr
     * ATTENTION: top becomes last, iterate backward
     */
    asbr = (ASBR*) ckalloc (sizeof(ASBR) + (state.depth-1) * sizeof(SBR));
    TRACE ("NEW asbr   = %p [%d] [%d+%d*%d]", asbr,
	   sizeof(ASBR) + (state.depth-1) * sizeof(SBR),
	   sizeof(ASBR), state.depth-1, sizeof(SBR));
    asbr->n = state.depth;
    for (state.depth--;
	 state.depth >=0;
	 state.depth--, state.top = next) {
	next = state.top->next;
	/* TODO: Assert bounds */
	asbr->sbr[state.depth] = state.top->sbr;
	FREE (state.top);
    }
    ASBR_DUMP (asbr);
    TRACE ("asbr = %p (%d)", asbr, asbr->n);
    TRACE_RETURN ("(ASBR*) %p", asbr);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */
        
static void
finalize (ASBRState* state)
{
    TRACE_FUNC ("(ASBRState*) %p", state);
    if (state->top) {
	state->top->closed = 1;
    }
    TRACE_RETURN_VOID;
}

static void
merge (ASBRState* state, SBR* current)
{
    push (state, current);
    while (merge2 (state));
}
    
static void
push (ASBRState* state, SBR* current)
{
    SBR_DUMP(current);

    ccSBR* ccsbr  = ALLOC (ccSBR);
    ccsbr->sbr    = *current;
    ccsbr->closed = 0;
    ccsbr->next   = state->top;

    state->top = ccsbr;
    state->depth ++;
}

static int
merge2 (ASBRState* state)
{
    ccSBR *top, *prev;
    /* Not enough in the state to merge */
    if (state->depth < 2) {
	TRACE ("merge2 (%d): not enough", state->depth);
	return 0;
    }
    /* Do not merge across a gap */
    top  = state->top;
    prev = top->next;
    if (prev->closed) {
	TRACE ("merge2 (%d): previous closed", state->depth);
	return 0;
    }
    /* Do not merge states of different length (hoisted out of `merging`). */
    if (prev->sbr.n != top->sbr.n) {
	TRACE ("merge2 (%d): length mismatch", state->depth);
	return 0;
    }
    if (!merging(&prev->sbr,&top->sbr)) {
	TRACE ("merge2 (%d): cannot merge", state->depth);
	return 0;
    }
    FREE (top);
    state->top = prev;
    state->depth --;
    TRACE ("merge2 (%d): merged, pop", state->depth);
    return 1;
}

#define R_EQU(a,b) (((a).start == (b).start) && ((a).end == (b).end))
#define R_ADJ(a,b) (((a).end + 1) == (b).start)

#define EQ(i) R_EQU(prev->br[i],top->br[i])
#define UP(i) R_ADJ(prev->br[i],top->br[i])
#define EX(i) prev->br[i].end = top->br[i].end; TRACE ("@ %d", i); return 1

static int
merging (SBR* prev, SBR* top)
{
    TRACE ("merging p (%p) c (%p)", prev, top);
    /* assert: prev-n == top->n, caller ensured */
    /* See merge2 below */
    switch (prev->n) {
    case 1:
	/* Merging allowed for
	 * (a) T adj P --> extend prev
	 */
	if (UP(0)) { EX (0); }
	break;
    case 2:
	/* Merging allowed for
	 * (a) T0 === P0 && T1 adj P1 -> extend P1
	 * (b) T0 adj P0 && T1 === P1 -> extend P0
	 */
	if (EQ(0) && UP(1)) { EX (1); }
	if (UP(0) && EQ(1)) { EX (0); }
	break;
    case 3:
	/* Merging allowed for
	 * (a) T0 === P0 && T1 === P1 && T2 adj P2 -> extend P2
	 * (b) T0 === P0 && T1 adj P1 && T2 === P2 -> extend P1
	 * (c) T0 adj P0 && T1 === P1 && T2 === P2 -> extend P0
	 */
	if (EQ(0) && EQ(1) && UP(2)) { EX (2); }
	if (EQ(0) && UP(1) && EQ(2)) { EX (1); }
	if (UP(0) && EQ(1) && EQ(2)) { EX (0); }
	break;
    case 4:
	/* Merging allowed for
	 * (a) T0 === P0 && T1 === P1 && T2 === P2 && T3 adj P3 -> extend P3
	 * (b) T0 === P0 && T1 === P1 && T2 adj P2 && T3 === P3 -> extend P2
	 * (c) T0 === P0 && T1 adj P1 && T2 === P2 && T3 === P3 -> extend P1
	 * (d) T0 adj P0 && T1 === P1 && T2 === P2 && T3 === P3 -> extend P0
	 */
	if (EQ(0) && EQ(1) && EQ(2) && UP(3)) { EX (3); }
	if (EQ(0) && EQ(1) && UP(2) && EQ(3)) { EX (2); }
	if (EQ(0) && UP(1) && EQ(2) && EQ(3)) { EX (1); }
	if (UP(0) && EQ(1) && EQ(2) && EQ(3)) { EX (0); }
	break;
    case 6:
	/* Merging allowed for
	 * (a) T0 === P0 && T1 === P1 && T2 === P2 && T3 === P3 && T4 === P4 && T5 adj P5 -> extend P5
	 * (b) T0 === P0 && T1 === P1 && T2 === P2 && T3 === P3 && T4 adj P4 && T5 === P5 -> extend P4
	 * (c) T0 === P0 && T1 === P1 && T2 === P2 && T3 adj P3 && T4 === P4 && T5 === P5 -> extend P3
	 * (d) T0 === P0 && T1 === P1 && T2 adj P2 && T3 === P3 && T4 === P4 && T5 === P5 -> extend P2
	 * (e) T0 === P0 && T1 adj P1 && T2 === P2 && T3 === P3 && T4 === P4 && T5 === P5 -> extend P1
	 * (f) T0 adj P0 && T1 === P1 && T2 === P2 && T3 === P3 && T4 === P4 && T5 === P5 -> extend P0
	 */
	if (EQ(0) && EQ(1) && EQ(2) && EQ(3) && EQ(4) && UP(5)) { EX (5); }
	if (EQ(0) && EQ(1) && EQ(2) && EQ(3) && UP(4) && EQ(5)) { EX (4); }
	if (EQ(0) && EQ(1) && EQ(2) && UP(3) && EQ(4) && EQ(5)) { EX (3); }
	if (EQ(0) && EQ(1) && UP(2) && EQ(3) && EQ(4) && EQ(5)) { EX (2); }
	if (EQ(0) && UP(1) && EQ(2) && EQ(3) && EQ(4) && EQ(5)) { EX (1); }
	if (UP(0) && EQ(1) && EQ(2) && EQ(3) && EQ(4) && EQ(5)) { EX (0); }
	break;
    default:
	/* Assert false - must not happen */
	break;
    }
    TRACE ("%s", "no");
    return 0;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

#ifdef CRITCL_TRACER
static void
__SBR_DUMP (const char* msg, SBR* sbr) {
#define BR(i) sbr->br[i].start, sbr->br[i].end
    switch (sbr->n) {
    case 1: {
	TRACE ("SBR %s (1): %3d-%3d",
	       msg, BR(0));
	break;
    }
    case 2: {
	TRACE ("SBR %s (2): %3d-%3d %3d-%3d",
	       msg, BR(0), BR(1));
	break;
    }
    case 3: {
	TRACE ("SBR %s (3): %3d-%3d %3d-%3d %3d-%3d",
	       msg, BR(0), BR(1), BR(2));
	break;
    }
    case 4: {
	TRACE ("SBR %s (4): %3d-%3d %3d-%3d %3d-%3d %3d-%3d",
	       msg, BR(0), BR(1), BR(2), BR(3));
	break;
    }
    case 6: {
	TRACE ("SBR %s (4): %3d-%3d %3d-%3d %3d-%3d %3d-%3d %3d-%3d %3d-%3d",
	       msg, BR(0), BR(1), BR(2), BR(3), BR(4), BR(5));
	break;
    }
    default: {
	ASSERT (0, "Illegal SBR size")
	    break;
    }
    }
#undef BR
}

static void
__CCSBR_DUMP (const char* msg, ccSBR* ccsbr) {
    int i = 0;
    char buf [60]; /* ATTENTION: Size of msg limited by this to 46 chars */
    while (ccsbr) {
	sprintf(buf, "CCSBR %s %4d %s", msg, i, ccsbr->closed ? "-" : " ");
	__SBR_DUMP (buf, &ccsbr->sbr);
	ccsbr = ccsbr->next;
    }
}

static void
__ASBR_DUMP (const char* msg, ASBR* asbr) {
    int i;
    char buf [30]; /* ATTENTION: msg limited by this to 19 chars */
    for (i=0; i < asbr->n ; i++) {
	sprintf(buf, "ASBR %s %4d", msg, i);
	__SBR_DUMP (buf, &asbr->sbr[i]);
    }
}
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

 /*
  * Local Variables:
  * mode: c
  * c-basic-offset: 4
  * fill-column: 78
  * End:
  */
