# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Global grammar attributes.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container/attribute/global
#debug prefix marpa/slif/container/attribute/global {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::container::attribute::global {
    superclass marpa::slif::container::attribute

    marpa::E marpa/slif/container/attribute/global \
	SLIF CONTAINER ATTRIBUTE GLOBAL

    constructor {container} {
	debug.marpa/slif/container/attribute/global {}
	# container = marpa::slif::container
	#marpa::import $container Container

	marpa A   default  warn
	marpa A   validate [mymethod v-inaccessible]
	marpa C inaccessible
	marpa A   validate [mymethod v-start]
	marpa C start

	next $container {*}$spec
	return
    }

    # # ## ### ##### ######## #############

    method v-inaccessible {_validate_ value} {
	debug.marpa/slif/container/attribute/global {}
	if {$value in {fatal ok warn}} {
	    return $value
	}
	my E "Bad code '$value', expected one of fatal, warn, or ok" \
	    BAD INACCESSIBLE $value
    }

    method v-start {_validate_ symbol} {
	debug.marpa/slif/container/attribute/global {}
	Container g1 must-have $symbol
	return $symbol
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
