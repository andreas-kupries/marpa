/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Lexer
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <lexer.h>
#include <rtc_int.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void marpa_rtc_lexer_complete (marpa_rtc_p p)

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
marpa_rtc_lexer_init (marpa_rtc_p p)
{
    LEX.g = marpa_g_new (CONF);
    marpa_rtc_spec_setup (LEX.g, SPEC->l0);
    marpa_rtc_dynset_cons (ACCEPT, SPEC->lexemes + ALWAYS.size);
    LEX.lexeme = marpa_rtc_stack_cons (80);
    LEX.start = -1;
    LEX.recce = 0;
}

void
marpa_rtc_lexer_free (marpa_rtc_p p)
{
    marpa_g_unref (LEX.g);
    marpa_rtc_dynset_release (ACCEPT);
    marpa_rtc_stack_destroy (LEX.lexeme);
}

void
marpa_rtc_lexer_enter (marpa_rtc_p p, int ch)
{
    /* Contrary to the Tcl runtime the C engine does not get multiple symbols,
     * only one, the current byte. Because byte-ranges are coded as rules in
     * the grammar instead of as input symbols.
     */

    if (LX.start == -1) {
	LX.start = GA.lastloc;
    }

    if (ch == -1) {
	marpa_rtc_lexer_complete (p);
	return;
    }

    marpa_rtc_stack_push (LX.lexeme, ch);
    res = marpa_r_alternative (LX.recce, ch, 1, 1);
    ASSERT (res >= 0, "L alt");
    // TODO: handle error

    res = marpa_r_earleme_complete (LX.recce);
    // TODO marpatcl_process_events (instance->grammar, marpatcl_recognizer_event_to_tcl, instance);
    if (res != MARPA_ERR_PARSE_EXHAUSTED) {
	// any error but exhausted is failure
	ASSERT (res >= 0, "L e-c");
    }

    if (marpa_r_is_exhausted (LX.recce)) {
	marpa_rtc_lexer_complete (p);
	return;
    }

    // Now the gate can update its (character) acceptables too.
    marpa_rtc_gate_acceptable (p);
    return;
}

void
marpa_rtc_lexer_eof (marpa_rtc_p p)
{
    if (LEX.start >= 0) {
	marpa_rtc_lexer_complete (p);
    }

    if (LEX.recce) {
	marpa_r_unref (LEX.recce);
	LEX.recce = 0;
    }

    marpa_rtc_parser_eof (p);
}

void
marpa_rtc_lexer_acceptable (marpa_rtc_p p)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    ASSERT (!LEX.recce, "Left over recognizer");

    // create new recognizer for next match, reset match state
    LEX.recce = marpa_r_new (LEX.g);
    LEX.start = -1;
    marpa_rtc_stack_clear (LEX.lexeme);
    res = marpa_r_start_input (LEX.recce);
    ASSERT (res >= 0, "L s-i");
    // -- marpatcl_process_events (p->l0, HANDLER, CDATA);
    // TODO: handle error

    // pull information about acceptables from the parser engine.
    
    /* This code puts information from the parser's recognizer directly into
     * the `dense` array of the lexer's dynset. It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * See also marpa_rtc_gate_acceptable(). A small difference, we have to
     * convert from parser terminal ids to the lexer's lexeme ids.
     */

    buf = marpa_rtc_dynset_dense (ACCEPT);
    n   = marpa_r_terminals_expected (PARS_R, buf);
    // TODO: down-convert parser symbols to lexer (lexeme ACS)
    marpa_rtc_dynset_link    (ACCEPT, n);
    marpa_rtc_dynset_include (ACCEPT, ALWAYS.size, ALWAYS.data);

    // And feed it into the new lexer recce
    n = marpa_rtc_dynset_size (ACCEPT);
    if (n) {
	int k;
	buf = marpa_rtc_dynset_dense (ACCEPT);
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
    marpa_rtc_gate_acceptable (p);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

void
marpa_rtc_lexer_complete (marpa_rtc_p p)
{
    // TODO complete
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
