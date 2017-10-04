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
    package require critcl::emap     1.1 ; # mode C support
    package require critcl::literals 1.2 ; # mode C support
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build Marpa, no proper compiler found."
}

critcl::cutil::alloc

# # ## ### ##### ######## #############
## Build configuration
# (1) Assertions, and tracing
# (2) Debugging symbols, memory tracking

critcl::cutil::assertions on
critcl::cutil::tracer     off

critcl::debug symbols
#critcl::debug memory
#critcl::debug symbols memory
    
# # ## ### ##### ######## #############
## Administrivia

critcl::config lines 1
critcl::config trace 0

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

# # ## ### ##### ######## #############
## Basic Tcl-based parsing engine - runtime::tcl 

critcl::tsources engine/tcl/pre.tcl    ; # Dependencies

critcl::tsources engine/tcl/semstd.tcl    ; # Standard behaviours for SV handling
critcl::tsources engine/tcl/semstore.tcl  ; # Store for semantic values (interning strings)
critcl::tsources engine/tcl/semcore.tcl   ; # Common core for the execution of step instructions.
critcl::tsources engine/tcl/inbound.tcl   ; # Character streamer.
critcl::tsources engine/tcl/gate.tcl      ; # Character translation, class handling, symbol gating
critcl::tsources engine/tcl/engine.tcl       ; # Base class for lexer, parser
critcl::tsources engine/tcl/engine_debug.tcl ; # - Debugging support, active on request
critcl::tsources engine/tcl/lexer.tcl        ; # Lexer, aggregate characters to lexemes
critcl::tsources engine/tcl/parser.tcl       ; # Parser, structure lexemes into ASTs

critcl::tsources engine/tcl/rt_lex.tcl    ; # Engine assembly / Runtime: Lexer
critcl::tsources engine/tcl/rt_parse.tcl  ; # Engine assembly / Runtime: Lexer+Parser

# # ## ### ##### ######## #############
## Main C section.

# # ## ### ##### ######## #############
## Supporting C code

## NOTE: We use the prefix "marpatcl_" / "MarpaTcl_" for our
##       declarations, to avoid conflicts with libmarpa's public
##       symbols.

## The RTC is the C-based runtime-to-be. It is technically not needed
## by marpa itself (until after we have moved boot parser to generated
## C code). It is included to force problems with it to break the
## marpa built itself, i.e. as canary.

critcl::cheaders rtc/*.h
critcl::csources rtc/*.c

critcl::ccode {
    TRACE_OFF;
}

critcl::source c/errors.tcl           ; # Mapping marpa error codes to strings.
critcl::source c/events.tcl           ; # Mapping marpa event types to strings.
critcl::source c/steps.tcl            ; # String pool for valuation-steps.
critcl::source c/support.tcl          ; # General utilities and types.
critcl::source c/type_conversions.tcl ; # Custom argument & result types
critcl::source c/context.tcl          ; # Per-interp package information, shared
					# with all classes and instances.

# # ## ### ##### ######## #############
## C classes for the various types of objects.

# Value    \  No separate classes for parse forest ordering,
# Tree     \| iteration and valuation. All in the bocage class.
# Ordering  V
critcl::source c/bocage.tcl     ; # Bocage aka parse forest class.
critcl::source c/recognizer.tcl ; # Recognizer class
critcl::source c/grammar.tcl    ; # Grammar class

# # ## ### ##### ######## #############
## 

critcl::source slif/boot_parser.tcl                ; # SLIF Parser RTC (hardwired)

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading Marpa failed."
}

# # ## ### ##### ######## #############

package provide marpa 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
