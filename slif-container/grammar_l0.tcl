# -*- tcl -*-
##
# (c) 2015-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
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
    variable myprio  ; # symbol -> int

    # - -- --- ----- -------- -------------
    # Lifecycle

    constructor {container} {
	debug.marpa/slif/container/grammar/l0 {}
	next $container {
	    after before discard
	} {
	    latm priority
	} {
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
	set myprio  {}

	debug.marpa/slif/container/grammar/l0 {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    # Public API

    method latm {} {
	debug.marpa/slif/container/grammar/l0 {}
	if {![dict size $mylatm]} { return {} }
	return [lrange $mylatm 0 end]
	# See the note in alter.tcl for explanation of the lrange.
    }

    method priority {} {
	debug.marpa/slif/container/grammar/l0 {}
	if {![dict size $mypriority]} { return {} }
	return [lrange $mypriority 0 end]
	# See the note in alter.tcl for explanation of the lrange.
    }

    # - -- --- ----- -------- -------------
    # Public API

    method validate {} {
	debug.marpa/slif/container/grammar/l0 {}
	next ;# common superclass checks
	# G1: Check lexeme symbols for presence in G1 as terminals
	dict for {sym si} [my SYM] {
	    if {[my get-class $sym] ne "lexeme"} continue
	    Container g1 must-have $sym
	    if {[Container g1 get-class $sym] eq "terminal"} continue
	    my E "Lexeme <$sym> missing in G1" LEXEME MISSING
	}
	return
    }

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
		    my Trigger: $symbol $v
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
    ## Accessors for (de)serialize - SGH API
    ##
    ## S|G|H - Set|Get|Have

    method S_latm     {blob} { set mylatm $blob ; return }
    method G_latm     {}     { return $mylatm }
    method H_latm     {}     { return [dict size $mylatm] }

    method S_priority {blob} { set myprio $blob ; return }
    method G_priority {}     { return $myprio }
    method H_priority {}     { return [dict size $myprio] }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
