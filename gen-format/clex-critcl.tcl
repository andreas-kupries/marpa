# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator) -- Core functionality see `marpa::gen::runtime::c`
##
# - Output format: C code, structures for RTC.
#   Code is formatted with newlines and indentation.
#   Code is a Critcl wrapper class around the RTC.
#   The generated class matches the API of Tcl engines, in
#   terms of construction and methods.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::format::clex-critcl 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for lexers
# Meta description based on the C runtime
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::gen::runtime::c
# Meta subject     marpa {lexer generator} lexing {generator lexer}
# Meta subject     {C runtime lexing} {lexer C runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::util
package require marpa::gen::runtime::c

debug define marpa/gen/format/clex-critcl
debug prefix marpa/gen/format/clex-critcl {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::clex-critcl {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::clex-critcl::container {gc} {
    debug.marpa/gen/format/clex-critcl {}
    variable self
    marpa fqn gc
    set config [marpa::gen::runtime::c::config [$gc serialize] {
	prefix {	}
	events l0
    }]

    set template [string trim [marpa asset $self]]

    if {[dict get $config @have-events@]} {
	set cname [dict get $config @cname@]
	dict set config @__event_pkg__@   "\n    package require critcl::literals"
	dict set config @__event_list__@  "${cname}_event_list"
    } else {
	dict set config @__event_pkg__@   ""
	dict set config @__event_list__@  0
    }

    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::clex-critcl 0
return
##
## Template and parts following (`source` will not process it)
# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                             http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ @slif-version@ By @slif-writer@
##
##	`marpa::runtime::c`-derived Lexer for grammar "@slif-name@".
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##
#* Space taken: @space@ bytes
##
#* Statistics
#* L0
#* - #Symbols:   @l0-symbols-c@
#* - #Lexemes:   @lexemes-c@
#* - #Discards:  @discards-c@
#* - #Always:    @always-c@
#* - #Rule Insn: @l0-insn-c@ (+2: setup, start-sym)
#* - #Rules:     @l0-rule-c@ (>= insn, brange)

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::class
    package require critcl::cutil@__event_pkg__@
}

if {![critcl::compiling]} {
    error "Unable to build @slif-name@, no compiler found."
}

critcl::cutil::alloc
critcl::cutil::assertions on
critcl::cutil::tracer     on

critcl::debug symbols
#critcl::debug memory
#critcl::debug symbols memory

# # ## ### ##### ######## ############# #####################
## Requirements

critcl::api import marpa::runtime::c 0
critcl::api import critcl::callback  1

# # ## ### ##### ######## ############# #####################
## Static data structures declaring the grammar

critcl::include string.h ;# memcpy
critcl::ccode {
    TRACE_OFF;

    /*
    ** Shared string pool (@string-length-sz@ bytes lengths over @string-c@ entries)
    **                    (@string-offset-sz@ bytes offsets -----^)
    **                    (@string-data-sz@ bytes character content)
    */

    static marpatcl_rtc_size @cname@_pool_length [@string-c@] = { /* @string-length-sz@ bytes */
@string-length-v@
    };

    static marpatcl_rtc_size @cname@_pool_offset [@string-c@] = { /* @string-offset-sz@ bytes */
@string-offset-v@
    };

    static marpatcl_rtc_string @cname@_pool = { /* 24 + @string-data-sz@ bytes */
	@cname@_pool_length,
	@cname@_pool_offset,
@string-data-v@
    };

    /*
    ** Map lexeme strings to parser symbol id (`match alternate` support).
    */

    static marpatcl_rtc_sym_lmap @cname@_lmap [@lexemes-c@] = {
@lexemes-map@
    };
@event-table@
    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym @cname@_l0_sym_name [@l0-symbols-c@] = { /* @l0-symbols-sz@ bytes */
@l0-symbols-indices@
    };

    static marpatcl_rtc_sym @cname@_l0_rule_definitions [@l0-code-c@] = { /* @l0-code-sz@ bytes */
@l0-code@
    };
@l0-trigger@
    static marpatcl_rtc_rules @cname@_l0 = { /* 48 */
	/* .sname   */  &@cname@_pool,
	/* .symbols */  { @l0-symbols-c@, @cname@_l0_sym_name },
	/* .lmap    */  { @lexemes-c@, @cname@_lmap },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  @cname@_l0_rule_definitions,
	/* .events  */  @event-ref@,
	/* .trigger */  @l0-trigger-ref@
    };

    static marpatcl_rtc_sym @cname@_l0semantics [@l0-semantics-c@] = { /* @l0-semantics-sz@ bytes */
@l0-semantics-v@
    };

    /*
    ** G1 structures - None, lexing only
    */

    /*
    ** Engine definition. G1 fields nulled.
    ** Triggers lex-only operation in the runtime.
    */

    static marpatcl_rtc_sym @cname@_always [@always-c@] = { /* @always-sz@ bytes */
@always-v@
    };

    static marpatcl_rtc_spec @cname@_spec = { /* 72 */
	/* .lexemes    */  @lexemes-c@,
	/* .discards   */  @discards-c@,
	/* .l_symbols  */  @l0-symbols-c@,
	/* .g_symbols  */  0,
	/* .always     */  { @always-c@, @cname@_always },
	/* .l0         */  &@cname@_l0,
	/* .g1         */  NULL,
	/* .l0semantic */  { @l0-semantics-c@, @cname@_l0semantics },
	/* .g1semantic */  { 0, 0 },
	/* .g1mask     */  { 0, 0 }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.
@event-names@
critcl::class def @slif-name@ {

    insvariable marpatcl_rtc_lex lstate {
	State for the token callback to store the incoming tokens and
	values before they get passed to the Tcl level.
    } {
	marpatcl_rtc_lex_init (&instance->lstate);
    } {
	marpatcl_rtc_lex_release (&instance->lstate);
    }

    # Note how `rtc` is declared before `pedesc`. We need it
    # initalized to be able to feed it into the construction of the
    # PE descriptor facade.
    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structure.
    } {
	instance->state = marpatcl_rtc_cons (&@cname@_spec,
					     NULL, /* No actions */
					     marpatcl_rtc_lex_token, (void*) &instance->lstate,
					     marpatcl_rtc_eh_report, (void*) &instance->ehstate );
    } {
	marpatcl_rtc_destroy (instance->state);
    }

    insvariable marpatcl_rtc_pedesc_p pedesc {
	Facade to the parse event descriptor structures.
	Maintained only when we have parse events declared, i.e. possible.
    } {
	// Feed our RTC structure into the facade class so that its constructor has access to it.
	marpatcl_rtc_pedesc_rtc_set (interp, instance->state);
	instance->pedesc = marpatcl_rtc_pedesc_new (interp, 0, 0);
	ASSERT (!marpatcl_rtc_pedesc_rtc_get (interp), "Constructor failed to take rtc structure");
    } {
	marpatcl_rtc_pedesc_destroy (instance->pedesc);
    }

    insvariable marpatcl_ehandlers ehstate {
	Handler for parse events
    } {
	marpatcl_rtc_eh_init (&instance->ehstate, interp,
			      (marpatcl_events_to_names) @__event_list__@);
	/* h.self initialized by the constructor post-body */
	/* See on-event above for further setup */
    } {
	marpatcl_rtc_eh_clear (&instance->ehstate);
	Tcl_DecrRefCount (instance->ehstate.self);
	instance->ehstate.self = 0;
    }

    insvariable Tcl_Obj* name {
	Object name, tail
    } { /* Initialized in the post constructor */ } {
	Tcl_DecrRefCount (instance->name);
    }


    method on-event proc {object args} void {
	marpatcl_rtc_eh_setup (&instance->ehstate, args.c, args.v);
    }

    method match proc {Tcl_Interp* ip object args} ok {
	/* -- Delegate to the parse event descriptor facade */
	return marpatcl_rtc_pe_match (instance->pedesc, ip, instance->name,
				      args.c, args.v);
    }

    constructor {
        /*
	 * Syntax:                          ... []
         * skip == 2: <class> new           ...
         *      == 3: <class> create <name> ...
         */

	if (objc > 0) {
	    Tcl_WrongNumArgs (interp, objcskip, objv-objcskip, 0);
	    goto error;
	}

	instance->lstate.ip = interp;
    } {
	/* Post body. Save the FQN for use in the callbacks */
	instance->ehstate.self = fqn;
	Tcl_IncrRefCount (fqn);
        instance->name = Tcl_NewStringObj (Tcl_GetCommandName (interp, instance->cmd), -1);
        Tcl_IncrRefCount (instance->name);
    }

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path list outcmd object args} ok {
	int from, to;
	if (!marpatcl_rtc_pe_range (ip, args.c, args.v, &from, &to)) { return TCL_ERROR; }

	Tcl_Obj* ebuf;
	if (marpatcl_rtc_fget (ip, instance->state, path, &ebuf) != TCL_OK) {
	    return TCL_ERROR;
	}

	instance->lstate.matched = critcl_callback_new (ip, outcmd.c, outcmd.v, 3);
	critcl_callback_extend (instance->lstate.matched, Tcl_NewStringObj ("enter", -1));

	int got;
	char* buf = Tcl_GetStringFromObj (ebuf, &got);
	marpatcl_rtc_enter (instance->state, buf, got, from, to);
	Tcl_DecrRefCount (ebuf);

	critcl_callback_p on_eof = critcl_callback_new (ip, outcmd.c, outcmd.v, 1);
	critcl_callback_extend (on_eof, Tcl_NewStringObj ("eof", -1));

	int res = critcl_callback_invoke (on_eof, 0, 0);

	critcl_callback_destroy (on_eof);
	critcl_callback_destroy (instance->lstate.matched);
	instance->lstate.matched = 0;

	return res;
    }

    method process proc {Tcl_Interp* ip pstring string list outcmd object args} ok {
	int from, to;
	if (!marpatcl_rtc_pe_range (ip, args.c, args.v, &from, &to)) { return TCL_ERROR; }

	instance->lstate.matched = critcl_callback_new (ip, outcmd.c, outcmd.v, 3);
	critcl_callback_extend (instance->lstate.matched, Tcl_NewStringObj ("enter", -1));

	marpatcl_rtc_enter (instance->state, string.s, string.len, from, to);

	critcl_callback_p on_eof = critcl_callback_new (ip, outcmd.c, outcmd.v, 1);
	critcl_callback_extend (on_eof, Tcl_NewStringObj ("eof", -1));

	int res = critcl_callback_invoke (on_eof, 0, 0);

	critcl_callback_destroy (on_eof);
	critcl_callback_destroy (instance->lstate.matched);
	instance->lstate.matched = 0;

	return res;
    }

    method extend proc {Tcl_Interp* ip pstring string} int {
	return marpatcl_rtc_enter_more (instance->state, string.s, string.len);
    }


    method extend-file proc {Tcl_Interp* ip object path} ok {
	Tcl_Obj* ebuf;
	if (marpatcl_rtc_fget (ip, instance->state, path, &ebuf) != TCL_OK) {
	    return TCL_ERROR;
	}

	int got;
	char* buf = Tcl_GetStringFromObj (ebuf, &got);
	int offset = marpatcl_rtc_enter_more (instance->state, buf, got);
	Tcl_DecrRefCount (ebuf);

	Tcl_SetObjResult (ip, Tcl_NewIntObj (offset));
	return TCL_OK;
    }
}

# # ## ### ##### ######## ############# #####################
return
