# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
#
# marpa::slif::container
# - Container class to hold grammars specified via SLIF.
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
# Package marpa::slif::container 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa, a container to
# Meta description hold grammars specified via SLIF
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     marpa::util
# Meta require     debug
# Meta require     debug::caller

## Meta require     oo::util
## Meta require     struct::matrix
## Meta require     fileutil
## Meta require     char
## Meta require     lambda
## Meta require     try

# Meta subject     marpa grammar {container for grammar} slif
# Meta subject     symbol rule {quantified rule} {priority rule} adverb
# Meta summary     Container for grammars specified via SLIF
# @@ Meta End

# # ## ### ##### ######## #############
## SLIF support: Grammar container

package require marpa::util

## Find a way to have this list only once.
# @owns: alter.tcl
# @owns: atom.tcl
# @owns: attr_global.tcl
# @owns: attr_lexsem.tcl
# @owns: attr_prio_g1.tcl
# @owns: attr_prio_l0.tcl
# @owns: attr_quant_g1.tcl
# @owns: attr_quant_l0.tcl
# @owns: attribute.tcl
# @owns: container.tcl
# @owns: grammar.tcl
# @owns: grammar_g1.tcl
# @owns: grammar_l0.tcl
# @owns: priority.tcl
# @owns: priority_g1.tcl
# @owns: priority_l0.tcl
# @owns: quantified.tcl
# @owns: quantified_g1.tcl
# @owns: quantified_l0.tcl
# @owns: serdes.tcl

apply {{selfdir} {
    source $selfdir/serdes.tcl        ; # - Abstract (de)serialization base
    source $selfdir/container.tcl     ; # SLIF container
    source $selfdir/atom.tcl          ; # - Lexical and structural atoms (literals, terminals)
    source $selfdir/alter.tcl         ; # - Generic alternative in priority rules
    source $selfdir/priority.tcl      ; # - Generic priority rules
    source $selfdir/priority_g1.tcl   ; #   - Specialized to G1 (attributes)
    source $selfdir/priority_l0.tcl   ; #   - Specialized to L0 (attributes)
    source $selfdir/quantified.tcl    ; # - Generic quantified rules
    source $selfdir/quantified_g1.tcl ; #   - Specialized to G1 (attributes)
    source $selfdir/quantified_l0.tcl ; #   - Specialized to L0 (attributes)
    source $selfdir/grammar.tcl       ; # - Basic grammar (symbols in various forms)
    source $selfdir/grammar_g1.tcl    ; #   - G1-specific extension of the basics
    source $selfdir/grammar_l0.tcl    ; #   - L0-specific extension of the basics
    source $selfdir/attribute.tcl     ; # - Attribute base
    source $selfdir/attr_global.tcl   ; #   - global container attributes
    source $selfdir/attr_lexsem.tcl   ; #   - lexeme-semantics attributes
    source $selfdir/attr_prio_g1.tcl  ; #   - Priority G1 rule attributes
    source $selfdir/attr_prio_l0.tcl  ; #   - Priority L0 rule attributes
    source $selfdir/attr_quant_g1.tcl ; #   - Quantified G1 rule attributes
    source $selfdir/attr_quant_l0.tcl ; #   - Quantified L0 rule attributes
}} [file dirname [file normalize [info script]]]

# # ## ### ##### ######## #############

package provide marpa::slif::container 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
