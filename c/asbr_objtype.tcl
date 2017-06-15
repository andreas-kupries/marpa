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
##   int marpa_get_otasbr_from_obj (Tcl_Obj* o, OTASBR** otasbrPtr) - Retrieve OTASBR from Tcl_Obj
##   ... marpa_new_otasbr_obj (Tcl_Obj* o, OTASBR* otasbr)          - Wrap OTASBR into Tcl_Obj (+1 ref)
#
## CriTcl Glue
#
## - cproc argument type
## - cproc result type

critcl::ccode {
    #define INT_REP       internalRep.otherValuePtr
    #define OTASBR_REP(o) ((OTASBR*) (o)->INT_REP)

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
	OTASBR* otasbr;
	TRACE_ENTER("marpa_otasbr_new");

	otasbr = (OTASBR*) ckalloc (sizeof (OTASBR));
	TRACE (("NEW otasbr = %p", otasbr));

	otasbr->refCount = 0;
	otasbr->asbr = asbr;

	TRACE_RETURN("==> otasbr :: %p", otasbr);
    }

    void
    marpa_otasbr_destroy (OTASBR* otasbr)
    {
	TRACE_ENTER("marpa_otasbr_destroy");
	marpa_asbr_destroy (otasbr->asbr);

	TRACE (("DEL otasbr = %p", otasbr));
	ckfree((char*) otasbr);

	TRACE_RETURN_VOID;
    }

    OTASBR*
    marpa_otasbr_take (OTASBR* otasbr)
    {
	TRACE_ENTER("marpa_otasbr_take");
	
	otasbr->refCount ++;
	TRACE (("%p RC %d", otasbr, otasbr ? otasbr->refCount : -5));
	TRACE_RETURN("==> otscr :: %p", otasbr);
    }
    
    void
    marpa_otasbr_release (OTASBR* otasbr)
    {
	TRACE_ENTER("marpa_otasbr_release");

	otasbr->refCount --;
	TRACE (("%p RC %d", otasbr, otasbr ? otasbr->refCount : -5));

	if (otasbr->refCount > 0) {
	    TRACE_RETURN_VOID;
	}

	marpa_otasbr_destroy (otasbr);
	TRACE_RETURN_VOID;
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
	TRACE_ENTER("marpa_asbr_rep_free");
	marpa_otasbr_release (OTASBR_REP(o));
	TRACE_RETURN_VOID;
    }
    
    static void
    marpa_asbr_rep_dup (Tcl_Obj* src, Tcl_Obj* dst)
    {
	TRACE_ENTER("marpa_asbr_rep_dup");
	TRACE (("Tcl_Obj %p RC %d", src, src ? src->refCount : -5));

	marpa_otasbr_take (OTASBR_REP(src));
	dst->INT_REP = src->INT_REP;
	dst->typePtr = &marpa_asbr_objtype;

	TRACE_RETURN_VOID;
    }
    
    static void
    marpa_asbr_rep_str (Tcl_Obj* o)
    {
	/*
	** Generate a string for a nested list, using the ASBR as basis
	*/
	char        buf [20];
	ASBR*       asbr = OTASBR_REP(o)->asbr;
	Tcl_DString ds;
	int         i, k;
	SBR*        sbr;
	BR*         br;
	
	TRACE_ENTER("marpa_asbr_rep_str");
	TRACE (("Tcl_Obj %p RC %d", o, o ? o->refCount : -5));

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
	ASBR*     asbr   = NULL;
	OTASBR*   otasbr = NULL;
	int       start, end, i;

	TRACE_ENTER ("marpa_asbr_rep_from_any");
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
	NULL /* from_any not supported, only via 2asbr from OTSCR */,
    };

    /* Public creator/accessor functions
    */

    Tcl_Obj*
    marpa_new_otasbr_obj (OTASBR* otasbr)
    {
	Tcl_Obj* obj = Tcl_NewObj ();
	TRACE_ENTER("marpa_new_otasbr_obj");
	
	Tcl_InvalidateStringRep (obj);
	obj->internalRep.otherValuePtr = marpa_otasbr_take (otasbr);
	obj->typePtr                   = &marpa_asbr_objtype;

	TRACE_RETURN("==> obj :: %p", obj);
    }

    int
    marpa_get_otasbr_from_obj (Tcl_Interp* interp, Tcl_Obj* o, OTASBR** otasbrPtr)
    {
	TRACE_ENTER("marpa_get_otscr_from_obj");
	if (o->typePtr != &marpa_asbr_objtype) {
	    if (marpa_asbr_rep_from_any (interp, o) != TCL_OK) {
		TRACE_RETURN("==> ERROR", TCL_ERROR);
	    }
	}

	*otasbrPtr = OTASBR_REP(o);
	TRACE (("==> otasbr :: %p", *otasbrPtr));
	TRACE_RETURN("==> OK", TCL_OK);
    }
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_ASBR {
        TRACE (("A(Marpa_ASBR): obj %p/%d, otscr %p/%d", @@, @@->refCount, @A, @A ? @A->refCount : -5));
    if (marpa_get_otasbr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} OTASBR* OTASBR*

critcl::resulttype Marpa_ASBR {
    TRACE (("R(Marpa_ASBR): otscr %p/%d", rv, rv ? rv->refCount : -5));
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpa_new_otasbr_obj (rv));
    TRACE (("R(Marpa_ASBR): obj %p/%d", Tcl_GetObjResult(interp), Tcl_GetObjResult(interp)->refCount));
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
    TRACE_ENTER("marpa::unicode::2asbr");
    TRACE_RETURN("==> otasbr :: %p", marpa_otasbr_new (marpa_asbr_new (charclass->scr)));
}

# # ## ### ##### ######## #############
return
