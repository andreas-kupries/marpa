/* Runtime for C-engine (RTC). Declarations. (Stacks of bytes)
 *                             Internal
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_BYTESTACK_INT_H
#define MARPATCL_RTC_BYTESTACK_INT_H
/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <bytestack.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 */

typedef struct marpatcl_rtc_bytestack {
    int            capacity; /* Number of elements allocated for `data` */
    int            size;     /* Number of elements used in `data` */
    unsigned char* data;     /* Content of the bytestack */
    /*
     * The `size` field also provides the `top-of-bytestack` information, as it
     * points to the cell of `data` where the **next** element will get
     * pushed.
     */
} marpatcl_rtc_bytestack;

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
