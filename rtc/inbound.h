/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: Inbound
 */

#ifndef MARPA_RTC_INBOUND_H
#define MARPA_RTC_INBOUND_H

#include <rtc.h>

/*
 * -- dynamic state of the inbound part of an rtc engine --
 */

typedef struct marpa_rtc_inbound {
    int location; /* Location of the current byte in the input.
		   */
} marpa_rtc_inbound;

/*
 * API seen by other parts.
 */

void marpa_rtc_inbound_cons     (marpa_rtc_p p);
void marpa_rtc_inbound_release  (marpa_rtc_p p);
int  marpa_rtc_inbound_location (marpa_rtc_p p);
void marpa_rtc_inbound_enter    (marpa_rtc_p p, const char* bytes);
void marpa_rtc_inbound_eof      (marpa_rtc_p p);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
