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
    error "Unable to build `marpa::c`, no proper compiler found."
}

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

critcl::cutil::alloc

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
## Supporting C code

critcl::ccode {
    TRACE_OFF;
}

critcl::source errors.tcl           ; # Mapping marpa error codes to strings.
critcl::source events.tcl           ; # Mapping marpa event types to strings.
critcl::source steps.tcl            ; # String pool for valuation-steps.
critcl::source support.tcl          ; # General utilities and types.
critcl::source type_conversions.tcl ; # Custom argument & result types
critcl::source context.tcl          ; # Per-interp package information, shared
					# with all classes and instances.

# Value    \  No separate classes for parse forest ordering,
# Tree     \| iteration and valuation. All in the bocage class.
# Ordering  V
critcl::source bocage.tcl     ; # Bocage aka parse forest class.
critcl::source recognizer.tcl ; # Recognizer class
critcl::source grammar.tcl    ; # Grammar class

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading `marpa::c` failed."
}

# # ## ### ##### ######## #############

package provide marpa::c 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
