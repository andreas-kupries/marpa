# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Utilities for C-level debugging (narrative)

# # ## ### ##### ######## #############
## Debug output (stdout) - TODO: stderr, hide in helper VA function
## Or see if we can declare a varargs macro.

critcl::ccode {
    #ifdef DEBUG
    #  define TRACE printf
    #else
    #  define TRACE if (0) printf
    #endif
}

# # ## ### ##### ######## #############
return
