/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Gate
 */

#include <rtc.h>

#define IN   (p->in)
#define GATE (p->gate)

void
marpa_rtc_gate_cons (marpa_rtc_p p)
{
    marpa_rtc_byteset_clear (&GATE.acceptable);
    marpa_rtc_stack_init    (&GATE.history);
    marpa_rtc_stack_init    (&GATE.pending);
    GATE.lastchar = -1;
    GATE.lastloc  = -1;
}

void
marpa_rtc_gate_enter (marpa_rtc_p p, const char* ch)
{
    int flushed = 0;
    GATE.lastchar = ch;
    GATE.lastloc  = IN.location;

    while (1) {
	if (marpa_rtc_byteset_contains (&GATE.acceptable, ch)) {
	    marpa_rtc_stack_push (&GATE.history, ch);
	    marpa_rtc_stack_push (&GATE.history, IN.location);

	    /* NOTE: My not need to push locations, simply decrement on redo. */

	    marpa_rtc_lexer_enter (p, ch);
	    return
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
marpa_rtc_gate_acceptable (marpa_rtc_p p, int c, Marpa_Symbol_ID* v)
{
    marpa_rtc_byteset_addmany_i (&GATE.acceptable, c, v);
}

void
marpa_rtc_gate_redo (marpa_rtc_p p, int n)
{
    if (n) {
	char ch;
	marpa_rtc_stack_move  (&GATE.pending, &GATE.history, n+n)
	marpa_rtc_stack_clear (&GATE.history);
	while (marpa_rtc_stack_size (&GATE.pending)) {
	    ch  = marpa_rtc_stack_pop (&GATE.pending);
	    loc = marpa_rtc_stack_pop (&GATE.pending);

	    IN.location = loc;
	    marpa_rtc_gate_enter (marpa_rtc_p p, ch);
	}
    } else {
	marpa_rtc_stack_clear (&GATE.history);
    }
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
