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
#   Compact formatting, no newlines, no indentation

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/gc
debug prefix marpa/export/gc {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::gc {
    namespace export serial container
    namespace ensemble create

    namespace import ::marpa::export::config
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::gc::serial {serial} {
    debug.marpa/export/gc {}

    lappend map {*}[config]
    lappend map @slif-serial@ $serial

    return [string map $map [template get]]
}

proc ::marpa::export::gc::container {gc} {
    debug.marpa/export/gc {}
    return [serial [$gc serialize]]
}

# # ## ### ##### ######## #############
return
