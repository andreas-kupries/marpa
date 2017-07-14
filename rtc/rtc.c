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
marpa_rtc_cons (marpa_rtc_spec* g)
{
  marpa_rtc_p p = ALLOC (marpa_rtc);
  SP = g;
  (void) marpa_c_init (&CO);
  marpa_rtc_inbound_cons (p);
  marpa_rtc_gate_cons    (p);
  marpa_rtc_lexer_cons   (p);
  marpa_rtc_parser_cons  (p);
}

void
marpa_rtc_release (marpa_rtc_p p)
{
  marpa_rtc_parser_release  (p);
  marpa_rtc_lexer_release   (p);
  marpa_rtc_gate_release    (p);
  marpa_rtc_inbound_release (p);
  FREE (p);
}

void
marpa_rtc_enter (marpa_rtc_p p, const char* bytes)
{
  marpa_rtc_inbound_enter (p, bytes);
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
