# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for generators. Conversion of RHS masks as provided by the
# SLIF semantics (list (bool)) to the format taken by the runtimes
# (list (int), indices to hide/remove).

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::remask 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Conversion of RHS
# Meta description masks from semantics to runtimes
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta subject     marpa {mask conversion} {conversion of masking}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/gen/remask
debug prefix marpa/gen/remask {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen {
    namespace export remask
    namespace ensemble create
}

# # ## ### ##### ######## #############
## API

proc ::marpa::gen::remask {mask} {
    debug.marpa/gen/remask {}
    # Convert mask from the semantics: list (bool), true => hide, 0 => visible
    # The engine takes a list of indices to remove instead.
    set i -1
    set filter {}
    foreach flag $mask {
	incr i
	if {!$flag} continue
	lappend filter $i
    }
    return $filter
}

# # ## ### ##### ######## #############
package provide marpa::gen::remask 1
return
