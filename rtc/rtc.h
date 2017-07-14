/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Main header, Public
 *
 * Notes:
 * - This engine is byte-based, not character-based. It is the responsibility
 *   of the generator to deconstruct UTF-8 character (strings) into byte
 *   sequences, and character classes into ASBR.
 *
 * - This engine does not support byte-ranges (at the moment).  It is again
 *   the responsibility of the generator to deconstruct ranges into
 *   alternations of bytes.
 *
 * Header for the public types
 */

#ifndef MARPA_RTC_H
#define MARPA_RTC_H

/*
 * Opaque structure type, pointer/public.
 * Other types seen in the interface.
 */

typedef struct marpa_rtc* marpa_rtc_p;

#include <spec.h>

/*
 * API functions
 */

marpa_rtc_p marpa_rtc_cons    (marpa_rtc_spec* g);
void        marpa_rtc_release (marpa_rtc_p p);
void        marpa_rtc_enter   (marpa_rtc_p p, const char* bytes);
void        marpa_rtc_eof     (marpa_rtc_p p);

// TODO: API for semantic actions.
// TODO: Callbacks (errors, events?)

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
