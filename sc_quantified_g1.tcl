# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Quantified rules, specialized to G1 (attribute wise)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/quantified/g1
debug prefix marpa/slif/container/quantified/g1 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::quantified::g1 {
    superclass marpa::slif::container::quantified

    marpa::E marpa/slif/container/quantified/g1 GRAMMAR CONTAINER QUANTIFIED G1

    constructor {rhs positive args} {
	debug.marpa/slif/container/quantified/g1 {}

	next marpa::slif::container::attribute::quantified::g1 \
	    $rhs $positive {*}$args

	debug.marpa/slif/container/quantified/g1 {/ok}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
