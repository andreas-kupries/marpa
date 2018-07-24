/* Runtime for C-engine (RTC). Declarations. (Grammar specification)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SPEC_H
#define MARPATCL_RTC_SPEC_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <marpa_runtime_c.h>
#include <sem.h>
#include <stack.h>

/*
 * TODO: G1 semantic handler needs access to more context:
 * TODO: - active marpa step instruction
 * TODO: - dynamic parser state (implies: static grammar structures)
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Notes:
 * - MARPATCL_SV_CMD : 2 arguments, string pool reference (action name)
 *                           and action code, counted from 0
 *   Dispatch function decides which to use.
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * See also export/rtc.tcl -- Keep In Sync
 *
 * -- symbol allocations in l0           -- in g1
 * --   0     ... 255         characters
 * -- 256     ... 256+L-1     lexemes    -- 0   ... L-1 terminals == lexemes
 * -- 256+L   ... 256+L+D-1   discards   -- L           start symbol
 * -- 256+L+D ... 256+L+D+X-1 other      -- L+1 ... G-1 other
 *
 * lexeme <-> terminal mapping   i.e. lexer vs parser
 *
 *   @ lexeme   <-- terminal + 256
 *   @ terminal <-- lexeme   - 256
 *
 * Further:
 *   In L0 the first L+D internal symbols are the actual lexeme and discard
 *   symbols. The first set actually are their ACS symbols. This means:
 *
 *   @ lex/dis symbol <-- ACS symbol     + (L+D)
 *   @ ACS symbol     <-- lex/dis symbol - (L+D)
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 *
 * setup - Use the static structures to fill an active Marpa grammar
 */

marpatcl_rtc_stack_p marpatcl_rtc_spec_setup_rd (marpatcl_rtc_rules* s);
marpatcl_rtc_stack_p marpatcl_rtc_spec_setup    (Marpa_Grammar g, marpatcl_rtc_rules* s, int rd);
const char*          marpatcl_rtc_spec_symname  (marpatcl_rtc_rules* g,  marpatcl_rtc_sym id, int* len);
const char*          marpatcl_rtc_spec_rulename (marpatcl_rtc_rules* g,  marpatcl_rtc_sym id, int* len);
const char*          marpatcl_rtc_spec_string   (marpatcl_rtc_string* p, marpatcl_rtc_sym id, int* len);
marpatcl_rtc_sym*    marpatcl_rtc_spec_g1decode (marpatcl_rtc_symvec* coding, marpatcl_rtc_sym rule, int* len);
marpatcl_rtc_sym     marpatcl_rtc_spec_g1map    (marpatcl_rtc_symvec* map, marpatcl_rtc_sym id);
int                  marpatcl_rtc_spec_symid    (marpatcl_rtc_rules* g, const char* symname);

#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
