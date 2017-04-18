# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Basic grammar (symbols and associated rules). Part of
# a SLIF container.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/grammar
debug prefix marpa/slif/container/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## Managing a set of symbols and their rules.

oo::class create marpa::slif::container::grammar {
    superclass marpa::slif::container::serdes

    marpa::E marpa/slif/container/grammar SLIF CONTAINER GRAMMAR

    variable mysymbol ; # :: dict (symbol-name -> symbol-instance)
    variable mysclass ; # :: dict (symbol-name -> class-name)
    variable mytype   ; # :: dict (type-name -> factory-instance)

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {spec p q} {
	debug.marpa/slif/container/grammar {}

	#marpa::import $container Container
	set mysymbol {}
	set mysclass {}
	set mytype   $spec
	dict set mytype priority   $p
	dict set mytype quantified $q

	debug.marpa/slif/container/grammar {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Public API

    forward quantified-rule   my Symbol: {} quantified
    forward priority-rule     my Symbol: {} priority

    method must-have {symbol} {
	debug.marpa/slif/container/grammar {}
	if {![dict exists $mysymbol $symbol]} {
	    my E "Unknown symbol '$symbol'" BAD SYMBOL
	}
	return [dict get $mysymbol $symbol]
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/grammar {}
	set serial {}
	dict for {symbol obj} $mysymbol {
	    set class [dict get $mysclass $symbol]
	    dict set serial $class $symbol [$obj serialize]
	}
	debug.marpa/slif/container/grammar {==> $serial}
	return $serial
    }

    method deserialize {blob} {
	debug.marpa/slif/container/grammar {}
	# blob       :: dict (class -> class-blob)
	# class-blob :: dict (symbol -> (type ...)...)
	set mysymbol {}
	set mysclass {}
	dict for {class cdata} $blob {
	    dict for {symbol spec} $cdata {
		foreach def $spec {
		    set details [lassign $def type]
		    my Symbol: $class $type $symbol {*}$details
		}
	    }
	}
	return
    }

    # - -- --- ----- -------- -------------
    ## Semi-public API - Used by derived classes

    method Symbol: {class type symbol args} {
	debug.marpa/slif/container/grammar {}

	my Class: $class $symbol
	if {![dict exists $mysymbol $symbol]} {
	    set factory [dict get $mytype $type]
	    set obj [{*}$factory new {*}$args]
	    dict set mysymbol $symbol $obj
	} else {
	    [dict get $mysymbol $symbol] extend {*}$args
	}
	return
    }

    method Class: {class symbol} {
	debug.marpa/slif/container/grammar {}
	# Define or change the class of a symbol
	# Ignore an empty class if the class is already known.

	if {![dict exists $mysclass $symbol] ||
	    ([dict get    $mysclass $symbol] eq {})} {
	    dict set mysclass $symbol $class
	    return
	} elseif {$class eq {}} {
	    return
	} elseif {$class ne [dict get $mysclass $symbol]} {
	    my E "Cannot change class of symbol '$symbol'" FORBIDDEN
	}
	return
    }

    method ValidateEvent {event types} {
	debug.marpa/slif/container/grammar {}
	if {[llength $event] != 3} {
	    my E "Expected event-spec, got $event" EVENT
	}
	lassign $event name state when
	if {![string is bool -strict $state]} {
	    my E "Expected boolean state in $event, got $state" EVENT
	}
	if {$when ni $types} {
	    set types [linsert [join $types {, }] end-1 or]
	    my E "Bad event-time $when, expected one of $types, in $event" EVENT
	}
	return $event
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
