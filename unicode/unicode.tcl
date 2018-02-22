# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Script glue to the unicode structures and utilities.

critcl::include asbr_int.h ;# SBR
critcl::include to_utf.h   ;# marpatcl_to_utf

# # ## ### ##### ######## #############

critcl::cconst marpa::unicode::max int UNI_MAX

# # ## ### ##### ######## #############

critcl::cproc marpa::unicode::2utf {
    Tcl_Interp*     interp
    Marpa_Codepoint code
    marpatcl_uflags {flags 0}
} object0 {
    int r, i;
    Tcl_Obj* b;
    SBR sbr;

    marpatcl_to_utf (&sbr, code, flags);

    b = Tcl_NewListObj (0,0);
    for (i = 0; i < sbr.n; i++) {
	r = Tcl_ListObjAppendElement (interp, b, Tcl_NewIntObj (sbr.br[i].start));
	if (r == TCL_OK) continue;
	Tcl_DecrRefCount (b);
	return 0;
    }
    return b;
}

# # ## ### ##### ######## #############
return
