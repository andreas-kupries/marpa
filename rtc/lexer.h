/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: Lexer
 */

#ifndef MARPA_RTC_LEXER_H
#define MARPA_RTC_LEXER_H

#include <marpa.h>
#include <dynset.h>
#include <stack_int.h>
#include <rtc.h>

/*
 * -- dynamic state of the lexer part of an rtc engine --
 */

typedef struct marpa_rtc_lexer {
    Marpa_Grammar     g;             /* Underlying L0 grammar */
    Marpa_Recognizer  recce;         /* Current recognizer */
    marpa_rtc_dynset  acceptable;    /* Currently acceptable parser symbols */
    marpa_rtc_stack_p lexeme;        /* Characters in the current match */
    int               start;         /* Location of match start */
} marpa_rtc_lexer;

/*
 * API -- lifecycle
 */

void marpa_rtc_lexer_init (marpa_rtc_p p);
void marpa_rtc_lexer_free (marpa_rtc_p p);

/*
 * API -- accessors and mutators
 */

void marpa_rtc_lexer_enter      (marpa_rtc_p p, int ch); /* IN.location implied */
void marpa_rtc_lexer_eof        (marpa_rtc_p p);
void marpa_rtc_lexer_acceptable (marpa_rtc_p p);

/* init       - initialize a lexer
 * free       - release lexer state
 * enter      - push a single byte of input
 * eof        - signal the end of the input
 * acceptable - information from parser about acceptable lexemes
 */

/* TODO: fail, get-context, extend-context */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
