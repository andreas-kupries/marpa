# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
#
# marpa::runtime::tcl
# - Runtime support for Tcl-based lexers and parsers
#
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::runtime::tcl 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Runtime for Tcl-based lexers and parsers.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     marpa
# Meta require     marpa::util
# Meta require     debug
# Meta require     debug::caller

# Meta subject     marpa grammar {container for grammar} slif
# Meta subject     symbol rule {quantified rule} {priority rule} adverb
# Meta summary     Container for grammars specified via SLIF
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require marpa::util
package require marpa ;# C pieces -- marpa::c in future, TODO

## Find a way to have this list only once.
# @owns: semstd.tcl
# @owns: semstore.tcl
# @owns: semcore.tcl
# @owns: inbound.tcl
# @owns: gate.tcl
# @owns: engine.tcl
# @owns: engine_debug.tcl
# @owns: lexer.tcl
# @owns: parser.tcl
# @owns: rt_lex.tcl
# @owns: rt_parse.tcl

apply {{selfdir} {
    source $selfdir/semstd.tcl       ; # Standard behaviours for SV handling
    source $selfdir/semstore.tcl     ; # Store for semantic values (interning strings)
    source $selfdir/semcore.tcl      ; # Common core for the execution of step instructions.
    source $selfdir/inbound.tcl      ; # Character streamer.
    source $selfdir/gate.tcl         ; # Character translation, class handling, symbol gating
    source $selfdir/engine.tcl       ; # Base class for lexer, parser
    source $selfdir/engine_debug.tcl ; # - Debugging support, active on request
    source $selfdir/lexer.tcl        ; # Lexer, aggregate characters to lexemes
    source $selfdir/parser.tcl       ; # Parser, structure lexemes into ASTs
    source $selfdir/rt_lex.tcl       ; # Engine assembly / Runtime: Lexer
    source $selfdir/rt_parse.tcl     ; # Engine assembly / Runtime: Lexer+Parser
}} [file dirname [file normalize [info script]]]

# # ## ### ##### ######## #############

package provide marpa::runtime::tcl 1
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
