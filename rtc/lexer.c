/* Runtime for C-engine (RTC). Implementation. (Engine: Lexing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <lexer.h>
#include <spec.h>
#include <stack.h>
#include <symset.h>
#include <events.h>
#include <rtc_int.h>
#include <progress.h>
#include <marpatcl_steptype.h>

TRACE_OFF;
TRACE_TAG_OFF (accept);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static char*             get_lexeme (marpatcl_rtc_p p, int* len);
static void              complete  (marpatcl_rtc_p p);
static int               get_parse (marpatcl_rtc_p    p,
				    Marpa_Tree        t,
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

#define TO_ACS(s)      ((s)+256)
#define TO_TERMINAL(s) ((s)-256)

#define LEX_START      (LEX.start)
#define LEX_LEN        (LEX.length)
#define LEX_END        (LEX.start + LEX_LEN - 1)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_lexer_init (marpatcl_rtc_p p)
{
    int k, res;
    TRACE_FUNC ("((rtc*) %p (L %d D %d A %d LA %d))",
		p, SPEC->lexemes, SPEC->discards, ALWAYS.size,
		SPEC->lexemes + ALWAYS.size);

    /* Note (%%accept/always%%): The ACCEPT symset contains G1 terminal
     * symbols, plus pseudo-terminals for the L0 discard ymbols. Conversion to
     * L0 ACS symbols (+256, TO_ACS) happens on entering them into the L0
     * recognizer. It was done this way to avoid the memory penalty of keeping
     * 256 superfluous and never-used entries for the L0 character symbols.
     */
    
    LEX.g = marpa_g_new (CONF);
    (void) marpa_g_force_valued (LEX.g);
    LRD   = marpatcl_rtc_spec_setup (LEX.g, SPEC->l0, TRACE_TAG_VAR (lexer_progress));
    marpatcl_rtc_symset_init (ACCEPT, SPEC->lexemes + SPEC->discards);
    marpatcl_rtc_symset_init (FOUND,  SPEC->lexemes);
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

    res = marpa_g_precompute (LEX.g);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 precompute");
    marpatcl_rtc_lexer_events (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    
    marpa_g_unref (LEX.g);
    marpatcl_rtc_symset_free (ACCEPT);
    marpatcl_rtc_symset_free (FOUND);
    marpatcl_rtc_stack_destroy (LEX.lexeme);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_enter (marpatcl_rtc_p p, int ch)
{
    int res;
    TRACE_FUNC ("((rtc*) %p, byte %d (@ %d))",
		 p, ch, GATE.lastloc);
    LEX_P (p);
    /* Contrary to the Tcl runtime the C engine does not get multiple symbols,
     * only one, the current byte. Because byte-ranges are coded as rules in
     * the grammar instead of as input symbols.
     */

    if (LEX.start == -1) {
	LEX.start  = GATE.lastloc;
	LEX.length = 0;
    }

    if (ch == -1) {
	complete (p);
       	// MAYBE FAIL.
	TRACE_RETURN_VOID;
    }

    marpatcl_rtc_stack_push (LEX.lexeme, ch);
    LEX.length ++;
    res = marpa_r_alternative (LEX.recce, ch, 1, 1);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 alternative");

    res = marpa_r_earleme_complete (LEX.recce);
    if (res && (marpa_g_error (LEX.g, NULL) != MARPA_ERR_PARSE_EXHAUSTED)) {
	// any error but exhausted is a hard failure
	marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 earleme_complete");
    }
    marpatcl_rtc_lexer_events (p);

    if (marpa_r_is_exhausted (LEX.recce)) {
	complete (p);
	// MAYBE FAIL
	TRACE_RETURN_VOID;
    }

    // Now the gate can update its (character) acceptables too.
    marpatcl_rtc_gate_acceptable (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p (start %d))", p, LEX.start);
    
    if (LEX.start >= 0) {
	complete (p);
	// MAYBE FAIL - TODO Handling ?
    }

    if (LEX.recce) {
	marpa_r_unref (LEX.recce);
	LEX.recce = 0;
    }

    marpatcl_rtc_parser_eof (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p, int keep)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    TRACE_FUNC ("((rtc*) %p, keep %d)", p, keep);
    ASSERT (!LEX.recce, "lexer: left over recognizer");

    // create new recognizer for next match, reset match state
    LEX.recce = marpa_r_new (LEX.g);
    LEX.start = -1;
    marpatcl_rtc_stack_clear (LEX.lexeme);
    res = marpa_r_start_input (LEX.recce);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 start_input");
    marpatcl_rtc_lexer_events (p);
    LEX_P (p);
    
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
	marpatcl_rtc_fail_syscheck (p, PAR.g, n, "g1 terminals_expected");
	marpatcl_rtc_symset_link    (ACCEPT, n);
	marpatcl_rtc_symset_include (ACCEPT, ALWAYS.size, ALWAYS.data);
    }
    
    /* And feed the results into the new lexer recce */
    n = marpatcl_rtc_symset_size (ACCEPT);
    if (n) {
	int k;
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	for (k=0; k < n; k++) {
	    TRACE_TAG (accept, "ACCEPT [%d]: %d = %s",
		       k, TO_ACS (buf[k]),
		       marpatcl_rtc_spec_symname (SPEC->l0, TO_ACS (buf[k]), 0));

	    res = marpa_r_alternative (LEX.recce, TO_ACS (buf [k]), 1, 1);
	    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 alternative/b");
	}

	res = marpa_r_earleme_complete (LEX.recce);
	marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 earleme_complete/b");
	marpatcl_rtc_lexer_events (p);
    }

    // Now the gate can update its acceptables (byte symbols) too.
    marpatcl_rtc_gate_acceptable (p);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

#ifdef CRITCL_TRACER
#define SHOW_SV(sv) \
    {							\
	char* svs = marpatcl_rtc_sv_show (sv, 0);	\
	TRACE_ADD (" sv %p = %s", sv, svs);		\
	FREE (svs);					\
    }
#else
#define SHOW_SV(sv)
#endif

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
    TRACE_RUN (int trees = -1);
    TRACE_FUNC ("((rtc*) %p (lex.recce %p))", p, LEX.recce);
	
    if (!LEX.recce) {
	TRACE_RETURN_VOID;
    }

    /* Find location with lexeme, work backwards from the end of the match */
    latest =  marpa_r_latest_earley_set (LEX.recce);
    redo = 0;
    while (1) {
	TRACE_HEADER (1);
	TRACE_ADD ("rtc %p ?? match %d", p, latest);

	b = marpa_b_new (LEX.recce, latest);
	if (b) break;
	redo ++;
	latest --;
	if (latest < 0) {
	    TRACE_ADD (" fail", 0);
	    TRACE_CLOSER;

	    mismatch (p);
	    // FAIL, aborting. Callers `lexer_enter`, `lexer_eof`.
	    TRACE_RETURN_VOID;
	}
	TRACE_CLOSER;
    }

    TRACE_ADD (" ok, redo %d", redo);
    TRACE_CLOSER;

    /* Get all the valid parses at the location and evaluate them.
     */

    o = marpa_o_new (b);
    ASSERT (o, "Marpa_Order creation failed");
		
    t = marpa_t_new (o);
    ASSERT (t, "Marpa_Tree creation failed");

    discarded = 0;
    marpatcl_rtc_symset_clear (FOUND);
    while (1) {
	status = get_parse (p, t, &token, &rule);
	if (status < 0) {
	    TRACE ("rtc %p parse %d /done", p, status);
	    break;
	}
	
	TRACE_RUN (trees ++);
	TRACE_HEADER (1);
	TRACE_ADD ("rtc %p parse [%d] %d", p, trees, status);
	TRACE_ADD (" lexeme %d (%s) rule %d",
		   token, marpatcl_rtc_spec_symname (SPEC->l0, token, 0), rule);

	/* rule = lexeme rule id
	 * token = ACS symbol id (lexeme or discard)
	 * Range'L0: 256 ... 256+L+D-1
	 * Range'G1: 0 ... L+D-1
	 */
	
	token = TO_TERMINAL (token);

	/* token = G1 terminal id (lexeme) or pseudo-terminal (discard)
	 * Range:   0 ... L+D-1
	 * Lexeme:  0 ... L-1
	 * Discard: L ... L+D-1
	 */

	ASSERT (token < (SPEC->lexemes+SPEC->discards), "pseudo-terminal out of bounds");
	if (token >= SPEC->lexemes) {
	    TRACE_ADD (" discarded", 0);
	    TRACE_CLOSER;

	    discarded ++;
	    continue;
	}

	TRACE_ADD (" terminal %d (%s)",
		   token, marpatcl_rtc_spec_symname (SPEC->g1, token, 0));

	if (marpatcl_rtc_symset_contains (FOUND, token)) {
	    TRACE_ADD (" duplicate, skip", 0);
	    TRACE_CLOSER;

	    continue;
	}
	TRACE_ADD (" save", 0);

	// On first alternative going through to the parser show its progress
	// for the location.
	if (!marpatcl_rtc_symset_size(FOUND)) { PAR_P (p); }

	marpatcl_rtc_symset_include (FOUND, 1, &token);

	// SV deduplication: If the semantic codes are all for a value
	// independent if token/rule ids, a single SV is generated and used in
	// all the symbols. Otherwise an SV is generated for each unique
	// token.  Note that this will not catch a token with multiple rules,
	// for these only the first is captured and forwarded.

	if (!LEX.single_sv || !sv) {
	    sv = get_sv (p, token, rule);
	    svid = marpatcl_rtc_store_add (p, sv);

	    TRACE_ADD (" [%d] :=", svid);
	    SHOW_SV (sv);
	}
	TRACE_CLOSER;

	res = marpa_r_alternative (PARS_R, token, svid, 1);
	marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 alternative");
    }

    marpa_t_unref (t);
    marpa_o_unref (o);
    marpa_r_unref (LEX.recce);
    LEX.recce = 0;

    if (!marpatcl_rtc_symset_size(FOUND) && discarded) {
	// Nothing found. Do not talk to parser. Restart lexing with the
	// current set of acceptable symbols.
	TRACE ("(rtc*) %p restart", p);
	marpatcl_rtc_lexer_acceptable (p, 1);
    } else {
	// Tell parser about number of alternatives given to it (See (%%))
	TRACE ("(rtc*) %p parse #%d (%d..%d/%d)", p, marpatcl_rtc_symset_size(FOUND),
	       LEX_START, LEX_END, LEX_LEN);
	marpatcl_rtc_parser_enter (p, marpatcl_rtc_symset_size(FOUND));
	// MAYBE FAIL
    }

    marpatcl_rtc_gate_redo (p, redo);

    TRACE_RETURN_VOID;
}

static int
get_parse (marpatcl_rtc_p    p,
	   Marpa_Tree        t,
	   marpatcl_rtc_sym* token,
	   marpatcl_rtc_sym* rule)
{
    Marpa_Value v;
    marpatcl_rtc_sym rules[2] = {-1,-1};
    int stop, status, rslot = 0, captoken = 0;

    TRACE_RUN (const char* sts = 0);
    TRACE_RUN (int k = -1);
    TRACE_FUNC ("((rtc*) %p, (Marpa_Tree) %p, (token*) %p, (rule*) %p)",
		p, t, token, rule);

    status = marpa_t_next (t);
    if (status == -1) {
	TRACE_RETURN ("%d", -1);
    }
    marpatcl_rtc_fail_syscheck (p, LEX.g, status, "t_next");

    v = marpa_v_new (t);
    ASSERT (v, "Marpa_Value creation failed");
    //TRACE_DO (_marpa_v_trace (v, 1));
    
    stop = 0;
    while (!stop) {
	Marpa_Step_Type stype = marpa_v_step (v);
	ASSERT (stype >= 0, "Step failure");
	TRACE_RUN (sts = marpatcl_steptype_decode_cstr (stype); k++);
	TRACE_HEADER (1);
	TRACE_ADD ("(rtc*) %p step[%4d] %d %s", p, k, stype, sts ? sts : "<<null>>");

	switch (stype) {
	case MARPA_STEP_INITIAL:
	    /* Nothing to do */
	    break;
	case MARPA_STEP_INACTIVE:
	    /* Done */
	    stop = 1;
	    break;
	case MARPA_STEP_RULE:
	    /* Keep last two rules saved so that we have quick access to
	     * next-to-last later */
	    TRACE_ADD ("  -- [%1d] rule %4d, span (%d-%d), %d := (%d-%d)",
		       rslot,
		       marpa_v_rule(v),
		       marpa_v_rule_start_es_id(v),
		       marpa_v_es_id(v),
		       marpa_v_result(v),
		       marpa_v_arg_0(v),
		       marpa_v_arg_n(v));
	    rules[rslot] = marpa_v_rule(v);
	    rslot = 1 - rslot;
	    break;
	case MARPA_STEP_TOKEN:
	    /* First token instruction has the id of the ACS symbol of the
	     * matched lexeme => terminal symbol derivable from this. */
	    TRACE_ADD (" -- token    %4d, span (%d-%d) <%s>, %d := <%d>",
		   marpa_v_token(v),
		   marpa_v_token_start_es_id(v),
		   marpa_v_es_id(v),
		   marpatcl_rtc_spec_symname (SPEC->l0, marpa_v_token(v), 0),
		   marpa_v_result(v),
		   marpa_v_token_value(v));
	    if (!captoken) {
		TRACE_ADD (" captured", 0);
		*token = marpa_v_token(v);
	    }
	    captoken = 1;
	    break;
	case MARPA_STEP_NULLING_SYMBOL:
	case MARPA_STEP_INTERNAL1:
	case MARPA_STEP_INTERNAL2:
	case MARPA_STEP_TRACE:
	    break;
	default:
	    break;
	}
	TRACE_CLOSER;
    }
    marpa_v_unref (v);

    TRACE ("rtc %p rule[%d] %d", p, rslot, rules[rslot]);
    *rule = rules[rslot];

    TRACE_RETURN ("%d", 0);
}

static void
mismatch (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_failit (p, "lexer");
    /* Caller `complete` has to abort */

    marpa_r_unref (LEX.recce);
    LEX.recce = 0;

    TRACE_RETURN_VOID;
}

static marpatcl_rtc_sv_p
get_sv (marpatcl_rtc_p   p,
	marpatcl_rtc_sym token, /* G1 parser terminal symbol id */
	marpatcl_rtc_sym rule)
{
    int k;
    /* SV is vector of pieces indicated by the codes */
    marpatcl_rtc_sv_p sv;
    /* local cache to avoid duplicate memory for duplicate key codes */
    marpatcl_rtc_sv_p start    = 0;
    marpatcl_rtc_sv_p end      = 0;
    marpatcl_rtc_sv_p length   = 0;
    marpatcl_rtc_sv_p g1start  = 0;
    marpatcl_rtc_sv_p g1end    = 0;
    marpatcl_rtc_sv_p g1length = 0;
    marpatcl_rtc_sv_p lhsname  = 0;
    marpatcl_rtc_sv_p lhsid    = 0;
    marpatcl_rtc_sv_p ruleid   = 0;
    marpatcl_rtc_sv_p value    = 0;

    //TRACE_FUNC ("((rtc*) %p, token %d, rule %d)", p, token, rule);
    sv = marpatcl_rtc_sv_cons_vec (SPEC->l0semantic.size);
    
#define DO(cache,cmd)				\
    if (!(cache)) {				\
	TRACE_ADD (" !%s", #cache);		\
	(cache) = cmd;				\
    };						\
    marpatcl_rtc_sv_vec_push (sv, (cache))
    
#define G1_SNAME(token)  marpatcl_rtc_spec_symname (SPEC->g1, token, NULL)
#define LEX_STR          get_lexeme (p, NULL)

    for (k = 0; k < SPEC->l0semantic.size; k++) {
	switch (SPEC->l0semantic.data[k]) {
	case MARPATCL_SV_START:		DO (start, marpatcl_rtc_sv_cons_int (LEX_START));		break;
	case MARPATCL_SV_END:		DO (end, marpatcl_rtc_sv_cons_int (LEX_END));			break;
	case MARPATCL_SV_LENGTH:	DO (length, marpatcl_rtc_sv_cons_int (LEX_LEN));		break;
	case MARPATCL_SV_G1START:	DO (g1start, marpatcl_rtc_sv_cons_int (-1));			break;//TODO
	case MARPATCL_SV_G1END:		DO (g1end, marpatcl_rtc_sv_cons_int (-1));			break;//TODO
	case MARPATCL_SV_G1LENGTH:	DO (g1length, marpatcl_rtc_sv_cons_int (1));			break;
	case MARPATCL_SV_RULE_NAME:	/* See below, LHS_NAME -- Specific to lexer semantics */
	case MARPATCL_SV_LHS_NAME:	DO (lhsname, marpatcl_rtc_sv_cons_string (G1_SNAME(token), 0));	break;
	case MARPATCL_SV_RULE_ID:	DO (ruleid, marpatcl_rtc_sv_cons_int (rule));			break;
	case MARPATCL_SV_LHS_ID:	DO (lhsid, marpatcl_rtc_sv_cons_int (token));			break;
	case MARPATCL_SV_VALUE:		DO (value, marpatcl_rtc_sv_cons_string (LEX_STR, 1));		break;
	default: ASSERT (0, "Invalid array descriptor key");
	}
    }
    return sv ;//TRACE_RETURN ("%p", sv);
}

static char*
get_lexeme (marpatcl_rtc_p p, int* len)
{
    int   n;
    char* v;

    //TRACE_FUNC ("(rtc %p, (len*) %p)", p, len);
    TRACE_ADD (" get_lexeme", 0);
    
    n = marpatcl_rtc_stack_size (LEX.lexeme);
    v = NALLOC (char, n+1);
    
    if (len) {
	//TRACE ("rtc %p, (len*) %p := %d", p, len, n);
	*len = n;
    }
    
    v[n] = '\0';
    while (n) {
	n--;
	v[n] = marpatcl_rtc_stack_pop (LEX.lexeme);
    }

    return v;//TRACE_RETURN ("'%s'", v);
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
