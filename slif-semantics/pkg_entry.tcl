# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
#
# marpa::slif::semantics
# - Semantics to process a SLIF syntax tree into a SLIF container
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
# Package marpa::slif::semantics 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa, the semantics to
# Meta description convert the abstract syntax tree
# Meta description delivered by a SLIF parser for a
# Meta description grammar into a series of instructions
# Meta description which enter that grammar into a SLIF
# Meta description container.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta require     char
# Meta require     oo::util
# Meta require     marpa::util
# Meta require     marpa::slif::literal
# Meta subject     marpa grammar {slif semantics} {semantics for slif}
# Meta summary     Container for grammars specified via SLIF
# @@ Meta End

# # ## ### ##### ######## #############
## SLIF support: Grammar container

package require debug
package require debug::caller
package require char ;# debugging narrative ?!
package require oo::util
package require marpa::util
package require marpa::slif::literal::parse
package require marpa::slif::literal::util

## Find a way to have this list only once.

# @owns: semantics.tcl
# @owns: debug.tcl
# @owns: start.tcl
# @owns: fixup.tcl
# @owns: defaults.tcl
# @owns: context.tcl
# @owns: flags.tcl
# @owns: singleton.tcl
# @owns: locations.tcl
# @owns: symbols.tcl

apply {{selfdir} {
    source $selfdir/semantics.tcl     ; # SLIF semantics, driven by AST
    source $selfdir/debug.tcl         ; # - Debug support
    source $selfdir/start.tcl         ; # - Start symbol handling
    source $selfdir/fixup.tcl         ; # - Defered adverb handling
    source $selfdir/defaults.tcl      ; # - Defaults, generic
    source $selfdir/context.tcl       ; # - Symbol context
    source $selfdir/flags.tcl         ; # - Flags, generic
    source $selfdir/singleton.tcl     ; # - Singleton, generic
    source $selfdir/locations.tcl     ; # - Locations for items
    source $selfdir/symbols.tcl       ; # - Item state machine
}} [file dirname [file normalize [info script]]]

# # ## ### ##### ######## #############

package provide marpa::slif::semantics 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
