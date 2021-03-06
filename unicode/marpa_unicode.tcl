# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
#
# marpa::unicode
# - Access to unicode tables, character classes, and operations on
#   them
#
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::bitmap
    package require critcl::iassoc
    package require critcl::cutil
}

if {![critcl::compiling]} {
    error "Unable to build Marpa, no proper compiler found."
}

critcl::source utilities.tcl
critcl::cutil::alloc

# # ## ### ##### ######## #############
## Build configuration
# (1) Assertions, and tracing
# (2) Debugging symbols, memory tracking

generate-tables

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
    {Binding to Jeffrey Kegler's libmarpa, an Earley/Leo/Aycock/Horspool parser engine. Unicode tables, character classes and operations.}

critcl::description {
    This package provides access to pre-computed unicode data tables,
    character classes, and operations on them.
}

critcl::subject marpa unicode {character class} charclass case-folding codepoint

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.5

critcl::ccode {
    TRACE_OFF;
}

# # ## ### ##### ######## #############
## Declare the Tcl layer

critcl::cheaders c/*.h
critcl::csources c/*.c

critcl::tsources tcl.tcl          ; # Tcl-level operations

critcl::source   types.tcl        ; # context and charclass
critcl::source   unflags.tcl      ; # 2utf, 2asbr flag support
critcl::source   points.tcl       ; # Codepoint argument type.
critcl::source   unicode.tcl      ; # C-level support functions: ASBR
critcl::source   unichar.tcl      ; # C-level support functions: ASSR
critcl::source   unifold.tcl      ; # C-level support functions: Case-folding
critcl::source   cc_objtype.tcl   ; # ObjType for uni-char classes (SCR).
critcl::source   asbr_objtype.tcl ; # ObjType for ASBR char class format.
critcl::source   assr_objtype.tcl ; # ObjType for ASSR char class format.

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading marpa::unicode failed."
}

# # ## ### ##### ######## #############

package provide marpa::unicode 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
