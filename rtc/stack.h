/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: integer stack (dynamic array)
 */

#ifndef MARPA_RTC_STACK_H
#define MARPA_RTC_STACK_H

/*
 * -- dynamic state of the stack part of an rtc engine --
 */

#define MARPA_RTC_BSMAX 256

typedef struct marpa_rtc_stack {
  int  n;
  int  max;
  int* data;
} marpa_rtc_stack;

/*
 * API seen by other parts.
 */

void marpa_rtc_stack_init  (marpa_rtc_stack* s);
void marpa_rtc_stack_clear (marpa_rtc_stack* s);
void marpa_rtc_stack_push  (marpa_rtc_stack* s, int v);
void marpa_rtc_stack_pop   (marpa_rtc_stack* s);
int  marpa_rtc_stack_size  (marpa_rtc_stack* s);
void marpa_rtc_stack_move  (marpa_rtc_stack* dst, marpa_rtc_stack* src, int n);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
