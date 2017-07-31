/* Runtime for C-engine (RTC). Implementation. (Engine: Failures)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <fail.h>
#include <rtc_int.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_fail_init (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_fail_init");
    TRACE (("rtc %p", p));

    FAIL.fail   = 0;
    FAIL.origin = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_fail_free (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_fail_free");
    TRACE (("rtc %p", p));
    /* Nothing to do */
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_failit (marpatcl_rtc_p p, const char* origin)
{
    TRACE_ENTER ("marpatcl_rtc_failit");
    TRACE (("rtc %p origin %s", p, origin ? origin : "<<null>>"));
    FAIL.fail = 1;
    if (origin && !FAIL.origin) {
	FAIL.origin = origin;
    }
    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_failed (marpatcl_rtc_p p)
{
    TRACE_ENTER ("marpatcl_rtc_failed");
    TRACE (("rtc %p", p));
    TRACE_RETURN ("%d", FAIL.fail);
}

void
marpatcl_rtc_fail_syscheck (marpatcl_rtc_p p, Marpa_Grammar g, int res, const char* label)
{
    TRACE_ENTER ("marpatcl_rtc_fail_syscheck");
    TRACE (("state = %d", res));
    if (res == -2) {
	int status = marpa_g_error (g, NULL);
	TRACE (("status = %d at %s", status, label));
	marpatcl_rtc_failit (p, "libmarpa");
	ASSERT (0, "syscheck general");
    }
    if (res == -1) {
	marpatcl_rtc_failit (p, "libmarpa: symbol not found");
	ASSERT (0, "syscheck missing symbol");
    }
    
    TRACE_RETURN_VOID;
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
