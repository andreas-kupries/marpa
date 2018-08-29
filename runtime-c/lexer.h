/* Runtime for C-engine (RTC). Declarations. (Engine: Lexing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 */

#ifndef MARPATCL_RTC_LEXER_H
#define MARPATCL_RTC_LEXER_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <symset.h>
#include <stack_int.h>
#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_lexer {
    int                  single_sv;     /* Bool, true if SV is identical across symbols */
    Marpa_Grammar        g;             /* Underlying L0 grammar */
    Marpa_Recognizer     recce;         /* Current recognizer */
    marpatcl_rtc_symset  acceptable;    /* Currently acceptable parser symbols */

    /*
     * Information about the current match
     */

    int                  cstart;        /* Start location (char offset) */
    int                  start;         /* Start location (byte offset) */
    int                  clength;       /* Length (in characters), or -1 (undef) */
    int                  length;        /* Length (in byte) */

    marpatcl_rtc_stack_p lexeme;        /* Collected characters (byte vector) */
    char*                lexemestr;     /* Lexeme string, or NULL */
    // FUTURE: capacity ? reduce memory churn (know length, s.a)

    marpatcl_rtc_symset  found;         /* Found terminal  symbols  */
    marpatcl_rtc_symset  discards;      /* Found discarded symbols  */
    marpatcl_rtc_symset  events;        /* Found lexer parse events */
    int                  m_event;       /* Active parse event, or -1 */

    marpatcl_rtc_stack_p m_sv;          /* Id's of the collected semantic values */
    int                  m_clearfirst;  /* Flag to trigger clearing of sv/found */
} marpatcl_rtc_lexer;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 *
 * init       - initialize a lexer
 * free       - release lexer state
 * enter      - push a single byte of input
 * flush      - signal end of lexeme (next byte to enter is invalid)
 * eof        - signal the end of the input
 * acceptable - information from parser about acceptable lexemes
 */

void  marpatcl_rtc_lexer_init       (marpatcl_rtc_p p);
void  marpatcl_rtc_lexer_free       (marpatcl_rtc_p p);
void  marpatcl_rtc_lexer_enter      (marpatcl_rtc_p p, int ch); /* IN.location implied */
void  marpatcl_rtc_lexer_flush      (marpatcl_rtc_p p);         /* IN.location implied */
void  marpatcl_rtc_lexer_eof        (marpatcl_rtc_p p);
void  marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p, int keep);
void  marpatcl_rtc_lexer_reset      (marpatcl_rtc_p p);


/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - match state accessors and mutators
 */

int         marpatcl_rtc_lexer_pe_get_lexeme_start  (marpatcl_rtc_p p);
int         marpatcl_rtc_lexer_pe_get_lexeme_length (marpatcl_rtc_p p);
const char* marpatcl_rtc_lexer_pe_get_lexeme_value  (marpatcl_rtc_p p);

marpatcl_rtc_symset* marpatcl_rtc_lexer_pe_get_symbols   (marpatcl_rtc_p p);
marpatcl_rtc_stack_p marpatcl_rtc_lexer_pe_get_semvalues (marpatcl_rtc_p p);

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
