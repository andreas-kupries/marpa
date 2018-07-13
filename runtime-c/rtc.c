/* Runtime for C-engine (RTC). Implementation. (Engine: All together)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
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
    marpatcl_rtc_gate_init    (p);
    marpatcl_rtc_lexer_init   (p);

    // Without G1 we go into lexing-only mode.
    if (SPEC->g1)
	marpatcl_rtc_parser_init (p);
    else
	marpatcl_rtc_lexer_acceptable (p, 0);

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
    marpatcl_rtc_store_free   (p);
    marpatcl_rtc_fail_free    (p);
    FREE (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_enter (marpatcl_rtc_p p, const unsigned char* bytes, int n)
{
    TRACE_FUNC ("((rtc*) %p, (char*) %p [%d]))", p, bytes, n);

    marpatcl_rtc_inbound_enter (p, bytes, n);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_inbound_eof (p);

    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_get_sv (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    // TODO retrieve SV for the whole parse

    TRACE_RETURN ("(sv*) %p", 0 /*TODO*/);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_gather_events (marpatcl_rtc_p         p,       // TRACE-only data
			    marpatcl_rtc_events*   decls,   // Search this database ...
			    marpatcl_rtc_eventtype type,    // ... for this type of events ...
			    marpatcl_rtc_symset*   symbols, // ... associated with these symbols ...
			    marpatcl_rtc_symset*   result)  // ... and record the found here.
{
    TRACE_RUN (const char* et = 0);
    TRACE_FUNC ("(events*) decls %p [%d]", decls, decls->size);
    TRACE_DO  (et = marpatcl_rtc_eventtype_decode_cstr (type));
    TRACE ("(int)     type %d = '%s'", type, et ? et : "<<unknown>>");
    TRACE_HEADER (1);
    TRACE_ADD ("(symset*) symbols %p [%d] =", symbols, marpatcl_rtc_symset_size (symbols));
    int j; for (j=0; j < symbols->n; j++) {
	TRACE_ADD (" (%d %s)", symbols->dense [j], marpatcl_rtc_spec_symname (SPEC->l0, symbols->dense[j], 0));
    }
    TRACE_CLOSER;

    TRACE ("(symset*) result  %p", result);

    marpatcl_rtc_sym k;
    marpatcl_rtc_symset_clear (result);
				     
    for (k=0; k < decls->size; k++) {
	TRACE_HEADER (1);
	TRACE_ADD ("[%d] = (%s %s (%d %s))",
		   k, 
		   decls->data[k].active ? "on " : "off",
		   marpatcl_rtc_eventtype_decode_cstr (decls->data[k].type),
		   decls->data[k].sym, marpatcl_rtc_spec_symname (SPEC->l0, decls->data[k].sym, 0));

	// Skip disabled events
	if (!decls->data[k].active) {
	    TRACE_ADD (" - not active, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}
	// Skip events without the requested type
	if (decls->data[k].type != type) {
	    TRACE_ADD (" - type mismatch, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}

	// Skip events without the requested symbols
	if (!marpatcl_rtc_symset_contains (symbols, decls->data[k].sym)) {
	    TRACE_ADD (" - symbol mismatch, skipped", 0);
	    TRACE_CLOSER;
	    continue;
	}

	// Extend result with active event for requested and symbol
	marpatcl_rtc_symset_include (result, 1, &k);
	TRACE_ADD (" - taking event %d", k);
	TRACE_CLOSER;
    }

    TRACE_RETURN_VOID;
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
