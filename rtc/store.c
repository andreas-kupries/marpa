/* Runtime for C-engine (RTC). Implementation. (Engine: Semantic store)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <store.h>
#include <rtc_int.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_store_init (marpatcl_rtc_p p)
{
    marpatcl_rtc_sva_init (&STOR.content, 10, 0); /* non-strict, expandable */
}

void
marpatcl_rtc_store_free (marpatcl_rtc_p p)
{
    marpatcl_rtc_sva_free (&STOR.content);
}

int
marpatcl_rtc_store_add (marpatcl_rtc_p p, marpatcl_rtc_sv_p sv)
{
    int id = marpatcl_rtc_sva_size (&STOR.content);
    marpatcl_rtc_sva_push (&STOR.content, sv);
    return id;
}

marpatcl_rtc_sv_p
marpatcl_rtc_store_get (marpatcl_rtc_p p, int at)
{
    return marpatcl_rtc_sva_get (&STOR.content, at);
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
