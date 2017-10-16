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
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    #package require critcl::util 1
    #package require critcl::class 1
    #package require critcl::emap     1.1 ; # mode C support
    #package require critcl::literals 1.2 ; # mode C support
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

critcl::subject marpa unicode {character class} charclass case-folding

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.5

critcl::ccode {
    TRACE_OFF;
}

# # ## ### ##### ######## #############
## Declare the Tcl layer

critcl::tsources tcl.tcl          ; # Tcl-level operations
critcl::source   unicode.tcl      ; # C-level support functions.
critcl::source   cc_objtype.tcl   ; # ObjType for uni-char classes (SCR).
critcl::source   asbr_objtype.tcl ; # ObjType for ASBR char class format.

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading marpa::unicode failed."
}

# # ## ### ##### ######## #############

package provide marpa::unicode 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
