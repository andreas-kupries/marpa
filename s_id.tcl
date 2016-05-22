# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Id generator

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/id
debug prefix marpa/slif/id {[debug caller] | }

# # ## ### ##### ######## #############
## Managing id generators

oo::class create marpa::slif::id {
    variable mycounter

    ##
    # API:
    # * constructor (name, -> grammar)

    constructor {} {
	debug.marpa/slif/id {}
	set mycounter 0
	debug.marpa/slif/id {/ok}
	return
    }

    method next {} {
	debug.marpa/slif/id {==> $mycounter}
	set result $mycounter
	incr mycounter
	return $result
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
