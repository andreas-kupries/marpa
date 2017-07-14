/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Inbound
 */

#include <rtc.h>

#define IN (p->in)

void
marpa_rtc_inbound_cons (marpa_rtc_p p)
{
    IN.location = -1;
}

int 
marpa_rtc_inbound_location (marpa_rtc_p p)
{
    return IN.location;
}

void
marpa_rtc_inbound_enter (marpa_rtc_p p, const char* bytes)
{
    const char* c = bytes;
    while (*c) {
	IN.location ++;
	marpa_rtc_gate_enter (p, c);
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
