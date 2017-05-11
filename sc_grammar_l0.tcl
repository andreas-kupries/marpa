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
	    atom       ::marpa::slif::container::atom

	    %named-class  {::marpa::slif::container::atom %named-class}
	    %string       {::marpa::slif::container::atom %string}
	    ^%named-class {::marpa::slif::container::atom ^%named-class}
	    ^character    {::marpa::slif::container::atom ^character}
	    ^charclass    {::marpa::slif::container::atom ^charclass}
	    ^named-class  {::marpa::slif::container::atom ^named-class}
	    ^range        {::marpa::slif::container::atom ^range}
	    character     {::marpa::slif::container::atom character}
	    charclass     {::marpa::slif::container::atom charclass}
	    named-class   {::marpa::slif::container::atom named-class}
	    range         {::marpa::slif::container::atom range}
	    string        {::marpa::slif::container::atom string}

	    byte          {::marpa::slif::container::atom byte}
	    brange        {::marpa::slif::container::atom brange}
	}   ::marpa::slif::container::priority::l0 \
	    ::marpa::slif::container::quantified::l0

	# The primary 'atom' at the top is the support for method
	# "literal", see the forward at the bottom. All the others are
	# there to support direct construction from deserializations
	# (See method "deserialize", call to "Symbol:"). This is the
	# set that declares the valid literal types.
	#
	# The two missing types (%range, ^%range) are not really
	# such. See the normalization rules N28, N30, and associated
	# footnote in doc/atoms.md for why they are eliminated by the
	# normalization code.

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

    forward literal    my Symbol: literal atom

    forward discard    my Class: discard
    forward lexeme     my Class: lexeme

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
