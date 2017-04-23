# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Atom: L0 negative character class.
# Should not be used.

# See the simplifier for literals, lowering them into simpler
# structures (alternatives of char(classes)).

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/negcharclass
debug prefix marpa/slif/container/atom/negcharclass {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::negcharclass {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/negcharclass \
	SLIF CONTAINER ATOM NEGCHARCLASS

    variable mynocase
    variable myspec   ;# :: list (codepoint|code-range ...)
    #                 ;# /alternation

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {spec nocase} {
	debug.marpa/slif/container/atom/negcharclass {}

	set myspec   $spec
	set mynocase $nocase

	debug.marpa/slif/container/atom/negcharclass {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/negcharclass {}
	return [list [list negcclass $myspec $mynocase]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
