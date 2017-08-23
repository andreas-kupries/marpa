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
#include <marpatcl_error.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_fail_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    FAIL.fail   = 0;
    FAIL.origin = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_fail_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    /* Nothing to do */
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_failit (marpatcl_rtc_p p, const char* origin)
{
    TRACE_FUNC ("((rtc*) %p, origin '%s')", p, origin ? origin : "<<null>>");

    // todo: lexer progress report, parser progress report
    
    FAIL.fail = 1;
    if (origin && !FAIL.origin) {
	FAIL.origin = origin;
    }

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_failed (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", FAIL.fail);
}

void
marpatcl_rtc_fail_syscheck (marpatcl_rtc_p p, Marpa_Grammar g, int res, const char* label)
{
    TRACE_FUNC ("((rtc*) %p, (Marpa_Grammar) %p, [[%s] = %d])", p, g, label, res);

    if (res == -2) {
	int status = marpa_g_error (g, NULL);

	TRACE_RUN (const char* e);
	TRACE_DO (e = marpatcl_error_decode_cstr (status));
	TRACE ("status = %d at %s (%s)", status, label, e ? e : "<<null>>");
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
