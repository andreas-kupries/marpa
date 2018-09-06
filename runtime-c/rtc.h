/* Runtime for C-engine (RTC). Declarations. (Engine: All together)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
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
#include <symset.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Opaque structure type, pointer/public.
 * Other types seen in the interface.
 */

typedef struct marpatcl_rtc* marpatcl_rtc_p;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 */

marpatcl_rtc_p    marpatcl_rtc_cons    (marpatcl_rtc_spec*      g,
					marpatcl_rtc_sv_cmd     a,
					marpatcl_rtc_result_cmd r,
					void*                   rcdata,
                                        marpatcl_rtc_event_cmd  e,
					void*                   ecdata);
void              marpatcl_rtc_destroy (marpatcl_rtc_p p);

void              marpatcl_rtc_enter   (marpatcl_rtc_p       p,
					const unsigned char* bytes,
					int                  n,
					int                  from,
					int                  to);

int               marpatcl_rtc_enter_more (marpatcl_rtc_p       p,
					   const unsigned char* bytes,
					   int                  n);

marpatcl_rtc_sv_p marpatcl_rtc_get_sv  (marpatcl_rtc_p p);
/* marpatcl_rtc_failed - see fail.h */

void              marpatcl_rtc_reset (marpatcl_rtc_p p);

void marpatcl_rtc_gather_events (marpatcl_rtc_rules*    decls,   // Search this database ...
				 marpatcl_rtc_eventtype type,    // ... for this type of events ...
				 marpatcl_rtc_symset*   symbols, // ... associated with these symbols ...
				 marpatcl_rtc_symset*   result); // ... and record the found here.

int marpatcl_rtc_raise_event (marpatcl_rtc_p p, int event_type);
//  1 - ok
//  0 - failed
// -1 - ignored, no callback available.

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
