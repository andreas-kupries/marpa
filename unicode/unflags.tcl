# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############

package require Tcl 8.5
package require critcl 3.1.11
critcl::buildrequirement {
    package require critcl::bitmap
}

# # ## ### ##### ######## #############
## Map the C-level flags for the codepoint encoder (2utf) to strings
## and back.

critcl::include to_utf.h ;# Flag definitions
critcl::bitmap::def marpatcl_uflags {
    mutf MARPATCL_MUTF
    cesu MARPATCL_CESU
    tcl  MARPATCL_TCL
    all  MARPATCL_TCL
} {tcl all}

# API pieces
##
# Encoder:     int     marpatcl_uflags_encode (interp, Tcl_Obj* state, int* result) :: string -> type
# Decoder:     TclObj* marpatcl_uflags_decode (interp, int      state)              :: type -> string
#
# Encoder/C:   int         marpatcl_uflags_encode_cstr (const char* state) :: string -> type
# Decoder/C:   const char* marpatcl_uflags_decode_cstr (int         state) :: type -> string
#
# Decl Hdr:    marpatcl_uflags.h
#
# Arg-Type:    marpatcl_uflags
# Result-Type: marpatcl_uflags

# # ## ### ##### ######## #############
return
