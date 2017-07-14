/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Lexer
 */

#include <rtc.h>

#define IN    (p->in)
#define GATE  (p->gate)
#define LEXER (p->lexer)

void
marpa_rtc_lexer_cons (marpa_rtc_p p)
{
    marpa_rtc_dynset_init (&LEXER.acceptable, p->spec.nlexeme + p->spec.nalways);
    marpa_rtc_stack_init  (&LEXER.lexeme);
    LEXER.start = -1;
    LEXER.recce = 0;
}

void
marpa_rtc_lexer_enter (marpa_rtc_p p, int ch)
{
}

void
marpa_rtc_lexer_eof (marpa_rtc_p p)
{
    if (LEXER.start >= 0) {
	// TODO: complete
	assert(0);
    }

    if (LEXER.recce) {
	marpa_r_unref (LEXER.recce);
	LEXER.recce = 0;
    }

    marpa_rtc_parser_eof (p);
}

void
marpa_rtc_lexer_acceptable (marpa_rtc_p p, int c, Marpa_Symbol_ID* v)
{
    int res;
    // assert !recce
    LEXER.recce = marpa_r_new (p->l0);
    LEXER.start = -1;
    marpa_rtc_stack_clear (&LEXER.lexeme);

    res = marpa_r_start_input (LEXER.recce);
    /* -- marpatcl_process_events (p->l0, HANDLER, CDATA); -- */
    // TODO: handle error

    marpa_rtc_dynset_clear (&LEXER.acceptable);
    if (p->spec.nalways||c) {
	int k;
	marpa_rtc_dynset_addmany (LEXER.acceptable, p->spec.nalways, p->spec.always);
	for (k=0; k < c; k++) {
	    marpa_rtc_dynset_add (LEXER.acceptable, p->spec.p_to_l[v[k]]);
	}

	for (k=0; k < LEXER.acceptable.n; k++) {
	    int sym = LEXER.acceptable.dense[k];
	    res = marpa_r_alternative (LEXER.recce, sym, 1, 1);
	    // TODO: handle error
	}

	res = marpa_r_earleme_complete (LEXER.recce);
	// marpatcl_process_events (p->l0, HANDLER, CDATA);
	// TODO: handle error
    }

    marpa_rtc_gate_acceptable (p, marpa_r_terminals_expected (LEXER.recce, LEXER.expected),
			       LEXER.expected);
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
