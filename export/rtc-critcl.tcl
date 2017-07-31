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
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/rtc-critcl
debug prefix marpa/export/rtc-critcl {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::rtc-critcl {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::rtc-critcl::container {gc} {
    debug.marpa/export/rtc-critcl {}
    variable self
    set config [marpa::export::core::rtc::config [$gc serialize] {
	prefix {	}
    }]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
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
##	rtc-derived Engine for grammar "@slif-name@". Lexing + Parsing.
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##
#* Space taken: @space@ bytes

package require Tcl 8.5 ;# apply, lassign, ...
package require critcl 3.1
critcl::buildrequirement {
    package require critcl::class 1
    package require critcl::emap
    package require critcl::literals
    package require critcl::cutil
}
if {![critcl::compiling]} { error "Unable to build @slif-name@, no compiler found." }

critcl::cutil::alloc
critcl::cutil::assertions on
critcl::cutil::tracer     on

# # ## ### ##### ######## ############# #####################
## Requirements

critcl::clibraries -L/usr/local/lib -lmarpa ; # XXX TODO automatic search/configuration
critcl::cheaders   -I/usr/local/include     ; # XXX TODO automatic search/configuration

critcl::cheaders rtc/*.h
critcl::csources rtc/*.c

critcl::include marpa.h
critcl::include spec.h
critcl::include rtc.h
critcl::include fail.h

critcl::source c/errors.tcl           ; # Mapping marpa error codes to strings.
critcl::source c/events.tcl           ; # Mapping marpa event types to strings.
critcl::source c/steps.tcl            ; # String pool for valuation-steps.

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

    static marpatcl_rtc_rules @cname@_g1 = { /* 48 */
	/* .sname   */  &@cname@_pool,
	/* .symbols */  { @g1-symbols-c@, @cname@_g1_sym_name },
	/* .rules   */  { @g1-rules-c@, @cname@_g1_rule_name },
	/* .lhs     */  { @g1-rules-c@, @cname@_g1_rule_lhs },
	/* .rcode   */  @cname@_g1_rule_definitions
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

critcl::class def @slif-name@ {
    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
    } {
	instance->state = marpatcl_rtc_cons (&@cname@_spec, NULL /* TODO FUTURE */);
    } {
	marpatcl_rtc_destroy (instance->state);
    }
    
    # constructor - automatic

    method process-file proc {Tcl_Interp* ip Tcl_Obj* path} ok {
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
	
	buf = NALLOC (char, 4096); // TODO: configurable
	while (!Tcl_Eof(in)) {
	    got = Tcl_Read (in, buf, 4096);
	    if (!got) continue; /* Pass the buck to next Tcl_Eof */
	    marpatcl_rtc_enter (instance->state, buf, got);
	    if (marpatcl_rtc_failed (instance->state)) break;
	}
	FREE (buf);

	(void) Tcl_Close (ip, in);
	return @stem@_complete (ip, instance->state);
    }
    
    method process proc {Tcl_Interp* ip pstring text} ok {
	marpatcl_rtc_enter (instance->state, text.s, text.len);
	return @stem@_complete (ip, instance->state);
    }

    support {
	/* Helper function encapsulating parse completion processing.
	** Stem:  @stem@
	** Pkg:   @package@
	** Class: @class@
	** IType: @instancetype@
	** CType: @classtype@
	*/

	static int
	@stem@_complete (Tcl_Interp* ip, marpatcl_rtc_p state)
	{
	    if (!marpatcl_rtc_failed (state)) {
		marpatcl_rtc_eof (state);
	    }
	    if (marpatcl_rtc_failed (state)) {
		// TODO: retrieve and throw error
		return TCL_ERROR;
	    } else {
		// TODO: retrieve and return AST
		return TCL_OK;
	    }
	}
    }
}

# # ## ### ##### ######## ############# #####################
package provide @cname@ @slif-version@
return
