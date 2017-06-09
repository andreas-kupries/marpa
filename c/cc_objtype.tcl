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
##   int GetCharClassFromObj (Tcl_Obj* o, SCR** scrPtr) - Retrieve SCR from Tcl_Obj
##   ... NewCharClass (Tcl_Obj* o, SCR* scr)            - Wrap SCR into Tcl_Obj (takes ownership)
#
## CriTcl Glue
#
## - cproc argument type
## - cproc result type

critcl::ccode {
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
	OTSCR* otscr = (OTSCR*) ckalloc (sizeof (OTSCR));
	otscr->refCount = 0;
	otscr->scr = scr;
	return otscr;
    }

    void
    marpa_otscr_destroy (OTSCR* otscr)
    {
	marpa_scr_destroy (otscr->scr);
	ckfree((char*) otscr);
	return;
    }

    OTSCR*
    marpa_otscr_take (OTSCR* otscr)
    {
	otscr->refCount ++;
	return otscr;
    }
    
    void
    marpa_otscr_release (OTSCR* otscr)
    {
	otscr->refCount --;
	if (otscr->refCount > 0) return;
	marpa_otscr_destroy (otscr);
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
	OTSCR* intRep = (OTSCR*) o->internalRep.otherValuePtr;
	intRep->refCount --;
	if (intRep->refCount > 0) return;
	marpa_otscr_release (intRep);
    }
    
    static void
    marpa_scr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
    {
	OTSCR* intRep = (OTSCR*) src->internalRep.otherValuePtr;
	marpa_otscr_take (intRep);
	dst->internalRep.otherValuePtr = src->internalRep.otherValuePtr;
	dst->typePtr = &marpa_scr_objtype;
    }
    
    static void
    marpa_scr_rep_str (Tcl_Obj* o)
    {
	/*
	// Generate a string for a list, using the CC as basis.
	// We ensure that the CC is canonical first.
	*/
	char        buf [20];
	OTSCR*      intRep = (OTSCR*) o->internalRep.otherValuePtr;
	SCR*        scr    = intRep->scr;
	Tcl_DString ds;
	int         i, length;
	CR*         cr;
	
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
	
	length = Tcl_DStringLength (&ds);
	
	o->length = length;
	o->bytes  = ckalloc(length);
	memcpy (o->bytes, Tcl_DStringValue (&ds), length+1);

	Tcl_DStringFree (&ds);
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

	TRACE_ENTER ("marpa_scr_rep_from_any");
	/*
	// The class is a list of codepoints and ranges (2-element lists).
	*/
	if (Tcl_ListObjGetElements(ip, o, &objc, &objv) != TCL_OK) {
	    goto fail;
	}

	scr = marpa_scr_new (objc);
	TRACE (("CAP %d", objc));
	for (i = 0; i < objc; i++) {
	    /* Extract and validate each element of the CC
	    */
	    if (Tcl_ListObjGetElements(ip, objv[i], &robjc, &robjv) != TCL_OK) {
		goto fail;
	    }
	    switch (robjc) {
		case 1: {
		    if ((Tcl_GetIntFromObj(ip, robjv[0], &start) != TCL_OK) ||
			marpa_scr_bad_codepoint (ip, "Point", start)) {
			goto fail;
		    }
		    end = start;
		    break;
		}
		case 2: {
		    if ((Tcl_GetIntFromObj(ip, robjv[0], &start) != TCL_OK) ||
			marpa_scr_bad_codepoint (ip, "Range (start)", start) ||
			(Tcl_GetIntFromObj(ip, robjv[1], &end) != TCL_OK) ||
			marpa_scr_bad_codepoint (ip, "Range (end)", end)) {
			goto fail;
		    }
		    if (end < start) {
			Tcl_SetErrorCode (ip, "MARPA", NULL);
			Tcl_SetObjResult (ip, Tcl_NewStringObj("Range empty (end before start)" ,-1));
			goto fail;
		    }
		    break;
		}
		default: {
		    Tcl_SetErrorCode (ip, "MARPA", NULL);
		    Tcl_SetObjResult (ip, Tcl_NewStringObj("Expected codepoint or range, got neither",-1));
		    goto fail;
		}
	    }

	    /*
	    // Add the validated element to the intrep under construction.
	    */
	    TRACE (("++ (%d...%d)", start, end));
	    marpa_scr_add_range(&scr, start, end);
	}

	TRACE (("USE %d", scr->n));
	
	otscr = (OTSCR*) ckalloc(sizeof(OTSCR));
	otscr->refCount = 1;
	otscr->scr = scr;

	/*
	// Kill the old intrep (a list). This was delayed as much as
	// possible. Afterward we can put in our own intrep.
	*/

	FreeIntRep (o);

	o->internalRep.otherValuePtr = otscr;
	o->typePtr                   = &marpa_scr_objtype;

	TRACE_RETURN ("ok: %d", TCL_OK);

    fail:
	if (scr) marpa_scr_destroy(scr);
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
	Tcl_Obj* obj = Tcl_NewObj ();

	Tcl_InvalidateStringRep (obj);
	obj->internalRep.otherValuePtr = marpa_otscr_take (otscr);
	obj->typePtr                   = &marpa_scr_objtype;
	return obj;
    }

    int
    marpa_get_otscr_from_obj (Tcl_Interp* interp, Tcl_Obj* o, OTSCR** otscrPtr)
    {
	if (o->typePtr != &marpa_scr_objtype) {
	    if (marpa_scr_rep_from_any (interp, o) != TCL_OK) {
		return TCL_ERROR;
	    }
	}

	*otscrPtr = (OTSCR*) o->internalRep.otherValuePtr;
	return TCL_OK;
    }
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_CharClass {
    if (marpa_get_otscr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} OTSCR* OTSCR*

critcl::resulttype Marpa_CharClass {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpa_new_otscr_obj (rv));
    /* No refcount adjustment */
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
    return marpa_otscr_new (marpa_scr_complement (charclass->scr));
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
    marpa_scr_norm (charclass->scr);
    return charclass;
}

# # ## ### ##### ######## #############
return
