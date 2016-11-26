# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

package require TclOO

# Test suite support.
# # ## ### ##### ######## #############
## Fake parser engines to use as mock upstream of a lexer

proc fake-parse  {} { global __parse ; set __parse [Marpa::Testing::P new] }
proc parsed      {} { global __parse ; $__parse destroy ; unset __parse }

# # ## ### ##### ######## #############
## Fake Parse Engine.

oo::class create Marpa::Testing::P {
    variable acc
    variable id
    constructor {} { set id 0 }
    method gate: {obj} {}
    method enter {c v} {}
    method eof {} {}
    method symbols {syms} {
	foreach s $syms { lappend acc $id ; incr id }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
