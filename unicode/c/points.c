/*
 * (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                          http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Validation functions for unicode points and ranges.
 */

#include <points.h>
#include <unidata.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

static void
report_bad_codepoint (Tcl_Interp* ip, const char* msg, Tcl_Obj* o);

static int
get_codepoint (Tcl_Interp* ip, Tcl_Obj* obj, int* codepoint, const char* msg);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

int
marpatcl_get_codepoint_from_obj (Tcl_Interp* ip,
				 Tcl_Obj* obj, int* codepoint)
{
    return get_codepoint (ip, obj, codepoint, "codepoint");
}

int
marpatcl_get_range_from_obj (Tcl_Interp* ip,
			     Tcl_Obj* obj, int* start, int* end)
{
    int       robjc;
    Tcl_Obj **robjv;

    if (Tcl_ListObjGetElements(ip, obj, &robjc, &robjv) != TCL_OK) {
	return TCL_ERROR;
    }
    if (robjc != 2) {
#define MSG "Expected 2-element list for range"
	Tcl_SetErrorCode (ip, "MARPA", NULL);
	Tcl_SetObjResult (ip, Tcl_NewStringObj(MSG,-1));
	return TCL_ERROR;
#undef MSG
    }
    if ((get_codepoint (ip, robjv[0], start, "range start") != TCL_OK) ||
	(get_codepoint (ip, robjv[1], end,   "range end") != TCL_OK)) {
	return TCL_ERROR;
    }
    if (*start > *end) {
	if (ip) {
	    char buf [100];
	    sprintf (buf, "Unexpected empty range (%d > %d)",
		     *start, *end);
	    Tcl_SetErrorCode (ip, "MARPA", NULL);
	    Tcl_SetObjResult (ip, Tcl_NewStringObj(buf,-1));
	}
	return TCL_ERROR;
    }
    return TCL_OK;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

static void
report_bad_codepoint (Tcl_Interp* ip, const char* msg, Tcl_Obj* o)
{
    // XXX FIXME URGENT -- Overlong `o` may overflow fixed-size buffer.
    // XXX FIXME URGENT -- Go dstring
    char buf [100];
    sprintf (buf, "Expected integer for %s in [0...%d], got \"%s\"",
	     msg, UNI_MAX, Tcl_GetString (o));
    Tcl_SetErrorCode (ip, "MARPA", NULL);
    Tcl_SetObjResult (ip, Tcl_NewStringObj(buf,-1));
}

static int
get_codepoint (Tcl_Interp* ip, Tcl_Obj* obj, int* codepoint, const char* msg)
{
    if ((Tcl_GetIntFromObj (ip, obj, codepoint) != TCL_OK) ||
	(*codepoint < 0) ||
	(*codepoint > UNI_MAX)) {
	if (ip) {
	    report_bad_codepoint (ip, msg, obj);
	}
	return TCL_ERROR;
    }
    return TCL_OK;
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
