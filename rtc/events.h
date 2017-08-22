/* Runtime for C-engine (RTC). Declarations. (Event handling)
 * - - -- --- ----- -------- ------------- ------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_EVENT_H
#define MARPATCL_RTC_EVENT_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 */

extern void marpatcl_rtc_lexer_events  (marpatcl_rtc_p p);
extern void marpatcl_rtc_parser_events (marpatcl_rtc_p p);

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
