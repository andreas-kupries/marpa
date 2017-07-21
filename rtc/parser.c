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

/*
 */

void
marpa_rtc_parser_init (marpa_rtc_p p)
{
    PAR.g = marpa_g_new (CONF);
    marpa_rtc_spec_setup (PAR.g, SPEC->g1);
    PAR.recce = marpa_r_new (PAR.g);
}

void
marpa_rtc_parser_free (marpa_rtc_p p)
{
    marpa_g_unref (PAR.g);
    marpa_r_unref (PAR.recce);
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
