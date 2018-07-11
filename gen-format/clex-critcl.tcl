# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

    lassign [lmap segment [marpa asset* $self] {
	string trim $segment
    }] template setup_events setup_no_events setup_post

    if {[dict get $config @have-events@]} {
	dict set config @__event_setup__@ [string map $config $setup_events]
	dict set config @__event_pkg__@   "\n    package require critcl::literals"
	dict set config @__event_post__@  " $setup_post"
    } else {
	dict set config @__event_setup__@ [string map $config $setup_no_events]
	dict set config @__event_pkg__@   ""
	dict set config @__event_post__@  " \{\}"
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
# (c) 2017-2018 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
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
@l0-event-struct@
    static marpatcl_rtc_rules @cname@_l0 = { /* 48 */
	/* .sname   */  &@cname@_pool,
	/* .symbols */  { @l0-symbols-c@, @cname@_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  @cname@_l0_rule_definitions,
	/* .events  */  @l0-event-struct-ref@
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

    insvariable marpatcl_rtc_sv_p tokens {
	Scratchpad for the @stem@_token callback to store the incoming
	tokens before they get passed to the Tcl level.
    } {
	instance->tokens = marpatcl_rtc_sv_cons_evec (1); // Expandable
	TRACE ("cons (i %p).(tokens %p)", instance, instance->tokens);
    } {
	TRACE ("dest (i %p).(tokens %p)", instance, instance->tokens);
	if (instance->tokens) marpatcl_rtc_sv_unref (instance->tokens);
    }

    insvariable marpatcl_rtc_sv_p values {
	Scratchpad for the @stem@_token callback to store the incoming
	values before they get passed to the Tcl level.
    } {
	instance->values = marpatcl_rtc_sv_cons_evec (1); // Expandable
	TRACE ("cons (i %p).(values %p)", instance, instance->values);
    } {
	TRACE ("dest (i %p).(values %p)", instance, instance->values);
	if (instance->values) marpatcl_rtc_sv_unref (instance->values);
    }

    @__event_setup__@

    insvariable Tcl_Interp* ip {
	Interpreter back reference for SV/Tcl conversion glue code
    } {
	instance->ip = 0;
    } { /* Nothing to release */ }

    insvariable critcl_callback_p matched {
	Tcl callback to report the matching of a token, with token information.
    } {
	instance->matched = 0;
    } {
	if (instance->matched) critcl_callback_destroy (instance->matched);
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

	instance->ip = interp;
    }@__event_post__@

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path list outcmd} ok {
	int res, got;
	char* buf;
	Tcl_Obj* cbuf = Tcl_NewObj();
	Tcl_Channel in = Tcl_FSOpenFileChannel (ip, path, "r", 0666);

	if (!in) {
	    return TCL_ERROR;
	}
	Tcl_SetChannelBufferSize (in, 4096);
	Tcl_SetChannelOption (ip, in, "-translation", "binary");
	Tcl_SetChannelOption (ip, in, "-encoding",    "utf-8");
	// TODO: abort on failed set-channel-option

	critcl_callback_p on_eof = critcl_callback_new (ip, outcmd.c, outcmd.v, 1);
	critcl_callback_extend (on_eof, Tcl_NewStringObj ("eof", -1));

	instance->matched = critcl_callback_new (ip, outcmd.c, outcmd.v, 3);
	critcl_callback_extend (instance->matched, Tcl_NewStringObj ("enter", -1));

	while (!Tcl_Eof(in)) {
	    got = Tcl_ReadChars (in, cbuf, 4096, 0);
	    if (got < 0) {
		return TCL_ERROR;
	    }
	    if (!got) continue; /* Pass the buck to next Tcl_Eof */
	    buf = Tcl_GetStringFromObj (cbuf, &got);
	    marpatcl_rtc_enter (instance->state, buf, got);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	Tcl_DecrRefCount (cbuf);

	(void) Tcl_Close (ip, in);

	res = critcl_callback_invoke (on_eof, 0, 0);

	critcl_callback_destroy (on_eof);
	critcl_callback_destroy (instance->matched);
	instance->matched = 0;

	return res;
    }

    method process proc {Tcl_Interp* ip pstring string list outcmd} ok {
	int res;

	critcl_callback_p on_eof = critcl_callback_new (ip, outcmd.c, outcmd.v, 1);
	critcl_callback_extend (on_eof, Tcl_NewStringObj ("eof", -1));

	instance->matched = critcl_callback_new (ip, outcmd.c, outcmd.v, 3);
	critcl_callback_extend (instance->matched, Tcl_NewStringObj ("enter", -1));

	marpatcl_rtc_enter (instance->state, string.s, string.len);

	res = critcl_callback_invoke (on_eof, 0, 0);

	critcl_callback_destroy (on_eof);
	critcl_callback_destroy (instance->matched);
	instance->matched = 0;

	return res;
    }

    support {
	/* Helper function capturing parse results (semantic values of the parser)
	** Stem:  @stem@
	** Pkg:   @package@
	** Class: @class@
	** IType: @instancetype@
	** CType: @classtype@
	*/

	static void
	@stem@_token (void* cdata, marpatcl_rtc_sv_p sv)
	{
	    @instancetype@ instance = (@instancetype@) cdata;
	    TRACE_FUNC ("(i %p), ((sv*) %p)", instance, sv);

	    // See rtc/lexer.c 'complete' (!SPEC->g1) for the caller.
	    //
	    // Call sequence:
	    // - sv == 0 : "enter" begins
	    // - sv == 1 : "enter" is complete, call to Tcl
	    // - any other sv:
	    //   - even call => sv is token [string]
	    //   - odd  call => sv is value [any]

	    if (sv == 0) {
		// Begin "enter"
		TRACE ("%s", "enter /begin");

		TRACE ("- clear (i %p).(tokens %p)", instance, instance->tokens);
		marpatcl_rtc_sv_vec_clear (instance->tokens);

		TRACE ("- clear (i %p).(values %p)", instance, instance->values);
		marpatcl_rtc_sv_vec_clear (instance->values);

		TRACE ("%s", "enter /begin done");
		TRACE_RETURN_VOID;
	    }

	    if (sv == ((marpatcl_rtc_sv_p) 1)) {
		// Complete "enter", call into Tcl
		TRACE ("%s", "enter close /begin");

		Tcl_Obj* v[2];
		v[0] = marpatcl_rtc_sv_astcl (instance->ip, instance->tokens);
		v[1] = marpatcl_rtc_sv_astcl (instance->ip, instance->values);

		TRACE ("%s", "enter close - callback");
		(void) critcl_callback_invoke (instance->matched, 2, v);
		TRACE ("%s", "enter close - callback return");

		TRACE ("%s", "enter close /done");
		TRACE_RETURN_VOID;
	    };

	    if (marpatcl_rtc_sv_vec_size (instance->tokens) ==
		marpatcl_rtc_sv_vec_size (instance->values)) {
		// Even call, both pads are empty or filled with matching t/v pairs.
		// This call is a new token.

		TRACE ("push token ((sv*) %p)", sv);
		marpatcl_rtc_sv_vec_push (instance->tokens, sv);
	    } else {
		// Odd call, we have one more token than values.
		// This call is a new value, match them again.

		TRACE ("push value ((sv*) %p)", sv);
		marpatcl_rtc_sv_vec_push (instance->values, sv);
	    }

	    TRACE_RETURN_VOID;
	}
    }
}

# # ## ### ##### ######## ############# #####################
return

    # Setup for events

    method on-event proc {Tcl_Interp* ip object args} void {
	marpatcl_rtc_eh_setup (&instance->h, ip, args.c, args.v, instance->self);
    }

    insvariable Tcl_Obj* self {
	Self reference of the instance command.
    } {
	/* Initialized by the constructor post-body */
    } {
	Tcl_DecrRefCount (instance->self);
	instance->self = 0;
    }
   
    insvariable marpatcl_ehandlers h {
	Handler for parse events
    } {
	marpatcl_rtc_eh_init (&instance->h);
	/* See on-event for full setup */
    } {
	marpatcl_rtc_eh_clear (&instance->h);
    }

    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&@cname@_spec,
					     NULL, /* No actions */
					     @stem@_token,
					     @stem@_event,
					     (void*) instance );
    } {
	marpatcl_rtc_destroy (instance->state);
    }

    support {
	/*
	** Helper function to handle parse events. Invoked by the runtime.
	** In turn delegates to the approciate critcl::callback to reach Tcl.
	*/

	static void
	@stem@_event (void* cdata, marpatcl_rtc_event_code code, int n, Marpa_Symbol_ID* ids)
	{
	    @instancetype@ instance = (@instancetype@) cdata;
	    if (!instance->h[0]) return;
	    Tcl_Obj* events = @slif-name@_event_list (n, ids);
	    Tcl_IncrRefcount (events);
	    critcl_callback_invoke (instance->h [code], 1, events);
	    Tcl_DecrRefcount (events);
	    return;
	}
    }

    # Setup without events

    method on-event proc {Tcl_Interp* ip object args} void {}

    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&@cname@_spec,
					     NULL, /* No actions */
					     @stem@_token,
					     0,
					     (void*) instance );
    } {
	marpatcl_rtc_destroy (instance->state);
    }

{
	/* Post body. Save the FQN for use in the callbacks */
	instance->self = fqn;
    }
