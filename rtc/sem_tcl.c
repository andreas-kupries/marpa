/* Runtime for C-engine (RTC). Implementation. (SV for Tcl)
 * - - -- --- ----- -------- ------------- ----------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_tcl.h>
#include <sem_int.h>
#include <critcl_trace.h>
#include <critcl_assert.h>

TRACE_ON;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define TAKE Tcl_IncrRefCount
#define RELE Tcl_DecrRefCount

static Tcl_Obj*
marpatcl_rtc_sv_astcl_do (Tcl_Interp* ip, marpatcl_rtc_sv_p sv, Tcl_Obj* null);

static Tcl_Obj*
marpatcl_rtc_sv_vec_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_vec v, Tcl_Obj* null);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

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


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
