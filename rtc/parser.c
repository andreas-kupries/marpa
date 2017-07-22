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
marpatcl_rtc_parser_init (marpatcl_rtc_p p)
{
    PAR.g = marpa_g_new (CONF);
    marpatcl_rtc_spec_setup (PAR.g, SPEC->g1);
    PAR.recce = marpa_r_new (PAR.g);
}

void
marpatcl_rtc_parser_free (marpatcl_rtc_p p)
{
    marpa_g_unref (PAR.g);
    marpa_r_unref (PAR.recce);
}

void
marpatcl_rtc_parser_enter (marpatcl_rtc_p p) // TODO: enter - syms, values
{
}

void
marpatcl_rtc_parser_eof (marpatcl_rtc_p p)
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
