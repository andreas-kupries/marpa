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

#ifndef MARPATCL_RTC_H
#define MARPATCL_RTC_H

/*
 * Opaque structure type, pointer/public.
 * Other types seen in the interface.
 */

typedef struct marpa_rtc* marpatcl_rtc_p;

#include <spec.h>

/*
 * API functions
 */

marpatcl_rtc_p          marpatcl_rtc_cons    (marpatcl_rtc_spec* g, marpatcl_rtc_sv_cmd a);
void                 marpatcl_rtc_release (marpatcl_rtc_p p);
void                 marpatcl_rtc_enter   (marpatcl_rtc_p p, const char* bytes, int n);
void                 marpatcl_rtc_eof     (marpatcl_rtc_p p);
marpatcl_rtc_semvalue_p marpatcl_rtc_sv      (marpatcl_rtc_p p);

// TODO: Callbacks (errors, events?)
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
