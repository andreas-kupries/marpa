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

debug define marpa/slif/attr/global
#debug prefix marpa/slif/attr/global {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::attr/global {
    superclass marpa::slif::attribute
    marpa::E marpa/slif/attr/global SLIF ATTR-GLOBAL

    constructor {container} {
	debug.marpa/slif/attr/global {}
	marpa::import $container Container

	next inaccessible [dict create \
	       default  warn \
	       validate [mymethod v-inaccessible] \
	] start [dict create \
		     validate [mymethod v-start]]
    }

    # # ## ### ##### ######## #############

    method v-inaccessible {_validate_ value} {
	debug.marpa/slif/attr/global {}
	if {$value in {fatal ok warn}} {
	    return $value
	}
	my E "Bad code '$value', expected one of fatal, warn, or ok" \
	    BAD INACCESSIBLE $value
    }

    method v-start {_validate_ symbol} {
	debug.marpa/slif/attr/global {}
	# TODO - Container g1 musthave! $symbol
	return $symbol
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
