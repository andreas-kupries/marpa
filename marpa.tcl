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

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::util 1
    package require critcl::class 1
    package require critcl::emap
    package require critcl::literals
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build Marpa, no proper compiler found."
}

critcl::source c/utilities.tcl
critcl::cutil::alloc

# # ## ### ##### ######## #############
## Build configuration
# (1) Choose the unicode range to support.
# (2) Assertions, and tracing
# (3) Debugging symbols, memory tracking

generate-tables ;# 'bmp' (default), or 'full'

critcl::cutil::assertions on
critcl::cutil::tracer     off

critcl::debug symbols
#critcl::debug memory
#critcl::debug symbols memory
    
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

## !ATTENTION! During package assembly by critcl the hierarchy below
## !ATTENTION! is flattened into a single directory. This means that
## !ATTENTION! file names must be unique across the directories.
## This does not apply to the critcl::source'd files coming after.

# # ## ### ##### ######## #############
## Mostly generic utilities for various things

critcl::tsources generic/sequencing.tcl ; # Method call sequence validation
critcl::tsources generic/support.tcl    ; # General Tcl level
critcl::tsources generic/unicode.tcl    ; # Unicode / UTF-8

					  # This is a generated file (See tools/unidata.tcl)
critcl::tsources generic/location.tcl   ; # Location/Range handling

# # ## ### ##### ######## #############
## Basic Tcl-based parsing engine

critcl::tsources engine/tcl/semstd.tcl    ; # Standard behaviours for SV handling
critcl::tsources engine/tcl/semstore.tcl  ; # Store for semantic values (interning strings)
critcl::tsources engine/tcl/semcore.tcl   ; # Common core for the execution of step instructions.
critcl::tsources engine/tcl/inbound.tcl   ; # Character streamer.
critcl::tsources engine/tcl/gate.tcl      ; # Character translation, class handling, symbol gating
critcl::tsources engine/tcl/engine.tcl    ; # Base class for lexer, parser
critcl::tsources engine/tcl/lexer.tcl     ; # Lexer, aggregate characters to lexemes
critcl::tsources engine/tcl/parser.tcl    ; # Parser, structure lexemes into ASTs

# # ## ### ##### ######## #############
## SLIF support commands and classes
## Parser, semantics, grammar container

critcl::tsources slif/boot_parser.tcl             ; # SLIF Parser (hardwired)

critcl::tsources slif/semantics/literal_util.tcl  ; # SLIF, support commands for literals
critcl::tsources slif/semantics/semantics.tcl     ; # SLIF semantics, driven by AST
critcl::tsources slif/semantics/debug.tcl         ; # - Debug support
critcl::tsources slif/semantics/start.tcl         ; # - Start symbol handling
critcl::tsources slif/semantics/fixup.tcl         ; # - Defered adverb handling
critcl::tsources slif/semantics/defaults.tcl      ; # - Defaults, generic
critcl::tsources slif/semantics/context.tcl       ; # - Symbol context
critcl::tsources slif/semantics/flags.tcl         ; # - Flags, generic
critcl::tsources slif/semantics/singleton.tcl     ; # - Singleton, generic
critcl::tsources slif/semantics/locations.tcl     ; # - Locations for items
critcl::tsources slif/semantics/symbols.tcl       ; # - Item state machine

critcl::tsources slif/container/serdes.tcl        ; # - Abstract (de)serialization base
critcl::tsources slif/container/container.tcl     ; # SLIF container
critcl::tsources slif/container/atom.tcl          ; # - Lexical and structural atoms (literals, terminals)
critcl::tsources slif/container/alter.tcl         ; # - Generic alternative in priority rules
critcl::tsources slif/container/priority.tcl      ; # - Generic priority rules
critcl::tsources slif/container/priority_g1.tcl   ; #   - Specialized to G1 (attributes)
critcl::tsources slif/container/priority_l0.tcl   ; #   - Specialized to L0 (attributes)
critcl::tsources slif/container/quantified.tcl    ; # - Generic quantified rules
critcl::tsources slif/container/quantified_g1.tcl ; #   - Specialized to G1 (attributes)
critcl::tsources slif/container/quantified_l0.tcl ; #   - Specialized to L0 (attributes)
critcl::tsources slif/container/grammar.tcl       ; # - Basic grammar (symbols in various forms)
critcl::tsources slif/container/grammar_g1.tcl    ; #   - G1-specific extension of the basics
critcl::tsources slif/container/grammar_l0.tcl    ; #   - L0-specific extension of the basics
critcl::tsources slif/container/attribute.tcl     ; # - Attribute base
critcl::tsources slif/container/attr_global.tcl   ; #   - global container attributes
critcl::tsources slif/container/attr_lexsem.tcl   ; #   - lexeme-semantics attributes
critcl::tsources slif/container/attr_prio_g1.tcl  ; #   - Priority G1 rule attributes
critcl::tsources slif/container/attr_prio_l0.tcl  ; #   - Priority L0 rule attributes
critcl::tsources slif/container/attr_quant_g1.tcl ; #   - Quantified G1 rule attributes
critcl::tsources slif/container/attr_quant_l0.tcl ; #   - Quantified L0 rule attributes
critcl::tsources slif/container/precedence.tcl    ; # SLIF, precedence utilities, rewrite

# # ## ### ##### ######## #############
## Main C section.

# # ## ### ##### ######## #############
## Supporting C code

## NOTE: We use the prefix "marpatcl_" / "MarpaTcl_" for our
##       declarations, to avoid conflicts with libmarpa's public
##       symbols.

#critcl::cheaders mc/*.h
#critcl::csources mc/*.c

critcl::source c/errors.tcl           ; # Mapping marpa error codes to strings.
critcl::source c/events.tcl           ; # Mapping marpa event types to strings.
critcl::source c/steps.tcl            ; # String pool for valuation-steps.
critcl::source c/support.tcl          ; # General utilities and types.
critcl::source c/type_conversions.tcl ; # Custom argument & result types
critcl::source c/context.tcl          ; # Per-interp package information, shared
					# with all classes and instances.

critcl::source c/unicode.tcl          ; # Unicode support functions.
critcl::source c/cc_objtype.tcl       ; # Tcl_ObjType for uni char classes (SCR).
critcl::source c/asbr_objtype.tcl     ; # Tcl_ObjType for ASBR char class format.

# # ## ### ##### ######## #############
## C classes for the various types of objects.

# Value    \  No separate classes for parse forest ordering,
# Tree     \| iteration and valuation. All in the bocage class.
# Ordering  V
critcl::source c/bocage.tcl     ; # Bocage aka parse forest class.
critcl::source c/recognizer.tcl ; # Recognizer class
critcl::source c/grammar.tcl    ; # Grammar class

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
