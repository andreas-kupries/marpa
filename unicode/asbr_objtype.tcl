# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Tcl_ObjType for ASBR-based Unicode Char Classes
## (See c/asbr_*.[ch] for definitions)

critcl::include to_utf.h           ;# flags
critcl::include asbr_objtype_int.h ;# Full type definitions

# # ## ### ##### ######## #############
# Glue to critcl::cproc

critcl::argtype Marpa_ASBR {
        TRACE ("A(Marpa_ASBR): obj %p/%d, otscr %p/%d", @@, @@->refCount, @A, @A ? @A->refCount : -5);
    if (marpatcl_get_otasbr_from_obj (interp, @@, &@A) != TCL_OK) {
	return TCL_ERROR;
    }
} OTASBR_p OTASBR_p

critcl::resulttype Marpa_ASBR {
    TRACE ("R(Marpa_ASBR): otscr %p/%d", rv, rv ? rv->refCount : -5);
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, marpatcl_new_otasbr_obj (rv));
    TRACE ("R(Marpa_ASBR): obj %p/%d", Tcl_GetObjResult(interp), Tcl_GetObjResult(interp)->refCount);
    /* No refcount adjustment */
    return TCL_OK;
} OTASBR_p

# # ## ### ##### ######## #############
## API exposed to Tcl level

critcl::cproc marpa::unicode::2asbr {
    Tcl_Interp*     interp
    Marpa_CharClass charclass
    marpatcl_uflags {flags 0}
} Marpa_ASBR {
    OTASBR_p r;
    /* charclass :: OTSCR* */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d), flags %d)", charclass, charclass->refCount, flags);
    TRACE ("(SCR*) %p", charclass->scr);
    r = marpatcl_otasbr_new (marpatcl_asbr_new (charclass->scr, flags));
    TRACE_RETURN ("(OTASBR*) %p", r);
}

# # ## ### ##### ######## #############
return
