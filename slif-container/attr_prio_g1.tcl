# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar attributes for G1 priority rule

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container/attribute/priority/g1
#debug prefix marpa/slif/container/attribute/priority/g1 {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::slif::container::attribute::priority::g1 {
    superclass marpa::slif::container::attribute

    marpa::E marpa/slif/container/attribute/priority/g1 \
	SLIF CONTAINER ATTRIBUTE PRIORITY G1

    constructor {grammar} {
	debug.marpa/slif/container/attribute/priority/g1 {}

	# empty, alternative:
	# - action, naming, assoc
	# - mask [system attribute]

	marpa A   default  {array values}
	marpa A   validate [mymethod v-action]
	marpa C action
	marpa A   default  left
	marpa A   validate [mymethod v-assoc]
	marpa C assoc
	marpa C* mask
	marpa C* name

	next $grammar {*}$spec
	return
    }

    # # ## ### ##### ######## #############

    # TODO: g1 v-action - move to mixin for both quantified and priority
    method v-action {_validate_ value} {
	debug.marpa/slif/container/attribute/priority/g1 {}
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

    method v-assoc {_validate_ value} {
	debug.marpa/slif/container/attribute/priority/g1 {}

	if {$value in {left right group}} {
	    return $value
	}
	my E "Bad association '$value', expected one of group, left, or right"
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
