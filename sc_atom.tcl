# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar atoms.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom
debug prefix marpa/slif/container/atom {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::atom {
    superclass marpa::slif::container::serdes

    marpa::E marpa/slif/container/atom SLIF CONTAINER ATOM

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {} {
	debug.marpa/slif/container/atom {}
	debug.marpa/slif/container/atom {/ok}
	return
    }

    # - -- --- ----- -------- -------------

    method extend {args} {
	debug.marpa/slif/container/atom {}
	my E "Atom cannot be extended: $args" \
	    FORBIDDEN
    }

    method deserialize {blob} {
	debug.marpa/slif/container/atom {}
	my E "Atom deserialization forbidden, go through constructor" \
	    FORBIDDEN
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
