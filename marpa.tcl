# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Requisites

package require critcl 3.1
critcl::buildrequirement {
    package require critcl::util 1
    package require critcl::class 1
    package require critcl::emap
    package require critcl::literals
}

# # ## ### ##### ######## #############

if {![critcl::compiling]} {
    error "Unable to build Marpa, no proper compiler found."
}

# # ## ### ##### ######## #############
## Generate unicode data tables.

set selfdir [file dirname [file normalize [info script]]]
set dud $selfdir/p_unidata.tcl
set tud $selfdir/tools/unidata.tcl

# Choose the unicode range to support. Default is BMP, because that is
# what Tcl does, currently. When it supports more we can go to full range.
# When making the switch remove $dud above to force its regeneration.

set urange bmp   ;# Basic Multilingual Plane
#set urange full  ;# Full support

if {![file exists $dud] ||
    ([file mtime $dud] < [file mtime $tud]) ||
    ([file mtime $dud] < [file mtime $selfdir/unidata/UnicodeData.txt]) ||
    ([file mtime $dud] < [file mtime $selfdir/unidata/Scripts.txt])} {

    critcl::msg -nonewline { (Generating unicode data tables, please wait (about 2min) ...}
    # It usually takes about two minutes and change to process the
    # unidata files.  The majority of that time is taken by the
    # conversion of unicode char classes to ASBR form, with the
    # majority of that centered on a few but large categories like the
    # various type of Letters (Ll, Lo, Lu), and derived categories
    # including them.

    set start [clock seconds]
    exec {*}[info nameofexecutable] $tud $dud $urange 0
    set delta [expr { [clock seconds] - $start}]
    critcl::msg -nonewline " Done in $delta seconds: [file size $dud] bytes)"
    unset start delta
} else {
    critcl::msg -nonewline { (Up-to-date unicode data tables available, skipping generation)}
}

unset selfdir tud dud urange

# # ## ### ##### ######## #############
## Administrivia

critcl::config lines 1

critcl::license \
    {Andreas Kupries} \
    {Under a BSD license.}

critcl::summary \
    {Binding to Jeffrey Kegler's libmarpa, an Earley/Leo/Aycock/Horspool parser engine.}

critcl::description {
    This package is yet a nother parser system, after Tcllib's PAGE and PT.
    Contrary to these this does not use PEG, but an Earley-based parser, libmarpa.
}

critcl::subject libmarpa
critcl::subject marpa
critcl::subject parser
critcl::subject lexer
critcl::subject earley
critcl::subject aycock
critcl::subject horspool
critcl::subject {joop leo}
critcl::subject table-parsing
critcl::subject ast
critcl::subject syntax
critcl::subject grammar
critcl::subject token
critcl::subject symbol

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.5

# # ## ### ##### ######## #############
## Declarations and linkage of the libmarpa library we are binding to.

critcl::clibraries -L/usr/local/lib -lmarpa ; # XXX TODO automatic search/configuration
critcl::cheaders   -I/usr/local/include     ; # XXX TODO automatic search/configuration
critcl::include    marpa.h

# # ## ### ##### ######## #############
## Declare the Tcl layer aggregating the C primitives / classes into
## useful commands and hierarchies.

# Runtime classes, low-level on top of the C-wrappers.
##
critcl::tsources u_sequencing.tcl ; # Utilities for method call sequence validation
critcl::tsources p_support.tcl   ; # General Tcl level utilities
critcl::tsources p_unicode.tcl   ; # Unicode / UTF-8 utilities
critcl::tsources p_unidata.tcl   ; # Unicode Tables (char classes in various forms, folding)
#                                ; # This is a generated file (via tools/unidata.tcl)
critcl::tsources p_location.tcl  ; # Location/Range utilities
critcl::tsources p_semstd.tcl    ; # Standard behaviours for SV
				   # handling
critcl::tsources p_semstore.tcl  ; # Store for semantic values
				   # (interning strings)
critcl::tsources p_semcore.tcl   ; # Common core for handling of step
				   # instructions.
critcl::tsources p_inbound.tcl   ; # Character streamer.
critcl::tsources p_gate.tcl      ; # Character translation, class
				   # handling, symbol gating
critcl::tsources p_engine.tcl    ; # Base class for lexer, parser
critcl::tsources p_lexer.tcl     ; # Lexer, aggregate characters to
				   # lexemes
critcl::tsources p_parser.tcl    ; # Parser, structure lexemes into
				   # ASTs

# SLIF support commands and classes
##

critcl::tsources s_parser.tcl          ; # SLIF Parser (hardwired)
critcl::tsources s_literal_util.tcl    ; # SLIF, support commands for literals
critcl::tsources s_semantics.tcl       ; # SLIF semantics, driven by AST
critcl::tsources s_sem_debug.tcl       ; # - Debug support
critcl::tsources s_sem_start.tcl       ; # - Start symbol handling
critcl::tsources s_sem_fixup.tcl       ; # - Defered adverb handling
critcl::tsources s_sem_defaults.tcl    ; # - Defaults, generic
critcl::tsources s_sem_context.tcl     ; # - Symbol context
critcl::tsources s_sem_flags.tcl       ; # - Flags, generic
critcl::tsources s_sem_singleton.tcl   ; # - Singleton, generic
critcl::tsources s_sem_locations.tcl   ; # - Locations for items
critcl::tsources s_sem_symbols.tcl     ; # - Item state machine

critcl::tsources sc_serdes.tcl         ; # - Abstract (de)serialization base
critcl::tsources s_container.tcl       ; # SLIF container
critcl::tsources sc_atom.tcl           ; # - Lexical and structural atoms (literals, terminals)
critcl::tsources sc_alter.tcl          ; # - Generic alternative in priority rules
critcl::tsources sc_priority.tcl       ; # - Generic priority rules
critcl::tsources sc_priority_g1.tcl    ; #   - Specialized to G1 (attributes)
critcl::tsources sc_priority_l0.tcl    ; #   - Specialized to L0 (attributes)
critcl::tsources sc_quantified.tcl     ; # - Generic quantified rules
critcl::tsources sc_quantified_g1.tcl  ; #   - Specialized to G1 (attributes)
critcl::tsources sc_quantified_l0.tcl  ; #   - Specialized to L0 (attributes)
critcl::tsources sc_grammar.tcl        ; # - Basic grammar (symbols in various forms)
critcl::tsources sc_grammar_g1.tcl     ; #   - G1-specific extension of the basics
critcl::tsources sc_grammar_l0.tcl     ; #   - L0-specific extension of the basics
critcl::tsources sc_attribute.tcl      ; # - Attribute base
critcl::tsources sc_attr_global.tcl    ; #   - global container attributes
critcl::tsources sc_attr_lexsem.tcl    ; #   - lexeme-semantics attributes
critcl::tsources sc_attr_prio_g1.tcl   ; #   - Priority G1 rule attributes
critcl::tsources sc_attr_prio_l0.tcl   ; #   - Priority L0 rule attributes
critcl::tsources sc_attr_quant_g1.tcl  ; #   - Quantified G1 rule attributes
critcl::tsources sc_attr_quant_l0.tcl  ; #   - Quantified L0 rule attributes

# Experimental work on an alternate grammar container (vs
# p_grammar.tcl) ...
#critcl::tsources g_id.tcl         ; # Id generator

# # ## ### ##### ######## #############
## Main C section.

# # ## ### ##### ######## #############
## Supporting C code

## NOTE: We use the prefix "marpatcl_" / "MarpaTcl_" for our
##       declarations, to avoid conflicts with libmarpa's public
##       symbols.

critcl::source c_util.tcl     ; # Utilities for debug narrative - TRACE.
critcl::source c_errors.tcl   ; # Mapping marpa error codes to strings.
critcl::source c_events.tcl   ; # Mapping marpa event types to strings.
critcl::source c_steps.tcl    ; # String pool for valuation-steps.
critcl::source c_support.tcl  ; # General utilities and types.
critcl::source c_typeconv.tcl ; # Custom argument & result types
critcl::source c_context.tcl  ; # Per-interp package information,
				# shared to all classes and instances.

# # ## ### ##### ######## #############
## C classes for the various types of objects.

# Value    \  No separate classes for parse forest ordering,
# Tree     \| iteration and valuation. All in the bocage class.
# Ordering  V
critcl::source c_bocage.tcl     ; # Bocage aka parse forest class.
critcl::source c_recognizer.tcl ; # Recognizer class
critcl::source c_grammar.tcl    ; # Grammar class

# # ## ### ##### ######## #############
## Tcl level parts of the system.

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading Marpa failed."
}

# # ## ### ##### ######## #############

package provide marpa 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
