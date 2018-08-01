/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Functions for a Tcl_ObjType wrapped around an ASSR representation
 */

#include <assr_objtype_int.h>
#include <assr_int.h>
#include <unidata.h>

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Type definition
 */

static Tcl_ObjType marpatcl_assr_objtype = {
    "marpa::cc::assr",
    marpatcl_assr_rep_free,
    marpatcl_assr_rep_dup,
    marpatcl_assr_rep_str,
    NULL /* from_any not supported, only via 2assr from OTSCR */,
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
 * OTASSR
 * - constructor
 * - destructor
 * - aquire, release reference
 */

OTASSR*
marpatcl_otassr_new (ASSR* assr)
{
    OTASSR* otassr;
    TRACE_FUNC ("((ASSR*) %p)", assr);

    otassr = ALLOC (OTASSR);
    TRACE ("NEW otassr = %p", otassr);

    otassr->refCount = 0;
    otassr->assr = assr;

    TRACE_RETURN ("(OTASSR*) %p", otassr);
}

void
marpatcl_otassr_destroy (OTASSR* otassr)
{
    TRACE_FUNC ("((OTASSR*) %p)", otassr);
    marpatcl_assr_destroy (otassr->assr);

    TRACE ("DEL (OTASSR*) %p", otassr);
    FREE (otassr);

    TRACE_RETURN_VOID;
}

OTASSR*
marpatcl_otassr_take (OTASSR* otassr)
{
    TRACE_FUNC ("((OTASSR*) %p)", otassr);

    otassr->refCount ++;
    TRACE ("(OTASSR*) %p (rc %d)", otassr, otassr ? otassr->refCount : -5);
    TRACE_RETURN ("(OTASSR*) %p", otassr);
}

void
marpatcl_otassr_release (OTASSR* otassr)
{
    TRACE_FUNC ("((OTASSR*) %p)", otassr);

    otassr->refCount --;
    TRACE ("(OTASSR*) %p (rc %d)", otassr, otassr ? otassr->refCount : -5);

    if (otassr->refCount > 0) {
	TRACE_RETURN_VOID;
    }

    marpatcl_otassr_destroy (otassr);
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
marpatcl_assr_rep_free (Tcl_Obj* o)
{
    TRACE_FUNC ( "(o %p)", o);
    marpatcl_otassr_release (OTASSR_REP(o));
    TRACE_RETURN_VOID;
}

void
marpatcl_assr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
{
    TRACE_FUNC ("(src %p (rc %d), dst %p)",
		src, src ? src->refCount : -5, dst);

    marpatcl_otassr_take (OTASSR_REP(src));
    dst->INT_REP = src->INT_REP;
    dst->typePtr = &marpatcl_assr_objtype;

    TRACE_RETURN_VOID;
}

void
marpatcl_assr_rep_str (Tcl_Obj* o)
{
    /*
     * Generate a string for a nested list, using the ASSR as basis
    */
    char        buf [20];
    ASSR*       assr = OTASSR_REP(o)->assr;
    Tcl_DString ds;
    int         i, k;
    SSR*        ssr;
    SR*         sr;

    TRACE_FUNC ("(o %p (rc %d))", o, o ? o->refCount : -5);

    Tcl_DStringInit (&ds);

    /* Iterate over the alternates */
    for (ssr = &assr->ssr[0], i = 0;
	 i < assr-> n;
	 i++, ssr ++) {
	/* Each alternate is a list (sequence) */
	Tcl_DStringStartSublist(&ds);
	for (sr = &ssr->sr[0], k = 0;
	     k < ssr->n;
	     k++, sr++) {
	    /* Each element of the sequence is a pair */
	    Tcl_DStringStartSublist(&ds);
	    sprintf(buf, "%d", sr->start);
	    Tcl_DStringAppendElement (&ds, buf);
	    sprintf(buf, "%d", sr->end);
	    Tcl_DStringAppendElement (&ds, buf);
	    Tcl_DStringEndSublist(&ds);
	}
	Tcl_DStringEndSublist(&ds);
    }

    STREP_DS (o, &ds);

    Tcl_DStringFree (&ds);
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * ObjType accessors
 */

Tcl_Obj*
marpatcl_new_otassr_obj (OTASSR* otassr)
{
    Tcl_Obj* obj = Tcl_NewObj ();
    TRACE_FUNC ("((OTASSR*) %p)", otassr);

    Tcl_InvalidateStringRep (obj);
    obj->internalRep.otherValuePtr = marpatcl_otassr_take (otassr);
    obj->typePtr                   = &marpatcl_assr_objtype;

    TRACE_RETURN ("(Tcl_Obj*) %p", obj);
}

int
marpatcl_get_otassr_from_obj (Tcl_Interp* ip, Tcl_Obj* o, OTASSR** otassrPtr)
{
    TRACE_FUNC ("(ip %p, o %p, (OTASSR**) %p)",
		ip, o, otassrPtr);
    if (o->typePtr != &marpatcl_assr_objtype) {
	TRACE_RETURN ("ERROR", TCL_ERROR);
    }

    *otassrPtr = OTASSR_REP(o);
    TRACE ("==> (OTASSR*) %p", *otassrPtr);
    TRACE_RETURN ("OK", TCL_OK);
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
