# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Quantified rules, specialized to L0 (attribute wise)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/quantified/l0
debug prefix marpa/slif/container/quantified/l0 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::quantified::l0 {
    superclass marpa::slif::container::quantified

    marpa::E marpa/slif/container/quantified/l0 GRAMMAR CONTAINER QUANTIFIED L0

    constructor {rhs positive args} {
	debug.marpa/slif/container/quantified/l0 {}

	next marpa::slif::container::attribute::quantified::l0 \
	    $rhs $positive {*}$args

	debug.marpa/slif/container/quantified/l0 {/ok}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
