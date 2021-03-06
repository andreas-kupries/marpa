/* Runtime for C-engine (RTC). Implementation. (Character location indexing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <clindex.h>
#include <rtc_int.h>
#include <stdlib.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define CL  (CLI.cloc)
#define BL  (CLI.bloc)
#define BS  (CLI.blen)
#define MC  (CLI.max_char)
#define MB  (CLI.max_byte)
#define ML  (CLI.max_blen)

#define B(C,i) (bl[i] + bs[i]*((C) - cl[i]))
#define C(B,i) (cl[i] + ((B) - bl[i]) / bs[i])

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_clindex_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

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
marpatcl_rtc_clindex_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_stack_destroy     (CL);
    marpatcl_rtc_stack_destroy     (BL);
    marpatcl_rtc_bytestack_destroy (BS);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_clindex_reset (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    // Maximals
    MC = -1;
    MB = -1;
    ML = 0;

    marpatcl_rtc_stack_clear     (CL);
    marpatcl_rtc_stack_clear     (BL);
    marpatcl_rtc_bytestack_clear (BS);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_clindex_update (marpatcl_rtc_p p, int blen)
{
    TRACE_FUNC ("((rtc*) %p, max %d @ char %d ~ byte %d |%d|)",
		p, MC, IN.clocation, IN.location, blen);

    // No updates in the middle of the input
    if (IN.clocation <= MC) {
	TRACE ("%s", "ignore not at end");
	TRACE_RETURN_VOID;
    }

    // Updates at the end must be one character after the maximal, no more.
    ASSERT ((IN.clocation - MC) == 1, "Gap in the location indexing");

    // Update visited.
    TRACE ("%s", "update maximal");
    MC = IN.clocation;
    MB = IN.location;

    // Check for change of byte length
    if (ML == blen) {
	TRACE ("%s", "no length change");
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
marpatcl_rtc_clindex_find_c (marpatcl_rtc_p p, int bloc)
{
    // Map byte offset to character location

    TRACE_FUNC ("((rtc*) %p, -> B%d, max %d ~b %d @ char %d ~b %d)",
		p, bloc, MC, MB, IN.clocation, IN.location);

    nearend:
    if (bloc == MB) {
	// The target location is at the maximal visited byte.
	// Use the cached maximal data.
	TRACE ("%d == [max @ %d]", bloc, MC);
	TRACE_RETURN ("goto %d", MC);
    }

    if (bloc > MB) {
	// The target byte location is after the maximal visited byte.  We
	// cannot simply extrapolate from the current maximal.  We have to
	// scan forward and extend the index to the requested location to
	// properly know.

	TRACE ("beyond max, scan forward from %d ~b %d, max %d ~b %d",
	       IN.clocation, IN.location, MC, MB);

	// Save current place (caller may look for location without wishing to move to it)
	int prevbloc = IN.location;
	int prevcloc = IN.clocation;

	// Jump to the end of the visited range as the place from where to
	// reach the target in a minimal number of steps.
	IN.clocation = MC;
	IN.location  = MB;

	TRACE ("jump to max %d ~b %d", IN.clocation, IN.location);
	TRACE ("byte steps: %d", bloc - IN.location);

	while (IN.location < bloc) {
	    TRACE ("%s", "byte step");
	    marpatcl_rtc_inbound_step (p);
	    TRACE ("to char %d ~b %d", IN.clocation, IN.location);
	}

	TRACE ("%s", "at target");

	// The location to find is now the maximal, or in the last range.  It
	// might not be maximal because multiple bytes can make up a
	// character, allowing our character steps to overshoot.
	ASSERT (bloc <= MB, "Scan to location failed to make it near-maximal");

	// Restore current location, in case caller did not wish to move.
	IN.location  = prevbloc;
	IN.clocation = prevcloc;

	// Reuse handler
	goto nearend;
    }

    // It is somewhere in the middle. We have search our index. Should we
    // actually have one.

    int sc; int* cl = marpatcl_rtc_stack_data (CL, &sc);

    if (!sc) {
	// we have no index for the target location to use.
	// Fake using byte length 1, i.e byte location == character location
	TRACE ("%d unindexed, scaled 1", bloc);
	TRACE_RETURN ("goto %d", bloc);
    }

    int sb; int*           bl = marpatcl_rtc_stack_data (BL, &sb);
    int sl; unsigned char* bs = marpatcl_rtc_bytestack_data (BS, &sl);

    ASSERT (sc == sb, "C/B size mismatch");
    ASSERT (sc == sl, "C/L size mismatch");

    // Test if the target location is in the last range known.
    if (bloc >= bl [sc-1]) {
	sc --;
	TRACE ("B%d >= [range %d (last) @ %d scaled %d]", bloc, cl [sc], bl [sc], bs [sc]);
	TRACE_RETURN ("goto %d", C(bloc, sc));
    }

    // (Binary) search for the range containing the target location.
    // We are looking for the largest bl[.] less than or equal to bloc.

    int low, high;
    for (low = 0, high = sc-1; low <= high; ) {
	int mid   = (low+high)/2;
	int probe = bl [mid];
	TRACE ("probe [%d..%d] @%d = %d ~ %d", low, high, mid, probe, bloc);

	if (probe == bloc) {
	    // Found target location exactly. That makes the calculation trivial.
	    // We return the stored character location.
	    TRACE ("B%d >= [range %d @ %d scaled %d]", bloc, cl [mid], bl [mid], bs [mid]);
	    TRACE_RETURN ("goto %d", cl[mid]);
	}

	if (probe > bloc) {
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
    TRACE ("B%d >= [range %d @ %d scaled %d]", bloc, cl [high], bl [high], bs [high]);
    TRACE_RETURN ("goto %d", C(bloc, high));
}

int
marpatcl_rtc_clindex_find (marpatcl_rtc_p p, int cloc)
{
    // Map character location to byte offset

    TRACE_FUNC ("((rtc*) %p, -> %d, max %d ~b %d @ char %d ~b %d)",
		p, cloc, MC, MB, IN.clocation, IN.location);

    if (cloc == MC) {
	// The target location is at the maximal visited character.
	// Use the cached maximal data.
    atend:
	TRACE ("%d == [max @ %d]", cloc, MB);
	TRACE_RETURN ("goto %d", MB);
    }

    if (cloc > MC) {
	// The target location is after the maximal visited.  We cannot simply
	// extrapolate from the current maximal.  We have to scan forward and
	// extend the index to the requested location to properly know.

	TRACE ("beyond max, scan forward from %d ~b %d, max %d ~b %d",
	       IN.clocation, IN.location, MC, MB);

	// Save current place (caller may look for location without wishing to move to it)
	int prevbloc = IN.location;
	int prevcloc = IN.clocation;

	// Jump to the end of the visited range as the place from where to
	// reach the target in a minimal number of steps.
	IN.clocation = MC;
	IN.location  = MB;

	TRACE ("jump to max %d ~b %d", IN.clocation, IN.location);
	TRACE ("char steps: %d", cloc - IN.clocation);
	while (IN.clocation < cloc) {
	    TRACE ("%s", "byte step");
	    marpatcl_rtc_inbound_step (p);
	    TRACE ("to char %d ~b %d", IN.clocation, IN.location);
	}

	TRACE ("%s", "at target");

	// The location to find is now the maximal.
	ASSERT (cloc == MC, "Scan to location failed to make it maximal");

	// Restore current location, in case caller did not wish to move.
	IN.location  = prevbloc;
	IN.clocation = prevcloc;

	// Reuse handler
	goto atend;
    }

    // It is somewhere in the middle. We have search our index. Should we
    // actually have one.

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
	TRACE_RETURN ("goto %d", B(cloc, sc));
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

    // Target location not found. `high` points to the highest entry less than
    // the target.

    TRACE ("%d >= [range %d @ %d scaled %d]", cloc, cl [high], bl [high], bs [high]);
    TRACE_RETURN ("goto %d", B(cloc, high));
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
