# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Script glue to the unicode structures and utilities.

#critcl::include unidata.h

# # ## ### ##### ######## #############

critcl::cproc marpa::unicode::data::fold {
    Tcl_Interp*     interp
    Marpa_Codepoint codepoint
} object0 {
    int r, i, n, *codes;
    Tcl_Obj* b;

    marpatcl_unfold (codepoint, &n, &codes);

    b = Tcl_NewListObj (0,0);
    if (n == 0) {
	// Codepoint is its own fold class.
	r = Tcl_ListObjAppendElement (interp, b, Tcl_NewIntObj (codepoint));
	if (r != TCL_OK) goto fail;
	return b;
    }

    // Assemble fold class
    for (i = 0; i < n; i++) {
        r = Tcl_ListObjAppendElement (interp, b, Tcl_NewIntObj (codes[i]));
	if (r != TCL_OK) goto fail;
    }
    return b;

fail:
    Tcl_DecrRefCount (b);
    return 0;
}

critcl::cproc marpa::unicode::data::fold/c {
    Tcl_Interp*     interp
    Marpa_Codepoint codepoint
} int {
    int r, i, n, *codes;
    Tcl_Obj* b;

    marpatcl_unfold (codepoint, &n, &codes);

    b = Tcl_NewListObj (0,0);
    if (n == 0) {
	// Codepoint is its own fold class.
	return codepoint;
    } else {
	return codes [0];
    }
}

# # ## ### ##### ######## #############
return
