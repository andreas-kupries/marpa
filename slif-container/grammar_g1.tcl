# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container. Specialized to G1.
# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/grammar/g1
debug prefix marpa/slif/container/grammar/g1 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::grammar::g1 {
    superclass marpa::slif::container::grammar

    marpa::E marpa/slif/container/grammar/g1 SLIF CONTAINER GRAMMAR G1

    variable myevent

    # - -- --- ----- -------- -------------
    # Lifecycle

    constructor {container} {
	debug.marpa/slif/container/grammar/g1 {}
	next $container {
	    terminal {::marpa::slif::container::atom terminal}
	}   ::marpa::slif::container::priority::g1 \
	    ::marpa::slif::container::quantified::g1

	set myevent {}

	debug.marpa/slif/container/grammar/g1 {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    # Public API - Inherited, override
    # - TODO: Move to superclass, shared g1/l0 - different events however

    method serialize {} {
	debug.marpa/slif/container/grammar/l0 {}
	set serial [next]

	if {[dict size $myevent]} {
	    dict set serial events $myevent
	}

	debug.marpa/slif/container/grammar/l0 {==> $serial}
	return $serial
    }

    method deserialize {blob} {
	debug.marpa/slif/container/grammar/l0 {}

	if {[dict exists $blob events]} {
	    set myevent [dict get $blob events]
	    dict unset blob events
	}

	next $blob
	return
    }

    # - -- --- ----- -------- -------------
    # Public API

    method validate {} {
	debug.marpa/slif/container/grammar/g1 {}
	next ;# common superclass checks
	# G1: Check terminal symbols for presence in L0 as lexemes
	dict for {sym si} [my SYM] {
	    if {[my get-class $sym] ne "terminal"} continue
	    Container l0 must-have $sym
	    if {[Container l0 get-class $sym] eq "lexeme"} continue
	    my E "Terminal <$sym> missing in L0" TERMINAL MISSING
	}
	return
    }

    method event {symbol spec} {
	debug.marpa/slif/container/grammar/g1 {}

	lassign [my ValidateEvent $spec {
	    completed predicted nulled
	}] name state when
	dict set myevent $symbol $when $name $state
	return
    }

    forward terminal   my Symbol: terminal terminal

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
