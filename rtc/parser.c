/* Runtime for C-engine (RTC). Implementation. (Engine: Parsing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <parser.h>
#include <rtc_int.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void complete  (marpatcl_rtc_p p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_parser_init (marpatcl_rtc_p p)
{
    PAR.g = marpa_g_new (CONF);
    marpatcl_rtc_spec_setup (PAR.g, SPEC->g1);
    PAR.recce = marpa_r_new (PAR.g);
}

void
marpatcl_rtc_parser_free (marpatcl_rtc_p p)
{
    marpa_g_unref (PAR.g);
    marpa_r_unref (PAR.recce);
}

void
marpatcl_rtc_parser_enter (marpatcl_rtc_p p, int found)
{
    if (!found) {
	complete (p); // TODO
	return;
    }

    // The token alternatives have already been entered, as part of
    // lexer.c/complete() before it called this function.

    res = marpa_r_earleme_complete (PAR.recce);
    if (res != MARPA_ERR_PARSE_EXHAUSTED) {
	// any error but exhausted is a hard failure
	ASSERT (res >= 0, "parser earleme-complete");
    }
    // TODO marpatcl_process_events (p->g1, HANDLER, CDATA);

    if (marpa_r_is_exhausted (PAR.recce)) {
	complete (p);
	// MAYBE FAIL
	return;
    }

    marpa_rtc_lexer_acceptable (p, 0);
}

void
marpatcl_rtc_parser_eof (marpatcl_rtc_p p)
{
    // TODO parser eof

    complete (p);

    // Forward to overall RTC

    
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

void
complete (marpatcl_rtc_p p)
{
    Marpa_Tree   t;
    Marpa_Order  o;
    Marpa_Bocage b;
    Marpa_Value  v;
    int latest;
    if (!PAR.recce) return;

    /* Find location with parse, work backwards from the end of the match */
    latest = marpa_r_latest_earley_set (PAR.recce);

    while (1) {
	b = marpa_b_new (LEX.recce, latest);
	if (b) break;
	latest --;
	if (latest < 0) {
	    marpatcl_rtc_failit (p, "parser");

	    marpa_r_unref (PAR.recce);
	    PAR.recce = 0;
	    return;
	}
    }

    // TODO: execute all trees in the found forest.
    // 

    /* Get all the valid parses at the location and evaluate them.
     */

    o = marpa_o_new (b);
    t = marpa_t_new (o);

    // masking information, on a per-rule basic
    
    while (1) {
	int stop, status = marpa_t_next (t);
	if (status == -1) break;
	ASSERT (status >= 0, "lexer tree failure");

	v = marpa_v_new (t);
	while (!stop) {
	    /* Execute semantics ... */
	    Marpa_Step_Type stype = marpa_v_step (v);
	    switch (stype) {
	    case MARPA_STEP_INITIAL:
		/* nothing to do */
		break;
	    case MARPA_STEP_INACTIVE:
		/* done */
		stop = 1;
		break;
	    case MARPA_STEP_RULE:
		// TODO: rule, find semantics, run -- 1st: array key codes
		break;
	    case MARPA_STEP_TOKEN:
		// TODO token - push on eval stack */
		break;
	    case MARPA_STEP_NULLING_SYMBOL:
		// TODO null symbol - find semantcs, run */
		break;
	    case MARPA_STEP_INTERNAL1:
	    case MARPA_STEP_INTERNAl2:
	    case MARPA_STEP_TRACE:
		/* internal, ignore, except under tracing */
		break;
	    }
	}
    }

    marpa_t_unref (t);
    marpa_o_unref (o);
    marpa_r_unref (PAR.recce);
    PAR.recce = 0;
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
