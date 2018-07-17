/* Runtime for C-engine (RTC). Declarations. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
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
    int location;  /* Location of the current byte in the input (byte offset). */
    int clocation; /* Same, as character offset */
    int trailer;   /* Number of bytes in the expected trailer */
    int header;    /* Number of bytes in a header so far */
} marpatcl_rtc_inbound;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init      - initialize an input processor
 * free      - release input state
 * location  - returns the current location in the input, as offset in bytes from the start
 * clocation - as above, as offset in characters from the start
 * enter     - push a string of `n` bytes from the input.
 *            `n < 0` --> Treat as \0-terminated, and push all but the terminator.
 * eof       - signal the end of the input
 */

void marpatcl_rtc_inbound_init      (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_free      (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_location  (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_clocation (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_enter     (marpatcl_rtc_p p, const unsigned char* bytes, int n);
void marpatcl_rtc_inbound_eof       (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_moveto    (marpatcl_rtc_p p, int cpos);
int  marpatcl_rtc_inbound_moveby    (marpatcl_rtc_p p, int cdelta);

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
