# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for writing state machines which check the sequencing of
# method calls of a class.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

debug define util/sequencing
#debug prefix marpa/inbound {[debug caller] | }

# # ## ### ##### ######## #############
## Helper command to create a method which dynamically activates a
## sequencing validator for a class.

proc validate-sequencing {{sequencer {}}} {

    # If the caller did not choose a sequencer class derive its name
    # from the name of the class getting defined, retrieved from the
    # calling context
    if {[llength [info level 0]] < 2} {
	set class [lindex [info level -1] 1]
	set sequencer ${class}::sequencer
    }

    lappend map @@ $sequencer
    uplevel 1 [list method validate-sequencing {} [string map $map {
	oo::objdefine [self] mixin @@
	return
    }]]
    return
}

# # ## ### ##### ######## #############
## Base class for sequencers, state and transforms.
## Assumes that the class a derived class is mixed into provides a
## method named "E" for error reporting, taking a message and a
## variable number of error codes.

oo::class create sequencer {
    # # -- --- ----- -------- -------------
    ## Public API for querying the DFA, current state

    method @ {} { my __Init ; return $__state }
    export @

    # # -- --- ----- -------- -------------
    ## Public API for triggering debug narrative in the DFA

    method debug {} { debug on util/sequencing }

    # # -- --- ----- -------- -------------
    ## DFA state

    variable __state

    # # -- --- ----- -------- -------------
    ## API to derived classes.

    # Override this method in derived classes to declare the
    # acceptable states.
    method __Init {} {
	return \
	    -code error \
	    -errorcode {SEQUENCER INIT} \
	    "Virtual method __Init not declared by derived class [self class]"
    }

    # Always use this (or __Init) first in all checked methods, to
    # initialize the validator's __state, or check the __state's
    # validity (self check against bugs in the validator).
    method __States {initial args} {
	my variable __state
	if {[info exists __state]} {
	    debug.util/sequencing {@:$__state:[info level -2]}
	    #puts @:$__state:[info level -2]
	    if {$__state in [linsert $args 0 $initial]} return
	    my E "" SEQUENCER INVALID STATE $__state 
	}
	set __state $initial
	#puts I:$__state:[info level -2]
	debug.util/sequencing {I:$__state:[info level -2]}
	return
    }

    # Conditionally fail on matching states
    method __Fail {expect __ msg args} {
	if {$__state ni $expect} return
	my E $msg {*}$args
    }

    # Conditionally fail on not matching states
    method __FNot {expect __ msg args} {
	if {$__state in $expect} return
	my E $msg {*}$args
    }

    # Conditionally move on matching states to a new state
    method __On {expect __ next} {
	if {$__state ni $expect} return
	set __state $next
	return
    }

    # Conditionally move on not matching states to a new state
    method __Not {expect __ next} {
	if {$__state in $expect} return
	set __state $next
	return
    }

    # Unconditionally move to a different state
    method __Goto {next} {
	set __state $next
	return
    }
}

# # ## ### ##### ######## #############
return
