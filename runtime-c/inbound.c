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

static unsigned char step (marpatcl_rtc_p p, const unsigned char* bytes);

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

    marpatcl_rtc_clindex_init (&IN.index);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_clindex_release (&IN.index);
	
    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_inbound_location (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", IN.clocation);
}

void
marpatcl_rtc_inbound_moveto (marpatcl_rtc_p p, int cpos)
{
    TRACE_FUNC ("((rtc*) %p, pos = %d)", p, cpos);

    IN.clocation = cpos;
    IN.location  = marpatcl_rtc_clindex_find (&IN.index, IN.clocation);

    TRACE ("((rtc*) %p, now pos = %d ~ %d)", p, IN.clocation, IN.location);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_moveby (marpatcl_rtc_p p, int cdelta)
{
    TRACE_FUNC ("((rtc*) %p, pos %d += %d)", p, IN.clocation, cdelta);

    IN.clocation += cdelta;
    IN.location  = marpatcl_rtc_clindex_find (&IN.index, IN.clocation);

    TRACE ("((rtc*) %p, now pos = %d ~ %d)", p, IN.clocation, IN.location);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_enter (marpatcl_rtc_p p, const unsigned char* bytes, int n)
{
#define NAME(sym) marpatcl_rtc_spec_symname (SPEC->l0, sym, 0)

    unsigned char ch;
    TRACE_FUNC ("(rtc %p bytes %p, n %d)", p, bytes, n);
    TRACE_TAG_DO (enter, print_input (bytes, n));

    if (n < 0) {
	n = strlen (bytes);
    }
    n --;

    TRACE ("max %d", n);
    while (IN.location < n) {
	// The outer loop catches when gate, lexer, etc. bounce us back after
	// reaching EOF. Because this means that the last characters need
	// re-processing.
	while (IN.location < n) {
	    // On loop entry the location points to the previously processed
	    // character. We now move to the current character, then extract and
	    // process it.
	    ch = step (p, bytes);
	    TRACE ("byte %3d at %d c %d <%s>", ch, IN.location, IN.clocation, NAME(ch));

	    marpatcl_rtc_gate_enter (p, ch);
	    if (FAIL.fail) break;
	    // Note, the post-processor (gate, lexer) have access to the
	    // location, via methods moveto, moveby, and rewind. Examples of
	    // use:
	    // - Rewind after reading behind the current lexeme
	    // - Rewind for parse events.

	}
	TRACE ("Failed/i = %d @ %d max %d", FAIL.fail, IN.location, n);
	if (FAIL.fail) break;
	// Trigger end of data processing in the post-processors.
	// Note that this may rewind the input to an earlier place,
	// forcing re-processing of some of the last characters.
	marpatcl_rtc_gate_eof (p);
    }

    TRACE ("Failed/o = %d @ %d max %d", FAIL.fail, IN.location, n);
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

static unsigned char
step (marpatcl_rtc_p p, const unsigned char* bytes)
{
    // Step to the next byte location
    IN.location ++;

    // Extract byte to process
    unsigned char ch = bytes [IN.location];

    // Possibly step to the next character location as well
#define SINGLE(c) (((c) & 0x80) == 0x00) // 0b1000,0000 : 0b0000,0000
#define TRAIL(c)  (((c) & 0xC0) == 0x80) // 0b1100,0000 : 0b1000,0000
#define LEAD2(c)  (((c) & 0xE0) == 0xC0) // 0b1110,0000 : 0b1100,0000
#define LEAD3(c)  (((c) & 0xF0) == 0xE0) // 0b1111,0000 : 0b1110,0000
#define LEAD4(c)  (((c) & 0xF8) == 0xF0) // 0b1111,1000 : 0b1111,0000
#define MOVE_HEADER for(; IN.header; IN.header --) { MOVE (1); }
#define MOVE(k) \
    IN.clocation ++;							\
    marpatcl_rtc_clindex_update (&IN.index, IN.clocation, IN.location, k) \
    
    if (SINGLE (ch)) {
	// A single stands for itself, no trailers expected, no lead
	IN.trailer = 0;
	IN.header  = 0;
	MOVE (1);
    } else if (TRAIL (ch)) {
	// A trailer should come after a lead-in.
	if (IN.trailer > 0) {
	    // A proper trailer extends the header, and reduces how much more
	    // trailers to still expect.
	    IN.trailer --;
	    IN.header  ++;
	    if (IN.trailer == 0) {
		// All expected trailers found, step a character. Reset header.
		MOVE (IN.header);
		IN.header = 0;
	    }
	} else {
	    // A standalone trailer is unexpected, and stands for itself.
	    MOVE (1);
	}
    } else if (LEAD2 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    MOVE_HEADER;
	}
	// Start of 2 byte character. Expect one trailer.
	IN.trailer = 1;
	IN.header  = 1;

    } else if (LEAD3 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    MOVE_HEADER;
	}
	// Start of 3 byte character. Expect 2 trailers.
	IN.trailer = 2;
	IN.header  = 1;

    } else if (LEAD4 (ch)) {
	if (IN.trailer > 0) {
	    // Unexpected begin of a character, previous incomplete.
	    // The previous bytes all stand for themselves now.
	    MOVE_HEADER;
	}
	// Start of 4 byte character. Expect 3 trailers.
	IN.trailer = 1;
	IN.header  = 1;

    } else {
	ASSERT (0,"");
    }

    return ch;
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
