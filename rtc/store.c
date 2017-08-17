/* Runtime for C-engine (RTC). Implementation. (Engine: Semantic store)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <store.h>
#include <rtc_int.h>
#include <critcl_trace.h>

TRACE_OFF

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_store_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("(rtc %p)", p);
    marpatcl_rtc_sva_init (&STOR.content, 10, 0); /* non-strict, expandable */
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_store_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("(rtc %p)", p);
    marpatcl_rtc_sva_free (&STOR.content);
    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_store_add (marpatcl_rtc_p p, marpatcl_rtc_sv_p sv)
{
    int id;
    TRACE_FUNC ("(rtc %p sv %p)", p, sv);
    id = marpatcl_rtc_sva_size (&STOR.content);
    marpatcl_rtc_sva_push (&STOR.content, sv);
    TRACE_RETURN ("%d", id);
}

marpatcl_rtc_sv_p
marpatcl_rtc_store_get (marpatcl_rtc_p p, int at)
{
    TRACE_FUNC ("(rtc %p at %d)", p, at);
    TRACE_RETURN ("%p", marpatcl_rtc_sva_get (&STOR.content, at));
}

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
