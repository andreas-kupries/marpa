/* Runtime for C-engine (RTC). Declarations. (Stacks of ints)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_STACK_H
#define MARPATCL_RTC_STACK_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 * - Opaque stack definition
 * - Indicator to use the internal default for the initial capacity.
 */

#define MARPATCL_RTC_STACK_DEFAULT_CAP (-1)

typedef struct marpatcl_rtc_stack* marpatcl_rtc_stack_p;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * cons     - construct set with maximal capacity
 * release  - free the set and its contents
 */

marpatcl_rtc_stack_p marpatcl_rtc_stack_cons    (int initial_capacity);
void                 marpatcl_rtc_stack_destroy (marpatcl_rtc_stack_p s);
int                  marpatcl_rtc_stack_size    (marpatcl_rtc_stack_p s);
void                 marpatcl_rtc_stack_push    (marpatcl_rtc_stack_p s, int v);
int                  marpatcl_rtc_stack_pop     (marpatcl_rtc_stack_p s);
void                 marpatcl_rtc_stack_clear   (marpatcl_rtc_stack_p s);
void                 marpatcl_rtc_stack_move    (marpatcl_rtc_stack_p dst,
						 marpatcl_rtc_stack_p src, int n);

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
