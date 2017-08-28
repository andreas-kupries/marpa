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

TRACE_ON; // Always - See progress.h for the actual controlling flags.

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static marpatcl_rtc_sym
decode_rule (marpatcl_rtc_rules*  g,
	     marpatcl_rtc_stack_p rd,
	     int                  rule,
	     marpatcl_rtc_stack_p rhs,
	     char**               insname)
{
    static char* iname[] = {
	"setup",	"done",		"priority ",
	"prioshort",	"quant*   ",	"quant+   ",
	"quant*s  ",	"quant+s  ",	"brange   "
    };
    marpatcl_rtc_sym* ins;
    marpatcl_rtc_sym cmd, detail, proper, sep, start, stop, lhs;
    int pc   = marpatcl_rtc_stack_get (rd, 2*rule);
    int rarg = marpatcl_rtc_stack_get (rd, 2*rule + 1);
    int k;
    
    ins = g->rcode + pc;
    MARPATCL_RCMD_UNBOX (ins[0], cmd, detail);
    *insname = iname[cmd];
    switch (cmd) {
    case MARPATCL_RC_SETUP: 
    case MARPATCL_RC_DONE:
	ASSERT (0, "Bad rule data, no rule instruction");
	break;
    case MARPATCL_RC_PRIO:
	marpatcl_rtc_stack_clear (rhs);
	for (k=0; k < detail; k++) { marpatcl_rtc_stack_push (rhs, ins[2+k]); }
	return ins[1];
	
    case MARPATCL_RC_PRIS:
	marpatcl_rtc_stack_clear (rhs);
	for (k=0; k < detail; k++) { marpatcl_rtc_stack_push (rhs, ins[1+k]); }
	// Back to the PRIO specifying the LHS (rarg = pc for this PRIO)
	ins = g->rcode + rarg;
	return ins[1];

    case MARPATCL_RC_QUN:
    case MARPATCL_RC_QUP:
    case MARPATCL_RC_QUNS:
    case MARPATCL_RC_QUPS:
	marpatcl_rtc_stack_clear (rhs);
	marpatcl_rtc_stack_push (rhs, ins[1]);
	return detail;

    case MARPATCL_RC_BRAN:
	// rarg = rhs byte in the range.
	marpatcl_rtc_stack_clear (rhs);
	marpatcl_rtc_stack_push (rhs, rarg);
	return detail;
    }

    return lhs;
}

static void
progress (const char*          label,   // string
	  marpatcl_rtc_p       p,       // Overall RTC state
	  marpatcl_rtc_rules*  spec,    // Relevant grammar spec (rcode, symbols, ...)
	  marpatcl_rtc_stack_p rd,      // rd :: map (rule id --> PC (into spec->rcode))
	  Marpa_Recognizer     r,       // Recognizer and
	  Marpa_Grammar        g,       // Grammar under inspection.
	  int                  location)
{
#define NAME(sym) marpatcl_rtc_spec_symname (spec, sym, 0)

    int count, k, res, maxdot;
    marpatcl_rtc_stack_p rhs;
    marpatcl_rtc_sym     lhs;
    marpatcl_rtc_sym cmd, detail;
    char tmp [100];
    char fmt [60];
    TRACE_FUNC ("%s((rtc*) %p, (spec*) %p, (stack*) rd %p, (Marpa_Recognizer) %p, (Marpa_Grammar) %p, location %d)",
		label, p, spec, rd, r, g, location);
    TRACE ("#symbols %d", spec->symbols.size);
    TRACE ("#rules   %d", spec->rules.size);

    // Compute width of column with flag and rule information, from max length
    // of dot positions and max length of rule ids.
    MARPATCL_RCMD_UNBOX (spec->rcode[0], cmd, detail);
    ASSERT (cmd == MARPATCL_RC_SETUP, "Missing SETUP at beginning of G instructions");
    // detail = max rhs, max dot position = detail+1
    sprintf (tmp, "______ X'%d:%d", spec->rules.size, detail+1);
    sprintf (fmt, " %%-%ds", (int) strlen (tmp));
    //TRACE ("col format `%s` for `%s`", fmt, tmp);
    
    count = marpa_r_progress_report_start  (r, location);
    marpatcl_rtc_fail_syscheck (p, g, count, "progress_report_start");

    rhs = marpatcl_rtc_stack_cons (-1);

    for (k =0; k < count; k++) {
	int                 j, dot, ddot, rhsl;
	int*                rv;
	Marpa_Earley_Set_ID origin;
	Marpa_Rule_ID       rule = marpa_r_progress_item (r, &dot, &origin);
	char prefix;
	char suffix [40] = { 0 };
	char* iname;
	marpatcl_rtc_fail_syscheck (p, g, rule, "progress_report_item");

	lhs = decode_rule (spec, rd, rule, rhs, &iname);
	rv  = marpatcl_rtc_stack_data (rhs, &rhsl);
	// lhs - id, rhs - stack of ids

	ddot = dot;
	if ((dot < 0) || (dot >= rhsl)) {
	    prefix = 'F';
	    ddot = rhsl;
	} else if (dot == 0) {
	    prefix = 'P';
	} else {
	    prefix = 'R';
	    sprintf (suffix, ":%d", dot);
	}
	
	TRACE_HEADER (1);
	TRACE_ADD ("%s[%5d/%5d]", label, k, count);
	//TRACE_ADD (" R'%d, %d-%d, .%d", rule, origin, location, dot);
	TRACE_RUN (sprintf (tmp, "______ %c'%d%s", prefix, rule, suffix));
	TRACE_ADD (fmt, tmp);
	TRACE_ADD (" (%5d-%5d)", origin, location);
	TRACE_ADD (" %s %d:<%s> ::= ", iname, lhs, NAME (lhs));
	for (j = 0 ; j < ddot ; j++) { TRACE_ADD (" %d:<%s>", rv[j], NAME (rv[j])); }
	TRACE_ADD (" %s", ".");
	for (      ; j < rhsl ; j++) { TRACE_ADD (" %d:<%s>", rv[j], NAME (rv[j])); }
	//TRACE_ADD ("", ... );
	TRACE_CLOSER;
    }
    
    res = marpa_r_progress_report_finish (r);
    marpatcl_rtc_fail_syscheck (p, g, res, "progress_report_finish");
    marpatcl_rtc_stack_destroy (rhs);
    
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
    progress ("lexer", p, SPEC->l0, LRD, LEX.recce, LEX.g, loc);
    
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_progress (marpatcl_rtc_p p)
{
    int loc;
    TRACE_FUNC ("((rtc*) %p)", p);
    
    loc = marpa_r_latest_earley_set (PAR.recce);
    marpatcl_rtc_fail_syscheck (p, PAR.g, loc, "g1 latest-earley-set");
    progress ("parser", p, SPEC->g1, PRD, PAR.recce, PAR.g, loc);
    
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
