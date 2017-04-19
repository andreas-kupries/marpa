# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Atom: L0 string.
# Should not be used.
# See the simplifier for literals, lowering them into simpler
# structures (sequences of char(classes)).

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/string
debug prefix marpa/slif/container/atom/string {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::string {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/string \
	SLIF CONTAINER ATOM STRING

    variable mynocase
    variable myspec   ;# :: list (codepoint)
    #                 ;# /sequence

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {spec nocase} {
	debug.marpa/slif/container/atom/string {}

	set myspec   $spec
	set mynocase $nocase

	debug.marpa/slif/container/atom/string {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/string {}
	return [list [list string $myspec $mynocase]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
