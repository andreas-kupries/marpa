/* Runtime for C-engine (RTC). Implementation. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 *
 * Requirements - Note, tracing via an external environment header.
 */

#include <environment.h>
#include <inbound.h>
#include <rtc_int.h>

TRACE_OFF;
TRACE_TAG_OFF (enter);

static void
step (marpatcl_rtc_p p, unsigned char ch);

#ifdef CRITCL_TRACER
static void
print_input (const unsigned char* bytes, int n)
{
    const unsigned char* c;
    if (n < 0) {
	int k;
	for (k = 0, c = bytes; *c; k++, c++) {
	    TRACE_TAG (enter, "[%8d] = %c (%d, %u)", k, *c, *c, (unsigned char) *c);
	}
    } else {
	int k;
	for (k = 0, c = bytes; n; k++, c++, n--) {
	    TRACE_TAG (enter, "[%8d] = %c (%3d, %3u)", k, *c, *c, (unsigned char) *c);
	}
    }
}
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_inbound_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    IN.location  = -1;
    IN.clocation = -1;
    IN.trailer   = 0;
    IN.header    = 0;

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
marpatcl_rtc_inbound_enter (marpatcl_rtc_p p, const unsigned char* bytes, int n)
{
    const unsigned char* c;
    TRACE_FUNC ("(rtc %p bytes %p, n %d)", p, bytes, n);
    TRACE_TAG_DO (enter, print_input (bytes, n));

    if (n < 0) {
	for (c = bytes; *c && !FAIL.fail; c++) {
	    step (p, *c);
	    marpatcl_rtc_gate_enter (p, *c);
	}
    } else {
	for (c = bytes; n && !FAIL.fail; c++, n--) {
	    step (p, *c);
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

static void
step (marpatcl_rtc_p p, unsigned char ch)
{
    /* Step to the next byte and character location */
    IN.location ++;

#define SINGLE(c) (((c) & 0x80) == 0x00) // 0b1000,0000 : 0b0000,0000
#define TAIL(c)   (((c) & 0xC0) == 0x80) // 0b1100,0000 : 0b1000,0000
#define LEAD2(c)  (((c) & 0xE0) == 0xC0) // 0b1110,0000 : 0b1100,0000
#define LEAD3(c)  (((c) & 0xF0) == 0xE0) // 0b1111,0000 : 0b1110,0000
#define LEAD4(c)  (((c) & 0xF8) == 0xF0) // 0b1111,1000 : 0b1111,0000

     if (SINGLE (ch)) {
	// Single stands for itself, no trailers expected, no lead
	IN.trailer = 0;
	IN.header  = 0;
	IN.clocation ++;
	
    } else if (TAIL (ch)) {
	if (IN.trailer > 0) {
	    IN.trailer --;
	    IN.header  ++;
	    if (IN.trailer == 0) {
		// All expected trailers found
		IN.clocation ++;
		IN.header = 0;
	    }
	} else {
	    // (unexpected) standalone trailer, stands for itself.
	    IN.clocation ++;
	}
    } else if (LEAD2 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    IN.clocation += IN.header;
	}
	// Start of 2 byte character. Expect one trailer.
	IN.trailer = 1;
	IN.header  = 1;
	
    } else if (LEAD3 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    IN.clocation += IN.header;
	}
	// Start of 3 byte character. Expect 2 trailers.
	IN.trailer = 2;
	IN.header  = 1;

    } else if (LEAD4 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    IN.clocation += IN.header;
	}
	// Start of 4 byte character. Expect 3 trailers.
	IN.trailer = 1;
	IN.header  = 1;

    } else {
	ASSERT (0,"");
    }
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
