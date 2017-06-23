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
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/gc-compact
debug prefix marpa/export/gc-compact {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::gc-compact {
    namespace export container
    namespace ensemble create

    namespace import ::marpa::export::config

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::gc-compact::container {gc} {
    debug.marpa/export/gc-compact {}
    return [Generate [$gc serialize]]
}

# # ## ### ##### ######## #############

proc ::marpa::export::gc-compact::Generate {serial} {
    debug.marpa/export/gc-compact {}

    lappend map {*}[config]
    lappend map @slif-serial@ $serial

    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

# # ## ### ##### ######## #############
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
package require marpa
package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller
debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }
oo::class @slif-name@ { superclass marpa::slif::container ; constructor {} { debug.marpa/grammar/@slif-name@ ; my deserialize {@slif-serial@}}}
return
