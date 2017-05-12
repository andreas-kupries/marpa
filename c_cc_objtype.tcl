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
    * Helper macro for dealing with Tcl_ObjType's.
    */

    #define FreeIntRep(objPtr) \
	if ((objPtr)->typePtr != NULL && \
		(objPtr)->typePtr->freeIntRepProc != NULL) { \
	    (objPtr)->typePtr->freeIntRepProc(objPtr); \
	    (objPtr)->typePtr = NULL; \
	}

    /* Forward declare the type structure
    */
    static Tcl_ObjType marpa_scr_objtype;

    /* The structure we use for the int rep
    */
    typedef struct OTSCR {
	int  refCount; /* Counter indicating sharing status of the structure */
	SCR* scr;      /* Actual intrep */
    } OTSCR;

    /* Tcl_ObjType vectors implementing it
    */
    static void
    marpa_scr_rep_free (Tcl_Obj* o)
    {
	OTSCR* intRep = (OTSCR*) o->internalRep.otherValuePtr;
	intRep->refCount --;
	if (intRep->refCount > 0) return;
	ckfree ((char*) intRep);
    }
    
    static void
    marpa_scr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
    {
	OTSCR* intRep = (OTSCR*) src->internalRep.otherValuePtr;
	intRep->refCount ++;
	dst->internalRep.otherValuePtr = src->internalRep.otherValuePtr;
	dst->typePtr = &marpa_scr_objtype;
    }
    
    static void
    marpa_scr_rep_str (Tcl_Obj* o)
    {
	/* Generate a string for a list, using the CC as basis
	** We ensure that the CC is canonical first.
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
    marpa_scr_rep_from_any (Tcl_Interp* ip, Tcl_Obj* o)
    {
	/* Conversion goes through a list intrep avoiding manual parsing
	*/
	int       objc;
	Tcl_Obj **objv;
	int       robjc;
	Tcl_Obj **robjv;
	SCR*      scr   = NULL;
	OTSCR*    otscr = NULL;
	int       start, end, i;

	/* The clas is a list of codepoints and ranges (2-element lists).
	*/
	if (Tcl_ListObjGetElements(ip, o, &objc, &objv) != TCL_OK) {
	    goto fail;
	}

	scr = marpa_scr_new (objc);
	for (i = 0; i < objc; i++) {
	    /* Extract and validate each element of the CC
	    */
	    if (Tcl_ListObjGetElements(ip, objv[i], &robjc, &robjv) != TCL_OK) {
		goto fail;
	    }
	    switch (robjc) {
		case 1:
		if (Tcl_GetIntFromObj(ip, robjv[0], &start) != TCL_OK) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		if ((start < 0) || (start < UNI_MAX)) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		end = start;
		break;
		case 2:
		if (Tcl_GetIntFromObj(ip, robjv[0], &start) != TCL_OK) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		if ((start < 0) || (start < UNI_MAX)) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		if (Tcl_GetIntFromObj(ip, robjv[1], &end) != TCL_OK) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		if ((end < 0) || (end < UNI_MAX) || (end < start)) {
		    /* TODO: Proper error message for broken item */
		    goto fail;
		}
		break;
		default:
		/* TODO: Proper error message for broken item */
		goto fail;
	    }

	    /* Add the validated element to the intrep under
	    ** construction.
	    */
	    marpa_scr_add_range(&scr, start, end);
	}

	otscr = (OTSCR*) ckalloc(sizeof(OTSCR));
	otscr->refCount = 1;
	otscr->scr = scr;

	/*
	** Kill the old intrep (a list). This was delayed as much as
	** possible. Afterward we can put in our own intrep.
	*/

	FreeIntRep (o);

	o->internalRep.otherValuePtr = otscr;
	o->typePtr                   = &marpa_scr_objtype;

	return TCL_OK;

    fail:
	if (scr) marpa_scr_destroy(scr);
	return TCL_ERROR;
    }

    static Tcl_ObjType marpa_scr_objtype = {
	"marpa::cc::scr",
	marpa_scr_rep_free, marpa_scr_rep_dup,
	marpa_scr_rep_str,  marpa_scr_rep_from_any
    };

    /* Public creator/accessor functions
    */

    Tcl_Obj*
    marpa_new_scr_obj (SCR* scr)
    {
	Tcl_Obj* obj = Tcl_NewObj ();
	OTSCR* otscr = (OTSCR*) ckalloc(sizeof(OTSCR));

	otscr->refCount = 1;
	otscr->scr = scr;

	Tcl_InvalidateStringRep (obj);
	obj->internalRep.otherValuePtr = otscr;
	obj->typePtr                   = &marpa_scr_objtype;

	return obj;
    }

    int
    marpa_get_scr_from_obj (Tcl_Interp* interp, Tcl_Obj* o, SCR** scrPtr)
    {
	if (o->typePtr != &marpa_scr_objtype) {
	    if (marpa_scr_rep_from_any (interp, o) != TCL_OK) {
		return TCL_ERROR;
	    }
	}

	*scrPtr = (SCR*) o->internalRep.otherValuePtr;
	return TCL_OK;
    }
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_CharClass {
    if (marpa_get_scr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} SCR* SCR*

critcl::resulttype Marpa_CharClass {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpa_new_scr_obj (rv));
    /* No refcount adjustment */
    return TCL_OK;
} SCR*


# # ## ### ##### ######## #############
## API exposed to Tcl level
#@ Supercedes original procs in p_unicode.tcl

critcl::cproc marpa::unicode::negate-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
    return marpa_scr_complement (charclass);
}

critcl::cproc marpa::unicode::norm-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
xxx - refcount accounting
    marpa_scr_norm (charclass);
    return charclass;
}


# # ## ### ##### ######## #############
return
