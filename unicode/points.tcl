# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############

package require Tcl 8.5
package require critcl 3.1.11

# # ## ### ##### ######## #############

critcl::include points.h

critcl::argtype Marpa_Codepoint {
    TRACE ("A(Marpa_Codepoint): obj %p (rc=%d)", @@, @@->refCount);
    if (marpatcl_get_codepoint_from_obj (interp, @@, &@A) != TCL_OK) {
	TRACE ("%s", "A(Marpa_Codepoint): ERROR");
	return TCL_ERROR;
    }
    TRACE ("A(Marpa_Codepoint): %d", @A);
    TRACE ("%s", "A(Marpa_Codepoint): DONE");
} int int

# # ## ### ##### ######## #############
return
