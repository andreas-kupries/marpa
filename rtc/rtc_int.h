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
#include <sem_int.h>
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
    marpa_rtc_sv_cmd   action;  /* Dispatcher for user actions */
    marpa_rtc_sv_array store;   /* Store for the lexer's semantic values */
} marpa_rtc;

/*
 * Shorthands for fields.
 */

#define SPEC (p->spec)
#define IN   (p->in)
#define GATE (p->gate)
#define LEX  (p->lexer)
#define PAR  (p->parser)
#define CONF (&(p->config))
#define ACT  (p->action)
#define STOR (&(p->store))

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
