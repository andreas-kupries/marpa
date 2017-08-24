/* Runtime for C-engine (RTC). Declarations. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_INBOUND_H
#define MARPATCL_RTC_INBOUND_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_inbound {
    int location; /* Location of the current byte in the input. */
} marpatcl_rtc_inbound;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init     - initialize an input processor
 * free     - release input state
 * location - returned the current location in the input, as offset in bytes from the start
 * enter    - push a string of `n` bytes from the input.
 *            `n < 0` --> Treat as \0-terminated, and push all but the terminator.
 * eof      - signal the end of the input
 */

void marpatcl_rtc_inbound_init     (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_free     (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_location (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_enter    (marpatcl_rtc_p p, const char* bytes, int n);
void marpatcl_rtc_inbound_eof      (marpatcl_rtc_p p);

#endif

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
