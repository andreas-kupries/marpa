/* Runtime for C-engine (RTC). Implementation. (Event handling)
 * - - -- --- ----- -------- ------------- --------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations, and tracing via an external environment header.
 */

#include <environment.h>
#include <marpa.h>
#include <events.h>
#include <rtc_int.h>
#include <marpatcl_event.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_lexer_events (marpatcl_rtc_p p)
{
    Marpa_Event_Type etype;
    Marpa_Event      event;

    TRACE_FUNC ("((rtc*) %p)", p);

    int v, i, n = marpa_g_event_count (LEX.g);

    for (i = 0; i < n; i++) {
	TRACE_RUN (const char* ets = 0);

	etype = marpa_g_event (LEX.g, &event, i);
	ASSERT (etype >= 0, "Bad event type");
	v = marpa_g_event_value (&event);

	TRACE_DO (ets = marpatcl_event_decode_cstr (etype));
	TRACE ("E [%2d/%2d] %s = %d", i, n, ets ? ets : "???", v);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_parser_events (marpatcl_rtc_p p)
{
    Marpa_Event_Type etype;
    Marpa_Event      event;

    TRACE_FUNC ("((rtc*) %p)", p);

    int v, i, n = marpa_g_event_count (PAR.g);

    for (i = 0; i < n; i++) {
	TRACE_RUN (const char* ets = 0);

	etype = marpa_g_event (PAR.g, &event, i);
	ASSERT (etype >= 0, "Bad event type");
	v = marpa_g_event_value (&event);

	TRACE_DO (ets = marpatcl_event_decode_cstr (etype));
	TRACE ("E [%2d/%2d] %s = %d", i, n, ets ? ets : "???", v);
    }

    TRACE_RETURN_VOID;
}

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
