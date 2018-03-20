/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.

 * Manipulation of unicodepoints, and of character classes (sets of
 * unicodepoints) represented by Alternate Sequences of Surrogate Ranges
 * (ASSR).
 */

#include <to_char.h>
#include <scr_int.h>
#include <assr_int.h>
#include <unidata.h> /* UNI_MAX */

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Internal support
 */

typedef struct ccSSR {
    unsigned char closed; /* Bool flag. True stops further merging */
    struct ccSSR* next;   /* Next item in the stack */
    SSR           ssr;    /* SSR to handle */
} ccSSR;

typedef struct ASSRState {
    ccSSR* top;
    int    depth;
} ASSRState;
    
static void merge    (ASSRState* state, SSR* current);
static int  merge2   (ASSRState* state);
static int  merging  (SSR* prev, SSR* top);
static void push     (ASSRState* state, SSR* current);
static void finalize (ASSRState* state);

/*
 * Internal debug support
 */

#ifdef CRITCL_TRACER
static void __SSR_DUMP   (const char* msg, SSR*   sbr);
static void __CCSSR_DUMP (const char* msg, ccSSR* ccsbr);
static void __ASSR_DUMP  (const char* msg, ASSR*  assr);

#define SSR_DUMP(sbr)     __SSR_DUMP(__func__,sbr)
#define CCSSR_DUMP(ccsbr) __CCSSR_DUMP(__func__,ccsbr)
#define ASSR_DUMP(assr)   __ASSR_DUMP(__func__,assr)
#else

#define SSR_DUMP(sbr)
#define CCSSR_DUMP(ccsbr)
#define ASSR_DUMP(assr)
#endif

/*
 * ASSR
 * - construct
 * - destroy
 */

void
marpatcl_assr_destroy (ASSR* assr) {
    /*
     * Trivial because the alternates are allocated as part of the
     * structure
     */
    TRACE_FUNC ("(assr %p)", assr);
    FREE (assr);
    TRACE_RETURN_VOID;
}
    
/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

ASSR*
marpatcl_assr_new (SCR* scr) {
    ASSRState state;
    CR     sr[2];
    SSR    current;
    int i, nsr, lastcode, codepoint;
    CR* cr;
    ASSR* assr;
    ccSSR* next;

    state.top   = NULL;
    state.depth = 0;
	
    TRACE_FUNC ("(scr %p)", scr);

    marpatcl_scr_norm (scr);
    SCR_DUMP ("marpatcl_assr_new", scr);
	
    for (cr = &scr->cr[0], i = 0, lastcode = 0;
	 i < scr->n;
	 cr++, i++)	{
	for (codepoint = cr->start;
	     codepoint <= cr->end;
	     codepoint ++) {
	    if (codepoint > (lastcode+1)) {
		/* Gap between codes, prevent merging */
		finalize(&state);
	    }
	    marpatcl_to_char (sr, &nsr, codepoint);
	    // Note: CR, SR types are identical. Simplify.
	    current.n = nsr;
	    current.sr[0].start = sr[0].start;
	    current.sr[0].end   = sr[0].end;
	    current.sr[1].start = sr[1].start;
	    current.sr[1].end   = sr[1].end;
	    merge (&state, &current);
	    lastcode = codepoint;
	}
    }

    CCSSR_DUMP (state.top);
    TRACE ("ccsbr = %p /%d", state.top, state.depth);
	
    /*
     * Convert state to assr
     * ATTENTION: top becomes last, iterate backward
     */
    assr = (ASSR*) ckalloc (sizeof(ASSR) + (state.depth-1) * sizeof(SSR));
    TRACE ("NEW assr   = %p [%d] [%d+%d*%d]", assr,
	   sizeof(ASSR) + (state.depth-1) * sizeof(SSR),
	   sizeof(ASSR), state.depth-1, sizeof(SSR));
    assr->n = state.depth;
    for (state.depth--;
	 state.depth >=0;
	 state.depth--, state.top = next) {
	next = state.top->next;
	/* TODO: Assert bounds */
	assr->ssr[state.depth] = state.top->ssr;
	FREE (state.top);
    }
    ASSR_DUMP (assr);
    TRACE ("assr = %p (%d)", assr, assr->n);
    TRACE_RETURN ("(ASSR*) %p", assr);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */
        
static void
finalize (ASSRState* state)
{
    TRACE_FUNC ("(ASSRState*) %p", state);
    if (state->top) {
	state->top->closed = 1;
    }
    TRACE_RETURN_VOID;
}

static void
merge (ASSRState* state, SSR* current)
{
    push (state, current);
    while (merge2 (state));
}
    
static void
push (ASSRState* state, SSR* current)
{
    SSR_DUMP(current);

    ccSSR* ccsbr  = ALLOC (ccSSR);
    ccsbr->ssr    = *current;
    ccsbr->closed = 0;
    ccsbr->next   = state->top;

    state->top = ccsbr;
    state->depth ++;
}

static int
merge2 (ASSRState* state)
{
    ccSSR *top, *prev;
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
    if (prev->ssr.n != top->ssr.n) {
	TRACE ("merge2 (%d): length mismatch", state->depth);
	return 0;
    }
    if (!merging(&prev->ssr,&top->ssr)) {
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

#define EQ(i) R_EQU(prev->sr[i],top->sr[i])
#define UP(i) R_ADJ(prev->sr[i],top->sr[i])
#define EX(i) prev->sr[i].end = top->sr[i].end; TRACE ("@ %d", i); return 1

static int
merging (SSR* prev, SSR* top)
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
__SSR_DUMP (const char* msg, SSR* sbr) {
#define SR(i) sbr->sr[i].start, sbr->sr[i].end
    switch (sbr->n) {
    case 1: {
	TRACE ("SSR %s (1): %3d-%3d",
	       msg, SR(0));
	break;
    }
    case 2: {
	TRACE ("SSR %s (2): %3d-%3d %3d-%3d",
	       msg, SR(0), SR(1));
	break;
    }
    case 3: {
	TRACE ("SSR %s (3): %3d-%3d %3d-%3d %3d-%3d",
	       msg, SR(0), SR(1), SR(2));
	break;
    }
    case 4: {
	TRACE ("SSR %s (4): %3d-%3d %3d-%3d %3d-%3d %3d-%3d",
	       msg, SR(0), SR(1), SR(2), SR(3));
	break;
    }
    case 6: {
	TRACE ("SSR %s (4): %3d-%3d %3d-%3d %3d-%3d %3d-%3d %3d-%3d %3d-%3d",
	       msg, SR(0), SR(1), SR(2), SR(3), SR(4), SR(5));
	break;
    }
    default: {
	ASSERT (0, "Illegal SSR size")
	    break;
    }
    }
#undef SR
}

static void
__CCSSR_DUMP (const char* msg, ccSSR* ccsbr) {
    int i = 0;
    char buf [60]; /* ATTENTION: Size of msg limited by this to 46 chars */
    while (ccsbr) {
	sprintf(buf, "CCSSR %s %4d %s", msg, i, ccsbr->closed ? "-" : " ");
	__SSR_DUMP (buf, &ccsbr->ssr);
	ccsbr = ccsbr->next;
    }
}

static void
__ASSR_DUMP (const char* msg, ASSR* assr) {
    int i;
    char buf [30]; /* ATTENTION: msg limited by this to 19 chars */
    for (i=0; i < assr->n ; i++) {
	sprintf(buf, "ASSR %s %4d", msg, i);
	__SSR_DUMP (buf, &assr->ssr[i]);
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
