/* Runtime for C-engine (RTC). Implementation. (Engine: Lexing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <lexer.h>
#include <spec.h>
#include <stack.h>
#include <symset.h>
#include <rtc_int.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static char*             get_lexeme (marpatcl_rtc_p p, int* len);
static void              complete  (marpatcl_rtc_p p);
static void              to_acs    (int c, Marpa_Symbol_ID* v);
static int               get_parse (Marpa_Tree        t,
				    marpatcl_rtc_sym* token,
				    marpatcl_rtc_sym* rule);
static void              mismatch  (marpatcl_rtc_p p);
static marpatcl_rtc_sv_p get_sv    (marpatcl_rtc_p   p,
				    marpatcl_rtc_sym token,
				    marpatcl_rtc_sym rule);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define ACCEPT (&LEX.acceptable)
#define FOUND  (&LEX.found)
#define PARS_R (PAR.recce)
#define ALWAYS (SPEC->always)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_lexer_init (marpatcl_rtc_p p)
{
    int k;
    LEX.g = marpa_g_new (CONF);
    marpatcl_rtc_spec_setup (LEX.g, SPEC->l0);
    marpatcl_rtc_symset_init (ACCEPT, SPEC->lexemes + ALWAYS.size);
    marpatcl_rtc_symset_init (FOUND, SPEC->lexemes);
    LEX.lexeme = marpatcl_rtc_stack_cons (80);
    LEX.start = -1;
    LEX.recce = 0;

    LEX.single_sv = 1;
    for (k = 0; k < SPEC->l0semantic.size; k++) {
	int key = SPEC->l0semantic.data[k];
	if ((k == MARPATCL_SV_RULE_ID) ||
	    (k == MARPATCL_SV_LHS_ID)) {
	    LEX.single_sv = 0;
	}
    }
}

void
marpatcl_rtc_lexer_free (marpatcl_rtc_p p)
{
    marpa_g_unref (LEX.g);
    marpatcl_rtc_symset_free (ACCEPT);
    marpatcl_rtc_symset_free (FOUND);
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
	complete (p);
	// MAYBE FAIL.
	return;
    }

    marpatcl_rtc_stack_push (LEX.lexeme, ch);
    res = marpa_r_alternative (LEX.recce, ch, 1, 1);
    ASSERT (res >= 0, "lexer alternative");

    res = marpa_r_earleme_complete (LEX.recce);
    if (res != MARPA_ERR_PARSE_EXHAUSTED) {
	// any error but exhausted is a hard failure
	ASSERT (res >= 0, "lexer earleme-complete");
    }
    // TODO marpatcl_process_events (p->l0, HANDLER, CDATA);

    if (marpa_r_is_exhausted (LEX.recce)) {
	complete (p);
	// MAYBE FAIL
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
	complete (p);
	// MAYBE FAIL - TODO Handling ?
    }

    if (LEX.recce) {
	marpa_r_unref (LEX.recce);
	LEX.recce = 0;
    }

    marpatcl_rtc_parser_eof (p);
}

void
marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p, int keep)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    ASSERT (!LEX.recce, "lexer: left over recognizer");

    // create new recognizer for next match, reset match state
    LEX.recce = marpa_r_new (LEX.g);
    LEX.start = -1;
    marpatcl_rtc_stack_clear (LEX.lexeme);
    res = marpa_r_start_input (LEX.recce);
    ASSERT (res >= 0, "lexer start-input");
    // TODO marpatcl_process_events (p->l0, HANDLER, CDATA);

    /* This code puts information from the parser's recognizer directly into
     * the `dense` array of the lexer's symset. It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * See also marpatcl_rtc_gate_acceptable(). A small difference, we have to
     * convert from parser terminal ids to the lexer's lexeme (ACS) ids.
     */

    if (!keep) {
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	n   = marpa_r_terminals_expected (PARS_R, buf);
	to_acs (n, buf);
	marpatcl_rtc_symset_link    (ACCEPT, n);
	marpatcl_rtc_symset_include (ACCEPT, ALWAYS.size, ALWAYS.data);
    }
    
    /* And feed the results into the new lexer recce */
    n = marpatcl_rtc_symset_size (ACCEPT);
    if (n) {
	int k;
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	for (k=0; k < n; k++) {
	    res = marpa_r_alternative (LEX.recce, buf [k], 1, 1);
	    ASSERT (res >= 0, "lexer alternative/b");
	}

	res = marpa_r_earleme_complete (LEX.recce);
	ASSERT (res >= 0, "lexer earleme-complete/b");
	// TODO marpatcl_process_events (p->l0, HANDLER, CDATA);
    }

    // Now the gate can update its acceptables (byte symbols) too.
    marpatcl_rtc_gate_acceptable (p);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

void
complete (marpatcl_rtc_p p)
{
    int status, redo, latest, res, discarded, svid;
    Marpa_Bocage b;
    Marpa_Order  o;
    Marpa_Tree   t;
    marpatcl_rtc_sym token;
    marpatcl_rtc_sym rule;
    marpatcl_rtc_sv_p sv = 0;

    if (!LEX.recce) return;

    /* Find location with lexeme, work backwards from the end of the match */
    latest =  marpa_r_latest_earley_set (LEX.recce);
    redo = 0;
    while (1) {
	b = marpa_b_new (LEX.recce, latest);
	if (b) break;
	redo ++;
	latest --;
	if (latest < 0) {
	    mismatch (p);
	    // FAIL, aborting. Callers `lexer_enter`, `lexer_eof`.
	    return;
	}
    }

    /* Get all the valid parses at the location and evaluate them.
     */

    o = marpa_o_new (b);
    t = marpa_t_new (o);
    rule = token = -1;
    discarded = 0;
    marpatcl_rtc_symset_clear (FOUND);
    while (1) {
	status = get_parse (t, &token, &rule);
	if (status < 0) break;
	// token = ACS lexeme symbol
	// rule  = lexeme rule

	if (((SPEC->lexemes+256) <= token) &&
	    (token < (SPEC->lexemes+SPEC->discards+255))) {
	    discarded ++;
	    continue;
	}
	// Translate ACS lexeme to parser terminal
	token -= 256;

	if (marpatcl_rtc_symset_contains (FOUND, token)) continue;
	marpatcl_rtc_symset_include (FOUND, 1, &token);

	// SV deduplication: If the semantic codes are all for a value
	// independent if token/rule ids, a single SV is generated and used in
	// all the symbols. Otherwise an SV is generated for each unique
	// token.  Note, this will not catch a token with multiple rules, for
	// these only the first is captured and forwarded.

	if (!LEX.single_sv || !sv) {
	    sv = get_sv (p, token, rule);
	    svid = marpatcl_rtc_store_add (p, sv);
	}
	
	res = marpa_r_alternative (PARS_R, token, svid, 1);
    }

    marpa_t_unref (t);
    marpa_o_unref (o);
    marpa_r_unref (LEX.recce);
    LEX.recce = 0;

    if (!marpatcl_rtc_symset_size(FOUND) && discarded) {
	// Nothing found. Do not talk to parser. Restart lexing with the
	// current set of acceptable symbols.
	marpatcl_rtc_lexer_acceptable (p, 1);
    } else {
	// Tell parser about number of alternatives given to it (See (%%))
	marpatcl_rtc_parser_enter (p, marpatcl_rtc_symset_size(FOUND));
	// MAYBE FAIL
    }

    marpatcl_rtc_gate_redo (p, redo);
}

static void
to_acs (int c, Marpa_Symbol_ID* v)
{
    /* v[i] ... Parser symbols ... Map to Lexer ACS
     * As per spec.h: lexeme = 256 + terminal
     */
    int k;
    for (k=0; k < c; k++) {
	v[k] += 256;
    }
}

static int
get_parse (Marpa_Tree        t,
	   marpatcl_rtc_sym* token,
	   marpatcl_rtc_sym* rule)
{
    Marpa_Value v;
    marpatcl_rtc_sym rules[2] = {-1,-1};
    int stop, status = marpa_t_next (t);
    int rslot = 0;

    if (status == -1) {
	return -1;
    }
    ASSERT (status >= 0, "lexer tree failure");

    v = marpa_v_new (t);
    while (!stop) {
	Marpa_Step_Type stype = marpa_v_step (v);
	if (stype == MARPA_STEP_INACTIVE) break;
	if (stype == MARPA_STEP_INITIAL) continue;
	if (stype == MARPA_STEP_TOKEN && token < 0) {
	    /* First token instruction has the id of the ACS symbol of the
		 * matched lexeme => terminal symbol derivable from this. */
	    *token = marpa_v_token(v);
	    continue;
	}
	if (stype == MARPA_STEP_RULE) {
	    /* Keep last two rules saved so that we have quick access to
	     * next-to-last later */
	    rules[rslot] = marpa_v_rule(v);
	    rslot = 1 - rslot;
	    continue;
	}
    }
    marpa_v_unref (v);
    *rule = rules[rslot];
    return 0;
}

static void
mismatch (marpatcl_rtc_p p)
{
    marpatcl_rtc_failit (p, "lexer");
    // Caller `complete` has to abort

    marpa_r_unref (LEX.recce);
    LEX.recce = 0;
}

static marpatcl_rtc_sv_p
get_sv (marpatcl_rtc_p   p,
	marpatcl_rtc_sym token, /* G1 parser terminal */
	marpatcl_rtc_sym rule)
{
    int k;
    /* SV is vector of pieces indicated by the codes */
    marpatcl_rtc_sv_p sv = marpatcl_rtc_sv_cons_vec (SPEC->l0semantic.size);
    /* local cache to avoid duplicate memory for duplicate key codes */
    marpatcl_rtc_sv_p start    = 0;
    marpatcl_rtc_sv_p length   = 0;
    marpatcl_rtc_sv_p g1start  = 0;
    marpatcl_rtc_sv_p g1length = 0;
    marpatcl_rtc_sv_p lhsname  = 0;
    marpatcl_rtc_sv_p lhsid    = 0;
    marpatcl_rtc_sv_p ruleid   = 0;
    marpatcl_rtc_sv_p value    = 0;
	
    for (k = 0; k < SPEC->l0semantic.size; k++) {
	switch (SPEC->l0semantic.data[k]) {
	case MARPATCL_SV_START:
	    if (!start) {
		start = marpatcl_rtc_sv_cons_int (LEX.start);
	    }
	    marpatcl_rtc_sv_vec_push (sv, start);
	    break;
	case MARPATCL_SV_LENGTH:
	    if (!length) {
		length = marpatcl_rtc_sv_cons_int (marpatcl_rtc_stack_size(LEX.lexeme));
	    }
	    marpatcl_rtc_sv_vec_push (sv, length);
	    break;
	case MARPATCL_SV_G1START:
	    if (!g1start) {
		g1start = marpatcl_rtc_sv_cons_int (-1);
	    }
	    marpatcl_rtc_sv_vec_push (sv, g1start);
	    break;
	case MARPATCL_SV_G1LENGTH:
	    if (!g1length)
		g1length = marpatcl_rtc_sv_cons_int (1);
	    marpatcl_rtc_sv_vec_push (sv, g1length);
	    break;
	case MARPATCL_SV_RULE_NAME:
	case MARPATCL_SV_LHS_NAME:
	    if (!lhsname) {
		lhsname = marpatcl_rtc_sv_cons_string (
			marpatcl_rtc_spec_symname (SPEC->g1, token, NULL), 0);
	    }
	    marpatcl_rtc_sv_vec_push (sv, lhsname);
	    break;
	case MARPATCL_SV_LHS_ID:
	    if (!lhsid) {
		lhsid = marpatcl_rtc_sv_cons_int (token);
	    }
	    marpatcl_rtc_sv_vec_push (sv, lhsid);
	    break;
	case MARPATCL_SV_RULE_ID:
	    if (!ruleid) {
		ruleid = marpatcl_rtc_sv_cons_int (rule);
	    }
	    marpatcl_rtc_sv_vec_push (sv, ruleid);
	    break;
	case MARPATCL_SV_VALUE:
	    if (!value) {
		value = marpatcl_rtc_sv_cons_string (get_lexeme (p, NULL), 1);
	    }
	    marpatcl_rtc_sv_vec_push (sv, value);
	    break;
	}
    }
    return sv;
}

static char*
get_lexeme (marpatcl_rtc_p p, int* len)
{
    int   n = marpatcl_rtc_stack_size (LEX.lexeme);
    char* v = NALLOC (char, n+1);

    if (len) {
	*len = n;
    }
    
    v[n] = '\0';
    while (n) {
	n--;
	v[n] = marpatcl_rtc_stack_pop (LEX.lexeme);
    }

    return v;
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
