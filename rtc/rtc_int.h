/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Main header, Internals
 */

#ifndef MARPA_RTC_INT_H
#define MARPA_RTC_INT_H

#include <spec.h>
#include <inbound.h>
#include <gate.h>
#include <lexer.h>
#include <parser.h>

/*
 * -- dynamic state of an rtc engine --
 */

typedef struct marpa_rtc {
    marpa_rtc_spec*    spec;    /* Static grammar definitions */
    Marpa_Config       config;  /* Config info shared to lexer and parser */
    marpa_rtc_inbound  in;      /* Main dispatch */
    marpa_rtc_gate     gate;    /* Gating to lexer */
    marpa_rtc_lexer    lexer;   /* Lexing, gating to parser */
    marpa_rtc_parser   parser;  /* Parsing state */
} marpa_rtc;

/*
 * Shorthands for fields.
 */

#define SP (p->spec)
#define IN (p->in)
#define GA (p->gate)
#define LX (p->lexer)
#define PA (p->parser)
#define CO (p->config)

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
