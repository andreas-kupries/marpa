/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: Gate
 */

#ifndef MARPA_RTC_GATE_H
#define MARPA_RTC_GATE_H

#include <byteset.h>
#include <stack.h>
#include <rtc.h>

/*
 * -- dynamic state of the gate part of an rtc engine --
 */

typedef struct marpa_rtc_gate {
    int               lastchar;   /* last character entered into the gate */
    int               lastloc;    /* Location of the lastchar */
    marpa_rtc_stack_p history;    /* History of the current match attempt */
    marpa_rtc_stack_p pending;    /* Scratch stack for history replay */
    marpa_rtc_byteset acceptable; /* Set of acceptable byte (symbols) */
} marpa_rtc_gate;

/*
 * API -- lifecycle
 */

void marpa_rtc_gate_init (marpa_rtc_p p);
void marpa_rtc_gate_free (marpa_rtc_p p);

/*
 * API -- accessors and mutators
 */

void marpa_rtc_gate_enter      (marpa_rtc_p p, const char ch); /* location implied */
void marpa_rtc_gate_eof        (marpa_rtc_p p);
void marpa_rtc_gate_acceptable (marpa_rtc_p p);
void marpa_rtc_gate_redo       (marpa_rtc_p p, int n);

/* init       - initialize a gate
 * free       - release gate state
 * enter      - push a single byte of input
 * eof        - signal the end of the input
 * acceptable - information from lexer about acceptable bytes
 * redo       - reset to and replay the last n bytes entered
 */

/* TODO: get-context, extend-context */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
