/* Runtime for C-engine (RTC). Declarations. (Engine: Parsing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_PARSER_H
#define MARPATCL_RTC_PARSER_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_parser {
    Marpa_Grammar    g;             /* Underlying G1 grammar */
    Marpa_Recognizer recce;         /* The parser */
} marpatcl_rtc_parser;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init  - initialize a lexer
 * free  - release lexer state
 * enter - push a lexeme
 * eof   - signal the end of the input
 */

void marpatcl_rtc_parser_init  (marpatcl_rtc_p p);
void marpatcl_rtc_parser_free  (marpatcl_rtc_p p);
void marpatcl_rtc_parser_enter (marpatcl_rtc_p p); // TODO: syms, values
void marpatcl_rtc_parser_eof   (marpatcl_rtc_p p);
/* TODO: fail, get-context, extend-context */

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
