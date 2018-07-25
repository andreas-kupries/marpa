/* Runtime for C-engine (RTC). Implementation. (Character location indexing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <clindex.h>
#include <stdlib.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define CL  (index->cloc)
#define BL  (index->bloc)
#define BS  (index->blen)
#define MC  (index->max_char)
#define MB  (index->max_byte)
#define ML  (index->max_blen)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_clindex_init (marpatcl_rtc_clindex* index)
{
    TRACE_FUNC ("((clindex*) %p)", index);

    CL = marpatcl_rtc_stack_cons     (MARPATCL_RTC_STACK_DEFAULT_CAP);
    BL = marpatcl_rtc_stack_cons     (MARPATCL_RTC_STACK_DEFAULT_CAP);
    BS = marpatcl_rtc_bytestack_cons (MARPATCL_RTC_BYTESTACK_DEFAULT_CAP);
    // Maximals
    MC = -1;
    MB = -1;
    ML = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_clindex_release (marpatcl_rtc_clindex* index)
{
    TRACE_FUNC ("((clindex*) %p)", index);
    
    marpatcl_rtc_stack_destroy (CL);
    marpatcl_rtc_stack_destroy (BL);
    marpatcl_rtc_bytestack_destroy (BS);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_clindex_update (marpatcl_rtc_clindex* index, int cloc, int bloc, int blen)
{
    TRACE_FUNC ("((clindex*) %p, mc %d ~ c %d, b %d |%d|)", index, MC, cloc, bloc, blen);

    // No updates in the middle of the input
    if (cloc <= MC) {
	TRACE_RETURN_VOID;
    }

    // Updates at the end must be one character after the maximal, no more.
    ASSERT ((cloc - MC) == 1, "Gap in the location indexing");

    // Update visited.
    MC = cloc;
    MB = bloc;

    // Check for change of byte length
    if (ML == blen) {
	TRACE_RETURN_VOID;
    }

    TRACE ("length change %d -> %d, saving %d @ %d", ML, blen, MC, MB);

    // Save start of the new run
    ML = blen;
    marpatcl_rtc_stack_push     (CL, MC);
    marpatcl_rtc_stack_push     (BL, MB);
    marpatcl_rtc_bytestack_push (BS, ML);

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_clindex_find (marpatcl_rtc_clindex* index, int cloc)
{
    TRACE_FUNC ("((clindex*) %p, @ %d)", index, cloc);
    
    if (cloc == MC) {
	// The target location is at the maximal visited.
	// Use the cached maximal data.

	TRACE ("%d == [max @ %d]", cloc, MB);
	TRACE_RETURN ("goto %d", MB);
    }

    if (cloc > MC) {
	// The target location is at or after the maximal visited.
	// Use the cached maximal data as pseudo run.

	// BUG for `>` !! We cannot do this as is. This assumes that we have
	// same-length characters from the maximal known, i.e. this wrongly
	// extrapolates into the unknown not yet visited part of the input.

	// FIX/TODO: Force a scan ahead to the target location to make it
	// maximal and the index properly extended, then recursively re-find.

	TRACE ("%d > [%d max @ %d, scaled %d, extrapolated, BUG]", cloc, MC, MB, ML);
	ASSERT (0, "Bad extrapolation");
	TRACE_RETURN ("goto %d", MB + ML*(cloc-MC));
    }

    int sc; int* cl = marpatcl_rtc_stack_data (CL, &sc);

    if (!sc) {
	// we have no index for the target location to use.
	// Fake using byte length 1, i.e byte location == character location
	TRACE ("%d unindexed, scaled 1", cloc);
	TRACE_RETURN ("goto %d", cloc);
    }

    int sb; int*           bl = marpatcl_rtc_stack_data (BL, &sb);
    int sl; unsigned char* bs = marpatcl_rtc_bytestack_data (BS, &sl);

    ASSERT (sc == sb, "C/B size mismatch");
    ASSERT (sc == sl, "C/L size mismatch");

    // Test if the target location is in the last range known.
    if (cloc >= cl [sc-1]) {
	sc --;
	TRACE ("%d >= [range %d (last) @ %d scaled %d]", cloc, cl [sc], bl [sc], bs [sc]);
	TRACE_RETURN ("goto %d", bl[sc] + bs[sc]*(cloc - cl[sc]));
    }

    // (Binary) search for the range containing the target location.
    // We are looking for the largest cl[.] less than or equal to cloc.

    int low, high;
    for (low = 0, high = sc-1; low <= high; ) {
	int mid   = (low+high)/2;
	int probe = cl [mid];
	TRACE ("probe [%d..%d] @%d = %d ~ %d", low, high, mid, probe, cloc);
		
	if (probe == cloc) {
	    // Found target location exactly. That makes the calculation trivial.
	    // We return the stored byte location.
	    TRACE ("%d >= [range %d @ %d scaled %d]", cloc, cl [mid], bl [mid], bs [mid]);
	    TRACE_RETURN ("goto %d", bl[mid]);
	}

	if (probe > cloc) {
	    // The tested range is after the target location.
	    // Continue search in lower interval.
	    high = mid-1;
	    continue;
	}

	// The tested range is before the target location.
	// Continue search in the higher interval, we might find something
	// later still.
	low = mid+1;
    }

    // Target location not found. high points to the highest entry less than
    // the target.

    TRACE ("%d >= [range %d @ %d scaled %d]", cloc, cl [high], bl [high], bs [high]);
    TRACE_RETURN ("goto %d", bl[high] + bs[high]*(cloc - cl[high]));
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
