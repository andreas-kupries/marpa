# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar attributes for lexeme-semantics

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container/attribute/lexsem
#debug prefix marpa/slif/container/attribute/lexsem {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::slif::container::attribute::lexsem {
    superclass marpa::slif::container::attribute

    marpa::E marpa/slif/container/attribute/lexsem \
	SLIF CONTAINER ATTRIBUTE LEXSEM

    constructor {container} {
	debug.marpa/slif/container/attribute/lexsem {}
	# container = marpa::slif::container

	marpa A   default  {array values}
	marpa A   validate [mymethod v-action]
	marpa C action

	next $container {*}$spec
	return
    }

    # # ## ### ##### ######## #############

    method v-bool {_validate_ value} {
	debug.marpa/slif/container/attribute/lexsem {}
	if {[string is bool -strict $value]} {
	    return $value
	}
	my E "Expected a boolean, got '$value'"
    }

    method v-action {_validate_ value} {
	debug.marpa/slif/container/attribute/lexsem {}
	lassign $value type details
	if {$type in {array cmd}} {
	    if {$type eq "array"} {
		foreach v $details {
		    if {$v ni {
			start length g1start g1length name
			lhs symbol rule value values
		    }} {
			my E "Bad action code '$v', expected one of g1length, g1start, length, lhs, name, rule, start, symbol, value, or values"
		    }
		}
	    }
	    return $value
	}
	my E "Bad action type '$type', expected one of array, or cmd"
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
