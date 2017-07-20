/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Lexer
 */

#include <lexer.h>
#include <rtc_int.h>
#include <critcl_assert.h>

void
marpa_rtc_lexer_cons (marpa_rtc_p p)
{
    LX.g = marpa_g_new (&CO);
    marpa_rtc_spec_setup (LX.g, SP->l0);
    marpa_rtc_dynset_cons (&LX.acceptable, SP->lexemes + SP->nalways);
    marpa_rtc_stack_init  (&LX.lexeme);
    LX.start = -1;
    LX.recce = 0;
}

void
marpa_rtc_lexer_release (marpa_rtc_p p)
{
    // TODO release - check with lexer.tcl behaviour
    marpa_g_unref (LX.g);
    marpa_rtc_dynset_release (&LX.acceptable);
    marpa_rtc_stack_release  (&LX.lexeme);
}

void
marpa_rtc_lexer_enter (marpa_rtc_p p, int ch)
{
    // TODO enter
}

void
marpa_rtc_lexer_eof (marpa_rtc_p p)
{
    if (LX.start >= 0) {
	ASSERT (0, "todo complete match");
	// TODO: complete the parse, eval
	return;
    }

    if (LX.recce) {
	marpa_r_unref (LX.recce);
	LX.recce = 0;
    }

    marpa_rtc_parser_eof (p);
}

void
marpa_rtc_lexer_acceptable (marpa_rtc_p p, int c, Marpa_Symbol_ID* v)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    ASSERT (!LX.recce, "Left over recognizer");

    // create new recognizer for next match, reset match state
    LX.recce = marpa_r_new (LX.g);
    LX.start = -1;
    marpa_rtc_stack_clear (&LX.lexeme);
    res = marpa_r_start_input (LX.recce);
    // -- marpatcl_process_events (p->l0, HANDLER, CDATA);
    // TODO: handle error

    // pull information about acceptables from the parser engine.
    
    buf = marpa_rtc_dynset_dense (&LX.acceptable);
    n   = marpa_r_terminals_expected (PA.recce, buf);
    // TODO: down-convert parser symbols to lexer (lexeme ACS)
    marpa_rtc_dynset_link    (&LX.acceptable, n);
    marpa_rtc_dynset_include (&LX.acceptable, SP->nalways, SP->always);

    // And feed it into the new lexer recce
    n = marpa_rtc_dynset_size (&LX.acceptable);
    if (n) {
	int k;
	buf = marpa_rtc_dynset_dense (&LX.acceptable);
	for (k=0; k < n; k++) {
	    res = marpa_r_alternative (LX.recce, buf [k], 1, 1);
	    // TODO: handle error
	}

	res = marpa_r_earleme_complete (LX.recce);
	// -- marpatcl_process_events (p->l0, HANDLER, CDATA);
	// TODO: handle error
    }

    // Now the gate can update its (character) acceptables too.
    marpa_rtc_gate_acceptable (p);
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */