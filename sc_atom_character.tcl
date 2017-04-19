# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Atom: L0 character.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/character
debug prefix marpa/slif/container/atom/character {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::character {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/character \
	SLIF CONTAINER ATOM CHARACTER

    variable mychar ;# :: codepoint

    # Note: codepoints <= 255 can be used for byte-based engines.

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {char} {
	debug.marpa/slif/container/atom/character {}

	set mychar $char

	debug.marpa/slif/container/atom/character {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/character {}
	return [list [list character $mychar]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
