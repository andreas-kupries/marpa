# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Handle differences between Tcl core versions
## 8.5: args => `...`
## 8.6: args => `?args ...?`

if {[package vsatisfies [info tclversion] 8.6]} {
    proc ARGS {m} {
	string map [list ... {?arg ...?}] $m
    }
    proc CORE {85 86} { set 86 }
    return
}

if {[package vsatisfies [info tclversion] 8.5]} {
    proc ARGS {m} {
	set m
    }
    proc CORE {85 86} { set 85 }
    return
}

error "Unhandled version of the Tcl core"

# # ## ### ##### ######## #############
return
