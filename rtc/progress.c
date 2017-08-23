/* Runtime for C-engine (RTC). Implementation. (Progress reports)
 * - - -- --- ----- -------- ------------- ----------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <progress.h>
#include <rtc_int.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_ON;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void progress (const char*      label,
		      marpatcl_rtc_p   p,
		      Marpa_Recognizer r,
		      Marpa_Grammar    g,
		      int              location)
{
    int count, k, res;
    TRACE_FUNC ("%s((rtc*) %p, (Marpa_Recognizer) %p, (Marpa_Grammar) %p, location %d)",
		label, p, r, g, location);

    count = marpa_r_progress_report_start  (r, location);
    marpatcl_rtc_fail_syscheck (p, g, count, "progress_report_start");
    
    for (k =0; k < count; k++) {
	int                 dot;
	Marpa_Earley_Set_ID origin;
	Marpa_Rule_ID       rule = marpa_r_progress_item (r, &dot, &origin);
	marpatcl_rtc_fail_syscheck (p, g, rule, "progress_report_item");

	// todo: human readable fields ...
	// rule -> rule name data -> lhs, rhs  --- RHS info is not available under RTC yet (*)
	// drule (rule, dot, rhs) -> ddot drule
	// - ddot <- dot (initialization)
	// - dot < 0 :: drule <- F'rule
	// -         :: ddot  <- rhs.length
	// - dot >= rhs.length :: S.a. dot < 0
	// - dot == 0 :: drule <- P'rule
	// - else     :: drule <- R'rule:dot
	// drhs <- (rhs.insert . @ddot).dnames.map (. <.>)
	//
	// line = ______ drule @origin-arg(location) lhs --> drhs
	//
	// implied in the setup instructions ... have to extend the runtime
	// info and have setup fill this when progress is activated on build.
	
	TRACE_HEADER (1);
	TRACE_ADD ("%s[%5d/%5d] R'%d, %d-%d, .%d", label, k, count, rule, origin, location, dot);
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	//TRACE_ADD ("", ... );
	TRACE_CLOSER;
    }
    
    res = marpa_r_progress_report_finish (r);
    marpatcl_rtc_fail_syscheck (p, g, res, "progress_report_finish");
    
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_lexer_progress (marpatcl_rtc_p p)
{
    int loc;
    TRACE_FUNC ("((rtc*) %p)", p);
    
    loc = marpa_r_latest_earley_set (LEX.recce);
    marpatcl_rtc_fail_syscheck (p, LEX.g, loc, "l0 latest-earley-set");
    progress ("lexer", p, LEX.recce, LEX.g, loc);
    
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_progress (marpatcl_rtc_p p)
{
    int loc;
    TRACE_FUNC ("((rtc*) %p)", p);
    
    loc = marpa_r_latest_earley_set (PAR.recce);
    marpatcl_rtc_fail_syscheck (p, PAR.g, loc, "g1 latest-earley-set");
    progress ("parser", p, PAR.recce, PAR.g, loc);
    
    TRACE_RETURN_VOID;
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
