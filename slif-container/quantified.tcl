# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Quantified rules

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/quantified
debug prefix marpa/slif/container/quantified {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::quantified {
    superclass marpa::slif::container::serdes

    variable myrhs
    variable mypositive

    marpa::E marpa/slif/container/quantified GRAMMAR CONTAINER QUANTIFIED

    constructor {grammar attrfactory rhs positive args} {
	debug.marpa/slif/container/quantified {}
	# grammar = marpa::slif::container::grammar
	marpa::import $grammar Grammar

	set myrhs      $rhs
	set mypositive $positive

	$attrfactory create A $grammar
	A set {*}$args

	debug.marpa/slif/container/quantified {/ok}
	return
    }

    method min-precedence {} {
	debug.marpa/slif/container/quantified {}
	# Quantified rules have no precedence.
	return 0
    }

    method recursive {lhs} {
	debug.marpa/slif/container/quantified {}
	# Logically speaking quantified rules are never recursive.
	# Even if the rule is indeed such. That is invalidate, see
	# validate below.
	return 0
    }

    method validate {lhs} {
	debug.marpa/slif/container/quantified {}
	Grammar must-have $myrhs
	if {$lhs eq $myrhs} {
	    my E "Quantified rule '$lhs': Recursion" RECURSION RHS
	}
	A validate
	if {![A has separator]} return
	# Separator symbol (if specified) validated here, attributes
	# has it disabled.  The latter because the semantics does not
	# top-sort definitions, i.e. the separator may not be defined
	# at construction time. But here now it must be.
	lassign [A get separator] sep __
	Grammar must-have $sep
	if {$lhs eq $sep} {
	    my E "Quantified rule '$lhs': Recursion through separator" \
		RECURSION SEPARATOR
	}
	return
    }

    method fixup {aliases} {
	debug.marpa/slif/container/quantified {}

	if {[dict exists $aliases $myrhs]} {
	    set myrhs [dict get $aliases $myrhs]
	}
	if {![A has separator]} return
	lassign [A get separator] sym proper

	if {![dict exists $aliases $sym]} return
	A set separator [list [dict get $aliases $sym] $proper]
	return
    }

    method extend {args} {
	debug.marpa/slif/container/quantified {}
	my E "Quantified rule cannot be extended" \
	    FORBIDDEN
    }

    method deserialize {args} {
	debug.marpa/slif/container/quantified {}
	my E "Quantified rule deserialization forbidden, go through constructor" \
	    FORBIDDEN
    }

    # # -- --- ----- -------- -------------

    method serialize {} {
	debug.marpa/slif/container/quantified {}
	set serial [list [list quantified $myrhs $mypositive {*}[A serialize]]]
	debug.marpa/slif/container/quantified {==> $serial}
	return $serial
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
