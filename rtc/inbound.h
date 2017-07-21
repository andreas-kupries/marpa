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
    int location; /* Location of the current byte in the input. */
} marpa_rtc_inbound;

/*
 * API -- lifecycle
 */

void marpa_rtc_inbound_init (marpa_rtc_p p);
void marpa_rtc_inbound_free (marpa_rtc_p p);

/*
 * API -- accessor and mutators
 */

int  marpa_rtc_inbound_location (marpa_rtc_p p);
void marpa_rtc_inbound_enter    (marpa_rtc_p p, const char* bytes, int n);
void marpa_rtc_inbound_eof      (marpa_rtc_p p);

/* init     - initialize an input processor
 * free     - release input state
 * location - returned the current location in the input, as offset in bytes from the start
 * enter    - push a string of `n` bytes from the input.
 *            `n < 0` --> Treat as \0-terminated, and push all but the terminator.
 * eof      - signal the end of the input
 */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
