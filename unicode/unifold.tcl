# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Script glue to the unicode structures and utilities.

# # ## ### ##### ######## #############
## Tcl_ObjType for SCR-based Unicode Char Classes
## (See c/scr_*.[ch] for definitions)

critcl::include scr_objtype_int.h ;# Full type definitions

#critcl::include unidata.h

# # ## ### ##### ######## #############

critcl::cproc marpa::unicode::unfold {
    Tcl_Interp*     interp
    Marpa_CharClass codes
} Marpa_CharClass {
    /* codes :: OTSCR_p */
    TRACE_FUNC ("((OTSCR*) %p (rc=%d))", codes, codes->refCount);
    TRACE ("(SCR*) %p", codes->scr);
    codes = marpatcl_otscr_new (marpatcl_scr_unfold (codes->scr));
    TRACE_RETURN ("(OTSCR*) %p", codes);
}

critcl::cproc marpa::unicode::fold/c {
    Tcl_Interp* interp
    list        codes
} object0 {
    /* codes.(c,v) */
    Tcl_Obj*  b;

    // lmap codepoint $codes { data fold/c $codepoint }

    if (!codes.c) {
	b = Tcl_NewListObj (0,0);
    } else {
	int r, i, n, *fold, codepoint;
        Tcl_Obj** v = NALLOC (Tcl_Obj*, codes.c);

	for (i = 0; i < codes.c; i++) {
	    if (marpatcl_get_codepoint_from_obj (interp, codes.v[i], &codepoint) != TCL_OK) {
		Tcl_DecrRefCount (b);
		return 0;
	    }

	    marpatcl_unfold (codepoint, &n, &fold);
	    v [i] = Tcl_NewIntObj (n ? fold[0] : codepoint);
	}
        b = Tcl_NewListObj (codes.c, v);
    }
    return b;
}

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
