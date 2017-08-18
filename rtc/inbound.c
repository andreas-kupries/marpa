/* Runtime for C-engine (RTC). Implementation. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <inbound.h>
#include <rtc_int.h>
#include <critcl_trace.h>

TRACE_ON;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_inbound_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    IN.location = -1;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    /* nothing to do */
    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_inbound_location (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", IN.location);
}

void
marpatcl_rtc_inbound_enter (marpatcl_rtc_p p, const char* bytes, int n)
{
    const char* c;
    TRACE_FUNC ("(rtc %p bytes %p, n %d)", p, bytes, n);

    if (n < 0) {
	for (c = bytes; *c && !FAIL.fail; c++) {
	    IN.location ++;
	    marpatcl_rtc_gate_enter (p, *c);
	}
    } else {
	for (c = bytes; n && !FAIL.fail; c++, n--) {
	    IN.location ++;
	    marpatcl_rtc_gate_enter (p, *c);
	}
    }

    TRACE ("Failed = %d", FAIL.fail);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_gate_eof (p);

    TRACE_RETURN_VOID;
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
