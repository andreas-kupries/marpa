# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

critcl::ccode {
    #include <string.h> /* memcopy */

    #ifndef UNI_MAX
    #define UNI_MAX 65535 /* BMP by default */
    #endif

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
	int n;     /* #ranges in the class */
	int max;   /* Allocated #ranges (n <= max) */
	int canon; /* Boolean flag, class is normalized, in canonical form */
	CR  cr[1]; /* Ranges allocated as part of the structure */
    } SCR;

    #ifdef CRITCL_TRACER
    #define SCR_DUMP(m,scr) { \
	int i; \
	for (i=0; i < (scr)->n; i++) { \
	   TRACE ((m " (%6d): %8d...%8d", i, \
		   (scr)->cr[i].start, \
		   (scr)->cr[i].end)); \
        } \
    }
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
	BR  br[6];            /* Ranges of the sequence */
    } SBR;

    typedef struct ccSBR {
	unsigned char closed; /* Bool flag. True stops further merging */
	struct ccSBR* next;   /* Next item in the stack */
	SBR           sbr;    /* SBR to handle */
    } ccSBR;

    typedef struct ASBR {
	int n;      /* Number of alternates in the class */
	SBR sbr[1]; /* Alternates allocated as part of structure */
    } ASBR;

    /*
    // SCR
    // - construct
    // - destroy
    // - extend
    // - normalize
    // - negate/complement
    */

    static SCR*
    marpa_scr_new (int n) {
	SCR* scr;

	if (n < 1) { n = 1; }

	scr = (SCR*) ckalloc (sizeof(SCR) + n*sizeof(CR));
	scr->n     = 0;   /* Nothing stored yet */
	scr->max   = n+1; /* Space for one more because of 'cr[1]' in SCR itself */
	scr->canon = 0;   /* Not normalized */
	return scr;
    }

    static void
    marpa_scr_destroy (SCR* scr) {
	/* Trivial because the ranges are allocated as part of the structure */
	ckfree ((char*) scr);
    }

    static void
    marpa_scr_add_range (SCR** pscr, int first, int last) {
	/* SCR** because the structure might be reallocated to make space */
	SCR* scr = *pscr;

	if (scr->n == scr->max) {
	    /* Double the space */
	    SCR* new = marpa_scr_new(2 * scr->max);
	    new->n = scr->n;

	    /* Copy content over */
	    memcpy (new->cr, scr->cr, scr->n * sizeof(CR));

	    /* Release old structure */
	    marpa_scr_destroy(scr);
	    scr = *pscr = new;
	}

	{
	    CR* cr = &scr->cr[scr->n];
	    cr->start = first;
	    cr->end   = last;
	    scr->n ++;
	}

	scr->canon = 0; /* If it was normalized before it may not be anymore */
    }

    static void
    marpa_scr_add_code (SCR** scr, int codepoint) {
	/* SCR** because the structure might be reallocated to make space */
	marpa_scr_add_range (scr, codepoint, codepoint);
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
    marpa_scr_norm (SCR* scr) {
	TRACE_ENTER ("marpa_scr_norm");
	TRACE (("#elements: %d", scr->n));
	
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
	    TRACE (("canonical"));
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
		TRACE (("Input   %8d...%8d | %8d...%8d", PS, PE, CS, CE));
		if (PS == CS) {
		    /* (1a), (1b) above. */
		    PE = CE;
		    TRACE (("(1[ab])  P extend %d", PE));
		    continue;
		}

		/* PS < CS ==> 2* or 3 */
		if (CS <= (PE+1)) {
		    /* (2a,b,c,d) */
		    PE = MAX (PE, CE);
		    TRACE (("(2[a-d]) P extend %d", PE));
		    continue;
		}

		/* (3) ((PE+1)) < CS <=> ((CS-PE) > 1), gap */
		TRACE (("(3) Next"));
		previous ++;
		*previous = *current;
	    }

	    TRACE (("(*) Last"));
	    previous ++;
	    
	    scr->n = previous - &scr->cr[0];
	    #undef PS
	    #undef PE
	    #undef CS
	    #undef CE
	    TRACE (("#final:    %d", scr->n));
	}

	scr->canon = 1;
	TRACE (("done"));
	TRACE_RETURN_VOID;
    }

    static SCR*
    marpa_scr_complement (SCR* scr) {
	/* NOTE:
	// unicode max from a generated c_unidata.tcl file (tools/unidata.tcl)
	// New script ? (tools/unidata_c.tcl ?)
	*/
	int nc;
	SCR* ncr;
	int cmin, cmax;
	CR *current, *sentinel, *store;

	TRACE_ENTER ("marpa_scr_complement");
	TRACE (("#elements: %d", scr->n));
	
	if (scr->n == 0) {
	    /*
	    // Negating an empty class yields the full range.
	    */
	    ncr = marpa_scr_new (1);
	    marpa_scr_add_range(&ncr, 0, UNI_MAX);
	    ncr->canon       = 1;
	    TRACE_RETURN ("ncr: %p", ncr);
	}
	
	marpa_scr_norm (scr);
	TRACE (("#norm elt: %d", scr->n));

	/*
	// For n ranges the complement has between n-1 to n+1 ranges.
	// This depends on which of the unicode limits are touched by
	// the class, or not.
	*/

	nc = scr->n + 1;
	if (scr->cr[0].start == 0) {
	    TRACE (("Bump 0", nc));
	    nc --;
	}
	if (scr->cr[scr->n-1].end == UNI_MAX) {
	    TRACE (("Bump MAX", nc));
	    nc --;
	}

	TRACE (("#negated:  %d", nc));
	ncr = marpa_scr_new (nc);

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
	    TRACE_RETURN ("ncr: %p", ncr);
	}
	
	cmin = 0;
	cmax = UNI_MAX;

	for (current  = &scr->cr[0],
	     sentinel = &scr->cr[scr->n],
	     store    = &ncr->cr[0];
	     current != sentinel;
	     current ++) {
	    TRACE (("Input   %d...%d", current->start, current->end));
	    if (current->start > cmin) {
		store->start = cmin;
		store->end   = current->start - 1;
		TRACE (("  Sto/I %d...%d", store->start, store->end));
		store ++;
	    }
	    cmin = current->end + 1;
	    TRACE (("  Skip  %d", cmin));
	}

	if (cmin < cmax) {
	    store->start = cmin;
	    store->end   = cmax;
	    TRACE (("  Sto/C %d...%d", store->start, store->end));
	    store ++;
	}
	
	ncr->n = store - &ncr->cr[0];
	ncr->canon = 1;
	TRACE (("#final:    %d\n", ncr->n));

	ASSERT (ncr->n <= nc, "Element overflow" );
	ASSERT (ncr->n == nc, "Missing elements" );
	TRACE_RETURN ("ncr: %p", ncr);
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
    finalize (ccSBR* state)
    {
	if (state == NULL) return;
	state->closed = 1;
    }

    static void
    push (ccSBR** statePtr, int* depthPtr, SBR* current)
    {
	ccSBR* state = (ccSBR*) ckalloc (sizeof (ccSBR));
	state->closed = 0;
	state->next = *statePtr;
	memcpy (&state->sbr, current, sizeof(SBR));
	*statePtr = state;
	*depthPtr ++;
    }

    #define R_EQU(a,b) (((a).start == (b).start) && ((a).end == (b).end))
    #define R_ADJ(a,b) (((a).end + 1) == (b).start)

    #define EQ(i) R_EQU(prev->br[i],top->br[i])
    #define UP(i) R_ADJ(prev->br[i],top->br[i])
    #define EX(i) prev->br[i].end = top->br[i].end; return 1

    static int
    merging (SBR* prev, SBR* top)
    {
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
	return 0;
    }
    
    static int
    merge2 (ccSBR** statePtr, int* depthPtr)
    {
	ccSBR *top, *prev;
	/* Not enough in the state to merge */
	if (*depthPtr < 2) {
	    return 0 ;
	}
	/* Do not merge across a gap */
	top = *statePtr;
	prev = top->next;
	if (prev->closed) {
	    return 0;
	}
	/* Do not merge states of different length (hoisted out of `merging`). */
	if (prev->sbr.n != top->sbr.n) {
	    return 0;
	}
	if (!merging(&prev->sbr,&top->sbr)) {
	    return 0;
	}
	*statePtr = prev;
	*depthPtr --;
	ckfree ((char*) top);
	return 1;
    }
    
    static void
    merge (ccSBR** statePtr, int* depthPtr, SBR* current)
    {
	push (statePtr, depthPtr, current);
	while (merge2 (statePtr, depthPtr));
    }
    
    static ASBR*
    marpa_asbr_new (SCR* scr) {
	SBR    current;
	ccSBR* state = NULL;
	int i, lastcode, depth = 0, code;
	CR* cr;

	marpa_scr_norm (scr);
	
	for (cr = &scr->cr[0], i = 0, depth = 0, lastcode = 0;
	     i < scr->n;
	     cr++, i++)	{
	    for (code = cr->start; code <= cr->end; code ++) {
		/* Reject the codepoints for surrogates */
		if ((0xD7FF < code) && (code < 0xE000)) continue;
		if (code > (lastcode+1)) {
		    /* Gap between codes, prevent merging */
		    finalize(state);
		}
		decode (&current, code);
		merge (&state, &depth, &current);
		lastcode = code;
	    }
	}

	return NULL; // TODO
    }

    static void
    marpa_asbr_destroy (ASBR* asbr) {
	/* Trivial because the alternates are allocated as part of the structure */
	ckfree ((char*) asbr);
    }

}

# # ## ### ##### ######## #############
return
