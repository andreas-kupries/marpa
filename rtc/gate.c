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
marpatcl_rtc_gate_init (marpatcl_rtc_p p)
{
    marpatcl_rtc_byteset_clear (ACCEPT);
    GATE.history = marpatcl_rtc_stack_cons (80);
    GATE.pending = marpatcl_rtc_stack_cons (10);
    GATE.lastchar = -1;
    GATE.lastloc  = -1;
}

void
marpatcl_rtc_gate_free (marpatcl_rtc_p p)
{
    marpatcl_rtc_stack_destroy (GATE.history);
    marpatcl_rtc_stack_destroy (GATE.pending);
    /* GATE.acceptable - nothing to do */
}

void
marpatcl_rtc_gate_enter (marpatcl_rtc_p p, const char ch)
{
    int flushed = 0;
    GATE.lastchar = ch;
    GATE.lastloc  = IN.location;

    while (!FAIL.fail) {
	if (marpatcl_rtc_byteset_contains (ACCEPT, ch)) {
	    marpatcl_rtc_stack_push (GATE.history, ch);
	    /* Note: Not pushing the locations, we know the last, and
	     * and can use that in the `redo` to properly move back.
	     */
	    marpatcl_rtc_lexer_enter (p, ch);
	    // See marpatcl_rtc_inbound_enter for test of failure and abort.
	    return;
	}

	/* No match: Try to close current symbol, then retry. But at most once.
	 */
	if (flushed) {
	    marpatcl_rtc_failit (p, "gate");
	    // See marpatcl_rtc_inbound_enter for test of failure and abort.
	    return;
	}

	flushed ++;
	marpatcl_rtc_lexer_enter (p, -1);
    }
}

void
marpatcl_rtc_gate_eof (marpatcl_rtc_p p)
{
    marpatcl_rtc_lexer_eof (p);
}

void
marpatcl_rtc_gate_acceptable (marpatcl_rtc_p p)
{
    /* This code puts information from the lexer's recognizer directly into
     * the `dense` array of the byteset (x). It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * (x) To allow this is the reason for `dense` using elements of type
     *     `Marpa_Symbol_ID` instead of `unsigned char`.
     */
    Marpa_Symbol_ID* v = marpatcl_rtc_byteset_dense (ACCEPT);
    int              c = marpa_r_terminals_expected (LEX_R, v);
    marpatcl_rtc_byteset_link (ACCEPT, c);
}

void
marpatcl_rtc_gate_redo (marpatcl_rtc_p p, int n)
{
    if (!n) {
	marpatcl_rtc_stack_clear (GATE.history);
    } else {
	/* Save the part of the history to replay, and reset the location
	 * accordingly. During replay we move forward again.
	 */
	marpatcl_rtc_stack_move (GATE.pending, GATE.history, n);
	IN.location -= n;
	/* Note: The move of the data to replay reversed it as well, placing
	 * the earlier characters higher in the stack. Popping them off again
	 * thus provides is them in the original time order, just as we need
	 * it.
	 */
	marpatcl_rtc_stack_clear (GATE.history);
	while (marpatcl_rtc_stack_size (GATE.pending)) {
	    IN.location ++;
	    marpatcl_rtc_gate_enter (p, marpatcl_rtc_stack_pop (GATE.pending));
	}
	ASSERT (!marpatcl_rtc_stack_size (GATE.pending), "History replay left data behind");
    }
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
