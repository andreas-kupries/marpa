/* Runtime for C-engine (RTC). Declarations. (Engine: All together)
 *                             Internal
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_INT_H
#define MARPATCL_RTC_INT_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <spec.h>
#include <inbound.h>
#include <gate.h>
#include <lexer.h>
#include <parser.h>
#include <store.h>
#include <fail.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc {
    Marpa_Config          config;  /* Config info shared to lexer and parser */
    marpatcl_rtc_spec*    spec;    /* Static grammar definitions */
    marpatcl_rtc_inbound  in;      /* Main dispatch */
    marpatcl_rtc_gate     gate;    /* Gating to lexer */
    marpatcl_rtc_lexer    lexer;   /* Lexing, gating to parser */
    marpatcl_rtc_parser   parser;  /* Parsing state */
    marpatcl_rtc_store    store;   /* Store for the lexer's semantic values */
    marpatcl_rtc_sv_cmd   action;  /* Dispatcher for G1 user actions */
    marpatcl_rtc_fail     fail;    /* Failure state */
} marpatcl_rtc;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands for fields.
 */

#define SPEC (p->spec)
#define IN   (p->in)
#define GATE (p->gate)
#define LEX  (p->lexer)
#define PAR  (p->parser)
#define CONF (&(p->config))
#define ACT  (p->action)
#define STOR (p->store)
#define FAIL (p->fail)

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
