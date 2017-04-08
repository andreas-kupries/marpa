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

debug define marpa/slif/attr/lexsem
#debug prefix marpa/slif/attr/lexsem {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::attr/lexsem {
    superclass marpa::slif::attribute
    marpa::E marpa/slif/attr/lexsem SLIF ATTR-LEXSEM

    constructor {container} {
	debug.marpa/slif/attr/lexsem {}
	marpa::import $container Container

	next action [dict create \
	     default {array values} \
	     validate [mymethod v-action] \
	] bless [dict create \
	     validate [mymethod v-bless]]
    }

    # # ## ### ##### ######## #############

    method v-action {_validate_ value} {
	debug.marpa/slif/attr/lexsem {}
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

    method v-bless {_validate_ value} {
	debug.marpa/slif/attr/lexsem {}
	lassign $value type details
	if {$type in {special standard}} {
	    # TODO: check supported specials ?
	    return $value
	}
	my E "Bad bless type '$type', expected one of special, or standard"
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
