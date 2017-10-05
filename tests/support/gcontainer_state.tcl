# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Pretty printing a serialization coming out of the SLIF container
## Reusing internals of generator "marpa::gen::format::gc".

kt local   support marpa::gen
kt local   support marpa::gen::format::gc

proc gc-format {serial {step {    }}} {
    return "grammar \{\n[marpa::gen::format::gc::Reformat $serial {} $step]\n\}"
}

# # ## ### ##### ######## #############
return
