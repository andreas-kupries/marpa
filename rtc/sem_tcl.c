/* Runtime for C-engine (RTC). Implementation. (SV for Tcl)
 * - - -- --- ----- -------- ------------- ----------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_tcl.h>
#include <sem_int.h>
#include <rtc_int.h>
#include <byteset.h>
#include <symset.h>
#include <stack.h>
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

static Tcl_Obj*
marpatcl_rtc_error (marpatcl_rtc_p p);

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
	//Tcl_SetObjResult (ip, marpatcl_rtc_error (p));
	//Tcl_SetErrorCode (ip, "SYNTAX", NULL);
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

static Tcl_Obj*
marpatcl_rtc_error (marpatcl_rtc_p p)
{
    // *** ATTENTION ***
    //
    // While the Tcl engine uses chars and char offsets RTC uses bytes and
    // byte offsets.  For testing this does not matter, operating solely in
    // the ASCII domain, where these things are identical.
    //
    // TODO: Extend GATE to mark and count char offsets (track char starts through the bit patterns of the utf bytes)
    // TODO: Extend GATE to remember the bytes of a (partially) read character.

    Tcl_Obj* msg = 0;
#if 0
    int chars = 0;
    char* lexeme;

    TRACE_FUNC ("((rtc*) %p)", p);
    
    msg = Tcl_ObjPrintf ("Parsing failed in %s.", FAIL.origin);
    TAKE (msg);

    TRACE ("GATE LL %d", GATE.lastloc);
    if (GATE.lastloc < 0) {
	Tcl_AppendPrintfToObj (msg, " No input");
    } else {
	Tcl_AppendPrintfToObj (msg, " Stopped at offset %d", GATE.lastloc);
    }

    // TODO: Properly handle a partially read UTF character at the end
    // IOW instead 'after reading' use 'while x bytes in reading'

    TRACE ("GATE LC %d|%d", GATE.lastchar, MARPATCL_RTC_BSMAX);
    TRACE ("LEXE # %d", marpatcl_rtc_stack_size (LEX.lexeme));
    
    if (marpatcl_rtc_stack_size (LEX.lexeme)) {
	// ATTENTION: This access to LEX.lexeme is destructive.
	Tcl_AppendPrintfToObj (msg, " after reading '");
	while (marpatcl_rtc_stack_size (LEX.lexeme)) {
	    char c = marpatcl_rtc_stack_pop (LEX.lexeme);
	    Tcl_AppendPrintfToObj (msg, "%s", QCS [c]);
	}
	if (GATE.lastchar >= 0) {
	    ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	    Tcl_AppendPrintfToObj (msg, "%s", QCS [GATE.lastchar]);
	}
	Tcl_AppendPrintfToObj (msg, "'");
    } else if (GATE.lastchar >= 0) {
	ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	Tcl_AppendPrintfToObj (msg, " after reading '%s'", QCS [GATE.lastchar]);
    }
    Tcl_AppendPrintfToObj (msg, ".");

    TRACE ("GATE #acc %d", marpatcl_rtc_byteset_size (&GATE.acceptable));
    if (marpatcl_rtc_byteset_size (&GATE.acceptable)) {
	int k;
	Tcl_AppendPrintfToObj (msg, " Expected any character in [");

	for (k=0; k < MARPATCL_RTC_BSMAX; k++) {
	    if (!marpatcl_rtc_byteset_contains (&GATE.acceptable, k)) continue;
	    Tcl_AppendPrintfToObj (msg, "%s", QCS [k]);
	}
	Tcl_AppendPrintfToObj (msg, "]");
	chars ++;
    }

    TRACE ("LEXE #acc %d", marpatcl_rtc_symset_size (&LEX.acceptable));
    if (marpatcl_rtc_symset_size (&LEX.acceptable)) {
	int           k, n = marpatcl_rtc_symset_size  (&LEX.acceptable);
	Marpa_Symbol_ID* d = marpatcl_rtc_symset_dense (&LEX.acceptable);
	const char* sep = "";

	if (chars) {
	    Tcl_AppendPrintfToObj (msg, " while looking for any of (");
	} else {
	    Tcl_AppendPrintfToObj (msg, " Looking for any of (");
	}

	// ATTENTION: qsort is destructive on the symset
	// (the cross-links with sparse are broken).
	qsort (d, n, sizeof (Marpa_Symbol_ID), compare);
	for (k=0; k < n; k++) {
	    Marpa_Symbol_ID sym = d [k];
	    const char* sname = marpatcl_rtc_spec_symname (SPEC->g1, sym, 0);
	    TRACE ("LEX? %4d '%s'", sym, sname);
	    
	    Tcl_AppendPrintfToObj (msg, "%s%s", sep, sname);
	    sep = ", ";
	}
	Tcl_AppendPrintfToObj (msg, ").");
    } else if (chars) {
	Tcl_AppendPrintfToObj (msg, ".");
    }
#endif
    return msg;
#if 0
    // TODO: l0 progress report.
    // TODO: char mismatch information

    if {[dict exists $context l0 report]} {
	append msg "\nL0 Report:\n[lindex [dict get $context l0 report] end]"
    }

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
