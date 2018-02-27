/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Manipulating character classes represented by a Sequence/set of Codepoints
 * and Ranges (SCR). The points are represented as ranges of cardinality 1.
 */

#include <stdlib.h> /* qsort */

#include <scr_int.h>
#include <unidata.h> /* UNI_MAX */

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Internal support
 */

static int
compare (const void* ain, const void* bin);
    
#undef  MAX
#define MAX(a,b) (((a) > (b)) ? (a) : (b))

/*
 * SCR
 * - construct
 * - destroy
 * - extend
 * - normalize
 * - negate/complement
 */

SCR_p
marpatcl_scr_new (int n)
{
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

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

void
marpatcl_scr_destroy (SCR_p scr)
{
    /*
     * Trivial because the ranges are allocated as part of the structure
     */
    TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
    FREE (scr);
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

void
marpatcl_scr_add_range (SCR_p scr, int first, int last)
{
    TRACE_FUNC ("((SCR*) %p [%d/%d], fl (%d...%d))",
		scr, scr->n, scr->max, first, last);
    ASSERT (scr->n < scr->max, "Unable to add range to full SCR");

    scr->cr[scr->n].start = first;
    scr->cr[scr->n].end   = last;
    scr->n ++;
    scr->canon = 0; /* If it was normalized before it may not be anymore */
    TRACE_RETURN_VOID;
}

void
marpatcl_scr_add_code (SCR_p scr, int codepoint)
{
    marpatcl_scr_add_range (scr, codepoint, codepoint);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

void
marpatcl_scr_norm (SCR_p scr)
{
    TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
	
    /*
     * Normalization is done in place. This is possible because the resulting
     * class cannot use more ranges than the input. It may have strictly less,
     * when overlapping ranges are merged.
     *
     * The operation happens in 2 phases
     * (1) Sort the ranges in ascending order
     * (2) Iterate over the sequence and merge overlapping/adjacent ranges.
     *
     * Of course, an already normalized class is not changed at all. And a
     * single-element class is canonical by definition.
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
	qsort (&scr->cr, scr->n, sizeof(CR), compare);
	SCR_DUMP("S", scr);

	/* Assertions, for all cr[i], cr[i+1] (P, C)
	 * (P->start <= C->start)
	 * (P->start == C->start) ==> (P->end <= C->end)
	 *
	 * This means the ranges in question can have the
	 * following relative locations to each other:
	 *
	 * (1a) |--------|    \   P is a subset of C, or identical
	 *      |--------|     \  Extend it to be C.
	 *                      >
	 * (1b) |--------|     /
	 *      |-----------| /
	 *
	 * (2a) |--------|            \   C is contained in P,
	 *         |---|               \  or extends it at the end.
	 *                              |
	 * (2b) |--------|              | Extend P to the max of (PE,CE)
	 *         |-----|              |
	 *                              > This is for CS <= PE+1
	 * (2c) |--------|              | (== in that means adjacent)
	 *         |---------|          |
	 *                              |
	 * (2d) |--------|             /
	 *                |---------| /
	 *
	 * (3)  |--------|            \ C is after P, with a non-empty gap.
	 *                 |---|      / P is final, C can be shifted as the next P
	 */

	for (previous = &scr->cr[0],
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

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

SCR_p
marpatcl_scr_complement (SCR_p scr)
{
    /*
     * NOTE: UNI_MAX originates from `unidata.h` (generated).
     */
    int nc;
    SCR* ncr;
    int cmin, cmax;
    CR *current, *sentinel, *store;

    TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);
	
    if (scr->n == 0) {
	/*
	 * Negating an empty class yields the full range.
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
     * For N ranges the complement has between N-1 to N+1 ranges.  This
     * depends on which of the two unicode limits are touched by the class, or
     * not.
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
	 * Negating a full range yields an empty class.
	 * Notes:
	 * -     scr->n >= 1 (0 was handled separately)
	 *   ==> nc >= 2
	 *   ==> nc' >= 0   (Max subtraction is 2)
	 * - (nc' == 0) ==> (nc == 2)
	 *              ==> both 0, UNI_MAX triggered
	 *              ==> input covered the entire range
	 *
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
 * - - -- --- ----- -------- ------------- ---------------------
 */

#ifdef CRITCL_TRACER
void
__marpatcl_SCR_DUMP (const char* msg, SCR* scr) {
    int i;
    for (i=0; i < (scr)->n; i++) {
	TRACE ("SCR %s (%6d): %8d...%8d", msg, i,
	       (scr)->cr[i].start,
	       (scr)->cr[i].end);
    }
}
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

static int
compare (const void* ain, const void* bin) {
    CR* a = (CR*) ain;
    CR* b = (CR*) bin;

    /*
     * Sort by the starting point first.
     */
    if (a->start < b->start) { return -1 ; }
    if (a->start > b->start) { return  1 ; }

    /*
     * For equal starting points sort by the closing points, i.e the shorter
     * range is sorted before the longer.
     */
    if (a->end < b->end) { return -1 ; }
    if (a->end > b->end) { return  1 ; }

    /*
     * Fully the same
     */
    return 0;
}

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
