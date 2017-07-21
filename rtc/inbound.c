/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Inbound
 */

#include <inbound.h>
#include <rtc_int.h>

/*
 */

void
marpa_rtc_inbound_init (marpa_rtc_p p)
{
    IN.location = -1;
}

void
marpa_rtc_inbound_free (marpa_rtc_p p)
{
    /* nothing to do */
}

int 
marpa_rtc_inbound_location (marpa_rtc_p p)
{
    return IN.location;
}

void
marpa_rtc_inbound_enter (marpa_rtc_p p, const char* bytes, int n)
{
    const char* c;
    if (n < 0) {
	for (c = bytes; *c; c++) {
	    IN.location ++;
	    marpa_rtc_gate_enter (p, *c);
	}
    } else {
	for (c = bytes; n; c++, n--) {
	    IN.location ++;
	    marpa_rtc_gate_enter (p, *c);
	}
    }
}

void
marpa_rtc_inbound_eof (marpa_rtc_p p)
{
    marpa_rtc_gate_eof (p);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
