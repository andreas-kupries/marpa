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
kt local   support marpa::gen::reformat

proc gc-format {serial {step {    }}} {
    return "grammar \{\n[marpa::gen reformat $serial {} $step]\n\}"
}

# # ## ### ##### ######## #############
return
