/* Runtime for C-engine (RTC). Implementation. (Engine: Parsing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <parser.h>
#include <rtc_int.h>
#include <sem_int.h>
#include <symset.h>
#include <events.h>
#include <lexer.h>
#include <progress.h>
#include <marpatcl_steptype.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void              complete  (marpatcl_rtc_p p);
static marpatcl_rtc_sv_p get_sv    (marpatcl_rtc_p      p,
				    marpatcl_rtc_sv_vec rhs,
				    Marpa_Value         v,
				    marpatcl_rtc_sym    rule);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_parser_init (marpatcl_rtc_p p)
{
    int res;
    TRACE_FUNC ("((rtc*) %p)", p);

    PAR.g = marpa_g_new (CONF);
    (void) marpa_g_force_valued (PAR.g);
    PRD   = marpatcl_rtc_spec_setup (PAR.g, SPEC->g1, TRACE_TAG_VAR (parser_progress));
    res = marpa_g_precompute (PAR.g);
    marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 precompute");
    marpatcl_rtc_parser_events (p);

    PAR.recce = marpa_r_new (PAR.g);
    TRACE ("new (recce) %p, (grammar) %p", PAR.recce, PAR.g);

    res = marpa_r_start_input (PAR.recce);
    marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 start_input");
    marpatcl_rtc_parser_events (p);

    marpatcl_rtc_lexer_acceptable (p, 0);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE ("del (recce) %p, (grammar) %p", PAR.recce, PAR.g);

    marpa_g_unref (PAR.g);
    PAR.g = 0;
    if (PAR.recce) marpa_r_unref (PAR.recce);
    PAR.recce = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_enter (marpatcl_rtc_p p)
{
    int res, found = marpatcl_rtc_symset_size (&LEX.found);
    TRACE_FUNC ("(rtc %p, found %d)", p, found);

    if (!found) {
	complete (p);
	TRACE_RETURN_VOID;
    }

    /*
     * It is time to enter the token alternatives. The data is available in
     * LEX.found (terminals) and LEX.m_sv (SV ids).
     *
     * __ATTENTION__ We make here use of the fact that the `dense` array of
     * symsets contains the terminals in order of inclusion == order of them
     * found, and that this matches the order of the ids in the m_sv stack.
     *
     * Also, that both set and stack will have the same size.
     */

    int k, nsv;
    int*             svids = marpatcl_rtc_stack_data (LEX.m_sv, &nsv);
    Marpa_Symbol_ID* syms  = marpatcl_rtc_symset_dense (&LEX.found);

    ASSERT (found == nsv, "Expected matching size for set of terminals and stack of SV ids");

    for (k=0; k < found; k++) {
	int svid     = svids [k];
	int terminal = syms  [k];

	res = marpa_r_alternative (PAR.recce, terminal, svid, 1);
	marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 alternative");
    }

    res = marpa_r_earleme_complete (PAR.recce);
    if (res && (marpa_g_error (PAR.g, NULL) != MARPA_ERR_PARSE_EXHAUSTED)) {
	// any error but exhausted is a hard failure
	marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 earleme_complete");
    }
    marpatcl_rtc_parser_events (p);

    if (marpa_r_is_exhausted (PAR.recce)) {
	complete (p);
	// MAYBE FAIL
	TRACE_RETURN_VOID;
    }

    marpatcl_rtc_lexer_acceptable (p, 0);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    complete (p);
    // Forward to overall RTC

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_reset (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    if (PAR.recce) marpa_r_unref (PAR.recce);

    PAR.recce = marpa_r_new (PAR.g);
    TRACE ("new (recce) %p, (grammar) %p", PAR.recce, PAR.g);

    int res = marpa_r_start_input (PAR.recce);
    marpatcl_rtc_fail_syscheck (p, PAR.g, res, "g1 start_input");
    marpatcl_rtc_parser_events (p);

    marpatcl_rtc_lexer_reset (p);
    marpatcl_rtc_lexer_acceptable (p, 0);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

#ifdef CRITCL_TRACER
#define SHOW_SV(sv) {					\
	char* svs = marpatcl_rtc_sv_show (sv, 0);	\
	TRACE_ADD (" sv %p = %s", sv, svs);		\
	FREE (svs);					\
    }

#define SHOW_MASK(mlen,mv) {		     \
	int j ; const char* sep = " M(";     \
	for (j =0; j < mlen; j++) {	     \
	    TRACE_ADD ("%s%d", sep, mv[j]);  \
	    sep = ",";			     \
	}				     \
        TRACE_ADD (")", 0);		     \
    }
#else
#define SHOW_SV(sv)
#define SHOW_MASK(mlen,mv)
#endif


void
complete (marpatcl_rtc_p p)
{
    Marpa_Tree   t;    marpatcl_rtc_sv_p sv;
    Marpa_Order  o;    marpatcl_rtc_sva  es;  /* evaluation stack */
    Marpa_Bocage b;    marpatcl_rtc_sva  rhs; /* rule rhs scratch pad */
    Marpa_Value  v;
    marpatcl_rtc_sym* mv;
    int               mlen, latest;

    TRACE_FUNC ("((rtc*) %p (par.recce %p))", p, PAR.recce);

    if (!PAR.recce) {
	TRACE_RETURN_VOID;
    }

    PAR_P (p);

    /* Find location with parse, work backwards from the end of the token-sequence */
    latest = marpa_r_latest_earley_set (PAR.recce);
    while (1) {
	TRACE_HEADER (1);
	TRACE_ADD ("rtc %p ?? match %d", p, latest);

	b = marpa_b_new (PAR.recce, latest);
	if (b) break;
	latest --;
	if (latest < 0) {
	    TRACE_ADD (" fail", 0);
	    TRACE_CLOSER;

	    marpatcl_rtc_failit (p, "parser");

	    TRACE ("del (recce) %p, (grammar) %p", PAR.recce, PAR.g);
	    marpa_r_unref (PAR.recce);
	    PAR.recce = 0;

	    TRACE_RETURN_VOID;
	}

	TRACE_CLOSER;
    }

    TRACE_ADD (" ok", 0);
    TRACE_CLOSER;

    /* Get all the valid parses at the location and evaluate them.
     */

    o = marpa_o_new (b);
    ASSERT (o, "Marpa_Order creation failed");

    t = marpa_t_new (o);
    ASSERT (t, "Marpa_Tree creation failed");

    marpatcl_rtc_sva_init (&es,  10, 0);
    marpatcl_rtc_sva_init (&rhs, 10, 0);

    while (1) {
	/* Per parse tree */
	int rid, stop, status = marpa_t_next (t);

	TRACE_RUN (const char* sts = 0);
	TRACE_RUN (int k = -1);
	TRACE_HEADER (1);
	TRACE_ADD ("parse ((rtc*) %p), tree %p = status %d", p, t, status);

	if (status == -1) {
	    TRACE_ADD (" /done", 0);
	    TRACE_CLOSER;
	    break;
	}
	marpatcl_rtc_fail_syscheck (p, PAR.g, status, "t_next");

	/* Execute semantics ... */
	v = marpa_v_new (t);
	ASSERT (v, "Marpa_Value creation failed");
	//TRACE_DO (_marpa_v_trace (v, 1));
	TRACE_ADD (" value %p", v);
	TRACE_CLOSER;

	stop = 0;
	while (!stop) {
	    /* Per instruction */
	    Marpa_Step_Type stype = marpa_v_step (v);
	    ASSERT (stype >= 0, "Step failure");

	    TRACE_RUN (sts = marpatcl_steptype_decode_cstr (stype); k++);
	    TRACE_HEADER (1);
	    TRACE_ADD ("(rtc*) %p, step[%4d] %d %s", p, k, stype, sts ? sts : "<<null>>");
	    switch (stype) {
	    case MARPA_STEP_INITIAL:
		/* nothing to do */
		break;
	    case MARPA_STEP_INACTIVE:
		/* done */
		stop = 1;
		break;
	    case MARPA_STEP_RULE:
		// marpa_v_arg_0(v)         - origin stack slot for 1st rhs child
		// marpa_v_arg_n(v)         - ditto for last rhs child
		// marpa_v_rule(v)          - rule id
		// marpa_v_result(v)        - destination stack slot
		// marpa_v_rule_start_es_id - G1 start location of rule
		// marpa_v_es_id            - G1 end location of rule
		/* rule
		 * - get values from stack (reduce vector)
		 * - get per-rule masking - filter vector
		 * - get per-rule semantic - run on vector
		 */
		TRACE_ADD ("    -- rule  %4d, span (%d-%d), %d := (%d-%d)",
			   marpa_v_rule(v),
			   marpa_v_rule_start_es_id(v),
			   marpa_v_es_id(v),
			   marpa_v_result(v),
			   marpa_v_arg_0(v),
			   marpa_v_arg_n(v));

		marpatcl_rtc_sva_copy (&rhs, &es,
				       marpa_v_arg_0(v), marpa_v_arg_n(v));
		rid = marpa_v_rule(v);

		/* get mask, filter */
		mv = marpatcl_rtc_spec_g1decode (&SPEC->g1mask, rid, &mlen);
		if (mlen) {
		    SHOW_MASK (mlen, mv);
		    marpatcl_rtc_sva_filter (&rhs, mlen, mv);
		}

		/* get semantics, eval */
		sv = get_sv (p, &rhs, v, rid);
		SHOW_SV (sv);
		marpatcl_rtc_sva_set_trunc (&es, marpa_v_result(v), sv);
		marpatcl_rtc_sva_clear (&rhs);
		break;
	    case MARPA_STEP_TOKEN:
		// marpa_v_token(v)       - token id - terminal symbol id
		// marpa_v_result(v)      - destination stack slot
		// marpa_v_token_value(v) - token's semantic value
		/* token - push on eval stack */
		TRACE_ADD ("   -- token %4d, span (%d-%d), <%s> %d := <%d>",
			   marpa_v_token(v),
			   marpa_v_token_start_es_id(v),
			   marpa_v_es_id(v),
			   marpatcl_rtc_spec_symname (SPEC->g1, marpa_v_token(v), 0),
			   marpa_v_result(v),
			   marpa_v_token_value(v));

		sv = marpatcl_rtc_store_get(p, marpa_v_token_value(v));
		SHOW_SV (sv);
		marpatcl_rtc_sva_set_fill (&es, marpa_v_result(v), sv);
		break;
	    case MARPA_STEP_NULLING_SYMBOL:
		// marpa_v_symbol(v) - symbol id
		// marpa_v_result(v) - destination stack slot
		/* null symbol - push null on eval stack
		 * -- might have semantics ?
		 */
		TRACE_ADD (" -- sym   %4d, span (%d-%d), <%s> %d := NULL",
			   marpa_v_symbol(v),
			   marpa_v_token_start_es_id(v),
			   marpa_v_es_id(v),
			   marpatcl_rtc_spec_symname (SPEC->g1, marpa_v_symbol(v), 0),
			   marpa_v_result(v));

		marpatcl_rtc_sva_set_fill (&es, marpa_v_result(v), NULL);
		break;
	    case MARPA_STEP_INTERNAL1:
	    case MARPA_STEP_INTERNAL2:
	    case MARPA_STEP_TRACE:
		/* internal, ignore, except under tracing */
		break;
	    default:
		break;
	    }
	    TRACE_CLOSER;
	} /* tree done */
	marpa_v_unref (v);

	// Get final value of the valuator from the stack
	// TODO: assert that we have one value (size == 1).
	sv = marpatcl_rtc_sva_get (&es, 0);
	TRACE_HEADER (1);
	TRACE_ADD ("tree :=", 0);
	SHOW_SV (sv);
	TRACE_CLOSER;

	// Invoke user-supplied callback for handling the SVs
	p->result (p->rcdata, sv);

	marpatcl_rtc_sva_clear (&es);
    }

    marpatcl_rtc_sva_free (&rhs);
    marpatcl_rtc_sva_free (&es);
    marpa_t_unref (t);
    marpa_o_unref (o);

    // From here on only an eof signal is allowed to come from the input. Note
    // however that we cannot assume that there is no more input at all. The
    // G1 end marker may still be followed by L0 discards. As these do not
    // make it to the parser's enter.
    marpatcl_rtc_lexer_acceptable (p, 0);

    TRACE ("del (recce) %p, (grammar) %p", PAR.recce, PAR.g);
    marpa_r_unref (PAR.recce);
    PAR.recce = 0;

    TRACE_RETURN_VOID;
}

static marpatcl_rtc_sv_p
get_sv (marpatcl_rtc_p      p,
	marpatcl_rtc_sv_vec rhs,
	Marpa_Value         v,
	marpatcl_rtc_sym    rule)
{
    int k, klen;
    marpatcl_rtc_sym* kv = marpatcl_rtc_spec_g1decode (&SPEC->g1semantic, rule, &klen);
    /* SV is vector of pieces indicated by the codes */
    marpatcl_rtc_sv_p sv = marpatcl_rtc_sv_cons_vec (klen);
    /* local cache to avoid duplicate memory for duplicate key codes */
    marpatcl_rtc_sv_p start    = 0;
    marpatcl_rtc_sv_p end      = 0;
    marpatcl_rtc_sv_p length   = 0;
    marpatcl_rtc_sv_p g1start  = 0;
    marpatcl_rtc_sv_p g1end    = 0;
    marpatcl_rtc_sv_p g1length = 0;
    marpatcl_rtc_sv_p lhsname  = 0;
    marpatcl_rtc_sv_p lhsid    = 0;
    marpatcl_rtc_sv_p rulename = 0;
    marpatcl_rtc_sv_p ruleid   = 0;
    marpatcl_rtc_sv_p value    = 0;

#define DO(cache,cmd)				\
    if (!(cache)) {				\
	TRACE_ADD (" !%s", #cache);		\
	(cache) = cmd;				\
    };						\
    marpatcl_rtc_sv_vec_push (sv, (cache))

#define G1_SNAME(token) marpatcl_rtc_spec_symname (SPEC->g1, token, NULL)
#define G1_RNAME(rule)  marpatcl_rtc_spec_rulename (SPEC->g1, rule, NULL)
#define TOKEN           marpatcl_rtc_spec_g1map (&SPEC->g1->lhs, rule)
#define G1_START        marpa_v_rule_start_es_id(v)
#define G1_END          marpa_v_es_id(v)
#define G1_LEN          (G1_END - G1_START + 1)

    int LEX_LEN = -1; // TODO remove fake

    for (k = 0; k < klen; k++) {
	switch (kv [k]) {
	case MARPATCL_SV_START:		DO (start, marpatcl_rtc_sv_cons_int (LEX.start));		break;//TODO lex location for parse element?
	case MARPATCL_SV_END:		DO (end, marpatcl_rtc_sv_cons_int (LEX.start));			break;//TODO lex location for parse element?
	case MARPATCL_SV_LENGTH:	DO (length, marpatcl_rtc_sv_cons_int (LEX_LEN));		break;//TODO lex length for parse element?
	case MARPATCL_SV_G1START:	DO (g1start, marpatcl_rtc_sv_cons_int (G1_START));		break;
	case MARPATCL_SV_G1END:		DO (g1end, marpatcl_rtc_sv_cons_int (G1_END));			break;
	case MARPATCL_SV_G1LENGTH:	DO (g1length, marpatcl_rtc_sv_cons_int (G1_LEN));		break;
	case MARPATCL_SV_RULE_NAME:	DO (rulename, marpatcl_rtc_sv_cons_string (G1_RNAME(rule), 0));	break;
	case MARPATCL_SV_LHS_NAME:	DO (lhsname, marpatcl_rtc_sv_cons_string (G1_SNAME(TOKEN), 0));	break;
	case MARPATCL_SV_RULE_ID:	DO (ruleid, marpatcl_rtc_sv_cons_int (rule));			break;
	case MARPATCL_SV_LHS_ID:	DO (lhsid, marpatcl_rtc_sv_cons_int (TOKEN));			break;
	case MARPATCL_SV_VALUE:		DO (value, marpatcl_rtc_sv_cons_vec_cp (rhs));			break;

	case  MARPATCL_SV_A_FIRST:
	    /* Special action ::first */
	    marpatcl_rtc_sv_destroy_i (sv);
	    return marpatcl_rtc_sva_get (rhs, 0);

	default: ASSERT (0, "Invalid array descriptor key");
	}
    }
    return sv;
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
