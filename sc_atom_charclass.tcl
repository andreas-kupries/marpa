# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. L0 Charclass atom.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/charclass
debug prefix marpa/slif/container/atom/charclass {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::charclass {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/charclass \
	SLIF CONTAINER ATOM CHARCLASS

    variable mynocase
    variable myspec   ;# :: list (codepoint|code-range ...)
    #                 ;# /alternation

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {spec nocase} {
	debug.marpa/slif/container/atom/charclass {}

	set myspec   $spec
	set mynocase $nocase

	debug.marpa/slif/container/atom/charclass {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/charclass {}
	return [list [list charclass $myspec $mynocase]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
