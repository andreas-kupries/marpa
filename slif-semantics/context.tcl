# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Symbol context
## - Layer: g1/l0
## - Type:  def/use

oo::class create marpa::slif::semantics::SymContext {
    variable mytype       ;# definition/usage
    variable mylayer      ;# L0/G1
    variable mylhs        ;# Symbol for upcoming alternatives
    variable myprecedence ;# Precedence level for alternatives

    marpa::E marpa/slif/semantics SLIF SEMANTICS SYMBOLCONTEXT

    constructor {} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype       {}
	set mylayer      {}
	set mylhs        {}
	set myprecedence {}
	return
    }

    # # -- --- ----- -------- -------------

    method precedence/reset {} {
	debug.marpa/slif/semantics {[debug caller] | }
	set myprecedence 0
	return
    }

    method precedence/loosen {} {
	debug.marpa/slif/semantics {[debug caller] | }
	incr myprecedence -1
	return
    }

    # # -- --- ----- -------- -------------

    method lhs {symbol} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylhs $symbol
	return
    }

    # # -- --- ----- -------- -------------

    method g1 {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylayer g1
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    method l0 {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylayer l0
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    # # -- --- ----- -------- -------------

    forward def my definition
    method definition {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype definition
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    forward use my usage
    method usage {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype usage
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    # # -- --- ----- -------- -------------

    method assert {args} {
	foreach property $args {
	    if {[my ${property}?]} continue
	    my E "Unexpected non-$property context" $property
	}
    }

    # # -- --- ----- -------- -------------

    method layer? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mylayer}
	return $mylayer
    }

    method type? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mytype}
	return $mytype
    }

    method lhs? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mylhs}
	return $mylhs
    }

    method precedence? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $myprecedence}
	return $myprecedence
    }

    # # -- --- ----- -------- -------------

    method definition? {} {
	set ok [expr {$mytype eq "definition"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    method usage? {} {
	set ok [expr {$mytype eq "usage"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    method g1? {} {
	set ok [expr {$mylayer eq "g1"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    method l0? {} {
	set ok [expr {$mylayer eq "l0"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    # # -- --- ----- -------- -------------
}
