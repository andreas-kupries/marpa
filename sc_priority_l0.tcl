# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Priority rules, specialized to L0 (attribute wise)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/priority/l0
debug prefix marpa/slif/container/priority/l0 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::priority::l0 {
    superclass marpa::slif::container::priority

    marpa::E marpa/slif/container/priority/l0 GRAMMAR CONTAINER PRIORITY L0

    constructor {rhs positive args} {
	debug.marpa/slif/container/priority/l0 {}

	next marpa::slif::container::attribute::priority::l0 \
	    $rhs $positive {*}$args

	debug.marpa/slif/container/priority/l0 {/ok}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
