# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Script glue to the unicode structures and utilities.

critcl::include scr_int.h ;# CR
critcl::include to_char.h ;# marpatcl_to_char

# # ## ### ##### ######## #############

critcl::cproc marpa::unicode::2char {
    Tcl_Interp*     interp
    Marpa_Codepoint code
} object0 {
    int r, i, n;
    Tcl_Obj* b;
    CR cr[2];

    marpatcl_to_char (cr, &n, code);

    b = Tcl_NewListObj (0,0);
    for (i = 0; i < n; i++) {
	r = Tcl_ListObjAppendElement (interp, b, Tcl_NewIntObj (cr[i].start));
	if (r == TCL_OK) continue;
	Tcl_DecrRefCount (b);
	return 0;
    }
    return b;
}

# # ## ### ##### ######## #############
return
