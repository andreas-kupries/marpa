# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Atom: L0 named characterclass.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/namedcc
debug prefix marpa/slif/container/atom/namedcc {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::namedcc {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/namedcc \
	SLIF CONTAINER ATOM NAMEDCC

    variable myname ;# :: string

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name} {
	debug.marpa/slif/container/atom/namedcc {}

	set myname $name

	debug.marpa/slif/container/atom/namedcc {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/namedcc {}
	return [list [list namedcc $myname]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
