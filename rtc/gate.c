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

void
marpa_rtc_gate_cons (marpa_rtc_p p)
{
    marpa_rtc_byteset_clear (&GA.acceptable);
    marpa_rtc_stack_init    (&GA.history);
    marpa_rtc_stack_init    (&GA.pending);
    GA.lastchar = -1;
    GA.lastloc  = -1;
}

void
marpa_rtc_gate_release (marpa_rtc_p p)
{
    marpa_rtc_stack_release (&GA.history);
    marpa_rtc_stack_release (&GA.pending);
}

void
marpa_rtc_gate_enter (marpa_rtc_p p, const char ch)
{
    int flushed = 0;
    GA.lastchar = ch;
    GA.lastloc  = IN.location;

    while (1) {
	if (marpa_rtc_byteset_contains (&GA.acceptable, ch)) {
	    marpa_rtc_stack_push (&GA.history, ch);
	    marpa_rtc_stack_push (&GA.history, IN.location);
	    // TODO: May not need to push locations, simply decrement on redo.

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
    /* Direct copy into the byte-set */
    Marpa_Symbol_ID* buf = marpa_rtc_byteset_dense (&GA.acceptable);
    int              n   = marpa_r_terminals_expected (LX.recce, buf);
    marpa_rtc_byteset_link (&GA.acceptable, n);
}

void
marpa_rtc_gate_redo (marpa_rtc_p p, int n)
{
    if (n) {
	char ch;
	int loc;
	marpa_rtc_stack_move  (&GA.pending, &GA.history, n+n);
	/* Note: The move of the data to replay reversed it as well, placing
	 * the earlier characters higher in the stack. Popping them off again
	 * thus provides is them in the original time order, just as we need
	 * it. It also reversed ch/loc.
	 */
	marpa_rtc_stack_clear (&GA.history);
	while (marpa_rtc_stack_size (&GA.pending)) {
	    ch  = marpa_rtc_stack_pop (&GA.pending);
	    loc = marpa_rtc_stack_pop (&GA.pending);

	    IN.location = loc;
	    marpa_rtc_gate_enter (p, ch);
	}
	ASSERT (!marpa_rtc_stack_size (&GA.pending), "History replay left data behind");
    } else {
	marpa_rtc_stack_clear (&GA.history);
    }
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
