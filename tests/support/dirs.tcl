# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Quick access to common directories of the testsuite.

proc td {} {
    return [file normalize $::tcltest::testsDirectory]
}

proc grdir {args} {
    return [file normalize [file join [td] grammars {*}$args]]
}

proc trdir {args} {
    return [file normalize [file join [td] traces {*}$args]]
}

proc redir {args} {
    return [file normalize [file join [td] results {*}$args]]
}

# # ## ### ##### ######## #############
return