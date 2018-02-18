# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Unicode structures and utilities.

# Char class as sequence of codepoints and ranges (SCR)
# - Constructor
# - Destructor
# - Normalization
# - Negation
# - Expansion of case-equivalent codepoints (future)
#   (Requires access to unicode tables ... Requires tables in C, currently Tcl)
# - Structures
#   CR   :: Codepoint Range
#   SCR  :: Set of CR
#   NSCR :: Normalized SCR (ordered, no overlapping ranges)

# Char class as Alternation of Sequences of Byte Ranges (ASBR)
# - Constructor
# - Destructor
# - Compile SCR to ASBR
# - Structures
#   BR   :: Byte Range
#   SBR  :: Sequence of BRs (max length 6 - full utf character)
#   ASBR :: Alternations of SBR (char class as utf8 automaton/trie)

# Note: UNI_MAX is defined in generated/unidata.c,
#       critcl::include'd first by marpa.tcl

critcl::ccode {
    #include <string.h> /* memcpy */
    #include <stdlib.h> /* qsort */
    
    #undef  MAX
    #define MAX(a,b) (((a) > (b)) ? (a) : (b))

    /*
    // Char class as sequence of codepoints and ranges
    */

    typedef struct CR {
	int start; /* First uni(code)point in the range */
	int end;   /* Last  uni(code)point in the range */
    } CR;

    typedef struct SCR {
	int n;     /* #ranges in the class, cr[0...n-1] */
	int max;   /* Allocated #ranges (n <= max) */
	int canon; /* Boolean flag, class is normalized, in canonical form */
	CR  cr[1]; /* Ranges allocated as part of the structure */
    } SCR;

    #ifdef CRITCL_TRACER
    static void __SCR_DUMP (const char* msg, SCR* scr) {
	int i;
	for (i=0; i < (scr)->n; i++) {
	    TRACE ("SCR %s (%6d): %8d...%8d", msg, i,
		    (scr)->cr[i].start,
		    (scr)->cr[i].end);
	}
    }
    #define SCR_DUMP(m,scr) __SCR_DUMP(m,scr)
    #else
    #define SCR_DUMP(m,scr)
    #endif

    /*
    // Char class as Alternation of Sequences of Byte Ranges
    */

    typedef struct BR {
	unsigned char start; /* First byte in the range */
	unsigned char end;   /* Last  byte in the range */
    } BR;

    typedef struct SBR {
	unsigned char n;      /* Length of the sequence */
	BR  br[4];            /* Ranges of the sequence */
    } SBR;

    #ifdef CRITCL_TRACER
    static void __SBR_DUMP (const char* msg, SBR* sbr) {
	#define BR(i) sbr->br[i].start, sbr->br[i].end
	switch (sbr->n) {
	    case 1: {
		TRACE ("SBR %s (1): %3d-%3d", msg, BR(0));
		break;
	    }
	    case 2: {
		TRACE ("SBR %s (2): %3d-%3d %3d-%3d", msg, BR(0), BR(1));
		break;
	    }
	    case 3: {
		TRACE ("SBR %s (3): %3d-%3d %3d-%3d %3d-%3d", msg, BR(0), BR(1), BR(2));
		break;
	    }
	    case 4: {
		TRACE ("SBR %s (4): %3d-%3d %3d-%3d %3d-%3d %3d-%3d", msg, BR(0), BR(1), BR(2), BR(3));
		break;
	    }
	    default: {
		ASSERT (0, "Illegal SBR size")
		break;
	    }
	}
	#undef BR
    }
    #define SBR_DUMP(sbr) __SBR_DUMP(__func__,sbr)
    #else
    #define SBR_DUMP(sbr)
    #endif

    typedef struct ccSBR {
	unsigned char closed; /* Bool flag. True stops further merging */
	struct ccSBR* next;   /* Next item in the stack */
	SBR           sbr;    /* SBR to handle */
    } ccSBR;

    typedef struct ASBRState {
	ccSBR* top;
	int    depth;
    } ASBRState;
    
    #ifdef CRITCL_TRACER
    static void __CCSBR_DUMP (const char* msg, ccSBR* ccsbr) {
	int i = 0;
	char buf [60]; /* ATTENTION: Size of msg limited by this to 46 chars */
	while (ccsbr) {
	    sprintf(buf, "CCSBR %s %4d %s", msg, i, ccsbr->closed ? "-" : " ");
	    __SBR_DUMP (buf, &ccsbr->sbr);
	    ccsbr = ccsbr->next;
	}
    }
    #define CCSBR_DUMP(ccsbr) __CCSBR_DUMP(__func__,ccsbr)
    #else
    #define CCSBR_DUMP(ccsbr)
    #endif
	
    typedef struct ASBR {
	int n;      /* Number of alternates in the class */
	SBR sbr[1]; /* Alternates allocated as part of structure */
    } ASBR;

    #ifdef CRITCL_TRACER
    static void __ASBR_DUMP (const char* msg, ASBR* asbr) {
	int i;
	char buf [30]; /* ATTENTION: msg limited by this to 19 chars */
	for (i=0; i < asbr->n ; i++) {
	    sprintf(buf, "ASBR %s %4d", msg, i);
	    __SBR_DUMP (buf, &asbr->sbr[i]);
	}
    }
    #define ASBR_DUMP(asbr) __ASBR_DUMP(__func__,asbr)
    #else
    #define ASBR_DUMP(asbr)
    #endif

    /*
    // SCR
    // - construct
    // - destroy
    // - extend
    // - normalize
    // - negate/complement
    */

    static SCR*
    marpatcl_scr_new (int n) {
	SCR* scr;
	TRACE_FUNC ("(n %d)", n);

	if (n < 1) { n = 1; }
	TRACE ("Allocating %d", n);
	
	scr = (SCR*) ckalloc (sizeof(SCR) + (n-1)*sizeof(CR));
	TRACE ("NEW scr    = %p .. %p [%d] [%d+%d*%d]", scr,
		((char*) scr)+sizeof(SCR)+(n-1)*sizeof(CR),
		sizeof(SCR)+(n-1)*sizeof(CR),
		sizeof(SCR), n-1, sizeof(CR));
	scr->n     = 0;  /* Nothing stored yet */
	scr->max   = n;  /* Note the 'cr[1]' in SCR itself */
	scr->canon = 0;  /* Not normalized */
	TRACE_RETURN ("(SCR*) %p", scr);
    }

    static void
    marpatcl_scr_destroy (SCR* scr) {
	/*
	// Trivial because the ranges are allocated as part of the structure
	*/
	TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
	ckfree ((char*) scr);
	TRACE_RETURN_VOID;
    }

    static void
    marpatcl_scr_add_range (SCR* scr, int first, int last) {
	TRACE_FUNC ("((SCR*) %p [%d/%d], fl (%d...%d))",
		    scr, scr->n, scr->max, first, last);
	ASSERT (scr->n < scr->max, "Unable to add range to full SCR");

	scr->cr[scr->n].start = first;
	scr->cr[scr->n].end   = last;
	scr->n ++;
	scr->canon = 0; /* If it was normalized before it may not be anymore */
	TRACE_RETURN_VOID;
    }

    static void
    marpatcl_scr_add_code (SCR* scr, int codepoint) {
	marpatcl_scr_add_range (scr, codepoint, codepoint);
    }

    static int
    scr_compare (const void* ain, const void* bin) {
	CR* a = (CR*) ain;
	CR* b = (CR*) bin;

	/*
	// Sort by starting point first
	*/
	if (a->start < b->start) { return -1 ; }
	if (a->start > b->start) { return  1 ; }

	/*
	// For equal starting points sort by the end points, i.e the
	// shorter range comes before the longer
	*/
	if (a->end < b->end) { return -1 ; }
	if (a->end > b->end) { return  1 ; }

	/* Fully the same */
	return 0;
    }

    static void
    marpatcl_scr_norm (SCR* scr) {
	TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
	
	/*
	// Normalization is done in place. The resulting class
	// cannot use more ranges than the input, making this
	// possible. It may have strictly less, when overlapping
	// ranges are merged.
	//
	// Operation in 2 phases
	// - Sort the ranges in ascending order
	// - Iterate over the range and merge overlapping/adjacent
	//   ones.
	//
	// Of course, an already normalized class is not changed at
	// all. And a single-element class is canonical by definition.
	*/

	if (scr->canon) {
	    TRACE ("%s", "canonical");
	    TRACE_RETURN_VOID;
	}

	if (scr->n > 1) {
	    CR *previous, *current, *sentinel;
	    #define PS previous->start
	    #define CS current->start
	    #define PE previous->end
	    #define CE current->end

	    SCR_DUMP("I", scr);
	    qsort (&scr->cr, scr->n, sizeof(CR), scr_compare);
	    SCR_DUMP("S", scr);

	    /* Assertions, for all cr[i], cr[i+1] (P, C)
	    // (P->start <= C->start)
	    // (P->start == C->start) ==> (P->end <= C->end)
	    //
	    // This means the ranges in question can have the
	    // following relative locations to each other:
	    //
	    // (1a) |--------|    \   P is a subset of C, or identical
	    //      |--------|     \  Extend it to be C.
	    //                      >
	    // (1b) |--------|     /
	    //      |-----------| /
	    //
	    // (2a) |--------|            \   C is contained in P,
	    //         |---|               \  or extends it at the end.
	    //                              |
	    // (2b) |--------|              | Extend P to the max of (PE,CE)
	    //         |-----|              |
	    //                              > This is for CS <= PE+1
	    // (2c) |--------|              | (== in that means adjacent)
	    //         |---------|          |
	    //                              |
	    // (2d) |--------|             /
	    //                |---------| /
	    //
	    // (3)  |--------|            \ C is after P, with a non-empty gap.
	    //                 |---|      / P is final, C can be shifted as the next P
	    */

	    for (
		 previous = &scr->cr[0],
		 current  = &scr->cr[1],
		 sentinel = &scr->cr[scr->n];
		 current != sentinel;
		 current ++) {
		TRACE ("Input   %8d...%8d | %8d...%8d", PS, PE, CS, CE);
		if (PS == CS) {
		    /* (1a), (1b) above. */
		    PE = CE;
		    TRACE ("(1[ab])  P extend %d", PE);
		    continue;
		}

		/* PS < CS ==> 2* or 3 */
		if (CS <= (PE+1)) {
		    /* (2a,b,c,d) */
		    PE = MAX (PE, CE);
		    TRACE ("(2[a-d]) P extend %d", PE);
		    continue;
		}

		/* (3) ((PE+1)) < CS <=> ((CS-PE) > 1), gap */
		TRACE ("%s", "(3) Next");
		previous ++;
		*previous = *current;
	    }

	    TRACE ("%s", "(*) Last");
	    previous ++;
	    
	    scr->n = previous - &scr->cr[0];
	    #undef PS
	    #undef PE
	    #undef CS
	    #undef CE
	    TRACE ("#final:    %d", scr->n);
	}

	scr->canon = 1;
	TRACE ("%s", "done");
	TRACE ("scr out %p :: #elements: %d", scr, scr->n);
	TRACE_RETURN_VOID;
    }

    static SCR*
    marpatcl_scr_complement (SCR* scr) {
	/* NOTE:
	// unicode max from a generated c_unidata.tcl file (tools/unidata.tcl)
	// New script ? (tools/unidata_c.tcl ?)
	*/
	int nc;
	SCR* ncr;
	int cmin, cmax;
	CR *current, *sentinel, *store;

	TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
	
	if (scr->n == 0) {
	    /*
	    // Negating an empty class yields the full range.
	    */
	    ncr = marpatcl_scr_new (1);
	    marpatcl_scr_add_range (ncr, 0, UNI_MAX);
	    ncr->canon       = 1;
	    TRACE ("ncr out %p :: #elements: %d, canonical", ncr, ncr->n);
	    TRACE_RETURN ("(SCR*) %p", ncr);
	}
	
	marpatcl_scr_norm (scr);
	TRACE ("#norm elt: %d", scr->n);

	/*
	// For n ranges the complement has between n-1 to n+1 ranges.
	// This depends on which of the unicode limits are touched by
	// the class, or not.
	*/

	nc = scr->n + 1;
	if (scr->cr[0].start == 0) {
	    TRACE ("Bump 0", nc);
	    nc --;
	}
	if (scr->cr[scr->n-1].end == UNI_MAX) {
	    TRACE ("Bump MAX", nc);
	    nc --;
	}

	TRACE ("#negated:  %d", nc);
	ncr = marpatcl_scr_new (nc);

	if (nc == 0) {
	    /*
	    // Negating a full range yields an empty class.
	    // Notes:
	    // -     scr->n >= 1 (0 was handled separately)
	    //   ==> nc >= 2
	    //   ==> nc' >= 0   (Max subtraction is 2)
	    // - (nc' == 0) ==> (nc == 2)
	    //              ==> both 0, UNI_MAX triggered
	    //              ==> input covered the entire range
	    //
	    */
	    ncr->canon = 1;
	    TRACE ("ncr out %p :: #elements: %d, canonical", ncr, ncr->n);
	    TRACE_RETURN ("(SCR*) %p", ncr);
	}
	
	cmin = 0;
	cmax = UNI_MAX;

	for (current  = &scr->cr[0],
	     sentinel = &scr->cr[scr->n],
	     store    = &ncr->cr[0];
	     current != sentinel;
	     current ++) {
	    TRACE ("Input   %d...%d", current->start, current->end);
	    if (current->start > cmin) {
		store->start = cmin;
		store->end   = current->start - 1;
		TRACE ("  Sto/I %d...%d", store->start, store->end);
		store ++;
	    }
	    cmin = current->end + 1;
	    TRACE ("  Skip  %d", cmin);
	}

	if (cmin < cmax) {
	    store->start = cmin;
	    store->end   = cmax;
	    TRACE ("  Sto/C %d...%d", store->start, store->end);
	    store ++;
	}
	
	ncr->n = store - &ncr->cr[0];
	ncr->canon = 1;
	TRACE ("#final:    %d\n", ncr->n);

	ASSERT (ncr->n <= nc, "Element overflow" );
	ASSERT (ncr->n == nc, "Missing elements" );
	TRACE ("ncr out %p :: #elements: %d, canonical", ncr, ncr->n);
	TRACE_RETURN ("(SCR*) %p", ncr);
    }

    /*
    // ASBR
    // - construct
    // - destroy
    */

    static void
    decode (SBR* sbr, int code) {
	int tmp;
	if (code < 128) {
	    sbr->n = 1;
	    sbr->br[0].start = tmp = code & 0x7f;
	    sbr->br[0].end   = tmp;
	    return;
	}
	if (code < 2048) {
	    sbr->n = 2;
	    sbr->br[0].start = tmp = ((code >> 6) & 0x1F) | 0xC0;
	    sbr->br[0].end   = tmp;
	    sbr->br[1].start = tmp = ((code     ) & 0x3F) | 0x80;
	    sbr->br[1].end   = tmp;
	    return;
	}
	if (code < 65536) {
	    sbr->n = 3;
	    sbr->br[0].start = tmp = ((code >> 12) & 0x0F) | 0xE0;
	    sbr->br[0].end   = tmp;
	    sbr->br[1].start = tmp = ((code >>  6) & 0x3F) | 0x80;
	    sbr->br[1].end   = tmp;
	    sbr->br[2].start = tmp = ((code      ) & 0x3F) | 0x80;
	    sbr->br[2].end   = tmp;
	    return;
	}

	sbr->n = 4;
	sbr->br[0].start = tmp = ((code >> 18) & 0x07) | 0xF0;
	sbr->br[0].end   = tmp;
	sbr->br[1].start = tmp = ((code >> 12) & 0x3F) | 0x80;
	sbr->br[1].end   = tmp;
	sbr->br[2].start = tmp = ((code >>  6) & 0x3F) | 0x80;
	sbr->br[2].end   = tmp;
	sbr->br[3].start = tmp = ((code      ) & 0x3F) | 0x80;
	sbr->br[3].end   = tmp;
    }
    
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
    push (ASBRState* state, SBR* current)
    {
	SBR_DUMP(current);
	ccSBR* ccsbr = (ccSBR*) ckalloc (sizeof (ccSBR));
	ccsbr->sbr    = *current;
	ccsbr->closed = 0;
	ccsbr->next   = state->top;
	state->top = ccsbr;
	state->depth ++;
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
	    // (a) T adj P --> extend prev
	    */
	    if (UP(0)) { EX (0); }
	    break;
	    case 2:
	    /* Merging allowed for
	    // (a) T0 === P0 && T1 adj P1 -> extend P1
	    // (b) T0 adj P0 && T1 === P1 -> extend P0
	    */
	    if (EQ(0) && UP(1)) { EX (1); }
	    if (UP(0) && EQ(1)) { EX (0); }
	    break;
	    case 3:
	    /* Merging allowed for
	    // (a) T0 === P0 && T1 === P1 && T2 adj P2 -> extend P2
	    // (b) T0 === P0 && T1 adj P1 && T2 === P2 -> extend P1
	    // (c) T0 adj P0 && T1 === P1 && T2 === P2 -> extend P0
	    */
	    if (EQ(0) && EQ(1) && UP(2)) { EX (2); }
	    if (EQ(0) && UP(1) && EQ(2)) { EX (1); }
	    if (UP(0) && EQ(1) && EQ(2)) { EX (0); }
	    break;
	    case 4:
	    /* Merging allowed for
	    // (a) T0 === P0 && T1 === P1 && T2 === P2 && T3 adj P3 -> extend P3
	    // (b) T0 === P0 && T1 === P1 && T2 adj P2 && T3 === P3 -> extend P2
	    // (c) T0 === P0 && T1 adj P1 && T2 === P2 && T3 === P3 -> extend P1
	    // (d) T0 adj P0 && T1 === P1 && T2 === P2 && T3 === P3 -> extend P0
	    */
	    if (EQ(0) && EQ(1) && EQ(2) && UP(3)) { EX (3); }
	    if (EQ(0) && EQ(1) && UP(2) && EQ(3)) { EX (2); }
	    if (EQ(0) && UP(1) && EQ(2) && EQ(3)) { EX (1); }
	    if (UP(0) && EQ(1) && EQ(2) && EQ(3)) { EX (0); }
	    break;
	    default:
	    /* Assert false - must not happen */
	    break;
	}
	TRACE ("%s", "no");
	return 0;
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
	ckfree ((char*) top);
	state->top = prev;
	state->depth --;
	TRACE ("merge2 (%d): merged, pop", state->depth);
	return 1;
    }
    
    static void
    merge (ASBRState* state, SBR* current)
    {
	push (state, current);
	while (merge2 (state));
    }
    
    static ASBR*
    marpatcl_asbr_new (SCR* scr) {
	ASBRState state;
	SBR    current;
	int i, lastcode, code;
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
	    for (code = cr->start; code <= cr->end; code ++) {
		/* Reject the codepoints for surrogates */
		if ((0xD7FF < code) && (code < 0xE000)) continue;
		if (code > (lastcode+1)) {
		    /* Gap between codes, prevent merging */
		    finalize(&state);
		}
		decode (&current, code);
		merge (&state, &current);
		lastcode = code;
	    }
	}

	CCSBR_DUMP (state.top);
	TRACE ("ccsbr = %p /%d", state.top, state.depth);
	
	/*
	// Convert state to asbr
	// ATTENTION: top becomes last, iterate backward
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
	    ckfree ((char*) state.top);
	}
	ASBR_DUMP (asbr);
	TRACE ("asbr = %p (%d)", asbr, asbr->n);
	TRACE_RETURN ("(ASBR*) %p", asbr);
    }

    static void
    marpatcl_asbr_destroy (ASBR* asbr) {
	/*
	// Trivial because the alternates are allocated as part of the
	// structure
	*/
	TRACE_FUNC ("(asbr %p)", asbr);
	ckfree ((char*) asbr);
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############

critcl::cconst marpa::unicode::max int UNI_MAX

# # ## ### ##### ######## #############

critcl::cproc marpa::unicode::2utf {
    Tcl_Interp*     interp
    int             code
} object0 {
    int r, i;
    Tcl_Obj* b;
    SBR sbr;
    
    decode (&sbr, code);

    b = Tcl_NewListObj (0,0);
    for (i = 0; i < sbr.n; i++) {
	r = Tcl_ListObjAppendElement (interp, b, Tcl_NewIntObj (sbr.br[i].start));
	if (r == TCL_OK) continue;
	Tcl_DecrRefCount (b);
	return 0;
    }
    return b;
}

# # ## ### ##### ######## #############
return
