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

    constructor {attrfactory rhs positive args} {
	debug.marpa/slif/container/quantified {}

	set myrhs      $rhs
	set mypositive $positive

	$attrfactory create A
	A set {*}$args

	debug.marpa/slif/container/quantified {/ok}
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
