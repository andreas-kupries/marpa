/* Runtime for C-engine (RTC). Implementation. (Engine: Semantic store)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 *
 * Requirements - Note, tracing via an external environment header.
 */

#include <environment.h>
#include <store.h>
#include <rtc_int.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_store_init (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_sva_init (&STOR.content, 10, 0); /* non-strict, expandable */

    // Push a dummy value to ensure that all true SVs get ids starting from 1.
    marpatcl_rtc_sva_push (&STOR.content, NULL);
    
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_store_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_sva_free (&STOR.content);

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_store_add (marpatcl_rtc_p p, marpatcl_rtc_sv_p sv)
{
    int id;
    TRACE_FUNC ("((rtc*) %p, sv %p)", p, sv);

    id = marpatcl_rtc_sva_size (&STOR.content);
    marpatcl_rtc_sva_push (&STOR.content, sv);

    ASSERT (id > 0, "store id failure, zero or less not allowed");
    TRACE_RETURN ("%d", id);
}

marpatcl_rtc_sv_p
marpatcl_rtc_store_get (marpatcl_rtc_p p, int at)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((rtc*) %p, at %d)", p, at);

    x = marpatcl_rtc_sva_get (&STOR.content, at);

    TRACE_RETURN ("(sv*) %p", x);
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
