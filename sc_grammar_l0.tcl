# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container. Specialized to L0.
# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/grammar/l0
debug prefix marpa/slif/container/grammar/l0 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::grammar::l0 {
    superclass marpa::slif::container::grammar

    marpa::E marpa/slif/container/grammar/l0 SLIF CONTAINER GRAMMAR L0

    variable mylatm  ; # symbol -> bool
    variable myevent ; # symbol -> when -> name -> state
    variable myprio  ; # symbol -> int

    # - -- --- ----- -------- -------------
    # Lifecycle

    constructor {} {
	debug.marpa/slif/container/grammar/l0 {}
	next {
	    string    ::marpa::slif::container::string
	    charclass ::marpa::slif::container::charclass
	    character ::marpa::slif::container::character
	}   ::marpa::slif::container::priority::l0 \
	    ::marpa::slif::container::quantified::l0

	set mylatm  {}
	set myevent {}
	set myprio  {}

	debug.marpa/slif/container/grammar/l0 {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    # Public API - Inherited, override

    method serialize {} {
	debug.marpa/slif/container/grammar/l0 {}
	set serial [next]

	foreach {var label} {
	    myevent events
	    mylatm  latm
	    myprio  priority
	} {
	    if {![dict size [set $var]]} continue
	    dict set serial $label [set $var]
	}

	debug.marpa/slif/container/grammar/l0 {==> $serial}
	return $serial
    }

    method deserialize {blob} {
	debug.marpa/slif/container/grammar/l0 {}

	foreach {var label} {
	    myevent events
	    mylatm  latm
	    myprio  priority
	} {
	    if {![dict exists $blob $label]} continue
	    set $var [dict get $blob $label]
	    dict unset blob $label
	}

	next $blob
	return
    }

    # - -- --- ----- -------- -------------
    # Public API

    method configure {symbol args} {
	debug.marpa/slif/container/grammar/l0 {}
	# args.keys in { event, latm, priority }

	# latm <bool>
	# event (name (on|off) (before|after|discard))
	# priority <int>

	foreach {k v} $args {
	    switch -exact -- $k {
		latm {
		    if {![string is bool -strict $v]} {
			my E "Expected boolean, got $v" LATM
		    }
		    dict set mylatm $symbol $v
		}
		event {
		    lassign [my ValidateEvent $v {
			after before discard
		    }] name state when
		    dict set myevent $symbol $when $name $state
		}
		priority {
		    if {![string is int -strict $v]} {
			my E "Expected integer, got $v" PRIORITY
		    }
		    dict set myprio $symbol $v
		}
		default {
		    my E "Bad option $k, expected one of event, latm, or priority" \
			BAD OPTION
		}
	    }
	}
	return
    }

    forward charclass  my Symbol: literal charclass
    forward character  my Symbol: literal character
    forward string     my Symbol: literal string
    forward discard    my Class: discard
    forward lexeme     my Class: lexeme

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
