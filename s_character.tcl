# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Character class atoms

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/character
debug prefix marpa/slif/character {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::character {
    superclass marpa::slif::atom

    marpa::E marpa/slif/character SLIF CHARACTER

    ##
    # API:
    # * constructor (name grammar value)

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name grammar value} {
	debug.marpa/slif/character {}

	next $name $grammar character $value

	debug.marpa/slif/character {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
