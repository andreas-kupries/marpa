# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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
# Package marpa::gen::format::cparse-critcl 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for parsers
# Meta description based on the C runtime, wrapped as critcl-based package
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::gen::runtime::c
# Meta subject     marpa {parser generator} lexing {generator parser}
# Meta subject     {C runtime parsing} {parsing C runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::util
package require marpa::gen::runtime::c

debug define marpa/gen/format/cparse-critcl
debug prefix marpa/gen/format/cparse-critcl {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::cparse-critcl {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::cparse-critcl::container {gc} {
    debug.marpa/gen/format/cparse-critcl {}
    variable self
    marpa fqn gc
    set config [marpa::gen::runtime::c::config [$gc serialize] {
	prefix {	}
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
package provide marpa::gen::format::cparse-critcl 0
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
##	`marpa::runtime::c`-derived Parser for grammar "@slif-name@".
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
#* G1
#* - #Symbols:   @g1-symbols-c@
#* - #Rule Insn: @g1-insn-c@ (+2: setup, start-sym)
#* - #Rules:     @g1-rule-c@ (match insn)

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

critcl::ccode {
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
    ** G1 structures
    */

    static marpatcl_rtc_sym @cname@_g1_sym_name [@g1-symbols-c@] = { /* @g1-symbols-sz@ bytes */
@g1-symbols-indices@
    };

    static marpatcl_rtc_sym @cname@_g1_rule_name [@g1-rules-c@] = { /* @g1-rules-sz@ bytes */
@g1-rules-v@
    };

    static marpatcl_rtc_sym @cname@_g1_rule_lhs [@g1-rules-c@] = { /* @g1-rules-sz@ bytes */
@g1-lhs-v@
    };

    static marpatcl_rtc_sym @cname@_g1_rule_definitions [@g1-code-c@] = { /* @g1-code-sz@ bytes */
@g1-code@
    };
@g1-event-struct@
    static marpatcl_rtc_rules @cname@_g1 = { /* 48 */
	/* .sname   */  &@cname@_pool,
	/* .symbols */  { @g1-symbols-c@, @cname@_g1_sym_name },
	/* .rules   */  { @g1-rules-c@, @cname@_g1_rule_name },
	/* .lhs     */  { @g1-rules-c@, @cname@_g1_rule_lhs },
	/* .rcode   */  @cname@_g1_rule_definitions,
	/* .events  */  @g1-event-struct-ref@
    };

    static marpatcl_rtc_sym @cname@_g1semantics [@g1-semantics-c@] = { /* @g1-semantics-sz@ bytes */
@g1-semantics-v@
    };

    static marpatcl_rtc_sym @cname@_g1masking [@g1-masking-c@] = { /* @g1-masking-sz@ bytes */
@g1-masking-v@
    };

    /*
    ** Parser definition
    */

    static marpatcl_rtc_sym @cname@_always [@always-c@] = { /* @always-sz@ bytes */
@always-v@
    };

    static marpatcl_rtc_spec @cname@_spec = { /* 72 */
	/* .lexemes    */  @lexemes-c@,
	/* .discards   */  @discards-c@,
	/* .l_symbols  */  @l0-symbols-c@,
	/* .g_symbols  */  @g1-symbols-c@,
	/* .always     */  { @always-c@, @cname@_always },
	/* .l0         */  &@cname@_l0,
	/* .g1         */  &@cname@_g1,
	/* .l0semantic */  { @l0-semantics-c@, @cname@_l0semantics },
	/* .g1semantic */  { @g1-semantics-c@, @cname@_g1semantics },
	/* .g1mask     */  { @g1-masking-c@, @cname@_g1masking }
    };
    /* --- end of generated data structures --- */
}

# # ## ### ##### ######## ############# #####################
## Class exposing the grammar engine.
@event-names@
critcl::class def @slif-name@ {
    insvariable marpatcl_rtc_sv_p result {
	Parse result
    } {
	instance->result = 0;
    } {
	if (instance->result) marpatcl_rtc_sv_unref (instance->result);
    }

    @__event_setup__@

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
    }@__event_post__@

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path} ok {
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
	return marpatcl_rtc_sv_complete (ip, &instance->result, instance->state);
    }

    method process proc {Tcl_Interp* ip pstring string} ok {
	marpatcl_rtc_enter (instance->state, string.s, string.len);
	return marpatcl_rtc_sv_complete (ip, &instance->result, instance->state);
    }

    support {
	/*
	** Stem:  @stem@
	** Pkg:   @package@
	** Class: @class@
	** IType: @instancetype@
	** CType: @classtype@
	*/

	/*
	** Helper function capturing parse results (semantic values of the parser)
	*/

	static void
	@stem@_result (void* cdata, marpatcl_rtc_sv_p sv)
	{
	    @instancetype@ instance = (@instancetype@) cdata;
	    if (instance->result) marpatcl_rtc_sv_unref (instance->result);
	    if (sv) marpatcl_rtc_sv_ref (sv);
	    instance->result = sv;
	    return;
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
					     @stem@_result,
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
					     @stem@_result,
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
