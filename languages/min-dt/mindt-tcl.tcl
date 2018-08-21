# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##

# mini doctools processor, Tcl based.

# @@ Meta Begin
# Package mindt::tcl 1
# Meta author      {Andreas Kupries}
# Meta category    Parser
# Meta description A minimal MINDT parser.
# Meta description Returns the abstract syntax tree of
# Meta description the MINDT read from file or stdin.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     parsing mindt {abstract syntax tree}
# Meta summary     A minimal MINDT parser based on the Tcl binding to
# Meta summary     Jeffrey Kegler's libmarpa.
# @@ Meta End

# # ## ### ##### ######## #############

package provide mindt::tcl 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug           ;# Tracing
package require debug::caller   ;# Tracing
package require mindt::base

# # ## ### ##### ######## #############

debug define mindt/tcl
#debug prefix mindt/tcl {[debug caller] | }
#debug on mindt/tcl

# # ## ### ##### ######## #############

oo::class create mindt::tcl {
    superclass mindt::base

    constructor {} {
	debug.mindt/tcl {[debug caller] | }
	# Just configure the base class with the actual parsers for
	# language and special forms. The base class has all the event
	# handling for the special forms.
	next \
	    [mindt::parser::tcl     new] \
	    [mindt::parser::sf::tcl new]
    }

    # # ## ### ##### ######## ##### ### ## # #
}

# # ## ### ##### ######## #############
return
