# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Quick access to common directories of the testsuite.

proc td {} {
    return [file normalize $::tcltest::testsDirectory]
}

proc indir {args} {
    return [file normalize [file join [td] input {*}$args]]
}

proc redir {args} {
    return [file normalize [file join [td] result {*}$args]]
}

proc locate {base args} {
    foreach file $args {
	set path [file join $base $file]
	if {![file exists $path]} continue
	return $path
    }
    return -code error "Unable to find any of [join $args {, }] for $base"
}

# # ## ### ##### ######## #############
return
