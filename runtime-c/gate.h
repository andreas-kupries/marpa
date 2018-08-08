/* Runtime for C-engine (RTC). Declarations. (Engine: Lexer gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 */

#ifndef MARPATCL_RTC_GATE_H
#define MARPATCL_RTC_GATE_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <byteset.h>
#include <stack.h>
#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_gate {
    int                  lastchar;   /* last character entered into the gate */
    int                  lastloc;    /* Location of the `lastchar` (byte offset) */
    int                  lastcloc;   /* Same, as character offset */
    int                  flushed;    /* Flushing state */
    marpatcl_rtc_byteset acceptable; /* Set of acceptable byte (symbols) */
} marpatcl_rtc_gate;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init       - initialize a gate
 * free       - release gate state
 * enter      - push a single byte of input
 * eof        - signal the end of the input
 * acceptable - information from lexer about acceptable bytes
 * redo       - reset to and replay the last n bytes entered
 */

void marpatcl_rtc_gate_init       (marpatcl_rtc_p p);
void marpatcl_rtc_gate_free       (marpatcl_rtc_p p);
void marpatcl_rtc_gate_enter      (marpatcl_rtc_p p, unsigned char ch); /* location implied */
void marpatcl_rtc_gate_eof        (marpatcl_rtc_p p);
void marpatcl_rtc_gate_acceptable (marpatcl_rtc_p p);
void marpatcl_rtc_gate_redo       (marpatcl_rtc_p p, int n);
/* TODO: get-context, extend-context */

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
