# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
#
#          Roughly equivalent to the Marpa::R2 perl binding (I hope).
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Flag to toggle integration of SV diagnostic code.
set refdebug 0

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::cutil
    package require critcl::emap     ;# For c/steps.tcl, c/events.tcl, pevents.tcl
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
critcl::cutil::tracer     on

critcl::debug symbols
#critcl::debug memory
#critcl::debug symbols memory

critcl::config lines 1
critcl::config trace 0
#critcl::config keepsrc 1

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

if {$refdebug} {
    critcl::cflags -DSEM_REF_DEBUG
}

critcl::clibraries -L/usr/local/lib -lmarpa ; # XXX TODO automatic search/configuration
critcl::cheaders   -I/usr/local/include     ; # XXX TODO automatic search/configuration
critcl::include    marpa.h

critcl::api import critcl_callback 1

# # ## ### ##### ######## #############
## Public API for use by generated lexers and parsers.

critcl::api header marpa_runtime_c.h

critcl::api function marpatcl_rtc_p marpatcl_rtc_cons {
    marpatcl_rtc_spec_p     g
    marpatcl_rtc_sv_cmd     a
    marpatcl_rtc_result_cmd r
    void*                   rcdata
    marpatcl_rtc_event_cmd  e
    void*                   ecdata
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

# generic support for lex-only mode

critcl::api function void marpatcl_rtc_lex_init {
    marpatcl_rtc_lex_p state
}
critcl::api function void marpatcl_rtc_lex_release {
    marpatcl_rtc_lex_p state
}
critcl::api function void marpatcl_rtc_lex_token {
    void*             cdata
    marpatcl_rtc_sv_p sv
}

# generic support for parse event handling

critcl::api function void marpatcl_rtc_eh_init {
    marpatcl_ehandlers_p     e
    Tcl_Interp*              ip
    marpatcl_events_to_names to_names
}
critcl::api function void marpatcl_rtc_eh_clear {
    marpatcl_ehandlers_p e
}
critcl::api function void marpatcl_rtc_eh_setup {
    marpatcl_ehandlers_p e
    int                  c
    Tcl_Obj*const*       v
}
critcl::api function void marpatcl_rtc_eh_report {
    void*                  cdata
    marpatcl_rtc_eventtype type
    int                    c
    int*                   ids
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
critcl::source pevents.tcl

if {$refdebug} {
    critcl::cproc marpa::slif::runtime::dump {} void {
	extern void marpatcl_rtc_sv_dump (void);
	marpatcl_rtc_sv_dump();
    }
}

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading `marpa::runtime::c` failed."
}

# # ## ### ##### ######## #############

package provide marpa::runtime::c 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
