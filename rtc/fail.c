/* Runtime for C-engine (RTC). Implementation. (Engine: Failures)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <fail.h>
#include <rtc_int.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_fail_init (marpatcl_rtc_p p)
{
    FAIL.fail   = 0;
    FAIL.origin = 0;
}

void
marpatcl_rtc_fail_free (marpatcl_rtc_p p)
{
    /* Nothing to do */
}

void
marpatcl_rtc_failit (marpatcl_rtc_p p, const char* origin)
{
    FAIL.fail = 1;
    if (!origin || FAIL.origin) return;
    FAIL.origin = origin;
    return;
}

int
marpatcl_rtc_failed (marpatcl_rtc_p p)
{
    return FAIL.fail;
}

// TODO: Collect failure information into a structure ...

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
