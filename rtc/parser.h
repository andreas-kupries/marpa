/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: Parser
 */

#ifndef MARPA_RTC_PARSER_H
#define MARPA_RTC_PARSER_H

#include <marpa.h>
#include <dynset.h>
#include <stack.h>
#include <rtc.h>

/*
 * -- dynamic state of the parser part of an rtc engine --
 */

typedef struct marpa_rtc_parser {
    Marpa_Grammar    g;             /* Underlying G1 grammar */
    Marpa_Recognizer recce;         /* The parser */
} marpa_rtc_parser;

/*
 * API seen by other parts.
 */

void marpa_rtc_parser_cons    (marpa_rtc_p p);
void marpa_rtc_parser_release (marpa_rtc_p p);
void marpa_rtc_parser_enter   (marpa_rtc_p p); // TODO: syms, values
void marpa_rtc_parser_eof     (marpa_rtc_p p);

/* TODO: fail, get-context, extend-context */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
