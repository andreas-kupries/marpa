/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Functions for a Tcl_ObjType wrapped around an SCR representation
 */

#include <scr_objtype_int.h>
#include <scr_int.h>
#include <unidata.h>
#include <points.h>
#include <marpatcl_unicontext.h>

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Type definition
 */

static Tcl_ObjType marpatcl_scr_objtype = {
    "marpa::unicode::cc::scr",
    marpatcl_scr_rep_free,
    marpatcl_scr_rep_dup,
    marpatcl_scr_rep_str,
    marpatcl_scr_rep_from_any
};

/*
 * Internal support
 */

#undef  FreeIntRep
#define FreeIntRep(objPtr)				\
    if ((objPtr)->typePtr != NULL &&			\
	(objPtr)->typePtr->freeIntRepProc != NULL) {	\
	(objPtr)->typePtr->freeIntRepProc(objPtr);	\
	(objPtr)->typePtr = NULL;			\
    }

/*
 * OTSCR
 * - constructor
 * - destructor
 * - aquire, release reference
 */
    
OTSCR*
marpatcl_otscr_new (SCR* scr)
{
    OTSCR* otscr;
    TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);

    otscr = ALLOC (OTSCR);
    TRACE ("NEW otscr  = %p (rc=0) [%d]", otscr, sizeof (OTSCR));

    otscr->refCount = 0;
    otscr->scr = scr;

    TRACE_RETURN ("(OTSCR*) %p", otscr);
}

void
marpatcl_otscr_destroy (OTSCR* otscr)
{
    TRACE_FUNC ("((OTSCR*) %p (rc %d, scr %p))",
		otscr, otscr->refCount, otscr->scr);
	
    marpatcl_scr_destroy (otscr->scr);

    TRACE ("DEL (OTSCR*) %p", otscr);
    FREE (otscr);

    TRACE_RETURN_VOID;
}

OTSCR*
marpatcl_otscr_take (OTSCR* otscr)
{
    TRACE_FUNC ("((OTSCR*) %p)", otscr);

    otscr->refCount ++;
    TRACE ("(OTSCR*) %p (rc=%d)", otscr, otscr ? otscr->refCount : -5);
    TRACE_RETURN ("(OTSCR*) %p", otscr);
}
    
void
marpatcl_otscr_release (OTSCR* otscr)
{
    TRACE_FUNC ("(OTSCR*) %p)", otscr);

    otscr->refCount --;
    TRACE ("(OTSCR*) %p (rc=%d)", otscr, otscr ? otscr->refCount : -5);

    if (otscr->refCount > 0) {
	TRACE_RETURN_VOID;
    }

    marpatcl_otscr_destroy (otscr);
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Int rep operations
 * - destructor
 * - duplicate
 * - stringify
 * - shimmer
 */
    
void
marpatcl_scr_rep_free (Tcl_Obj* o)
{
    TRACE_FUNC ("(o %p (rc %d))", o, o->refCount);
    TRACE ("(OTSCR*) %p (rc=%d)", OTSCR_REP(o), OTSCR_REP(o)->refCount);
    TRACE ("(SCR*) %p", OTSCR_REP(o)->scr);

    marpatcl_otscr_release (OTSCR_REP(o));

    TRACE_RETURN_VOID;
}
    
void
marpatcl_scr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
{
    TRACE_FUNC ("(src %p (rc=%d), dst %p)",
		src, src ? src->refCount : -5, dst);
	
    marpatcl_otscr_take (OTSCR_REP(src));
    dst->INT_REP = src->INT_REP;
    dst->typePtr = &marpatcl_scr_objtype;

    TRACE_RETURN_VOID;
}
    
void
marpatcl_scr_rep_str (Tcl_Obj* o)
{
    /*
     * Generate a string for a list, using the CC as basis.  We ensure that
     * the CC is canonical first.
     */
    char        buf [20];
    SCR*        scr = OTSCR_REP(o)->scr;
    Tcl_DString ds;
    int         i;
    CR*         cr;

    TRACE_FUNC ("(o %p (rc=%d))", o, o->refCount);
    TRACE ("(OTSCR*) %p (rc=%d)", OTSCR_REP(o), OTSCR_REP(o)->refCount);
    TRACE ("(SCR*) %p", OTSCR_REP(o)->scr);

    marpatcl_scr_norm (scr);
    Tcl_DStringInit (&ds);

    for (cr = &scr->cr[0], i = 0;
	 i < scr->n;
	 i++, cr++) {
	if (cr->start == cr->end) {
	    /* range is single element */
	    sprintf(buf, "%d", cr->start); 
	    Tcl_DStringAppendElement (&ds, buf);
	} else {
	    /* actual range */
	    Tcl_DStringStartSublist(&ds);
	    sprintf(buf, "%d", cr->start); 
	    Tcl_DStringAppendElement (&ds, buf);
	    sprintf(buf, "%d", cr->end); 
	    Tcl_DStringAppendElement (&ds, buf);
	    Tcl_DStringEndSublist(&ds);
	}
    }

    STREP_DS (o, &ds);

    Tcl_DStringFree (&ds);
    TRACE_RETURN_VOID;
}

int
marpatcl_scr_rep_from_any (Tcl_Interp* ip, Tcl_Obj* o)
{
    /*
     * The conversion goes through a list intrep, avoiding manual parsing of
     * the structure.
     */
    int       objc;
    Tcl_Obj **objv;
    int       robjc;
    Tcl_Obj **robjv;
    SCR*      scr   = NULL;
    OTSCR*    otscr = NULL;
    int       start, end, i;

    marpatcl_unicontext_data ctx =  marpatcl_unicontext (ip);

    TRACE_FUNC ("(ip %p, o %p)", ip, o);
    /*
     * The class is a list of codepoints and ranges (2-element lists).
     */
    if (Tcl_ListObjGetElements(ip, o, &objc, &objv) != TCL_OK) {
	goto fail;
    }

    scr = marpatcl_scr_new (objc);
    TRACE ("CAP %d", objc);
    for (i = 0; i < objc; i++) {
	Tcl_Obj* elt = objv[i];
	TRACE ("PROCESS. [%02d] %p", i, elt);
	    
	/*
	 * First handle objects which already have a suitable type.  No
	 * conversions required, only data extraction and validation.
	 */

	if (elt->typePtr == ctx->intType) {
	    TRACE ("INT. ... [%02d] %p", i, elt);

	process_int:
	    TRACE ("INT. CHK [%02d] %p", i, elt);
	    if (marpatcl_get_codepoint_from_obj (ip, elt, &start) != TCL_OK) {
		goto fail;
	    }
	    TRACE ("++ (%d)", start);
	    marpatcl_scr_add_range(scr, start, start);
	    continue;

	}

	if (elt->typePtr == ctx->listType) {
	    TRACE ("LIST ... [%02d] %p", i, elt);

	process_list:
	    TRACE ("LIST CHK [%02d] %p", i, elt);
	    if (marpatcl_get_range_from_obj (ip, elt, &start, &end) != TCL_OK) {
		goto fail;
	    }
	    TRACE ("++ (%d...%d)", start, end);
	    marpatcl_scr_add_range(scr, start, end);
	    continue;
	}

	/*
	 * While object has no suitable type, it may be convertible to
	 * such. Those which are convertable get dispatched to the handlers
	 * above.
	 */

	if (Tcl_GetIntFromObj(ip, elt, &start) == TCL_OK) {
	    TRACE ("INT. CVT [%02d] %p", i, elt);
	    goto process_int;
	}

	if (Tcl_ListObjGetElements(ip, elt, &robjc, &robjv) == TCL_OK) {
	    TRACE ("LIST CVT [%02d] %p", i, elt);
	    goto process_list;
	}

	TRACE ("NO.. CVT [%02d] %p", i, elt);

	/*
	 * No suitable type, and not convertible to such either.  Most of the
	 * time this is not reached because most bogus input is convertible to
	 * a list. And then the range-validation kicks in. Only bad list
	 * syntax comes here.
	 */

	Tcl_SetErrorCode (ip, "MARPA", NULL);
	Tcl_SetObjResult (ip, Tcl_NewStringObj("Expected codepoint or range, got neither",-1));
	goto fail;
    }

    TRACE ("USE %d", scr->n);
	
    otscr = marpatcl_otscr_take (marpatcl_otscr_new (scr));

    /*
     * Kill the old intrep (a list). This was delayed as much as
     * possible. Afterward we can put in our own intrep.
     */

    FreeIntRep (o);

    o->INT_REP = otscr;
    o->typePtr = &marpatcl_scr_objtype;

    TRACE_RETURN ("ok: %d", TCL_OK);

 fail:
    TRACE ("%s", "FAIL");
    if (scr) {
	marpatcl_scr_destroy(scr);
    }
    TRACE_RETURN ("err: %d", TCL_ERROR);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * ObjType accessors
 */

Tcl_Obj*
marpatcl_new_otscr_obj (OTSCR* otscr)
{
    Tcl_Obj* obj;
    TRACE_FUNC ("((OTSCR*) %p)", otscr);
    obj = Tcl_NewObj ();
    TRACE ("(Tcl_Obj*) %p (rc=%d)", obj, obj->refCount);
	
    Tcl_InvalidateStringRep (obj);
    obj->INT_REP = marpatcl_otscr_take (otscr);
    obj->typePtr = &marpatcl_scr_objtype;

    TRACE_RETURN ("(Tcl_Obj*) %p", obj);
}

int
marpatcl_get_otscr_from_obj (Tcl_Interp* ip, Tcl_Obj* o, OTSCR** otscrPtr)
{
    TRACE_FUNC ("(ip %p, o %p (rc=%d), oscr^ %p",
		o, o->refCount, otscrPtr);

    if (o->typePtr != &marpatcl_scr_objtype) {
	if (marpatcl_scr_rep_from_any (ip, o) != TCL_OK) {
	    TRACE_RETURN ("ERROR", TCL_ERROR);
	}
    }

    *otscrPtr = OTSCR_REP(o);
    TRACE ("(OTSCR*) %p (rc=%d)", *otscrPtr, (*otscrPtr)->refCount);
    TRACE_RETURN ("OK", TCL_OK);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

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
