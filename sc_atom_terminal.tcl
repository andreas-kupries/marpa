# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. G1 Terminal atom.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/terminal
debug prefix marpa/slif/container/atom/terminal {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::terminal {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/terminal \
	SLIF CONTAINER ATOM TERMINAL

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {} {
	debug.marpa/slif/container/atom/terminal {}
	debug.marpa/slif/container/atom/terminal {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/terminal {}
	return [list [list terminal]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
