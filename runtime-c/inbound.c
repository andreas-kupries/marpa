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
TRACE_TAG_OFF (utf);
TRACE_TAG_OFF (locations);

#define NAME(sym) marpatcl_rtc_spec_symname (SPEC->l0, sym, 0)

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

static void
print_input_l (marpatcl_rtc_p p)
{
    //unsigned char s = '((';
    const unsigned char* c;
    int k;
    TRACE_TAG_HEADER (locations, 1);
    TRACE_TAG_ADD    (locations, "%p LOC ((", p);
    for (k = 0, c = IN.bytes; k < IN.size; k++, c++) {
	if (*c < 32) {
	    // Control character, explicit octal output.
	    TRACE_TAG_ADD (locations, "\\%03o", *c);
	} else {
	    // Use symbol names, should be the character itself, or escaped thing.
	    TRACE_TAG_ADD (locations, "%s", NAME (*c));
	}
	//s = ',';
    }
    TRACE_TAG_ADD    (locations, "))", 0);
    TRACE_TAG_CLOSER (locations);
}
#endif

static int ok_char (marpatcl_rtc_p p, int trailers);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_inbound_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    IN.bytes     = 0;
    IN.size      = 0;
    IN.csize     = 0;
    IN.owned     = 0;
    IN.location  = -1;
    IN.clocation = -1;
    IN.cstop     = -2;
    IN.trailer   = 0;
    IN.clen      = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    if (IN.owned) {
	FREE (IN.bytes);
    }

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
    TRACE_RETURN ("%d", IN.clocation);
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

    IN.clocation = cpos;
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
marpatcl_rtc_inbound_move_byte (marpatcl_rtc_p p, int delta)
{
    TRACE_FUNC ("((rtc*) %p, byte pos %d += %d)", p, IN.location, delta);

    IN.location += delta;
    IN.clocation = marpatcl_rtc_clindex_find_c (p, IN.location);

    TRACE ("((rtc*) %p, now pos = %d ~ %d)", p, IN.clocation, IN.location);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_inbound_no_stop (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p", p);

    IN.cstop = -2;

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

    IN.cstop = IN.clocation + limit;

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
    unsigned char ch;
    TRACE_FUNC ("(rtc %p bytes %p, n %d, [%d...%d])", p, bytes, max, from, to);
    TRACE_TAG_DO (enter, print_input (bytes, max));

    if (max < 0) {
	max = strlen (bytes);
    }

    IN.bytes = (char*) bytes; // Copying the pointer means we do not own it.
    IN.owned = 0;             // Relevant to `enter_more`.
    IN.psize = max;
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

    TRACE_TAG (locations, "%p LOC _ __ ___ _____ ________ _____________ START", p);
    TRACE_RUN (int last = -1 );

    while (1) {
	TRACE_TAG_DO (locations, if (IN.size != last) { last = IN.size; print_input_l (p); });

	TRACE_TAG_HEADER (locations, 1);
	TRACE_TAG_ADD    (locations, "%p LOC [[M:%6d E:%6d S:%6d -- B%6d C%6d]]",
			  p, max, IN.size, IN.cstop, IN.location, IN.clocation);

	if (IN.clocation == IN.cstop) {
	    TRACE_TAG_ADD (locations, " STOP", 0);
	    // Stop triggered (after last character, just before new).
	    // Clear stop marker, post event, continue (via fall through)
	    IN.cstop     = -2;
	    marpatcl_rtc_symset_clear (EVENTS);
	    POST_EVENT (marpatcl_rtc_event_stop);
	    if (evok == 0) break;
	    //  1 - ok,      resume processing
	    // -1 - ignored, resume as well
	    TRACE_TAG_ADD    (locations, " & CONT /", 0);
	    TRACE_TAG_CLOSER (locations);
	    continue;
	}

	if (IN.location == max) {
	    TRACE_TAG_ADD (locations, " EO1", 0);
	    // Trigger end of data processing in the post-processors.
	    // (Ad 4) Note that this may rewind the input to an earlier
	    // place, forcing re-processing of some of the last
	    // characters.
	    marpatcl_rtc_gate_eof (p);

	    if (IN.location == max) {
		TRACE_TAG_ADD (locations, " !EO1", 0);
		break;
	    }
	    TRACE_TAG_ADD    (locations, " /", 0);
	    TRACE_TAG_CLOSER (locations);
	    continue;
	}

	if (IN.location == (IN.size-1)) {
	    // Reached end of physical input stream, if extended. That means
	    // that the user failed to set a stop marker which would have
	    // stopped us before here.

	    marpatcl_rtc_symset_clear (EVENTS);
	    POST_EVENT (marpatcl_rtc_event_over);
	    if (evok == 0) break;
	    //  1 - ok,      abort
	    // -1 - ignored, abort
	    marpatcl_rtc_fail_ioover (p);
	    break;
	}

	ch = marpatcl_rtc_inbound_step (p);
	TRACE ("byte %3d @ char %d ~ byte %d = <%s>", ch, IN.clocation, IN.location, NAME(ch));
	TRACE_TAG_ADD (locations, " ++ [[%6d %6d ~ %3d <%s>]]", IN.clocation, IN.location, ch, NAME(ch));

	TRACE_TAG_ADD (locations, " gate", 0);

	marpatcl_rtc_gate_enter (p, ch);
	if (FAIL.fail) break;
	// Note, the post-processor (gate, lexer) have access to the location,
	// via methods moveto, moveby, and rewind. Examples of use:
	// - Rewind after reading behind the current lexeme
	// - Rewind for parse events.
	TRACE_TAG_CLOSER (locations);
    } /* while */
    TRACE_TAG_ADD    (locations, " / F:%d", FAIL.fail);
    TRACE_TAG_CLOSER (locations);

    TRACE_TAG (locations, "%p LOC _ __ ___ _____ ________ _____________ DONE", p);

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

    int            offset   = IN.size;
    int            newsize  = offset + 1 + max;
    unsigned char* newbytes;
    if (IN.owned) {
	// We own the memory for IN.bytes, thus we are allowed to directly
	// expand the area, nothing can trip over that.
	newbytes = REALLOC (IN.bytes, unsigned char, newsize);
	ASSERT (newbytes, "Failed to expand memory for input");
    } else {
	// The memory for IN.bytes belongs to the outside. Cannot simply
	// realloc, may pull the rug out from under somebody. Allocate in the
	// new size and do all the copying.
	newbytes = NALLOC (unsigned char, newsize);
	ASSERT (newbytes, "Failed to expand memory for copy of input");
	memcpy (newbytes, IN.bytes, IN.size * sizeof (unsigned char));
    }

    // Separator for the previous stream, and copy new data in.
    newbytes [offset] = '\0';
    memcpy (newbytes + offset + 1, bytes, max * sizeof (unsigned char));

    IN.owned = 1; // We own the memory now, regardless of its previous state.
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
    int len;

    TRACE_TAG (utf, "eyes: %d \\%3o @ %d", ch, ch, IN.location);

    // Possibly step to the next character location as well
#define SINGLE(c) (((c) & 0x80) == 0x00) // 0b1000,0000 : 0b0000,0000
#define TRAIL(c)  (((c) & 0xC0) == 0x80) // 0b1100,0000 : 0b1000,0000
#define LEAD2(c)  (((c) & 0xE0) == 0xC0) // 0b1110,0000 : 0b1100,0000
#define LEAD3(c)  (((c) & 0xF0) == 0xE0) // 0b1111,0000 : 0b1110,0000
#define LEAD4(c)  (((c) & 0xF8) == 0xF0) // 0b1111,1000 : 0b1111,0000
#define MOVE(k)						\
    IN.trailer = ((k)-1);				\
    IN.clen = k;					\
    IN.clocation ++;					\
    TRACE ("reached %d by %d", IN.clocation, k);	\
    marpatcl_rtc_clindex_update (p, k)

    if (SINGLE (ch)) {
	// Found a single. It stands for itself. There are no trailers
	// expected.
	TRACE_TAG (utf, "/single", 0);
	MOVE (1);
	TRACE_RETURN ("=> %d", ch);
    }

    // For multi-byte characters the processing is much more complex.
    //
    // - First, we have to step the character location on the first byte,
    //   i.e. the lead-in. Not at the last byte, that is too late for correct
    //   counting. That worked only for singles, which are both first and last.
    //
    // - Two, on the trailer bytes we do not step the character location.
    //
    // - Except, three, if there are not enough trailer bytes following the
    //   lead-in. Then we have to step per trailer byte too, treating each
    //   (including lead-in) as a separate character.
    //
    // All of this means that we have to check the correctness of the
    // character, i.e the number of actual trailer bytes, vs. expected, on the
    // lead-in, and save the result to control stepping on the trailers, and
    // the character index, of course. This is of course also dependent on the
    // correctness of the character, i.e. if the bytes count as themselves, or
    // as one.
    //
    // Lastly, when checking do not forget to avoid reading past the end of
    // the input stream.

    if (LEAD2 (ch)) { len = 2; goto step; }
    if (LEAD3 (ch)) { len = 3; goto step; }
    if (LEAD4 (ch)) { len = 4; goto step; }

    if (TRAIL (ch)) {
	// Found a trailer byte. The counter (set up by the lead-ins) tells us
	// if it is part of a character proper, or not. In case of the latter
	// it counts as a stand-alone character.
	TRACE_TAG (utf, "/trailer %d", IN.trailer);
	if (IN.trailer) {
	    // This is part of a group proper. Count the group size down.
	    IN.trailer --;
	    TRACE_RETURN ("=> %d", ch);
	}
	// This trailer is stand-alone. It counts as a character.
	MOVE (1);
	TRACE_RETURN ("=> %d", ch);
    }

    // Completely bogus, no UTF-8. Consider it as a stand-alone character.  No
    // need to panic. Lexer or gate are likely to reject it as unacceptable
    // input, making it a simple parse error. And for languages where such
    // bytes are legal a panic breaks them.

    MOVE (1);
    TRACE_RETURN ("=> %d", ch);

 step:
    // Found a lead-in for a (len)-byte character. We expect len-1 trailer
    // bytes.

    TRACE_TAG (utf, "/lead%d", len);
    if (ok_char (p, len-1)) {
	// We found all the trailer bytes, this and the next len-1 bytes count
	// as a single group, i.e. one character.
	MOVE (len);
	TRACE_RETURN ("=> %d", ch);
    }

    // Bad. The lead-in byte is missing its trailer, all or in part. Count it
    // as-is.

    MOVE (1);
    TRACE_RETURN ("=> %d", ch);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

static int
ok_char (marpatcl_rtc_p p, int trailers)
{
    TRACE_FUNC ("((rtc*) %p, trailers %d)", p, trailers);
    ASSERT (trailers, "Expected to expect > 0 trailer bytes");

    // IN.location points to just before the first of the expected trailer
    // bytes. I.e. it references the lead-in.

    int k;
    for (k = IN.location + 1; trailers; k++, trailers--) {
	// Do not go beyond the end of the stream
	if (k >= IN.size) { TRACE_RETURN ("FAIL EOF", 0); }

	// Report an unexpected non-trailer.
	unsigned char ch = IN.bytes [k];
	if (!TRAIL (ch)) { TRACE_RETURN ("FAIL TRAILER", 0); }
    }

    TRACE_RETURN ("OK", 1);
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
