/* Runtime for C-engine (RTC). Implementation. (SV for Tcl)
 * - - -- --- ----- -------- ------------- ----------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_tcl.h>
#include <sem_int.h>
#include <rtc_int.h>
#include <spec.h>
#include <byteset.h>
#include <symset.h>
#include <stack.h>
#include <progress.h>
#include <critcl_trace.h>
#include <critcl_assert.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands, externals, and forward declarations for internals.
 */

extern const char* marpatcl_qcs [256];

#define QCS  marpatcl_qcs
#define TAKE Tcl_IncrRefCount
#define RELE Tcl_DecrRefCount

static Tcl_Obj*
marpatcl_rtc_sv_astcl_do (Tcl_Interp* ip, marpatcl_rtc_sv_p sv, Tcl_Obj* null);

static Tcl_Obj*
marpatcl_rtc_sv_vec_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_vec v, Tcl_Obj* null);

static void
marpatcl_rtc_error (Tcl_Interp* ip, marpatcl_rtc_p p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

extern int
marpatcl_rtc_sv_complete (Tcl_Interp* ip, marpatcl_rtc_sv_p* sv, marpatcl_rtc_p p)
{
    /* This function is called with a pointer to where the SV will be
     * stored. This is necesssary because at the time of the call the SV is
     * not known yet. It is only after the call to 'marpatcl_rtc_eof' below
     * that the SV will be known and stored at the referenced location.
     */

    TRACE_FUNC ("(Interp*) %p, (sv**) %p, (rtc*) %p", ip, sv, p);

    if (!marpatcl_rtc_failed (p)) {
	TRACE ("EOF", 0);
	marpatcl_rtc_eof (p);
    }
    if (!marpatcl_rtc_failed (p)) {
	Tcl_Obj* r;
	TRACE ("SV-AS-TCL (sv*) %p", sv);
	r = marpatcl_rtc_sv_astcl (ip, *sv);
	if (r) {
	    TRACE ("SV OK (Tcl_Obj*) %p", r);
	    Tcl_SetObjResult (ip, r);
	    TRACE_RETURN ("OK", TCL_OK);
	}
	/* Assumes that an error message was left in ip */
    } else {
	TRACE ("FAIL", 0);
	marpatcl_rtc_error (ip, p);
    }
    TRACE_RETURN ("ERROR", TCL_ERROR);
}

extern Tcl_Obj*
marpatcl_rtc_sv_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_p sv)
{
    Tcl_Obj *svres, *null;
    TRACE_FUNC ("(Interp*) %p, (sv*) %p", ip, sv);

    null = Tcl_NewListObj (0,0);
    TAKE (null);
    svres = marpatcl_rtc_sv_astcl_do (ip, sv, null);
    if (svres) TAKE (svres);
    RELE (null);

    TRACE_RETURN ("(Tcl_Obj*) %p", svres);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal helpers
 */

static Tcl_Obj*
marpatcl_rtc_sv_astcl_do (Tcl_Interp* ip, marpatcl_rtc_sv_p sv, Tcl_Obj* null)
{
    if (!sv) {
	return null;
    }

    switch (T_GET) {
    case marpatcl_rtc_sv_type_string:
	return Tcl_NewStringObj (STR,-1);
	/**/
    case marpatcl_rtc_sv_type_int:
	return Tcl_NewIntObj (INT);
	/**/
    case marpatcl_rtc_sv_type_double:
	return Tcl_NewDoubleObj (FLT);
	/**/
    case marpatcl_rtc_sv_type_vec:
	return marpatcl_rtc_sv_vec_astcl (ip, VEC, null);
	/**/
    default:
	/* TODO -- custom data -- quick HACK - null it - work out a better rep later */
	return null;
    }
    ASSERT (0, "Should not happen");
}

static Tcl_Obj*
marpatcl_rtc_sv_vec_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_vec v, Tcl_Obj* null)
{
    int k;
    Tcl_Obj* svres = Tcl_NewListObj (0 /*n*/,0);
    // TODO CHECK: Will using n > 0 pre-alloc an internal array (I suspect not) */

    for (k = 0; k < v->size; k++) {
	Tcl_Obj* el = marpatcl_rtc_sv_astcl_do (ip, v->data[k], null);
	if (!el || (Tcl_ListObjAppendElement(ip, svres, el) != TCL_OK)) {
	    RELE (svres);
	    return 0;
	}
    }

    return svres;
}

static int
compare (const void* a, const void* b)
{
    Marpa_Symbol_ID* as = (Marpa_Symbol_ID*) a;
    Marpa_Symbol_ID* bs = (Marpa_Symbol_ID*) b;
    if (*as < *bs) return -1;
    if (*as > *bs) return 1;
    return 0;
}

static void
error_location (Tcl_DString *ds, marpatcl_rtc_p p)
{
    ASSERT (FAIL.origin, "origin missing");
    Tcl_DStringAppend (ds, "Parsing failed in ", -1);
    Tcl_DStringAppend (ds, FAIL.origin, -1);
    Tcl_DStringAppend (ds, ".", -1);

    TRACE ("GATE LL %d", GATE.lastloc);
    if (GATE.lastloc < 0) {
	Tcl_DStringAppend (ds, " No input", -1);
    } else {
	char buf [30];
	sprintf (buf, "%d", GATE.lastloc);
	Tcl_DStringAppend (ds, " Stopped at offset ", -1);
	Tcl_DStringAppend (ds, buf, -1);
    }
}

static void
error_match_candidate (Tcl_DString *ds, marpatcl_rtc_p p)
{
    // TODO: Properly handle a partially read UTF character at the end
    // IOW instead 'after reading' use 'while x bytes in reading'

    TRACE ("GATE LC %d|%d", GATE.lastchar, MARPATCL_RTC_BSMAX);
    TRACE ("LEXE # %d", marpatcl_rtc_stack_size (LEX.lexeme));

    if (marpatcl_rtc_stack_size (LEX.lexeme)) {
	// ATTENTION: This access to LEX.lexeme is destructive.
        Tcl_DStringAppend (ds, " after reading '", -1);
	while (marpatcl_rtc_stack_size (LEX.lexeme)) {
	    char c = marpatcl_rtc_stack_pop (LEX.lexeme);
	    Tcl_DStringAppend (ds, QCS [c], -1);
	}
	if (GATE.lastchar >= 0) {
	    ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	    Tcl_DStringAppend (ds, QCS [GATE.lastchar], -1);
	}
	Tcl_DStringAppend (ds, "'", -1);
    } else if (GATE.lastchar >= 0) {
	ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	Tcl_DStringAppend (ds, " after reading '", -1);
	Tcl_DStringAppend (ds, QCS [GATE.lastchar], -1);
	Tcl_DStringAppend (ds, "'", -1);
    }
    Tcl_DStringAppend (ds, ".", -1);
}

static void
error_lex_accept (Tcl_DString *ds, marpatcl_rtc_p p)
{
    TRACE ("GATE #acc %d", marpatcl_rtc_byteset_size (&GATE.acceptable));
    if (marpatcl_rtc_byteset_size (&GATE.acceptable)) {
	int k;
	Tcl_DStringAppend (ds, " Expected any character in [", -1);

	for (k=0; k < MARPATCL_RTC_BSMAX; k++) {
	    if (!marpatcl_rtc_byteset_contains (&GATE.acceptable, k)) continue;
	    Tcl_DStringAppend (ds, QCS [k], -1);
	}
	Tcl_DStringAppend (ds, "]", -1);
    }
}

static void
error_parse_accept (Tcl_DString *ds, marpatcl_rtc_p p)
{
    int chars = marpatcl_rtc_byteset_size (&GATE.acceptable);
    //char buf [30];

    TRACE ("LEXE #acc %d", marpatcl_rtc_symset_size (&LEX.acceptable));
    if (marpatcl_rtc_symset_size (&LEX.acceptable)) {
	int           k, n = marpatcl_rtc_symset_size  (&LEX.acceptable);
	Marpa_Symbol_ID* d = marpatcl_rtc_symset_dense (&LEX.acceptable);
	const char* sep = "";

	if (chars) {
	    Tcl_DStringAppend (ds, " while looking for any of (", -1);
	} else {
	    Tcl_DStringAppend (ds, " Looking for any of (", -1);
	}
	
	// ATTENTION: We are destructive on the symset
	// //
	// First conversion from G1 syms to L0 ACS to String ids.
	// Reuses symset space, destroys it.
	for (k=0; k < n; k++) {
	    d [k] = SPEC->l0->symbols.data [d [k] + 256];
	}
	// Second conversion from string ids to strings, after sorting the
	// ids. Based on the fact that the strings are stored sorted by the
	// generator (export/rtc-critcl.tcl), causing the sort order of the
	// ids to match the lexicographic order.
	qsort (d, n, sizeof (Marpa_Symbol_ID), compare);
	for (k=0; k < n; k++) {
	    Marpa_Symbol_ID sym = d [k];
	    const char* sname = marpatcl_rtc_spec_string (SPEC->l0->sname, sym, 0);
	    TRACE ("LEX? %4d '%s'", sym, sname);
	    //sprintf (buf, "(%d) ", sym);
	    Tcl_DStringAppend (ds, sep, -1);
	    //Tcl_DStringAppend (ds, buf, -1);
	    Tcl_DStringAppend (ds, sname, -1);
	    sep = ", ";
	}

	Tcl_DStringAppend (ds, ").", -1);
    } else if (chars) {
	Tcl_DStringAppend (ds, ".", -1);
    }
}

static void
error_print (void* cdata, const char* string)
{
    Tcl_DString* ds = (Tcl_DString*) cdata;
    Tcl_DStringAppend (ds, string, -1);
}

static void
error_l0_progress (Tcl_DString *ds, marpatcl_rtc_p p)
{
    // Skip progress report if there is no recognizer to query
    if (!LEX.recce) return;

    Tcl_DStringAppend (ds, "\nL0 Report:\n", -1);
    // We need the rule_data for the/a readable progress report.  Generate it
    // if it was not made during regular setup (with progress tracing on).
    // That is the normal case, i.e. generate just for the error message.
    if (!LRD) {
	LRD = marpatcl_rtc_spec_setup_rd (SPEC->l0);
    }
    marpatcl_rtc_progress (error_print, ds,
			   p, SPEC->l0, LRD, LEX.recce, LEX.g,
			   marpa_r_latest_earley_set (LEX.recce));
}

static void
marpatcl_rtc_error (Tcl_Interp* ip, marpatcl_rtc_p p)
{
    // *** ATTENTION ***
    //
    // While the Tcl engine uses chars and char offsets RTC uses bytes and
    // byte offsets.  For testing this does not matter, operating solely in
    // the ASCII domain, where these things are identical.
    //
    // TODO: Extend GATE to mark and count char offsets (track char starts through the bit patterns of the utf bytes)
    // TODO: Extend GATE to remember the bytes of a (partially) read character.

    Tcl_DString ds;

    TRACE_FUNC ("((rtc*) %p)", p);

    Tcl_DStringInit       (&ds);
    error_location        (&ds, p);
    error_match_candidate (&ds, p);
    error_lex_accept      (&ds, p);
    error_parse_accept    (&ds, p);
    error_l0_progress     (&ds, p);

    Tcl_SetErrorCode  (ip, "SYNTAX", NULL);
    Tcl_DStringResult (ip, &ds);
    Tcl_DStringFree (&ds);

#if 0
    // TODO: char mismatch information

    if {[dict exists $context l0 char] &&
	[dict exists $context l0 csym]} {
	set ch [char quote cstring [dict get $context l0 char]]
	append msg "\nMismatch:\n'$ch' => ([dict get $context l0 csym]) ni"

	    // acceptsym, map -- generate from GATE.acceptable

	if {[dict exists $context l0 acceptmap]} {
  	dict for {asym aname} [dict get $context l0 acceptmap] {
  	    append msg "\n [format %4d $asym]: $aname"
  	}
      } elseif {[dict exists $context l0 acceptsym]} {
  	append msg " (dict exists $context l0 acceptsym])"
      }
  }
#endif
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
