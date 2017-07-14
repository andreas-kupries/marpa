/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Parser
 */

#include <parser.h>
#include <rtc_int.h>

void
marpa_rtc_parser_cons (marpa_rtc_p p)
{
    PA.g = marpa_g_new (&CO);
    marpa_rtc_spec_setup (PA.g, SP->g1);
    PA.recce = marpa_r_new (PA.g);
}

void
marpa_rtc_parser_release (marpa_rtc_p p)
{
    marpa_g_unref (PA.g);
    marpa_r_unref (PA.recce);
}

void
marpa_rtc_parser_enter (marpa_rtc_p p) // TODO: enter - syms, values
{
}

void
marpa_rtc_parser_eof (marpa_rtc_p p)
{
    // TODO parser eof
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
