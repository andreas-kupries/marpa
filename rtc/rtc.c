/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Main RTC engine
 */

#include <rtc.h>
#include <rtc_int.h>
#include <critcl_alloc.h>

/*
 */

marpa_rtc_p
marpa_rtc_cons (marpa_rtc_spec* g, marpa_rtc_sv_cmd a)
{
    marpa_rtc_p p = ALLOC (marpa_rtc);
    SPEC = g;
    (void) marpa_c_init (CONF);
    marpa_rtc_inbound_init (p);
    marpa_rtc_gate_init    (p);
    marpa_rtc_lexer_init   (p);
    marpa_rtc_parser_init  (p);
    marpa_rtc_sva_init     (STOR, 10, 0); /* non-strict, expandable */
    ACT = a;
}

void
marpa_rtc_release (marpa_rtc_p p)
{
    marpa_rtc_parser_free  (p);
    marpa_rtc_lexer_free   (p);
    marpa_rtc_gate_free    (p);
    marpa_rtc_inbound_free (p);
    marpa_rtc_sva_free     (STOR);
    FREE (p);
}

void
marpa_rtc_enter (marpa_rtc_p p, const char* bytes, int n)
{
    marpa_rtc_inbound_enter (p, bytes, n);
}

void
marpa_rtc_eof (marpa_rtc_p p)
{
    marpa_rtc_inbound_eof (p);
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
