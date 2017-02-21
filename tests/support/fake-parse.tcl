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

proc fake-parse     {} { global __parse ; set __parse [Marpa::Testing::FP new] }
proc fake-parse-nil {} { global __parse ; set __parse [Marpa::Testing::FPN new] }
proc parsed         {} { global __parse ; $__parse destroy ; unset __parse }

# # ## ### ##### ######## #############
## Fake Parse Engine - Signals acceptable on enter

oo::class create Marpa::Testing::FP {
    variable acc
    variable id
    variable gate
    constructor {} { set id 0 }
    method gate: {g} { set gate $g; return }
    method enter {c v} {
	$gate acceptable $acc
	return
    }
    method eof {} {}
    method fail {} {}
    method symbols {syms} {
	foreach s $syms { lappend acc $id ; incr id }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Fake Parse Engine - Does not signal acceptable on enter

oo::class create Marpa::Testing::FPN {
    variable acc
    variable id
    variable gate
    constructor {} { set id 0 }
    method gate: {g} { set gate $g; return }
    method enter {c v} {
	return
    }
    method eof {} {}
    method fail {} {}
    method symbols {syms} {
	foreach s $syms { lappend acc $id ; incr id }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
