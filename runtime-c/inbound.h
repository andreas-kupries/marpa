/* Runtime for C-engine (RTC). Declarations. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 */

#ifndef MARPATCL_RTC_INBOUND_H
#define MARPATCL_RTC_INBOUND_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>
#include <clindex.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_inbound {
    unsigned char* bytes;     /* Input byte string to process */
    int            size;      /* Length of the input byte string, in bytes */
    int            csize;     /* Same, in characters. <0 indicates byte, not yet converted */
    int            location;  /* Index of the current byte in input (byte offset) */
    int            clocation; /* Same, as character offset */
    int            cstop;     /* Location to stop processing at */
    int            trailer;   /* Number of bytes in the expected trailer */
    int            header;    /* Number of bytes in a header so far */
} marpatcl_rtc_inbound;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init      - initialize an input processor
 * free      - release input state
 * location  - returns the current location in the input, as offset in characters from the start of the input
 * enter     - push a string of `n` bytes from the input.
 *            `n < 0` --> Treat as \0-terminated, and push all but the terminator.
 * eof       - signal the end of the input
 */

void marpatcl_rtc_inbound_init      (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_free      (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_location  (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_last      (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_enter     (marpatcl_rtc_p p,
				     const unsigned char* bytes, int n,
				     int from, int to);

int  marpatcl_rtc_inbound_enter_more (marpatcl_rtc_p p,
				      const unsigned char* bytes, int n);

void marpatcl_rtc_inbound_moveto    (marpatcl_rtc_p p, int cpos);
void marpatcl_rtc_inbound_moveby    (marpatcl_rtc_p p, int cdelta);

void marpatcl_rtc_inbound_set_stop  (marpatcl_rtc_p p, int cpos);
void marpatcl_rtc_inbound_set_limit (marpatcl_rtc_p p, int limit);
void marpatcl_rtc_inbound_no_stop   (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_stoploc   (marpatcl_rtc_p p);

unsigned char marpatcl_rtc_inbound_step (marpatcl_rtc_p p);

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
