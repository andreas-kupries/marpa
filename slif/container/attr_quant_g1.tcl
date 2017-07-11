# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar attributes for G1 quantified rule

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container/attribute/quantified/g1
#debug prefix marpa/slif/container/attribute/quantified/g1 {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::slif::container::attribute::quantified::g1 {
    superclass marpa::slif::container::attribute

    marpa::E marpa/slif/container/attribute/quantified/g1 \
	SLIF CONTAINER ATTRIBUTE QUANTIFIED G1

    constructor {grammar} {
	debug.marpa/slif/container/attribute/quantified/g1 {}
	marpa::import $grammar Grammar

	# quantified: action, separator

	marpa A   default  {array values}
	marpa A   validate [mymethod v-action]
	marpa C action
	marpa A   validate [mymethod v-separator]
	marpa C separator

	next $grammar {*}$spec
	return
    }

    # # ## ### ##### ######## #############

    # TODO: g1 v-action - move to mixin for both quantified and priority
    method v-action {_validate_ value} {
	debug.marpa/slif/container/attribute/quantified/g1 {}
	lassign $value type details
	if {$type in {array cmd special}} {
	    if {$type eq "array"} {
		foreach v $details {
		    if {$v ni {
			start length g1start g1length name
			lhs symbol rule value values ord
		    }} {
			my E "Bad action code '$v', expected one of g1length, g1start, length, lhs, name, rule, start, symbol, value, or values"
		    }
		}
	    }
	    # TODO: check special for allowed values
	    return $value
	}
	my E "Bad action type '$type', expected one of array, cmd, or special"
	return
    }

    method v-separator {_validate_ value} {
	debug.marpa/slif/container/attribute/quantified/g1 {}
	lassign $value symbol proper
	#Grammar must-have $symbol -- Semantics is not written to top-sort definitions.
	if {![string is bool -strict $proper]} {
	    my E "Bad flag proper in separator definition, expected boolean, got \"$proper\""
	}
	return $value
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
