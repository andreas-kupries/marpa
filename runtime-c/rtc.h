/* Runtime for C-engine (RTC). Declarations. (Engine: All together)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
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
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <spec.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Opaque structure type, pointer/public.
 * Other types seen in the interface.
 */

typedef struct marpatcl_rtc* marpatcl_rtc_p;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Type of the callback invoked to return the results (semantic values).
 */

typedef void (*marpatcl_rtc_result) (void* clientdata, marpatcl_rtc_sv_p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 */

marpatcl_rtc_p    marpatcl_rtc_cons    (marpatcl_rtc_spec* g,
					marpatcl_rtc_sv_cmd a,
					marpatcl_rtc_result r,
					void* rcd);
void              marpatcl_rtc_destroy (marpatcl_rtc_p p);
void              marpatcl_rtc_enter   (marpatcl_rtc_p p, const char* bytes, int n);
void              marpatcl_rtc_eof     (marpatcl_rtc_p p);
marpatcl_rtc_sv_p marpatcl_rtc_get_sv  (marpatcl_rtc_p p);
/* marpatcl_rtc_failed - see fail.h */

// TODO: Callbacks (errors, events?)
#endif

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
