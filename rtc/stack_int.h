/* Runtime for C-engine (RTC). Declarations. (Stacks of ints)
 *                             Internal
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_STACK_INT_H
#define MARPATCL_RTC_STACK_INT_H
/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <stack.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 */

typedef struct marpatcl_rtc_stack {
    int  capacity; /* Number of elements allocated for `data` */
    int  size;     /* Number of elements used in `data` */
    int* data;     /* Content of the stack */
    /*
     * The `size` field also provides the `top-of-stack` information, as it
     * points to the cell of `data` where the **next** element will get
     * pushed.
     */
} marpatcl_rtc_stack;

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
