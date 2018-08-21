# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##

# doctools processor, Tcl based.

# @@ Meta Begin
# Package doctools::tcl 1
# Meta author      {Andreas Kupries}
# Meta category    Parser
# Meta description A DOCTOOLS parser.
# Meta description Returns the abstract syntax tree of
# Meta description the doctools read from file or stdin.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     parsing doctools {abstract syntax tree}
# Meta summary     A doctools parser based on the Tcl binding to
# Meta summary     Jeffrey Kegler's libmarpa.
# @@ Meta End

# # ## ### ##### ######## #############

package provide doctools::tcl 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug           ;# Tracing
package require debug::caller   ;# Tracing
package require doctools::base

# # ## ### ##### ######## #############

debug define doctools/tcl
#debug prefix doctools/tcl {[debug caller] | }
#debug on doctools/tcl

# # ## ### ##### ######## #############

oo::class create doctools::tcl {
    superclass doctools::base

    constructor {} {
	debug.doctools/tcl {[debug caller] | }
	# Just configure the base class with the actual parsers for
	# language and special forms. The base class has all the event
	# handling for the special forms.
	next \
	    [doctools::parser::tcl     new] \
	    [doctools::parser::sf::tcl new]
    }

    # # ## ### ##### ######## ##### ### ## # #
}

# # ## ### ##### ######## #############
return
