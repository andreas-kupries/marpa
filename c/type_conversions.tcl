# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Custom argument and result types for cproc and cproc-like methods.
## Declare conversions between the Tcl and C levels.

# # ## ### ##### ######## #############
## Results ...

critcl::resulttype Marpa_Int {
    return marpatcl_result (interp, ((MarpaTcl_Base*) cd), rv, NULL);
} int

critcl::resulttype Marpa_Rank          = Marpa_Int
critcl::resulttype Marpa_Boolean       = Marpa_Int
critcl::resulttype Marpa_Earleme       = Marpa_Int
critcl::resulttype Marpa_Earley_Set_ID = Marpa_Int

critcl::resulttype Marpa_Symbol_Int {
    return marpatcl_result (interp, ((MarpaTcl_Base*) cd), rv, "No symbol found for id");
} int

critcl::resulttype Marpa_Symbol_ID      = Marpa_Symbol_Int
critcl::resulttype Marpa_Symbol_Boolean = Marpa_Symbol_Int

critcl::resulttype Marpa_StartSymbol_ID {
    return marpatcl_result (interp, ((MarpaTcl_Base*) cd), rv, "No start symbol defined");
} int

critcl::resulttype Marpa_Rule_Int {
    return marpatcl_result (interp, ((MarpaTcl_Base*) cd), rv, "No rule found for id");
} int

critcl::resulttype Marpa_Rule_ID      = Marpa_Rule_Int
critcl::resulttype Marpa_Rule_Boolean = Marpa_Rule_Int

# # ## ### ##### ######## #############
## ... and arguments

critcl::argtype Marpa_Symbol_ID     = int
critcl::argtype Marpa_Rule_ID       = int
critcl::argtype Marpa_Rule_Int      = int
critcl::argtype Marpa_Rank          = int
critcl::argtype Marpa_Earleme       = int
critcl::argtype Marpa_Earley_Set_ID = int

critcl::ccode {
    #define NIL (-1) /* undefined/null/nil symbol, rule, ... */
}

# # ## ### ##### ######## #############

critcl::resulttype MarpaTcl_Obj* {
    if (rv == NULL) { return TCL_ERROR; }
    Tcl_SetObjResult(interp, rv);
    /* No refcount adjustment */
    return TCL_OK;
} Tcl_Obj*

# # ## ### ##### ######## #############
return
