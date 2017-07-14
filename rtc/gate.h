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
    int               lastchar;   /* last character entered into the gate
				   */
    int               lastloc;    /* Location of the lastchar
				   */
    marpa_rtc_stack   history;    /* History of the current attempt to
				   * match a lexeme (or discard)
				   */
    marpa_rtc_stack   pending;    /* Scratch stack for partial history replay */
    marpa_rtc_byteset acceptable; /* Set of acceptable byte (symbols)
				   */
} marpa_rtc_gate;

/*
 * API seen by other parts.
 */

void marpa_rtc_gate_cons       (marpa_rtc_p p);
void marpa_rtc_gate_release    (marpa_rtc_p p);
void marpa_rtc_gate_enter      (marpa_rtc_p p, const char ch); /* IN.location implied */
void marpa_rtc_gate_eof        (marpa_rtc_p p);
void marpa_rtc_gate_acceptable (marpa_rtc_p p);
void marpa_rtc_gate_redo       (marpa_rtc_p p, int n);

/* TODO: get-context, extend-context */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
