# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

package require TclOO

# Test suite support.
# # ## ### ##### ######## #############
## Fake input to use upstream of a gate

proc fake-in  {} { global __in ; set __in [Marpa::Testing::FIN new] }
proc inok     {} { global __in ; $__in destroy ; unset __in }

# # ## ### ##### ######## #############
## Fake Input.

oo::class create Marpa::Testing::FIN {
    method rewind {n} { return }
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
