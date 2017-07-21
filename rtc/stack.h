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
 * Opaque stack definition
 */

typedef struct marpa_rtc_stack* marpa_rtc_stack_p;

/*
 * Indicator to use the internal default for the initial capacity.
 */

#define MARPA_RTC_STACK_DEFAULT_CAP (-1)

/*
 * API -- lifecycle
 */

marpa_rtc_stack_p marpa_rtc_stack_cons    (int initial_capacity);
void              marpa_rtc_stack_destroy (marpa_rtc_stack_p s);

/*
 * API -- accessor and mutators
 */

int  marpa_rtc_stack_size    (marpa_rtc_stack_p s);
void marpa_rtc_stack_push    (marpa_rtc_stack_p s, int v);
int  marpa_rtc_stack_pop     (marpa_rtc_stack_p s);
void marpa_rtc_stack_clear   (marpa_rtc_stack_p s);
void marpa_rtc_stack_move    (marpa_rtc_stack_p dst, marpa_rtc_stack_p src, int n);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
