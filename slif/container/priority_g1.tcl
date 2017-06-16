# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Priority rules, specialized to G1 (attribute wise)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/priority/g1
debug prefix marpa/slif/container/priority/g1 {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::priority::g1 {
    superclass marpa::slif::container::priority

    marpa::E marpa/slif/container/priority/g1 GRAMMAR CONTAINER PRIORITY G1

    constructor {grammar rhs positive args} {
	debug.marpa/slif/container/priority/g1 {}

	next $grammar marpa::slif::container::attribute::priority::g1 \
	    $rhs $positive {*}$args

	debug.marpa/slif/container/priority/g1 {/ok}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
