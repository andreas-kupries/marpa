# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Tcl_ObjType for SCR-based Unicode Char Classes
## (See c_unicode.tcl for definitions)

## Core API Functions
#
##   void free (Tcl_Obj* o)                  - Release IntRep
##   void dup  (Tcl_Obj* src, Tcl_Obj* dst)  - Dup IntRep of src into dst (refcount ?)
##   void str  (Tcl_Obj* o)                  - Generate StrRep from IntRep
##   int  from (Tcl_Interp* ip, Tcl_Obj* o)  - Generate IntRep from StrRep
# 
##   Tcl_ObjType ...
# 
## User Constructor, Accessor Functionality
# 
##   int marpa_get_otscr_from_obj (Tcl_Obj* o, OTSCR** otscrPtr) - Retrieve OTSCR from Tcl_Obj
##   ... marpa_new_otscr_obj (Tcl_Obj* o, OTSCR* otscr)          - Wrap OTSCR into Tcl_Obj (+1 ref)
#
## CriTcl Glue
#
## - cproc argument type
## - cproc result type

critcl::ccode {
    #define INT_REP       internalRep.otherValuePtr
    #define OTSCR_REP(o) ((OTSCR*) (o)->INT_REP)

    /*
    // The structure we use for the int rep
    */
    
    typedef struct OTSCR {
	int  refCount; /* Counter indicating sharing status of the structure */
	SCR* scr;      /* Actual intrep */
    } OTSCR;

    /*
    // Helper functions for intrep lifecycle and use.
    */
    
    OTSCR*
    marpa_otscr_new (SCR* scr)
    {
	OTSCR* otscr;
	TRACE_FUNC ("((SCR*) %p (elt %d))", scr, scr->n);

	otscr = (OTSCR*) ckalloc (sizeof (OTSCR));
	TRACE ("NEW otscr  = %p (rc=0) [%d]", otscr, sizeof (OTSCR));

	otscr->refCount = 0;
	otscr->scr = scr;

	TRACE_RETURN ("(OTSCR*) %p", otscr);
    }

    void
    marpa_otscr_destroy (OTSCR* otscr)
    {
	TRACE_FUNC ("((OTSCR*) %p (rc %d, scr %p))",
		    otscr, otscr->refCount, otscr->scr);
	
	marpa_scr_destroy (otscr->scr);

	TRACE ("DEL (OTSCR*) %p", otscr);
	ckfree((char*) otscr);

	TRACE_RETURN_VOID;
    }

    OTSCR*
    marpa_otscr_take (OTSCR* otscr)
    {
	TRACE_FUNC ("((OTSCR*) %p)", otscr);

	otscr->refCount ++;
	TRACE ("(OTSCR*) %p (rc=%d)", otscr, otscr ? otscr->refCount : -5);
	TRACE_RETURN ("(OTSCR*) %p", otscr);
    }
    
    void
    marpa_otscr_release (OTSCR* otscr)
    {
	TRACE_FUNC ("(OTSCR*) %p)", otscr);

	otscr->refCount --;
	TRACE ("(OTSCR*) %p (rc=%d)", otscr, otscr ? otscr->refCount : -5);

	if (otscr->refCount > 0) {
	    TRACE_RETURN_VOID;
	}

	marpa_otscr_destroy (otscr);
	TRACE_RETURN_VOID;
    }

    /*
    // Helper macro for dealing with Tcl_ObjType's.
    */

    #undef  FreeIntRep
    #define FreeIntRep(objPtr) \
	if ((objPtr)->typePtr != NULL && \
		(objPtr)->typePtr->freeIntRepProc != NULL) { \
	    (objPtr)->typePtr->freeIntRepProc(objPtr); \
	    (objPtr)->typePtr = NULL; \
	}

    /*
    // Forward declare the type structure
    */
    
    static Tcl_ObjType marpa_scr_objtype;

    /*
    // Tcl_ObjType vectors implementing it
    */
    
    static void
    marpa_scr_rep_free (Tcl_Obj* o)
    {
	TRACE_FUNC ("(o %p (rc %d))", o, o->refCount);
	TRACE ("(OTSCR*) %p (rc=%d)", OTSCR_REP(o), OTSCR_REP(o)->refCount);
	TRACE ("(SCR*) %p", OTSCR_REP(o)->scr);

	marpa_otscr_release (OTSCR_REP(o));

	TRACE_RETURN_VOID;
    }
    
    static void
    marpa_scr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
    {
	TRACE_FUNC ("(src %p (rc=%d), dst %p)",
		    src, src ? src->refCount : -5, dst);
	
	marpa_otscr_take (OTSCR_REP(src));
	dst->INT_REP = src->INT_REP;
	dst->typePtr = &marpa_scr_objtype;

	TRACE_RETURN_VOID;
    }
    
    static void
    marpa_scr_rep_str (Tcl_Obj* o)
    {
	/*
	// Generate a string for a list, using the CC as basis.
	// We ensure that the CC is canonical first.
	*/
	char        buf [20];
	SCR*        scr = OTSCR_REP(o)->scr;
	Tcl_DString ds;
	int         i;
	CR*         cr;

	TRACE_FUNC ("(o %p (rc=%d))", o, o->refCount);
	TRACE ("(OTSCR*) %p (rc=%d)", OTSCR_REP(o), OTSCR_REP(o)->refCount);
	TRACE ("(SCR*) %p", OTSCR_REP(o)->scr);

	marpa_scr_norm (scr);
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

    static int
    marpa_scr_bad_codepoint (Tcl_Interp* ip, const char* msg, int codepoint) {
	char buf [100];
	if ((codepoint >= 0) &&
	    (codepoint <= UNI_MAX)) {
	    return 0;
	}
	sprintf (buf, "%s out of range (0...%d): %d",
		 msg, UNI_MAX, codepoint);
	Tcl_SetErrorCode (ip, "MARPA", NULL);
	Tcl_SetObjResult (ip, Tcl_NewStringObj(buf,-1));
	return 1;
    }
    
    static int
    marpa_scr_bad_range (Tcl_Interp* ip, int start, int end) {
	char buf [100];
	if (start <= end) {
	    return 0;
	}
	sprintf (buf, "Range empty (end (%d) before start (%d))",
		 start, end);
	Tcl_SetErrorCode (ip, "MARPA", NULL);
	Tcl_SetObjResult (ip, Tcl_NewStringObj(buf,-1));
	return 1;
    }
    
    static int
    marpa_scr_rep_from_any (Tcl_Interp* ip, Tcl_Obj* o)
    {
	/*
	// The conversion goes through a list intrep, avoiding manual
	// parsing of the structure.
	*/
	int       objc;
	Tcl_Obj **objv;
	int       robjc;
	Tcl_Obj **robjv;
	SCR*      scr   = NULL;
	OTSCR*    otscr = NULL;
	int       start, end, i;
	marpatcl_context_data ctx =  marpatcl_context (ip);

	TRACE_FUNC ("(ip %p, o %p)", ip, o);
	/*
	// The class is a list of codepoints and ranges (2-element lists).
	*/
	if (Tcl_ListObjGetElements(ip, o, &objc, &objv) != TCL_OK) {
	    goto fail;
	}

	scr = marpa_scr_new (objc);
	TRACE ("CAP %d", objc);
	for (i = 0; i < objc; i++) {
	    Tcl_Obj* elt = objv[i];

	    /*
	    // First handle objects which already have a suitable type.
	    // No conversions required, only data extraction and validation.
	    */

	    if (elt->typePtr == ctx->intType) {
		Tcl_GetIntFromObj(ip, elt, &start);

	    process_int:
		if (marpa_scr_bad_codepoint (ip, "Point", start)) {
		    goto fail;
		}
		TRACE ("++ (%d)", start);
		marpa_scr_add_range(scr, start, start);
		continue;

	    }

	    if (elt->typePtr == ctx->listType) {
		Tcl_ListObjGetElements(ip, elt, &robjc, &robjv);

	    process_list:
		if ((Tcl_GetIntFromObj (ip, robjv[0], &start) != TCL_OK) ||
		    marpa_scr_bad_codepoint (ip, "Range (start)", start) ||
		    (Tcl_GetIntFromObj (ip, robjv[1], &end) != TCL_OK) ||
		    marpa_scr_bad_codepoint (ip, "Range (end)", end) ||
		    marpa_scr_bad_range(ip, start, end)) {
		    goto fail;
		}
		TRACE ("++ (%d...%d)", start, end);
		marpa_scr_add_range(scr, start, end);
		continue;
	    }

	    /*
	    // While object has no suitable type, it may be
	    // convertible to such. Those which are convertable get
	    // dispatched to the handlers above.
	    */

	    if (Tcl_GetIntFromObj(ip, elt, &start) == TCL_OK) {
		goto process_int;
	    }

	    if (Tcl_ListObjGetElements(ip, elt, &robjc, &robjv) == TCL_OK) {
		goto process_list;
	    }

	    /*
	    // No suitable type, and not convertible to such either.
	    */

	    Tcl_SetErrorCode (ip, "MARPA", NULL);
	    Tcl_SetObjResult (ip, Tcl_NewStringObj("Expected codepoint or range, got neither",-1));
	    goto fail;
	}

	TRACE ("USE %d", scr->n);
	
	otscr = marpa_otscr_take (marpa_otscr_new (scr));

	/*
	// Kill the old intrep (a list). This was delayed as much as
	// possible. Afterward we can put in our own intrep.
	*/

	FreeIntRep (o);

	o->INT_REP = otscr;
	o->typePtr = &marpa_scr_objtype;

	TRACE_RETURN ("ok: %d", TCL_OK);

    fail:
	TRACE ("%s", "FAIL");
	if (scr) {
	    marpa_scr_destroy(scr);
	}
	TRACE_RETURN ("err: %d", TCL_ERROR);
    }
    
    static Tcl_ObjType marpa_scr_objtype = {
	"marpa::cc::scr",
	marpa_scr_rep_free,
	marpa_scr_rep_dup,
	marpa_scr_rep_str,
	marpa_scr_rep_from_any
    };

    /* Public creator/accessor functions
    */

    Tcl_Obj*
    marpa_new_otscr_obj (OTSCR* otscr)
    {
	Tcl_Obj* obj;
	TRACE_FUNC ("((OTSCR*) %p)", otscr);
	obj = Tcl_NewObj ();
	TRACE ("(Tcl_Obj*) %p (rc=%d)", obj, obj->refCount);
	
	Tcl_InvalidateStringRep (obj);
	obj->INT_REP = marpa_otscr_take (otscr);
	obj->typePtr = &marpa_scr_objtype;

	TRACE_RETURN ("(Tcl_Obj*) %p", obj);
    }

    int
    marpa_get_otscr_from_obj (Tcl_Interp* ip, Tcl_Obj* o, OTSCR** otscrPtr)
    {
	TRACE_FUNC ("(ip %p, o %p (rc=%d), oscr^ %p",
		    o, o->refCount, otscrPtr);

	if (o->typePtr != &marpa_scr_objtype) {
	    if (marpa_scr_rep_from_any (ip, o) != TCL_OK) {
		TRACE_RETURN ("ERROR", TCL_ERROR);
	    }
	}

	*otscrPtr = OTSCR_REP(o);
	TRACE ("(OTSCR*) %p (rc=%d)", *otscrPtr, (*otscrPtr)->refCount);
	TRACE_RETURN ("OK", TCL_OK);
    }
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_CharClass {
    @A = NULL;
    TRACE ("A(Marpa_CharClass): obj %p (rc=%d)", @@, @@->refCount);
    if (marpa_get_otscr_from_obj (interp, @@, &@A) != TCL_OK) {
	TRACE ("%s", "A(Marpa_CharClass): ERROR");
	return TCL_ERROR;
    }
    TRACE ("A(Marpa_CharClass): (OTSCR*) %p (rc=%d)", @A, @A->refCount);
    TRACE ("%s", "A(Marpa_CharClass): DONE");
} OTSCR* OTSCR*

critcl::resulttype Marpa_CharClass {
    TRACE ("R(Marpa_CharClass): (OTSCR*) %p (rc=%d)", rv, rv ? rv->refCount : -5);
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpa_new_otscr_obj (rv));
    TRACE ("R(Marpa_CharClass): obj %p (rc=%d)", Tcl_GetObjResult(interp), Tcl_GetObjResult(interp)->refCount);
    /* No refcount adjustment */
    TRACE ("%s", "R(Marpa_CharClass): DONE");
    return TCL_OK;
} OTSCR*

# # ## ### ##### ######## #############
## API exposed to Tcl level
## Supercedes original procs in p_unicode.tcl

critcl::cproc marpa::unicode::negate-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
    /* charclass :: OTSCR* */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))", charclass, charclass->refCount);
    TRACE ("(SCR*) %p", charclass->scr);
    charclass = marpa_otscr_new (marpa_scr_complement (charclass->scr));
    TRACE_RETURN ("(OTSCR*) %p", charclass);
}

critcl::cproc marpa::unicode::norm-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
    /*
    // charclass :: OTSCR*
    // The deeper intrep is modified.
    // A possible string rep is not.
    */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))",
		charclass, charclass->refCount);
    TRACE ("(SCR*) %p", charclass->scr);
    marpa_scr_norm (charclass->scr);
    TRACE_RETURN ("(OTSCR*) %p", charclass);
}

# # ## ### ##### ######## #############
return
