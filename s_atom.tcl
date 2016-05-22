# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Basic atoms, derived from symbols.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/atom
debug prefix marpa/slif/atom {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::atom {
    superclass marpa::slif::symbol

    variable mytype  ;# Type of the atom,
    variable myvalue ;# and value

    marpa::E marpa/slif/atom SLIF ATOM

    ##
    # API:
    # * constructor (name grammar type value)

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name grammar type value} {
	debug.marpa/slif/atom {}

	next $name $grammar
	set mytype  $type
	set myvalue $value

	debug.marpa/slif/atom {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
