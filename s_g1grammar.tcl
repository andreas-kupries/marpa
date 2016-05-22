# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container. Specialized to G1
# - Start symbol

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/g1/grammar
debug prefix marpa/slif/g1/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::g1::grammar {
    superclass marpa::slif::grammar

    marpa::E marpa/slif/g1/grammar SLIF G1 GRAMMAR

    variable mystart ;# Instance of the start symbol

    ##
    # API:
    # * constructor (name)
    # * start!      (obj)

    constructor {name container} {
	debug.marpa/slif/g1/grammar {}

	set mystart  {}
	next $name $container

	debug.marpa/slif/g1/grammar {/ok}
	return
    }

    method start! {obj} {
	debug.marpa/slif/g1/grammar {}
	# TODO: assert (self has symbol obj)
	set mystart $obj

	debug.marpa/slif/g1/grammar {/done}
	return
    }


    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
