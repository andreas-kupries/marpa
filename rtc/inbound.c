/* Runtime for C-engine (RTC). Implementation. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <inbound.h>
#include <rtc_int.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_inbound_init (marpatcl_rtc_p p)
{
    IN.location = -1;
}

void
marpatcl_rtc_inbound_free (marpatcl_rtc_p p)
{
    /* nothing to do */
}

int 
marpatcl_rtc_inbound_location (marpatcl_rtc_p p)
{
    return IN.location;
}

void
marpatcl_rtc_inbound_enter (marpatcl_rtc_p p, const char* bytes, int n)
{
    const char* c;
    if (n < 0) {
	for (c = bytes; *c; c++) {
	    IN.location ++;
	    marpatcl_rtc_gate_enter (p, *c);
	}
    } else {
	for (c = bytes; n; c++, n--) {
	    IN.location ++;
	    marpatcl_rtc_gate_enter (p, *c);
	}
    }
}

void
marpatcl_rtc_inbound_eof (marpatcl_rtc_p p)
{
    marpatcl_rtc_gate_eof (p);
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
