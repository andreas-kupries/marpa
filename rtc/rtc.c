/* Runtime for C-engine (RTC). Implementation. (Engine: All together)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <rtc.h>
#include <rtc_int.h>
#include <critcl_alloc.h>
#include <critcl_trace.h>

TRACE_OFF

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_p
marpatcl_rtc_cons (marpatcl_rtc_spec* g, marpatcl_rtc_sv_cmd a)
{
    marpatcl_rtc_p p;
    TRACE_FUNC ("(spec %p, cmd %p)", g, a);
    
    p = ALLOC (marpatcl_rtc);
    SPEC = g;
    ACT = a;
    (void) marpa_c_init (CONF);
    marpatcl_rtc_fail_init    (p);
    marpatcl_rtc_store_init   (p);
    marpatcl_rtc_inbound_init (p);
    marpatcl_rtc_gate_init    (p);
    marpatcl_rtc_lexer_init   (p);
    marpatcl_rtc_parser_init  (p);

    TRACE_RETURN ("%p", p);
}

void
marpatcl_rtc_destroy (marpatcl_rtc_p p)
{
    TRACE_FUNC ("(rtc %p)", p);
    marpatcl_rtc_parser_free  (p);
    marpatcl_rtc_lexer_free   (p);
    marpatcl_rtc_gate_free    (p);
    marpatcl_rtc_inbound_free (p);
    marpatcl_rtc_store_free   (p);
    marpatcl_rtc_fail_free    (p);
    FREE (p);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_enter (marpatcl_rtc_p p, const char* bytes, int n)
{
    TRACE_FUNC ("(rtc %p bytes %p, n%d)", p, bytes, n);
    marpatcl_rtc_inbound_enter (p, bytes, n);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("(rtc %p)", p);
    marpatcl_rtc_inbound_eof (p);
    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_get_sv (marpatcl_rtc_p p)
{
    // TODO retrieve SV for the whole parse
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
