/* Runtime for C-engine (RTC). Implementation. (Engine: Lexing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <lexer.h>
#include <symset.h>
#include <rtc_int.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void marpatcl_rtc_lexer_complete (marpatcl_rtc_p p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define ACCEPT (&LEX.acceptable)
#define PARS_R (PAR.recce)
#define ALWAYS (SPEC->always)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_lexer_init (marpatcl_rtc_p p)
{
    LEX.g = marpa_g_new (CONF);
    marpatcl_rtc_spec_setup (LEX.g, SPEC->l0);
    marpatcl_rtc_symset_init (ACCEPT, SPEC->lexemes + ALWAYS.size);
    LEX.lexeme = marpatcl_rtc_stack_cons (80);
    LEX.start = -1;
    LEX.recce = 0;
}

void
marpatcl_rtc_lexer_free (marpatcl_rtc_p p)
{
    marpa_g_unref (LEX.g);
    marpatcl_rtc_symset_free (ACCEPT);
    marpatcl_rtc_stack_destroy (LEX.lexeme);
}

void
marpatcl_rtc_lexer_enter (marpatcl_rtc_p p, int ch)
{
    int res;
    /* Contrary to the Tcl runtime the C engine does not get multiple symbols,
     * only one, the current byte. Because byte-ranges are coded as rules in
     * the grammar instead of as input symbols.
     */

    if (LEX.start == -1) {
	LEX.start = GATE.lastloc;
    }

    if (ch == -1) {
	marpatcl_rtc_lexer_complete (p);
	return;
    }

    marpatcl_rtc_stack_push (LEX.lexeme, ch);
    res = marpa_r_alternative (LEX.recce, ch, 1, 1);
    ASSERT (res >= 0, "L alt");
    // TODO: handle error

    res = marpa_r_earleme_complete (LEX.recce);
    // TODO marpatcl_process_events (instance->grammar, marpatcl_recognizer_event_to_tcl, instance);
    if (res != MARPA_ERR_PARSE_EXHAUSTED) {
	// any error but exhausted is failure
	ASSERT (res >= 0, "L e-c");
    }

    if (marpa_r_is_exhausted (LEX.recce)) {
	marpatcl_rtc_lexer_complete (p);
	return;
    }

    // Now the gate can update its (character) acceptables too.
    marpatcl_rtc_gate_acceptable (p);
    return;
}

void
marpatcl_rtc_lexer_eof (marpatcl_rtc_p p)
{
    if (LEX.start >= 0) {
	marpatcl_rtc_lexer_complete (p);
    }

    if (LEX.recce) {
	marpa_r_unref (LEX.recce);
	LEX.recce = 0;
    }

    marpatcl_rtc_parser_eof (p);
}

void
marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    ASSERT (!LEX.recce, "Left over recognizer");

    // create new recognizer for next match, reset match state
    LEX.recce = marpa_r_new (LEX.g);
    LEX.start = -1;
    marpatcl_rtc_stack_clear (LEX.lexeme);
    res = marpa_r_start_input (LEX.recce);
    ASSERT (res >= 0, "L s-i");
    // -- marpatcl_process_events (p->l0, HANDLER, CDATA);
    // TODO: handle error

    // pull information about acceptables from the parser engine.
    
    /* This code puts information from the parser's recognizer directly into
     * the `dense` array of the lexer's symset. It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * See also marpatcl_rtc_gate_acceptable(). A small difference, we have to
     * convert from parser terminal ids to the lexer's lexeme ids.
     */

    buf = marpatcl_rtc_symset_dense (ACCEPT);
    n   = marpa_r_terminals_expected (PARS_R, buf);
    // TODO: down-convert parser symbols to lexer (lexeme ACS)
    marpatcl_rtc_symset_link    (ACCEPT, n);
    marpatcl_rtc_symset_include (ACCEPT, ALWAYS.size, ALWAYS.data);

    // And feed it into the new lexer recce
    n = marpatcl_rtc_symset_size (ACCEPT);
    if (n) {
	int k;
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	for (k=0; k < n; k++) {
	    res = marpa_r_alternative (LEX.recce, buf [k], 1, 1);
	    ASSERT (res >= 0, "L alt/b");
	    // TODO: handle error
	}

	res = marpa_r_earleme_complete (LEX.recce);
	ASSERT (res >= 0, "L e-c/b");
	// -- marpatcl_process_events (p->l0, HANDLER, CDATA);
	// TODO: handle error
    }

    // Now the gate can update its acceptables (byte symbols) too.
    marpatcl_rtc_gate_acceptable (p);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

void
marpatcl_rtc_lexer_complete (marpatcl_rtc_p p)
{
    // TODO complete
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
