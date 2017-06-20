# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Pretty printing a serialization coming out of the SLIF container
## Reusing internals from the generator backend "marpa::export::gc-formatted".

proc gc-format {serial {step {    }}} {
    return "grammar \{\n[marpa::export::gc-formatted::Reformat $serial {} $step]\n\}"
}

# # ## ### ##### ######## #############
return
