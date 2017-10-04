# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
#
# marpa::util
# - A mix of utility commands and classes.
#   - location values and operations
#   - method sequencing support
#   - timing support
#   - Miscellanea
#
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::util 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa, miscellaneous utility commands
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta subject     marpa
# Meta summary     Utiliy commands
# @@ Meta End

# # ## ### ##### ######## #############
## SLIF support: Grammar container

## Find a way to have this list only once.
# @owns: location.tcl
# @owns: timing.tcl
# @owns: support.tcl
# @owns: sequencing.tcl

apply {{selfdir} {
    source $selfdir/sequencing.tcl ; # Method call sequence validation
    source $selfdir/timing.tcl     ; # Method call benchmarking
    source $selfdir/support.tcl    ; # General Tcl level
    source $selfdir/location.tcl   ; # Location/Range handling
}} [file dirname [file normalize [info script]]]

# # ## ### ##### ######## #############

package provide marpa::util 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
