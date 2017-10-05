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
#   Definition loaded on construction.
#
#   Compact formatting, no newlines, no indentation. Ditto for the
#   template itself.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::format::gc-compact 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for grammar containers.
# Meta description Compact formatting
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
package require marpa::util

debug define marpa/gen/format/gc-compact
debug prefix marpa/gen/format/gc-compact {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::gc-compact {
    namespace export container
    namespace ensemble create

    namespace import ::marpa::gen::config

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::gc-compact::container {gc} {
    debug.marpa/gen/format/gc-compact {}
    marpa::fqn gc
    return [Generate [$gc serialize]]
}

# # ## ### ##### ######## #############

proc ::marpa::gen::format::gc-compact::Generate {serial} {
    debug.marpa/gen/format/gc-compact {}

    lappend map {*}[config]
    lappend map @slif-serial@ $serial

    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::gc-compact 0
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
# (Gen: @tool-operator@, @tool@, @generation-time@)
# (c) 2017 Template - Andreas Kupries - BSD licensed
# http://wiki.tcl.tk/andreas%20kupries
# http://core.tcl.tk/akupries/
package provide @slif-name@ @slif-version@
package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller
package require marpa::slif::container
debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }
oo::class create @slif-name@ { superclass marpa::slif::container ; constructor {} { debug.marpa/grammar/@slif-name@ ; my deserialize {@slif-serial@}}}
return
