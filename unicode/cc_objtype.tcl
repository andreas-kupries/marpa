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
