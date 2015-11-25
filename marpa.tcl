# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

#critcl::tsources policy.tcl

critcl::tsources p_support.tcl  ; # General Tcl level utilities
critcl::tsources p_location.tcl ; # Location/Range utilities
critcl::tsources p_semstd.tcl   ; # Standard behaviours for SV handling
critcl::tsources p_semstore.tcl ; # Store for semantic values
				  # (interning strings)
critcl::tsources p_semcore.tcl  ; # Common core for handling of step
				  # instructions.
critcl::tsources p_inbound.tcl  ; # Character streamer.
critcl::tsources p_gate.tcl     ; # Character translation, class
				  # handling, symbol gating
critcl::tsources p_engine.tcl   ; # Base class for lexer, parser
critcl::tsources p_lexer.tcl    ; # Lexer, aggregate characters to
				  # lexemes
critcl::tsources p_parser.tcl   ; # Parser, structure lexemes into
				  # ASTs
critcl::tsources p_grammar.tcl  ; # SLIF grammar container

# # ## ### ##### ######## #############
## Main C section.

# # ## ### ##### ######## #############
## Supporting C code

## NOTE: We use the prefix "marpatcl_" / "MarpaTcl_" for our
##       declarations, to avoid conflicts with libmarpa's public
##       symbols.

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
