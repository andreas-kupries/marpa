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

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/cparse-raw
debug prefix marpa/export/cparse-raw {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::cparse-raw {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::cparse-raw::container {gc} {
    debug.marpa/export/cparse-raw {}
    variable self
    set config   [marpa::export::core::rtc::config [$gc serialize]]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
return
##
## Template following (`source` will not process it)
/* -*- c -*-
**
* This template is BSD-licensed.
* (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
*                                     http://core.tcl.tk/akupries/
**
* (c) @slif-year@ Grammar @slif-name@ @slif-version@ By @slif-writer@
**
**	rtc-derived Engine for grammar "@slif-name@". Lexing + Parsing.
**	Generated On @generation-time@
**		  By @tool-operator@
**		 Via @tool@
**
** Space taken: @space@ bytes
**
** Statistics
** L0
** - #Symbols:   @l0-symbols-c@
** - #Lexemes:   @lexemes-c@
** - #Discards:  @discards-c@
** - #Always:    @always-c@
** - #Rule Insn: @l0-insn-c@ (+2: setup, start-sym)
** - #Rules:     @l0-rule-c@ (>= insn, brange)
** G1
** - #Symbols:   @g1-symbols-c@
** - #Rule Insn: @g1-insn-c@ (+2: setup, start-sym)
** - #Rules:     @g1-rule-c@ (match insn)
*/

#include <spec.h>
#include <rtc.h>

/*
 * Shared string pool (@string-length-sz@ bytes lengths over @string-c@ entries)
 *                    (@string-offset-sz@ bytes offsets -----^)
 *                    (@string-data-sz@ bytes character content)
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
 * L0 structures
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
 * G1 structures
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
 * Parser definition
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

/*
 * Constructor
 */

marpatcl_rtc_p
@cname@_constructor (marpatcl_rtc_sv_cmd a)
{
    return marpatcl_rtc_cons (&@cname@_spec, a);
}
