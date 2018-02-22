# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Tcl_ObjType for SCR-based Unicode Char Classes
## (See c/scr_*.[ch] for definitions)

critcl::include scr_objtype_int.h ;# Full type definitions

# # ## ### ##### ######## #############
## Holder for the Tcl_ObjType's used by the `rep_from_any`.
## scr_objtype.c includes the header file created for the iassoc.

critcl::iassoc::def marpatcl_unicontext {} {
    Tcl_ObjType* listType;
    Tcl_ObjType* intType;
} {
    Tcl_Obj* lst;
    Tcl_Obj* elt;

    elt = Tcl_NewIntObj(0);
    data->intType = elt->typePtr;

    lst = Tcl_NewListObj (1, &elt);
    data->listType = lst->typePtr;
    Tcl_DecrRefCount (lst);
} {
    /* nothing to do */
}

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_CharClass {
    @A = NULL;
    TRACE ("A(Marpa_CharClass): obj %p (rc=%d)", @@, @@->refCount);
    if (marpatcl_get_otscr_from_obj (interp, @@, &@A) != TCL_OK) {
	TRACE ("%s", "A(Marpa_CharClass): ERROR");
	return TCL_ERROR;
    }
    TRACE ("A(Marpa_CharClass): (OTSCR*) %p (rc=%d)", @A, @A->refCount);
    TRACE ("%s", "A(Marpa_CharClass): DONE");
} OTSCR_p OTSCR_p

critcl::resulttype Marpa_CharClass {
    TRACE ("R(Marpa_CharClass): (OTSCR*) %p (rc=%d)", rv, rv ? rv->refCount : -5);
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpatcl_new_otscr_obj (rv));
    TRACE ("R(Marpa_CharClass): obj %p (rc=%d)",
	   Tcl_GetObjResult(interp),
	   Tcl_GetObjResult(interp)->refCount);
    /* No refcount adjustment */
    TRACE ("%s", "R(Marpa_CharClass): DONE");
    return TCL_OK;
} OTSCR_p

# # ## ### ##### ######## #############
## API exposed to Tcl level

critcl::cproc marpa::unicode::negate-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
    /* charclass :: OTSCR_p */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))", charclass, charclass->refCount);
    TRACE ("(SCR*) %p", charclass->scr);
    charclass = marpatcl_otscr_new (marpatcl_scr_complement (charclass->scr));
    TRACE_RETURN ("(OTSCR*) %p", charclass);
}

critcl::cproc marpa::unicode::norm-class {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_CharClass {
    /*
     * charclass :: OTSCR*
     * The deeper intrep is modified.
     * A possible string rep is not.
     */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))",
		charclass, charclass->refCount);
    TRACE ("(SCR*) %p", charclass->scr);
    marpatcl_scr_norm (charclass->scr);
    TRACE_RETURN ("(OTSCR*) %p", charclass);
}

# # ## ### ##### ######## #############
return
