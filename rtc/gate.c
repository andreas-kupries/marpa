/* Runtime for C-engine (RTC). Implementation. (Engine: Lexer gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <gate.h>
#include <rtc_int.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define ACCEPT (&GATE.acceptable)
#define LEX_R  (LEX.recce)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_gate_init (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_gate_init");
    TRACE (("rtc %p", p));
    marpatcl_rtc_byteset_clear (ACCEPT);
    GATE.history = marpatcl_rtc_stack_cons (80);
    GATE.pending = marpatcl_rtc_stack_cons (10);
    GATE.lastchar = -1;
    GATE.lastloc  = -1;
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_gate_free (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_gate_free");
    TRACE (("rtc %p", p));
    marpatcl_rtc_stack_destroy (GATE.history);
    marpatcl_rtc_stack_destroy (GATE.pending);
    /* GATE.acceptable - nothing to do */
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_gate_enter (marpatcl_rtc_p p, const char ch)
{
    int flushed = 0;
    TRACE_ENTER ("marpatcl_rtc_gate_enter");
    TRACE (("rtc %p byte %d @ %d", p, ch, IN.location));
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
	    TRACE_RETURN_VOID;
	}

	/* No match: Try to close current symbol, then retry. But at most once.
	 */
	TRACE (("rtc %p not acceptable", p));
	if (flushed) {
	    TRACE (("rtc %p flushed, fail", p));
	    marpatcl_rtc_failit (p, "gate");
	    // See marpatcl_rtc_inbound_enter for test of failure and abort.
	    TRACE_RETURN_VOID;
	}

	TRACE (("rtc %p flush", p));
	flushed ++;
	marpatcl_rtc_lexer_enter (p, -1);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_gate_eof (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_gate_eof");
    TRACE (("rtc %p", p));
    marpatcl_rtc_lexer_eof (p);
    TRACE_RETURN_VOID;
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
    TRACE_ENTER ("marpatcl_rtc_gate_acceptable");
    TRACE (("rtc %p", p));
    {
	Marpa_Symbol_ID* v = marpatcl_rtc_byteset_dense (ACCEPT);
	int              c = marpa_r_terminals_expected (LEX_R, v);
	marpatcl_rtc_fail_syscheck (p, LEX.g, c, "terminals_expected");
	marpatcl_rtc_byteset_link (ACCEPT, c);
#ifdef CRITCL_TRACER
	{
	    int k, n = marpatcl_rtc_byteset_size (ACCEPT);
	    for (k=0; k < n; k++) {
		TRACE (("ACCEPT [%d]: %d = %s", k, v[k],
			marpatcl_rtc_spec_symname (SPEC->l0, v[k], 0)));
	    }	       
	}
#endif
    }
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_gate_redo (marpatcl_rtc_p p, int n)
{
    TRACE_ENTER ("marpatcl_rtc_gate_redo");
    TRACE (("rtc %p redo %d", p, n));
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
    TRACE_RETURN_VOID;
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
