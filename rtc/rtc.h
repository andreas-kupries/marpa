/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Main header
 *
 * Notes:
 * - This engine is byte-based, not character-based. It is the responsibility
 *   of the generator to deconstruct UTF-8 character (strings) into byte
 *   sequences, and character classes into ASBR.
 *
 * - This engine does not support byte-ranges (at the moment).  It is again
 *   the responsibility of the generator to deconstruct ranges into
 *   alternations of bytes.
 */

#ifndef MARPA_RTC_H
#define MARPA_RTC_H

typedef struct marpa_rtc* marpa_rtc_p;

#include <spec.h>
#include <byteset.h>
#include <dynset.h>
#include <stack.h>
#include <inbound.h>
#include <gate.h>
#include <lexer.h>
#include <parser.h>

/*
 * -- dynamic state of an rtc engine --
 */

typedef struct marpa_rtc {
    marpa_rtc_grammar* spec;    /* Static grammar definitions */
    marpa_rtc_inbound  in;      /* Main dispatch */
    marpa_rtc_gate     gate;    /* Gating to lexer */
    marpa_rtc_lexer    lexer;   /* Lexing, gating to parser */
    marpa_rtc_parser   parser;  /* Parsing state */
} marpa_rtc;

/*
 * API functions
 */

marpa_rtc_p marpa_rtc_cons  (marpa_rtc_grammar g);
void        marpa_rtc_enter (marpa_rtc_p p, const char* bytes);
void        marpa_rtc_eof   (marpa_rtc_p p);

// TODO: API for semantic actions.

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
