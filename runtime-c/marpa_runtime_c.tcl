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
    package require critcl::cutil
    package require critcl::emap     ;# For c/steps.tcl, c/events.tcl
    package require critcl::literals ;# For c/steps.tcl
}

if {![critcl::compiling]} {
    error "Unable to build `marpa::runtime::c`, no proper compiler found."
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

critcl::config lines 1
critcl::config trace 0
    
# # ## ### ##### ######## #############
## Administrivia

critcl::license \
    {Andreas Kupries} \
    {Under a BSD license.}

critcl::summary \
    {Binding to Jeffrey Kegler's libmarpa, an Earley/Leo/Aycock/Horspool parser engine.}

critcl::description {
    Part of TclMarpa. Runtime for C-based lexers and parsers, wrapped in Critcl.
}

critcl::subject libmarpa marpa parser lexer {c runtime} earley aycock horspool
critcl::subject {joop leo} table-parsing chart-parsing top-down

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.5
critcl::cutil::alloc

# # ## ### ##### ######## #############
## Declarations and linkage of the libmarpa library we are binding to.

critcl::clibraries -L/usr/local/lib -lmarpa ; # XXX TODO automatic search/configuration
critcl::cheaders   -I/usr/local/include     ; # XXX TODO automatic search/configuration
critcl::include    marpa.h

# # ## ### ##### ######## #############
## Public API for use by generated lexers and parsers.

critcl::api header marpa_runtime_c.h

critcl::api function marpatcl_rtc_p marpatcl_rtc_cons {
    marpatcl_rtc_spec_p g
    marpatcl_rtc_sv_cmd a
    marpatcl_rtc_result r
    void*               rcd
}
critcl::api function void marpatcl_rtc_destroy {
    marpatcl_rtc_p p
}
critcl::api function void marpatcl_rtc_enter {
    marpatcl_rtc_p p
    {const char*}  bytes
    int            n
}
critcl::api function int marpatcl_rtc_failed {
    marpatcl_rtc_p p
}
critcl::api function Tcl_Obj* marpatcl_rtc_sv_astcl {
    Tcl_Interp*       ip
    marpatcl_rtc_sv_p sv
}
critcl::api function int marpatcl_rtc_sv_complete {
    Tcl_Interp*        ip
    marpatcl_rtc_sv_p* sv
    marpatcl_rtc_p     p
}
critcl::api function marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_evec {
    int capacity
}
critcl::api function marpatcl_rtc_sv_p marpatcl_rtc_sv_ref {
    marpatcl_rtc_sv_p v
}
critcl::api function void marpatcl_rtc_sv_unref {
    marpatcl_rtc_sv_p v
}
critcl::api function void marpatcl_rtc_sv_vec_clear {
    marpatcl_rtc_sv_p v
}
critcl::api function void marpatcl_rtc_sv_vec_push {
    marpatcl_rtc_sv_p v
    marpatcl_rtc_sv_p x
}
critcl::api function int marpatcl_rtc_sv_vec_size {
    marpatcl_rtc_sv_p v
}

# # ## ### ##### ######## #############
## Supporting C code

## NOTE: We use the prefix "marpatcl_" / "MarpaTcl_" for our
##       declarations, to avoid conflicts with any of libmarpa's
##       public symbols.

critcl::cheaders -I[file dirname [file normalize [info script]]]
critcl::csources *.c

critcl::ccode {
    TRACE_OFF;
}

# Use various definitions from `marpa::c` here too.
# - marpa events
# - marpa step types
# - marpa step fields
# - marpa error codes

critcl::source ../c/events.tcl
critcl::source ../c/steps.tcl
critcl::source ../c/errors.tcl

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading `marpa::runtime::c` failed."
}

# # ## ### ##### ######## #############

package provide marpa::runtime::c 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl: