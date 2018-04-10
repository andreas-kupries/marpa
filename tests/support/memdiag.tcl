# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
#
# Memory diagnosis support

package require TclOO
package require fileutil

# # ## ### ##### ######## #############
## Basic memory statistics: current and max allocation (bytes)

proc memusage {label} { #return
    lassign [split [memory info] \n] tm tf cpa cba mpa mba

    set cba [lindex $cba end]
    set mba [lindex $mba end]
    
    puts "memuse\t$label\t$cba\t$mba"
    return
}

# # ## ### ##### ######## #############
## Dump a list of all active objects and their classes into a file.
## Information is sorted, for easier differencing.

proc odump {dst} {
    set lines {}
    foreach c [lsort -dict [info class instances oo::class]] {
	foreach o [lsort -dict [info class instances $c]] {
	    set n [info object namespace $o]
	    lappend lines "O\t$o\t$n\t$c"
	}
    }
    fileutil::writeFile $dst [join $lines \n]\n
    return
}

# # ## ### ##### ######## #############
return
