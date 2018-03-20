/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Functions for a Tcl_ObjType wrapped around an ASBR representation
 */

#include <asbr_objtype_int.h>
#include <asbr_int.h>
#include <unidata.h>

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;

/*
 * Type definition
 */

static Tcl_ObjType marpatcl_asbr_objtype = {
    "marpa::cc::asbr",
    marpatcl_asbr_rep_free,
    marpatcl_asbr_rep_dup,
    marpatcl_asbr_rep_str,
    NULL /* from_any not supported, only via 2asbr from OTSCR */,
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
 * OTASBR
 * - constructor
 * - destructor
 * - aquire, release reference
 */

OTASBR*
marpatcl_otasbr_new (ASBR* asbr)
{
    OTASBR* otasbr;
    TRACE_FUNC ("((ASBR*) %p)", asbr);

    otasbr = ALLOC (OTASBR);
    TRACE ("NEW otasbr = %p", otasbr);

    otasbr->refCount = 0;
    otasbr->asbr = asbr;

    TRACE_RETURN ("(OTASBR*) %p", otasbr);
}

void
marpatcl_otasbr_destroy (OTASBR* otasbr)
{
    TRACE_FUNC ("((OTASBR*) %p)", otasbr);
    marpatcl_asbr_destroy (otasbr->asbr);

    TRACE ("DEL (OTASBR*) %p", otasbr);
    FREE (otasbr);

    TRACE_RETURN_VOID;
}

OTASBR*
marpatcl_otasbr_take (OTASBR* otasbr)
{
    TRACE_FUNC ("((OTASBR*) %p)", otasbr);
	
    otasbr->refCount ++;
    TRACE ("(OTASBR*) %p (rc %d)", otasbr, otasbr ? otasbr->refCount : -5);
    TRACE_RETURN ("(OTASBR*) %p", otasbr);
}
    
void
marpatcl_otasbr_release (OTASBR* otasbr)
{
    TRACE_FUNC ("((OTASBR*) %p)", otasbr);

    otasbr->refCount --;
    TRACE ("(OTASBR*) %p (rc %d)", otasbr, otasbr ? otasbr->refCount : -5);

    if (otasbr->refCount > 0) {
	TRACE_RETURN_VOID;
    }

    marpatcl_otasbr_destroy (otasbr);
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
marpatcl_asbr_rep_free (Tcl_Obj* o)
{
    TRACE_FUNC ( "(o %p)", o);
    marpatcl_otasbr_release (OTASBR_REP(o));
    TRACE_RETURN_VOID;
}
    
void
marpatcl_asbr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
{
    TRACE_FUNC ("(src %p (rc %d), dst %p)",
		src, src ? src->refCount : -5, dst);

    marpatcl_otasbr_take (OTASBR_REP(src));
    dst->INT_REP = src->INT_REP;
    dst->typePtr = &marpatcl_asbr_objtype;

    TRACE_RETURN_VOID;
}
    
void
marpatcl_asbr_rep_str (Tcl_Obj* o)
{
    /*
     * Generate a string for a nested list, using the ASBR as basis
    */
    char        buf [20];
    ASBR*       asbr = OTASBR_REP(o)->asbr;
    Tcl_DString ds;
    int         i, k;
    SBR*        sbr;
    BR*         br;
	
    TRACE_FUNC ("(o %p (rc %d))", o, o ? o->refCount : -5);

    Tcl_DStringInit (&ds);

    /* Iterate over the alternates */
    for (sbr = &asbr->sbr[0], i = 0;
	 i < asbr-> n;
	 i++, sbr ++) {
	/* Each alternate is a list (sequence) */
	Tcl_DStringStartSublist(&ds);
	for (br = &sbr->br[0], k = 0;
	     k < sbr->n;
	     k++, br++) {
	    /* Each element of the sequence is a pair */
	    Tcl_DStringStartSublist(&ds);
	    sprintf(buf, "%d", br->start);
	    Tcl_DStringAppendElement (&ds, buf);
	    sprintf(buf, "%d", br->end); 
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
marpatcl_new_otasbr_obj (OTASBR* otasbr)
{
    Tcl_Obj* obj = Tcl_NewObj ();
    TRACE_FUNC ("((OTASBR*) %p)", otasbr);
	
    Tcl_InvalidateStringRep (obj);
    obj->internalRep.otherValuePtr = marpatcl_otasbr_take (otasbr);
    obj->typePtr                   = &marpatcl_asbr_objtype;

    TRACE_RETURN ("(Tcl_Obj*) %p", obj);
}

int
marpatcl_get_otasbr_from_obj (Tcl_Interp* ip, Tcl_Obj* o, OTASBR** otasbrPtr)
{
    TRACE_FUNC ("(ip %p, o %p, (OTASBR**) %p)",
		ip, o, otasbrPtr);
    if (o->typePtr != &marpatcl_asbr_objtype) {
	TRACE_RETURN ("ERROR", TCL_ERROR);
    }

    *otasbrPtr = OTASBR_REP(o);
    TRACE ("==> (OTASBR*) %p", *otasbrPtr);
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
