# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Base class for both Lexer and parser runtimes. Shared code.

# # ## ### ##### ######## #############
## Requisites

package require oo::util ;# mymethod

debug define marpa/engine/tcl/base
debug prefix marpa/engine/tcl/base {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::engine::tcl::base {
    # # ## ### ##### ######## #############
    marpa::E marpa/engine/tcl/base ENGINE TCL BASE

    constructor {} {
	debug.marpa/engine/tcl/base {}
	set myeventprefix {}
	return
    }

    # # ## ### ##### ######## #############
    ## State

    variable myeventprefix
    # myeventprefix :: list (word...)
    # Callback command to handle parse events

    # # ## ### ##### ######## #############
    ## Public API

    method on-event {args} {
	debug.marpa/engine/tcl/base {}
	set myeventprefix $args
	return
    }

    # # ## ### ##### ######## #############
    ## Internal method to signal events
    ## Called from components

    method post {args} {
	debug.marpa/engine/tcl/parse {}
	if {![llength $myeventprefix]} {
	    debug.marpa/engine/tcl/parse { Ignored }
	    return
	}
	debug.marpa/engine/tcl/parse { Invoke }
	uplevel #0 [linsert $args 0 {*}$myeventprefix [self]]
	return
    }

    # # ## ### ##### ######## #############
    ## Option processing for engine process(-file) methods

    method Options {words} {
	# Input: External `from F`, output internal F' = F - 1, default  0 external
	# Input: External `to S`,   output internal S' = S - 1, default -1 external
	# See also gate.tcl, method `location` etc.

	debug.marpa/engine/tcl/base {}
	if {[llength $words] % 2 == 1} {
	    my E "Last option has no value" {WRONG ARGS}
	}
	set from   0 ;# int >= 0 (location)
	set to    -1 ;# int >= 0 (location)
	set limit -1 ;# int >  0
	foreach {key value} $words {
	    switch -exact -- $key {
		from  { my Location $value ; set from  $value		     }
		to    { my Location $value ; set to    $value ; set limit -1 }
		limit { my PosInt   $value ; set limit $value ; set to    -1 }
		default {
		    my E "Unknown option \"$key\", expected one of from, limit, or to" \
			{BAD OPTION}
		}
	    }
	}

	# from, to - external form until here.
	# Translate to the internal forms.
	if {$limit > 0} {
	    set to [expr {$from + $limit}]
	}

	incr from -1
	incr to   -1

	return [list $from $to]
    }

    method Location {x} {
	debug.marpa/engine/tcl/base {}
	incr x 0
	if {$x >= 0} return
	return -code error "expected location (>= 0), but got \"$x\""
    }

    method PosInt {x} {
	debug.marpa/engine/tcl/base {}
	incr x 0
	if {$x > 0} return
	return -code error "expected int > 0, but got \"$x\""
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
