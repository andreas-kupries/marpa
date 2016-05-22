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

debug define marpa/slif/charclass
debug prefix marpa/slif/charclass {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::charclass {
    superclass marpa::slif::atom

    marpa::E marpa/slif/charclass SLIF CHARCLASS

    ##
    # API:
    # * constructor (name grammar value)

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name grammar value} {
	debug.marpa/slif/charclass {}

	next $name $grammar charclass $value

	debug.marpa/slif/charclass {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
