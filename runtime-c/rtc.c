/* Runtime for C-engine (RTC). Implementation. (Engine: All together)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <rtc.h>
#include <rtc_int.h>
#include <marpatcl_rtc_eventtype.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_p
marpatcl_rtc_cons (marpatcl_rtc_spec*      g,
		   marpatcl_rtc_sv_cmd     a,
		   marpatcl_rtc_result_cmd r,
		   void*                   rcdata,
		   marpatcl_rtc_event_cmd  e,
		   void*                   ecdata)
{
    marpatcl_rtc_p p;
    TRACE_FUNC ("((spec*) %p, (cmd) %p)", g, a);

    p = ALLOC (marpatcl_rtc);
    SPEC = g;
    ACT  = a;
    p->result = r;  p->rcdata = rcdata;
    p->event  = e;  p->ecdata = ecdata;
    (void) marpa_c_init (CONF);
    marpatcl_rtc_fail_init    (p);
    marpatcl_rtc_store_init   (p);
    marpatcl_rtc_inbound_init (p);
    marpatcl_rtc_clindex_init (p);
    marpatcl_rtc_gate_init    (p);
    marpatcl_rtc_lexer_init   (p);

    // Without G1 we go into lexing-only mode.
    if (SPEC->g1)
	marpatcl_rtc_parser_init (p);
    else
	marpatcl_rtc_lexer_acceptable (p, 0);

    p->done = 0;
    TRACE_RETURN ("(rtc*) %p", p);
}

void
marpatcl_rtc_destroy (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    // Without G1 we are in lexing-only mode.
    if (SPEC->g1) marpatcl_rtc_parser_free  (p);

    marpatcl_rtc_lexer_free   (p);
    marpatcl_rtc_gate_free    (p);
    marpatcl_rtc_inbound_free (p);
    marpatcl_rtc_clindex_free (p);
    marpatcl_rtc_store_free   (p);
    marpatcl_rtc_fail_free    (p);
    FREE (p);

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_num_streams (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("(#streams) %d", marpatcl_rtc_inbound_num_streams (p));
}

int
marpatcl_rtc_num_processed (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("(#processed) %d", marpatcl_rtc_inbound_num_processed (p));
}

int
marpatcl_rtc_size_input (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("(#input) %d", marpatcl_rtc_inbound_size (p));
}

void
marpatcl_rtc_enter (marpatcl_rtc_p p, const unsigned char* bytes, int n, int from, int to)
{
    TRACE_FUNC ("((rtc*) %p, (char*) %p [%d], [%d...%d]))", p, bytes, n, from, to);

    if (p->done) {
	marpatcl_rtc_reset (p);
    }

    marpatcl_rtc_inbound_enter (p, bytes, n, from, to);
    p->done = 1;

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_enter_more (marpatcl_rtc_p p, const unsigned char* bytes, int n)
{
    TRACE_FUNC ("((rtc*) %p, (char*) %p [%d]))", p, bytes, n);

    int offset = marpatcl_rtc_inbound_enter_more (p, bytes, n);

    TRACE_RETURN ("(offset) %d", offset + 1);
}

marpatcl_rtc_sv_p
marpatcl_rtc_get_sv (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    // TODO retrieve SV for the whole parse

    TRACE_RETURN ("(sv*) %p", 0 /*TODO*/);
}


void
marpatcl_rtc_reset (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_fail_reset    (p);
    marpatcl_rtc_store_reset   (p);
    marpatcl_rtc_inbound_reset (p);
    marpatcl_rtc_clindex_reset (p);
    marpatcl_rtc_gate_reset    (p);

    marpatcl_rtc_parser_reset  (p);
    // marpatcl_rtc_lexer_reset   (p);
    p->done = 0;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_gather_events (marpatcl_rtc_rules*    decls,   // Search this database ...
			    marpatcl_rtc_eventtype type,    // ... for this type of events ...
			    marpatcl_rtc_symset*   symbols, // ... associated with these symbols ...
			    marpatcl_rtc_symset*   result)  // ... and record the found here.
{
    marpatcl_rtc_event*   event   = decls->event;
    marpatcl_rtc_trigger* trigger = decls->trigger;

    TRACE_RUN (const char* et = 0);
    TRACE_FUNC ("(trigger*) %p [%d], (event*) %p [%d]", trigger, trigger->size, event, event->size);
    TRACE_DO  (et = marpatcl_rtc_eventtype_decode_cstr (type));
    TRACE ("(int)     type %d = '%s'", type, et ? et : "<<unknown>>");
    TRACE_HEADER (1);

    TRACE_ADD ("(symset*) symbols %p [%d] =", symbols, marpatcl_rtc_symset_size (symbols));
    int j; for (j=0; j < symbols->n; j++) {
	TRACE_ADD (" (%d %s)", symbols->dense [j], marpatcl_rtc_spec_symname (decls, symbols->dense[j], 0));
    }
    TRACE_CLOSER;

    TRACE ("(symset*) result  %p", result);

    marpatcl_rtc_sym k;
    marpatcl_rtc_symset_clear (result);

    for (k=0; k < trigger->size; k++) {
	TRACE_HEADER (1);
	TRACE_ADD ("[%d] = (%s %s (%d %s))",
		   k,
		   event->data [trigger->data[k].id] ? "on " : "off",
		   marpatcl_rtc_eventtype_decode_cstr (trigger->data[k].type),
		   trigger->data[k].sym, marpatcl_rtc_spec_symname (decls, trigger->data[k].sym, 0));

	// Skip disabled events
	int eid = trigger->data[k].id;
	if (!event->data [eid]) {
	    TRACE_ADD (" - not active, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}
	// Skip events without the requested type
	if (trigger->data[k].type != type) {
	    TRACE_ADD (" - type mismatch, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}

	// Skip events without the requested symbols
	if (!marpatcl_rtc_symset_contains (symbols, trigger->data[k].sym)) {
	    TRACE_ADD (" - symbol mismatch, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}

	// Extend result with active event for requested and symbol
	TRACE_ADD (" - taking event %d", eid);
	marpatcl_rtc_symset_add (result, eid);
	TRACE_CLOSER;
    }

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_raise_event (marpatcl_rtc_p p, int event_type)
{
    TRACE_FUNC ("((rtc*) %p, ev %d, #%d --> (%p, cd %p))",
		p, event_type, EVENTS->n, p->event, p->ecdata);

    if (!p->event) {
	TRACE_RETURN ("(ignored) %d", -1);
    }

    LEX.m_event = event_type;
    LEX.m_clearfirst = 1;

    int evok = p->event (p->ecdata, event_type, EVENTS->n, EVENTS->dense);

    LEX.m_event = marpatcl_rtc_eventtype_LAST;

    if (!evok) { marpatcl_rtc_fail_event (p); }

    TRACE_RETURN ("(ok) %d", evok);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
