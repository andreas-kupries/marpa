# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Tcl_ObjType for ASBR-based Unicode Char Classes
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
    ** The structure we use for the int rep
    */
    
    typedef struct OTASBR {
	int   refCount; /* Counter indicating sharing status of the structure */
	ASBR* asbr;     /* Actual intrep */
    } OTASBR;

    /*
    ** Helper functions for intrep lifecycle and use.
    */

    OTASBR*
    marpa_otasbr_new (ASBR* asbr)
    {
	OTASBR* otasbr = (OTASBR*) ckalloc (sizeof (OTASBR));
	otasbr->refCount = 0;
	otasbr->asbr = asbr;
	return otasbr;
    }

    void
    marpa_otasbr_destroy (OTASBR* otasbr)
    {
	marpa_asbr_destroy (otasbr->asbr);
	ckfree((char*) otasbr);
	return;
    }

    OTASBR*
    marpa_otasbr_take (OTASBR* otasbr)
    {
	otasbr->refCount ++;
	return otasbr;
    }
    
    void
    marpa_otasbr_release (OTASBR* otasbr)
    {
	otasbr->refCount --;
	if (otasbr->refCount > 0) return;
	marpa_otasbr_destroy (otasbr);
    }

    /*
    ** Helper macro for dealing with Tcl_ObjType's.
    */

    #undef  FreeIntRep
    #define FreeIntRep(objPtr) \
	if ((objPtr)->typePtr != NULL && \
		(objPtr)->typePtr->freeIntRepProc != NULL) { \
	    (objPtr)->typePtr->freeIntRepProc(objPtr); \
	    (objPtr)->typePtr = NULL; \
	}

    /*
    ** Forward declare the type structure
    */
    
    static Tcl_ObjType marpa_asbr_objtype;

    /*
    ** Tcl_ObjType vectors implementing it
    */
    
    static void
    marpa_asbr_rep_free (Tcl_Obj* o)
    {
	OTASBR* intRep = (OTASBR*) o->internalRep.otherValuePtr;
	intRep->refCount --;
	if (intRep->refCount > 0) return;
	marpa_otasbr_release (intRep);
    }
    
    static void
    marpa_asbr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
    {
	OTASBR* intRep = (OTASBR*) src->internalRep.otherValuePtr;
	marpa_otasbr_take (intRep);
	dst->internalRep.otherValuePtr = src->internalRep.otherValuePtr;
	dst->typePtr = &marpa_asbr_objtype;
    }
    
    static void
    marpa_asbr_rep_str (Tcl_Obj* o)
    {
	/*
	** Generate a string for a nested list, using the ASBR as basis
	*/
	char        buf [20];
	OTASBR*     intRep = (OTASBR*) o->internalRep.otherValuePtr;
	ASBR*       asbr   = intRep->asbr;
	Tcl_DString ds;
	int         i, k, length;
	SBR*        sbr;
	BR*         br;
	
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
	
	length = Tcl_DStringLength (&ds);
	
	o->length = length;
	o->bytes  = ckalloc(length);
	memcpy (o->bytes, Tcl_DStringValue (&ds), length+1);

	Tcl_DStringFree (&ds);
    }
    
    static int
    marpa_asbr_rep_from_any (Tcl_Interp* ip, Tcl_Obj* o)
    {
	/*
	** The conversion goes through a list intrep avoiding manual parsing
	*/
	int       objc;
	Tcl_Obj **objv;
	int       robjc;
	Tcl_Obj **robjv;
	ASBR*      asbr   = NULL;
	OTASBR*    otasbr = NULL;
	int       start, end, i;

	/*
	** The ASBR is a list of alternates. Each alternate is a
	** sequence, i.e. a list of pairs. Each pair is a list of two
	** integers in the range 0-256.
	*
	** The additional condition that each alternate has no
        ** intersection with any other is difficult to check, and left
        ** out.
	*/

	if (Tcl_ListObjGetElements(ip, o, &objc, &objv) != TCL_OK) {
	    goto fail;
	}

	/* ... generally complex ... leaving out ... constructed from SCR anyway */

	otasbr = (OTASBR*) ckalloc(sizeof(OTASBR));
	otasbr->refCount = 1;
	otasbr->asbr = asbr;

	/*
	** Kill the old intrep (a list). This was delayed as much as
	** possible. Afterward we can put in our own intrep.
	*/

	FreeIntRep (o);

	o->internalRep.otherValuePtr = otasbr;
	o->typePtr                   = &marpa_asbr_objtype;

	return TCL_OK;

    fail:
	if (asbr) marpa_asbr_destroy(asbr);
	return TCL_ERROR;
    }

    static Tcl_ObjType marpa_asbr_objtype = {
	"marpa::cc::asbr",
	marpa_asbr_rep_free,
	marpa_asbr_rep_dup,
	marpa_asbr_rep_str,
	NULL,
    };

    /* Public creator/accessor functions
    */

    Tcl_Obj*
    marpa_new_otasbr_obj (OTASBR* otasbr)
    {
	Tcl_Obj* obj = Tcl_NewObj ();

	Tcl_InvalidateStringRep (obj);
	obj->internalRep.otherValuePtr = marpa_otasbr_take (otasbr);
	obj->typePtr                   = &marpa_asbr_objtype;
	return obj;
    }

    int
    marpa_get_otasbr_from_obj (Tcl_Interp* interp, Tcl_Obj* o, OTASBR** otasbrPtr)
    {
	if (o->typePtr != &marpa_asbr_objtype) {
	    if (marpa_asbr_rep_from_any (interp, o) != TCL_OK) {
		return TCL_ERROR;
	    }
	}

	*otasbrPtr = (OTASBR*) o->internalRep.otherValuePtr;
	return TCL_OK;
    }
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_ASBR {
    if (marpa_get_otasbr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} OTASBR* OTASBR*

critcl::resulttype Marpa_ASBR {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpa_new_otasbr_obj (rv));
    /* No refcount adjustment */
    return TCL_OK;
} OTASBR*

# # ## ### ##### ######## #############
## API exposed to Tcl level
## Supercedes original procs in p_unicode.tcl

critcl::cproc marpa::unicode::2asbr {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_ASBR {
    /* charclass :: OTSCR* */
    return marpa_otasbr_new (marpa_asbr_new (charclass->scr));
}

# # ## ### ##### ######## #############
return
