# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator)
##
# - Output format: Tcl code
#   Subclass of "marpa::slif::container" with embedded grammar
#   definition loaded on construction.
#
#   Expanded formatting of the serialization, with newlines and proper
#   indentation to show nesting. Human readability over size.

#   Grammar is reduced as for tparse/tlex. IOW it shows how the
#   literals got encoded for this, and the rewritten precedenced
#   rules.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::format::gc-tcl 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for grammar containers.
# Meta description Human-readable formatting. Reduced as for the Tcl runtime.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::gen
# Meta subject     marpa {container generator} lexing {generator container}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::gen
package require marpa::gen::reformat
package require marpa::gen::runtime::tcl
package require marpa::util

debug define marpa/gen/format/gc-tcl
debug prefix marpa/gen/format/gc-tcl {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::gc-tcl {
    namespace export container
    namespace ensemble create

    namespace import ::marpa::gen::config

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::gc-tcl::container {gc} {
    debug.marpa/gen/format/gc-tcl {}
    marpa::fqn gc

    set gcr [marpa::gen::runtime::tcl gc [$gc serialize]]
    set serial [$gcr serialize]
    $gcr destroy

    return [Generate $serial]
}

# # ## ### ##### ######## #############

proc ::marpa::gen::format::gc-tcl::Generate {serial} {
    debug.marpa/gen/format/gc-tcl {}

    lappend map {*}[config]
    lappend map @slif-serial@ \n[marpa::gen reformat $serial]\n\t

    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::gc-tcl 0
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
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

package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#
package require marpa::slif::container

# # ## ### ##### ######## #############

debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create @slif-name@ {
    superclass marpa::slif::container

    constructor {} {
	debug.marpa/grammar/@slif-name@
	my deserialize {@slif-serial@}
	return
    }
}

# # ## ### ##### ######## #############
return
