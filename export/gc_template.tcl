# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter support (gc, gc-formatted): Template access.
##

# Note: The template is part of this file, after a ^Z character. Tcl's
# source command will not read beyond that character, and thus use
# only the package code itself, as it should. In the initialization
# code we the read file again, via introspection, and -eofchar
# shenanigans allow us to skip the package code and read the template
# instead.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/gc/template
debug prefix marpa/export/gc/template {[debug caller] | }

# # ## ### ##### ######## #############
## State

namespace eval ::marpa::export::gc::template {
    namespace export get
    namespace ensemble create

    variable template
}

# # ## ### ##### ######## #############
## Initialization

apply {{self} {
    variable template
    set ch [open $self]
    # Skip package code, use special EOF handling analogous to `source`.
    fconfigure $ch -eofchar \x1A
    read $ch
    # Switch to regular EOF handling
    fconfigure $ch -eofchar {}
    # Skip the separator character
    read $ch 1
    # And then read the template into memory
    set template [string trim [read $ch]]
    close $ch
    return
} ::marpa::export::gc::template} [info script]

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::gc::template::get {} {
    debug.marpa/export/gc/template {}
    variable template
    return $template
}

# # ## ### ##### ######## #############
return
##
## Template following (`source` will not process it)

# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	Container for SLIF Grammar "@slif-name@"
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require marpa	      ;# marpa::slif::container
package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#

# # ## ### ##### ######## #############

debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }

# # ## ### ##### ######## #############

oo::class @slif-name@ {
    superclass marpa::slif::container

    constructor {} {
	debug.marpa/grammar/@slif-name@
	my deserialize {@slif-serial@}
	return
    }
}

# # ## ### ##### ######## #############
return
