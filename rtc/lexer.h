/* Runtime for C-engine (RTC). Declarations. (Engine: Lexeing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_LEXER_H
#define MARPATCL_RTC_LEXER_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <dynset.h>
#include <stack_int.h>
#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_lexer {
    Marpa_Grammar        g;             /* Underlying L0 grammar */
    Marpa_Recognizer     recce;         /* Current recognizer */
    marpatcl_rtc_dynset  acceptable;    /* Currently acceptable parser symbols */
    marpatcl_rtc_stack_p lexeme;        /* Characters in the current match */
    int                  start;         /* Location of match start */
} marpatcl_rtc_lexer;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 *
 * init       - initialize a lexer
 * free       - release lexer state
 * enter      - push a single byte of input
 * eof        - signal the end of the input
 * acceptable - information from parser about acceptable lexemes
 */

void marpatcl_rtc_lexer_init       (marpatcl_rtc_p p);
void marpatcl_rtc_lexer_free       (marpatcl_rtc_p p);
void marpatcl_rtc_lexer_enter      (marpatcl_rtc_p p, int ch); /* IN.location implied */
void marpatcl_rtc_lexer_eof        (marpatcl_rtc_p p);
void marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p);
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
