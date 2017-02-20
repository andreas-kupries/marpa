# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

package require TclOO

# Test suite support.
# # ## ### ##### ######## #############
## Fake lex engines to use downstream of a gate, or upstream of a
## parser engine

proc fake-lex-in  {} { global __lex ; set __lex [Marpa::Testing::FLI new] }
proc fake-lex-end {} { global __lex ; set __lex [Marpa::Testing::FLE new] }
proc fake-lex-nil {} { global __lex ; set __lex [Marpa::Testing::FLN new] }
proc fake-lex-not {} { global __lex ; set __lex [Marpa::Testing::FLX new] }
proc lexed        {} { global __lex ; $__lex destroy ; unset __lex }

# # ## ### ##### ######## #############
## Fake Lex Engine, No signaling on enter.

oo::class create Marpa::Testing::FLN {
    variable gate
    variable acc
    method gate: {g} { set gate $g ; return }
    method enter {c v} {}
    method eof {} {}
    method symbols {syms} {
	set i 0
	foreach s $syms { lappend acc $i ; incr i }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Fake Lex Engine, Behaviour at the beginning and middle of a lexeme

oo::class create Marpa::Testing::FLI {
    variable gate
    variable acc
    method gate: {g} { set gate $g ; return }
    method enter {c v} {
	$gate acceptable $acc
	return
    }
    method eof {} {}
    method symbols {syms} {
	set i 0
	foreach s $syms { lappend acc $i ; incr i }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Fake Lex Engine, Behaviour at the end of a lexeme

oo::class create Marpa::Testing::FLE {
    variable gate
    variable acc
    method gate: {g} { set gate $g ; return }
    method enter {c v} {
	$gate acceptable $acc
	$gate redo 0
	return
    }
    method eof {} {}
    method symbols {syms} {
	set i 0
	foreach s $syms { lappend acc $i ; incr i }
	return $acc
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Fake Lex Engine, limit acceptable

oo::class create Marpa::Testing::FLX {
    variable gate
    variable acc
    method gate: {g} { set gate $g ; return }
    method enter {c v} {
	$gate acceptable $acc
	return
    }
    method eof {} {}
    method symbols {syms} {
	set i 0
	foreach s $syms { lappend r $i ; incr i }
	set acc 0
	return $r
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
