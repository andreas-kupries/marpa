# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator) -- Core functionality see `export::core::rtc`
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
    }]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::clex-critcl 0
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
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
    package require critcl::cutil
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

# # ## ### ##### ######## ############# #####################
## Static data structures declaring the grammar

critcl::include string.h ;# memcpy
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

    /*
    ** L0 structures
    */

    static marpatcl_rtc_sym @cname@_l0_sym_name [@l0-symbols-c@] = { /* @l0-symbols-sz@ bytes */
@l0-symbols-indices@
    };

    static marpatcl_rtc_sym @cname@_l0_rule_definitions [@l0-code-c@] = { /* @l0-code-sz@ bytes */
@l0-code@
    };

    static marpatcl_rtc_rules @cname@_l0 = { /* 48 */
	/* .sname   */  &@cname@_pool,
	/* .symbols */  { @l0-symbols-c@, @cname@_l0_sym_name },
	/* .rules   */  { 0, NULL },
	/* .lhs     */  { 0, NULL },
	/* .rcode   */  @cname@_l0_rule_definitions
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

critcl::class def @slif-name@ {

    insvariable marpatcl_rtc_sv_p tokens {
	Scratchpad for the @stem@_token callback to store the incoming
	tokens before they get passed to the Tcl level.
    } {
	instance->tokens = marpatcl_rtc_sv_cons_evec (1); // Expandable
    } {
	if (instance->tokens) marpatcl_rtc_sv_unref (instance->tokens);
    }

    insvariable marpatcl_rtc_sv_p values {
	Scratchpad for the @stem@_token callback to store the incoming
	values before they get passed to the Tcl level.
    } {
	instance->values = marpatcl_rtc_sv_cons_evec (1); // Expandable
    } {
	if (instance->values) marpatcl_rtc_sv_unref (instance->values);
    }

    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&@cname@_spec,
					     NULL, @stem@_token,
					     (void*) instance );
    } {
	marpatcl_rtc_destroy (instance->state);
    }

    # Future: Wrap callback handling into a C utility class to handle
    # everything for the user.
    insvariable int outcmd_c {
	Command prefix to handle the tokens delivered by the lexer, count
    } {
	instance->outcmd_c = 0;
    } { /* Nothing to release */ }

    insvariable Tcl_Obj** outcmd_v {
	Command prefix to handle the tokens delivered by the lexer, elements
    } {
	instance->outcmd_v = 0;
    } { /* Nothing to release */ }

    insvariable Tcl_Interp* ip {
	Interpreter back reference for instance internal callbacks from the C engine.
    } {
	instance->ip = 0;
    } { /* Nothing to release */ }

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
    } {}

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path list outcmd} ok {
	int res, got;
	char* buf;
	Tcl_Channel in = Tcl_FSOpenFileChannel (ip, path, "r", 0666);

	if (!in) {
	    return TCL_ERROR;
	}
	Tcl_SetChannelBufferSize (in, 4096);
	Tcl_SetChannelOption (ip, in, "-translation", "binary");
	Tcl_SetChannelOption (ip, in, "-encoding",    "binary");
	// TODO: abort on failed set-channel-option

	instance->outcmd_c = outcmd.c;
	instance->outcmd_v = outcmd.v;

	buf = NALLOC (char, 4096); // TODO: configurable
	while (!Tcl_Eof(in)) {
	    got = Tcl_Read (in, buf, 4096);
	    if (!got) continue; /* Pass the buck to next Tcl_Eof */
	    marpatcl_rtc_enter (instance->state, buf, got);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	FREE (buf);

	(void) Tcl_Close (ip, in);

	res = @stem@_callout_eof (instance);

    	// Clear outcmd
	instance->outcmd_c = 0;
	instance->outcmd_v = 0;

	return res;
    }

    method process proc {Tcl_Interp* ip pstring string list outcmd} ok {
	int res;

	instance->outcmd_c = outcmd.c;
	instance->outcmd_v = outcmd.v;

	marpatcl_rtc_enter (instance->state, string.s, string.len);

	res = @stem@_callout_eof (instance);

    	// Clear outcmd
	instance->outcmd_c = 0;
	instance->outcmd_v = 0;

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

	static void incr_v (int c, Tcl_Obj** v) {
	    int i; for (i=0; i < c; i++) { Tcl_IncrRefCount (v[i]); }
	}

	static void decr_v (int c, Tcl_Obj** v) {
	    int i; for (i=0; i < c; i++) { Tcl_DecrRefCount (v[i]); }
	}

	static int
	@stem@_callout_eof (@instancetype@ instance)
	{
	    int c = instance->outcmd_c + 1;
	    int res;
	    Tcl_Obj** v = NALLOC (Tcl_Obj*, c);
	    memcpy (v, instance->outcmd_v, instance->outcmd_c * sizeof (Tcl_Obj*));

	    // TODO: literal pool for the method names
	    v [c-1] = Tcl_NewStringObj ("eof", -1);

	    incr_v (c, v);
	    res = Tcl_EvalObjv (instance->ip, c, v, 0);
	    decr_v (c, v);
	    return res;
	}

	static int
	@stem@_callout_enter (@instancetype@ instance, Tcl_Obj* ts, Tcl_Obj* vs)
	{
	    int c = instance->outcmd_c + 3;
	    int res;
	    Tcl_Obj** v = NALLOC (Tcl_Obj*, c);
	    memcpy (v, instance->outcmd_v, instance->outcmd_c * sizeof (Tcl_Obj*));

	    // TODO: literal pool for the method names
	    v [c-3] = Tcl_NewStringObj ("enter", -1);
	    v [c-2] = ts;
	    v [c-1] = vs;

	    incr_v (c, v);
	    res = Tcl_EvalObjv (instance->ip, c, v, 0);
	    decr_v (c, v);
	    return res;
	}

	static void
	@stem@_token (void* cdata, marpatcl_rtc_sv_p sv)
	{
	    @instancetype@ instance = (@instancetype@) cdata;
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
		marpatcl_rtc_sv_vec_clear (instance->tokens);
		marpatcl_rtc_sv_vec_clear (instance->values);
		return;
	    }

	    if (sv == ((marpatcl_rtc_sv_p) 1)) {
		// Complete "enter", call into Tcl

		Tcl_Obj* ts = marpatcl_rtc_sv_astcl (instance->ip, instance->tokens);
		Tcl_Obj* vs = marpatcl_rtc_sv_astcl (instance->ip, instance->values);

		(void) @stem@_callout_enter (instance, ts, vs);

		Tcl_DecrRefCount (ts);
		Tcl_DecrRefCount (vs);
		return;
	    };

	    if (marpatcl_rtc_sv_vec_size (instance->tokens) ==
		marpatcl_rtc_sv_vec_size (instance->values)) {
		// Even call, both pads are empty or filled with matching t/v pairs.
		// This call is a new token.
		marpatcl_rtc_sv_vec_push (instance->tokens, sv);
	    } else {
		// Odd call, we have one more token than values.
		// This call is a new value, match them again.
		marpatcl_rtc_sv_vec_push (instance->values, sv);
	    }
	    return;
	}
    }
}

# # ## ### ##### ######## ############# #####################
return
