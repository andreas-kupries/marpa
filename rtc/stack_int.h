/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: integer stack (dynamic array)
 */

#ifndef MARPA_RTC_STACK_INT_H
#define MARPA_RTC_STACK_INT_H

#include <stack.h>

/*
 * Structure of stack objects.
 */

typedef struct marpa_rtc_stack {
    int  capacity; /* Number of elements allocated for `data` */
    int  size;     /* Number of elements used in `data` */
    int* data;     /* Content of the stack */

    /*
     * The `size` is also the `top-of-stack` information, it points to the
     * cell of data where the **next** element will get pushed.
     */
} marpa_rtc_stack;

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
