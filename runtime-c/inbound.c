/* Runtime for C-engine (RTC). Implementation. (Engine: Input processing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, tracing via an external environment header.
 */

#include <environment.h>
#include <inbound.h>
#include <rtc_int.h>

TRACE_OFF;
TRACE_TAG_OFF (enter);

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

    IN.bytes     = 0;
    IN.location  = -1;
    IN.clocation = -1;
    IN.cstop     = -1;
    IN.trailer   = 0;
    IN.header    = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    // nothing to do
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_reset (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_inbound_free (p);
    marpatcl_rtc_inbound_init (p);

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_inbound_location (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", IN.clocation + 1);
}

int
marpatcl_rtc_inbound_last (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    if (IN.csize < 0) {
	// Compute information, extend clindex to cover it.
	IN.csize = marpatcl_rtc_clindex_find_c (p, -IN.csize);
    }

    TRACE_RETURN ("%d", IN.csize);
}

void
marpatcl_rtc_inbound_moveto (marpatcl_rtc_p p, int cpos)
{
    TRACE_FUNC ("((rtc*) %p, pos = %d)", p, cpos);

    IN.clocation = cpos - 1;
    IN.location  = marpatcl_rtc_clindex_find (p, IN.clocation);

    TRACE ("((rtc*) %p, now pos = %d ~ %d)", p, IN.clocation, IN.location);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_moveby (marpatcl_rtc_p p, int cdelta)
{
    TRACE_FUNC ("((rtc*) %p, pos %d += %d)", p, IN.clocation, cdelta);

    IN.clocation += cdelta;
    IN.location  = marpatcl_rtc_clindex_find (p, IN.clocation);

    TRACE ("((rtc*) %p, now pos = %d ~ %d)", p, IN.clocation, IN.location);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_no_stop (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p", p);

    IN.cstop = -1;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_set_stop (marpatcl_rtc_p p, int cpos)
{
    TRACE_FUNC ("((rtc*) %p, pos = %d)", p, cpos);

    IN.cstop = cpos;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_set_limit (marpatcl_rtc_p p, int limit)
{
    // ASSERT limit > 0 == critcl pos.int TODO
    TRACE_FUNC ("((rtc*) %p, limit = %d)", p, limit);

    IN.cstop = IN.clocation + 1 + limit;

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_inbound_stoploc (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", IN.cstop);
}

void
marpatcl_rtc_inbound_enter (marpatcl_rtc_p p, const unsigned char* bytes, int max, int from, int to)
{
#define NAME(sym) marpatcl_rtc_spec_symname (SPEC->l0, sym, 0)

    unsigned char ch;
    TRACE_FUNC ("(rtc %p bytes %p, n %d, [%d...%d])", p, bytes, max, from, to);
    TRACE_TAG_DO (enter, print_input (bytes, max));

    if (max < 0) {
	max = strlen (bytes);
    }

    IN.bytes = (char*) bytes;
    IN.size  = max;
    IN.csize = -max; // Negative value indicates information in byte waiting
                     // for conversion into actual character location. We
                     // defer the conversion until the information is actually
                     // requested by the user. See `_last()`.

    max --;
    TRACE ("max %d", max);

    // Initial processing range.
    marpatcl_rtc_inbound_moveto   (p, from);
    marpatcl_rtc_inbound_set_stop (p, to);

    // Notes on locations and the processing loops.
    //
    // [1] At the beginning of the loop `mylocation` points to the __last__
    //     processed character.
    // [2] We move to the current character just before processing it (Forward
    //     enter ...).
    // [3] When parse events are invoked we point to the character to process
    //     next (i.e. one ahead), and have to compensate on return so that the
    //     loop entry condition [1] is true again. We actually make the
    //     translation in the location methods of this class, see `location?`
    //     and below, without actually moving.
    // [4] The previous double loop construction was eliminated by hoisting
    //     the outer code into the proper contionals of the inner loop,
    //     leaving a single loop handling all the things.

    while (1) {
	if (IN.location == max) {
	    // Trigger end of data processing in the post-processors.
	    // (Ad 4) Note that this may rewind the input to an earlier
	    // place, forcing re-processing of some of the last
	    // characters.
	    marpatcl_rtc_gate_eof (p);

	    if (IN.location == max) break;
	    continue;
	}

	int prevbloc = IN.location;
	int prevcloc = IN.clocation;

	ch = marpatcl_rtc_inbound_step (p);
	TRACE ("byte %3d @ char %d ~ byte %d = <%s>", ch, IN.clocation, IN.location, NAME(ch));

	if (IN.clocation == IN.cstop) {
	    // Stop triggered.
	    // Bounce, clear stop marker, post event, restart from bounce
	    IN.location  = prevbloc;
	    IN.clocation = prevcloc;
	    IN.cstop     = -2;
	    marpatcl_rtc_symset_clear (EVENTS);
	    POST_EVENT (marpatcl_rtc_event_stop);
	    if (!evok) break;
	    continue;
	}

	marpatcl_rtc_gate_enter (p, ch);
	if (FAIL.fail) break;
	// Note, the post-processor (gate, lexer) have access to the location,
	// via methods moveto, moveby, and rewind. Examples of use:
	// - Rewind after reading behind the current lexeme
	// - Rewind for parse events.
    }

    TRACE ("Failed/o = %d @ %d max %d", FAIL.fail, IN.location, max);
    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_inbound_enter_more (marpatcl_rtc_p p,
				 const unsigned char* bytes, int max)
{
    TRACE_FUNC ("((rtc*) %p, (char*) %p [%d]))", p, bytes, max);

    if (max < 0) {
	max = strlen (bytes);
    }

    int            offset   = IN.size + 1;
    int            newsize  = offset + max;
    unsigned char* newbytes = REALLOC (IN.bytes, unsigned char, newsize);
    ASSERT (newbytes, "Failed to expand memory for input");

    newbytes [offset-1] = '\0';
    memcpy (newbytes + offset, bytes, max * sizeof (unsigned char));

    IN.bytes = newbytes;
    IN.size  = newsize;

    // Notes
    // - The change to `IN.bytes` does not affect the `max` used by `enter`
    //   above to detect the end of the primary input.
    // - The new input will only be processed by moving explictly into its
    //   region. Processing it will not trigger EOI.
    // - The \0 separator ensures that positioning to the start of the first
    //   of the secondary inputs without triggering the eof condition in
    //   `enter` when we move to it.

    TRACE_RETURN ("(offset) %d", offset);
}

unsigned char
marpatcl_rtc_inbound_step (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    // Step to the next byte location
    IN.location ++;

    // Extract byte to process
    unsigned char ch = IN.bytes [IN.location];

    // Possibly step to the next character location as well
#define SINGLE(c) (((c) & 0x80) == 0x00) // 0b1000,0000 : 0b0000,0000
#define TRAIL(c)  (((c) & 0xC0) == 0x80) // 0b1100,0000 : 0b1000,0000
#define LEAD2(c)  (((c) & 0xE0) == 0xC0) // 0b1110,0000 : 0b1100,0000
#define LEAD3(c)  (((c) & 0xF0) == 0xE0) // 0b1111,0000 : 0b1110,0000
#define LEAD4(c)  (((c) & 0xF8) == 0xF0) // 0b1111,1000 : 0b1111,0000
#define MOVE_HEADER for(; IN.header; IN.header --) { MOVE (1); }
#define MOVE(k)						\
    IN.clocation ++;					\
    TRACE ("reached %d by %d", IN.clocation, k);	\
    marpatcl_rtc_clindex_update (p, k)

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

    TRACE_RETURN ("=> %d", ch);
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
