/* Runtime for C-engine (RTC). Declarations. (Progress reports)
 * - - -- --- ----- -------- ------------- --------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_PROGRESS_H
#define MARPATCL_RTC_PROGRESS_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>
#include <critcl_trace.h>

TRACE_TAG_OFF (lexer_progress);
TRACE_TAG_OFF (parser_progress);

#ifdef CRITCL_TRACER
#define LEX_P(p) { TRACE_TAG_DO (lexer_progress,  marpatcl_rtc_lexer_progress  (p)); }
#define PAR_P(p) { TRACE_TAG_DO (parser_progress, marpatcl_rtc_parser_progress (p)); }
#else
#define LEX_P(p) /* nothing */
#define PAR_P(p) /* nothing */
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessors and mutators
 */

extern void marpatcl_rtc_lexer_progress  (marpatcl_rtc_p p);
extern void marpatcl_rtc_parser_progress (marpatcl_rtc_p p);

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
