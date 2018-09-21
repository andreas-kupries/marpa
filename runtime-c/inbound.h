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
    /*
     * Physical input stream: content, size, status
     */

    unsigned char* bytes;     /* Input byte string to process */
    int            size;      /* Length of the input byte string, in bytes */
    int            csize;     /* Same, in characters. Note: A value <0
			       * indicates byte size, not yet converted to
			       * characters */
    int            psize;     /* Length of the primary string, in bytes */
    unsigned char  owned;     /* true  -> .bytes is owned by this structure,
			       * false -> .bytes belongs to the outside */
    /*
     * IO level events - user-specified engine stop
     */

    int            cstop;     /* Location to stop processing at. Character
			       * offset.  The engine stops and raises the
			       * event just before processing the character at
			       * this location.
			       */
    /*
     * Dynamic IO state. Location in the stream, UTF decode support counters.
     */

    int            location;  /* Index of the current byte (byte offset) */
    int            clocation; /* Same as above, as character offset */

    unsigned char  trailer;   /* The number of trailer bytes in a character
			       * proper. IOW the number of bytes to come where
			       * we do not step the character location. */
    unsigned char  clen;      /* The number of bytes in the current
			       * character */

    /* Note that there is no need to spent a full int on the counter (4/8
     * bytes memory per) as UTF-8 characters consist of at most 4 bytes.
     */
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
void marpatcl_rtc_inbound_reset     (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_location  (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_last      (marpatcl_rtc_p p);
void marpatcl_rtc_inbound_enter     (marpatcl_rtc_p p,
				     const unsigned char* bytes, int n,
				     int from, int to);

int  marpatcl_rtc_inbound_enter_more (marpatcl_rtc_p p,
				      const unsigned char* bytes, int n);

void marpatcl_rtc_inbound_moveto    (marpatcl_rtc_p p, int cpos);
void marpatcl_rtc_inbound_moveby    (marpatcl_rtc_p p, int cdelta);
void marpatcl_rtc_inbound_move_byte (marpatcl_rtc_p p, int delta);

void marpatcl_rtc_inbound_set_stop  (marpatcl_rtc_p p, int cpos);
void marpatcl_rtc_inbound_set_limit (marpatcl_rtc_p p, int limit);
void marpatcl_rtc_inbound_no_stop   (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_stoploc   (marpatcl_rtc_p p);

unsigned char marpatcl_rtc_inbound_step (marpatcl_rtc_p p);

int  marpatcl_rtc_inbound_num_streams   (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_num_processed (marpatcl_rtc_p p);
int  marpatcl_rtc_inbound_size          (marpatcl_rtc_p p);

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
