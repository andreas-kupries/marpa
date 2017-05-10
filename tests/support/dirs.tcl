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

proc grdir {} {
    return [file normalize [file join [td] grammars]]
}

proc trdir {} {
    return [file normalize [file join [td] traces]]
}

# # ## ### ##### ######## #############
return
