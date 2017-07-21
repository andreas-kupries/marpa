/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Gate
 */

#include <gate.h>
#include <rtc_int.h>
#include <critcl_assert.h>

/*
 */

#define ACCEPT (&GATE.acceptable)
#define LEX_R  (LEX.recce)

/*
 */

void
marpa_rtc_gate_init (marpa_rtc_p p)
{
    marpa_rtc_byteset_clear (ACCEPT);
    GATE.history = marpa_rtc_stack_cons (80);
    GATE.pending = marpa_rtc_stack_cons (10);
    GATE.lastchar = -1;
    GATE.lastloc  = -1;
}

void
marpa_rtc_gate_free (marpa_rtc_p p)
{
    marpa_rtc_stack_destroy (GATE.history);
    marpa_rtc_stack_destroy (GATE.pending);
    /* GATE.acceptable - nothing to do */
}

void
marpa_rtc_gate_enter (marpa_rtc_p p, const char ch)
{
    int flushed = 0;
    GATE.lastchar = ch;
    GATE.lastloc  = IN.location;

    while (1) {
	if (marpa_rtc_byteset_contains (ACCEPT, ch)) {
	    marpa_rtc_stack_push (GATE.history, ch);
	    /* Note: Not pushing the locations, we know the last, and
	     * and can use that in the `redo` to properly move back.
	     */
	    marpa_rtc_lexer_enter (p, ch);
	    return;
	}

	/* No match: Try to close current symbol, then retry. But at most once
	 */
	if (flushed) {
	    // TODO: FAIL
	}

	flushed ++;
	marpa_rtc_lexer_enter (p, -1);
    }
}

void
marpa_rtc_gate_eof (marpa_rtc_p p)
{
    marpa_rtc_lexer_eof (p);
}

void
marpa_rtc_gate_acceptable (marpa_rtc_p p)
{
    /* This code puts information from the lexer's recognizer directly into
     * the `dense` array of the byteset (x). It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * (x) To allow this is the reason for `dense` using elements of type
     *     `Marpa_Symbol_ID` instead of `unsigned char`.
     */
    Marpa_Symbol_ID* v = marpa_rtc_byteset_dense (ACCEPT);
    int              c = marpa_r_terminals_expected (LEX_R, v);
    marpa_rtc_byteset_link (ACCEPT, c);
}

void
marpa_rtc_gate_redo (marpa_rtc_p p, int n)
{
    if (!n) {
	marpa_rtc_stack_clear (GATE.history);
    } else {
	/* Save the part of the history to replay, and reset the location
	 * accordingly. During replay we move forward again.
	 */
	marpa_rtc_stack_move (GATE.pending, GATE.history, n);
	IN.location -= n;
	/* Note: The move of the data to replay reversed it as well, placing
	 * the earlier characters higher in the stack. Popping them off again
	 * thus provides is them in the original time order, just as we need
	 * it.
	 */
	marpa_rtc_stack_clear (GATE.history);
	while (marpa_rtc_stack_size (GATE.pending)) {
	    IN.location ++;
	    marpa_rtc_gate_enter (p, marpa_rtc_stack_pop (GATE.pending));
	}
	ASSERT (!marpa_rtc_stack_size (GATE.pending), "History replay left data behind");
    }
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
