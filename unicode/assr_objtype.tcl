# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Tcl_ObjType for ASSR-based Unicode Char Classes
## (See c/assr_*.[ch] for definitions)

critcl::include assr_objtype_int.h ;# Full type definitions

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_ASSR {
        TRACE ("A(Marpa_ASSR): obj %p/%d, otscr %p/%d", @@, @@->refCount, @A, @A ? @A->refCount : -5);
    if (marpatcl_get_otassr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} OTASSR_p OTASSR_p

critcl::resulttype Marpa_ASSR {
    TRACE ("R(Marpa_ASSR): otscr %p/%d", rv, rv ? rv->refCount : -5);
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpatcl_new_otassr_obj (rv));
    TRACE ("R(Marpa_ASSR): obj %p/%d", Tcl_GetObjResult(interp), Tcl_GetObjResult(interp)->refCount);
    /* No refcount adjustment */
    return TCL_OK;
} OTASSR_p

# # ## ### ##### ######## #############
## API exposed to Tcl level

critcl::cproc marpa::unicode::2assr {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
} Marpa_ASSR {
    OTASSR_p r;
    /* charclass :: OTSCR* */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))", charclass, charclass->refCount);
    TRACE ("(SCR*) %p", charclass->scr);
    r = marpatcl_otassr_new (marpatcl_assr_new (charclass->scr));
    TRACE_RETURN ("(OTASSR*) %p", r);
}

# # ## ### ##### ######## #############
return
