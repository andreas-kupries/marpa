# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##

# doctools processor, C based.

# @@ Meta Begin
# Package doctools::c 1
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

package provide doctools::c 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug           ;# Tracing
package require debug::caller   ;# Tracing

package require doctools::base
package require	doctools::parser::c
package require	doctools::parser::sf::c

# # ## ### ##### ######## #############

debug define doctools/c
#debug prefix doctools/c {[debug caller] | }
#debug on doctools/c

# # ## ### ##### ######## #############

oo::class create doctools::c {
    superclass doctools::base

    constructor {} {
	debug.doctools/c {[debug caller] | }
	# Just configure the base class with the actual parsers for
	# language and special forms. The base class has all the event
	# handling for the special forms.
	next \
	    [doctools::parser::c     new] \
	    [doctools::parser::sf::c new]
    }

    # # ## ### ##### ######## ##### ### ## # #
}

# # ## ### ##### ######## #############
return
