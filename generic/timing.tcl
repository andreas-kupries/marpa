# -*- tcl -*-
##
# (c) 2016-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for benchmarking of method calls through filtering

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

debug define util/benchmarking
#debug prefix util/benchmarking {[debug caller] | }

# # ## ### ##### ######## #############
## Helper command to prepare a class for benchmarking.

proc method-benchmarking {} {
    debug.util/benchmarking {Benchmarking [marpa D {
        oo::objdefine [uplevel 1 self] mixin marpa::method-benchmarking
    }]}
    return
}

# # ## ### ##### ######## #############
## Mixin filter class for benchmarking

oo::class create marpa::method-benchmarking {
    # # -- --- ----- -------- -------------

    filter Bench
    method Bench {args} {
	set micro [lindex [time {set result [next {*}$args]} 1] 0]
	debug.util/benchmarking {[self target] time $micro}
	return $result
    }
}

# # ## ### ##### ######## #############
return
