/* Runtime for C-engine (RTC). Implementation. (SV for Tcl)
 * - - -- --- ----- -------- ------------- ----------------
 * (c) 2017-2018 Andreas Kupries
 *
 * Requirements
 */

#include <sem_tcl.h>
#include <sem_int.h>
#include <rtc_int.h>
#include <spec.h>
#include <byteset.h>
#include <symset.h>
#include <stack.h>
#include <progress.h>
#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_callback/critcl_callbackDecls.h>
#include <marpatcl_rtc_eventtype.h>

TRACE_OFF;
TRACE_TAG_OFF (eh);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands, externals, and forward declarations for internals.
 */

#define TAKE   Tcl_IncrRefCount
#define RELE   Tcl_DecrRefCount

static Tcl_Obj*    astcl_do  (Tcl_Interp* ip, marpatcl_rtc_sv_p   sv, Tcl_Obj* null);
static Tcl_Obj*    vec_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_vec v,  Tcl_Obj* null);
static void        make_err  (Tcl_Interp* ip, marpatcl_rtc_p p);
static const char* qcs       (int i);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- Generic event handling
 */

void
marpatcl_rtc_eh_init (marpatcl_ehandlers* e, Tcl_Interp* ip,
		      marpatcl_events_to_names to_names)
{
    TRACE_TAG_FUNC (eh, "(marpatcl_ehandler*) %p, (Tcl_Interp*) %p", e, ip);

    e->ip       = ip;
    e->to_names = to_names;

    int i;
    for (i=0; i < marpatcl_rtc_eventtype_LAST; i++) {
	e->event [i] = 0;
    }
    
    TRACE_TAG_RETURN_VOID (eh);
}

void
marpatcl_rtc_eh_clear (marpatcl_ehandlers* e)
{
    TRACE_TAG_FUNC (eh, "(marpatcl_ehandler*) %p", e);
	
    int i;
    for (i=0; i < marpatcl_rtc_eventtype_LAST; i++) {
	if (!e->event [i]) continue;
	critcl_callback_destroy (e->event [i]);
    }
    
    TRACE_TAG_RETURN_VOID (eh);
}

void
marpatcl_rtc_eh_setup (marpatcl_ehandlers* e,
		       int                 c,
		       Tcl_Obj* const*     v)
{
    TRACE_TAG_FUNC (eh, "(marpatcl_ehandler*) %p, c=%d, v=%p", e, c, v);

    marpatcl_rtc_eh_clear (e);
    marpatcl_rtc_eh_init  (e, e->ip, e->to_names);

    if (!c) {
	TRACE_TAG (eh, "Skipping setup, no command prefix", 0);
	TRACE_TAG_RETURN_VOID (eh);
    }

    TRACE_TAG (eh, "Setting up per-event callbacks", 0);

    int i;
    for (i=0; i < marpatcl_rtc_eventtype_LAST; i++) {
	e->event [i] = critcl_callback_new (e->ip, c, (Tcl_Obj**) v, 3);
	critcl_callback_extend (e->event [i], e->self);
	critcl_callback_extend (e->event [i], marpatcl_rtc_eventtype_decode (e->ip, i));
	// Of the three argument slots we created the callback with now only
	// one is left, to hold the list of event names.
    }

    TRACE_TAG_RETURN_VOID (eh);
}

void
marpatcl_rtc_eh_report (void*                  cdata,
			marpatcl_rtc_eventtype type,
			int                    c,
			int*                   ids)
{
    TRACE_TAG_FUNC (eh, "(marpatcl_ehandler*) %p, type=%d, c=%d, v=%p", cdata, type, c, ids);
    marpatcl_ehandlers_p e = (marpatcl_ehandlers_p) cdata;

    if (!e->event[0]) {
	TRACE_TAG (eh, "PE ignored, no Tcl callback", 0);
	TRACE_TAG_RETURN_VOID (eh);
	TRACE_RETURN_VOID;
    }

    TRACE_TAG (eh, "PE taken, posting to Tcl", 0);

    Tcl_Obj* events = e->to_names (e->ip, c, ids);
    TAKE (events);

    critcl_callback_invoke (e->event [type], 1, &events);

    RELE (events);
    TRACE_TAG_RETURN_VOID (eh);
}
/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- Generic parse completion
 */

extern int
marpatcl_rtc_sv_complete (Tcl_Interp* ip, marpatcl_rtc_sv_p* sv, marpatcl_rtc_p p)
{
    /* This function is called with a pointer to where the SV will be
     * stored. This is necesssary because at the time of the call the SV is
     * not known yet. It is only after the call to 'marpatcl_rtc_eof' below
     * that the SV will be known and stored at the referenced location.
     */

    TRACE_FUNC ("(Interp*) %p, (sv**) %p, (rtc*) %p", ip, sv, p);

    if (!marpatcl_rtc_failed (p)) {
	TRACE ("EOF", 0);
	marpatcl_rtc_eof (p);
    }
    if (!marpatcl_rtc_failed (p)) {
	Tcl_Obj* r;
	TRACE ("SV-AS-TCL (sv*) %p", sv);
	r = marpatcl_rtc_sv_astcl (ip, *sv);
	if (r) {
	    TRACE ("SV OK (Tcl_Obj*) %p (rc %d)", r, r->refCount);
	    Tcl_SetObjResult (ip, r);
	    TRACE_RETURN ("OK", TCL_OK);
	}
	/* Assumes that an error message was left in ip */
    } else {
	TRACE ("FAIL", 0);
	make_err (ip, p);
    }
    TRACE_RETURN ("ERROR", TCL_ERROR);
}

extern Tcl_Obj*
marpatcl_rtc_sv_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_p sv)
{
    Tcl_Obj *svres, *null;
    TRACE_FUNC ("(Interp*) %p, (sv*) %p", ip, sv);

    null = Tcl_NewListObj (0,0);
    TAKE (null);
    svres = astcl_do (ip, sv, null);
    RELE (null);

    TRACE ("R ((Tcl_Obj*) %p) (rc %d))", svres, svres ? svres->refCount : -1);
    TRACE_RETURN ("(Tcl_Obj*) %p", svres);
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - Generic lex-only state support
 */

void
marpatcl_rtc_lex_init (marpatcl_rtc_lex_p state)
{
    TRACE_FUNC ("(marpatcl_rtc_lex_p %p)", state);

    state->tokens  = marpatcl_rtc_sv_cons_evec (1); // Expandable
    state->values  = marpatcl_rtc_sv_cons_evec (1); // Expandable
    state->ip      = 0;
    state->matched = 0;

    TRACE ("cons (marpatcl_rtc_lex_p %p).(tokens %p)", state, state->tokens);
    TRACE ("cons (marpatcl_rtc_lex_p %p).(values %p)", state, state->values);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lex_release (marpatcl_rtc_lex_p state)
{
    TRACE_FUNC ("(marpatcl_rtc_lex_p %p)", state);

    if (state->tokens) marpatcl_rtc_sv_unref (state->tokens);
    if (state->values) marpatcl_rtc_sv_unref (state->values);

    state->tokens = 0;
    state->values = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lex_token (void* cdata, marpatcl_rtc_sv_p sv)
{
    marpatcl_rtc_lex_p state = (marpatcl_rtc_lex_p) cdata;
    TRACE_FUNC ("(marpatcl_rtc_lex_p %p), ((sv*) %p)", state, sv);

    // See rtc/lexer.c 'complete' (!SPEC->g1) for the caller.
    //
    // Call sequence:
    // - sv == 0 : "enter" begins
    // - sv == 1 : "enter" is complete, call to Tcl
    // - any other sv:
    //   - even call => sv is token [string]
    //   - odd  call => sv is value [any]

    if (sv == 0) {
	// Begin "enter"
	TRACE ("%s", "enter /begin");

	TRACE ("- clear (marpatcl_rtc_lex_p %p).(tokens %p)", state, state->tokens);
	marpatcl_rtc_sv_vec_clear (state->tokens);

	TRACE ("- clear (marpatcl_rtc_lex_p %p).(values %p)", state, state->values);
	marpatcl_rtc_sv_vec_clear (state->values);

	TRACE ("%s", "enter /begin done");
	TRACE_RETURN_VOID;
    }

    if (sv == ((marpatcl_rtc_sv_p) 1)) {
	// Complete "enter", call into Tcl
	TRACE ("%s", "enter close /begin");

	Tcl_Obj* v[2];
	v[0] = marpatcl_rtc_sv_astcl (state->ip, state->tokens);
	v[1] = marpatcl_rtc_sv_astcl (state->ip, state->values);

	TRACE ("%s", "enter close - callback");
	(void) critcl_callback_invoke (state->matched, 2, v);
	TRACE ("%s", "enter close - callback return");

	TRACE ("%s", "enter close /done");
	TRACE_RETURN_VOID;
    };

    if (marpatcl_rtc_sv_vec_size (state->tokens) ==
	marpatcl_rtc_sv_vec_size (state->values)) {
	// Even call, both pads are empty or filled with matching t/v pairs.
	// This call is a new token.

	TRACE ("push token ((sv*) %p)", sv);
	marpatcl_rtc_sv_vec_push (state->tokens, sv);
    } else {
	// Odd call, we have one more token than values.
	// This call is a new value, match them again.

	TRACE ("push value ((sv*) %p)", sv);
	marpatcl_rtc_sv_vec_push (state->values, sv);
    }

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal helpers
 */

static Tcl_Obj*
astcl_do (Tcl_Interp* ip, marpatcl_rtc_sv_p sv, Tcl_Obj* null)
{
    Tcl_Obj* r;
    TRACE_FUNC ("(Interp*) %p, (sv*) %p, (Tcl_Obj*) %p <null>",
		ip, sv, null);
    if (!sv) {
	TRACE ("Rn ((Tcl_Obj*) %p) (rc %d))", null, null->refCount);
	TRACE_RETURN ("(Tcl_Obj*) %p", null);
    }

    switch (T_GET) {
    case marpatcl_rtc_sv_type_string:
	r = Tcl_NewStringObj (STR,-1);
	TRACE ("Rs ((Tcl_Obj*) %p) (rc %d))", r, r->refCount);
	TRACE_RETURN ("(Tcl_Obj*) %p", r);
	/**/
    case marpatcl_rtc_sv_type_int:
	r = Tcl_NewIntObj (INT);
	TRACE ("Ri ((Tcl_Obj*) %p) (rc %d))", r, r->refCount);
	TRACE_RETURN ("(Tcl_Obj*) %p", r);
	/**/
    case marpatcl_rtc_sv_type_double:
	r = Tcl_NewDoubleObj (FLT);
	TRACE ("Rd ((Tcl_Obj*) %p) (rc %d))", r, r->refCount);
	TRACE_RETURN ("(Tcl_Obj*) %p", r);
	/**/
    case marpatcl_rtc_sv_type_vec:
	r = vec_astcl (ip, VEC, null);
	TRACE ("Rv ((Tcl_Obj*) %p) (rc %d))", r, r ? r->refCount : -1);
	TRACE_RETURN ("(Tcl_Obj*) %p", r);
	/**/
    default:
	/* TODO -- custom data -- quick HACK - null it - work out a better rep later */
	TRACE ("R* ((Tcl_Obj*) %p) (rc %d))", null, null->refCount);
	TRACE_RETURN ("(Tcl_Obj*) %p", null);
    }
    ASSERT (0, "Should not happen");
}

static Tcl_Obj*
vec_astcl (Tcl_Interp* ip, marpatcl_rtc_sv_vec v, Tcl_Obj* null)
{
    int k;
    Tcl_Obj* svres = Tcl_NewListObj (0 /*n*/,0);
    // TODO CHECK: Will using n > 0 pre-alloc an internal array (I suspect not) */
    TRACE_FUNC ("(Interp*) %p, (sv_vec) %p, (Tcl_Obj*) %p <null>",
		ip, v, null);

    for (k = 0; k < v->size; k++) {
	Tcl_Obj* el = astcl_do (ip, v->data[k], null);
	TRACE ("[%3d] ((Tcl_Obj*) %p) (rc %d))", k, el, el ? el->refCount : -1);
	if (!el || (Tcl_ListObjAppendElement(ip, svres, el) != TCL_OK)) {
	    TRACE ("[%3d] fail ((Tcl_Obj*) %p) (rc %d))", k, svres, svres ? svres->refCount : -1);
	    RELE (svres);
	    TRACE_RETURN ("(Tcl_Obj*) %p", 0);
	}
    }

    TRACE ("R ((Tcl_Obj*) %p) (rc %d))", svres, svres ? svres->refCount : -1);
    TRACE_RETURN ("(Tcl_Obj*) %p", svres);
}

static int
compare (const void* a, const void* b)
{
    Marpa_Symbol_ID* as = (Marpa_Symbol_ID*) a;
    Marpa_Symbol_ID* bs = (Marpa_Symbol_ID*) b;
    if (*as < *bs) return -1;
    if (*as > *bs) return 1;
    return 0;
}

static void
error_location (Tcl_DString *ds, marpatcl_rtc_p p)
{
    ASSERT (FAIL.origin, "origin missing");
    Tcl_DStringAppend (ds, "Parsing failed in ", -1);
    Tcl_DStringAppend (ds, FAIL.origin, -1);
    Tcl_DStringAppend (ds, ".", -1);

    TRACE ("GATE LL %d", GATE.lastloc);
    if (GATE.lastloc < 0) {
	Tcl_DStringAppend (ds, " No input", -1);
    } else {
	char buf [30];
	if (GATE.lastcloc < 0) {
	    sprintf (buf, "%d", GATE.lastloc);
	} else {
	    sprintf (buf, "%d", GATE.lastcloc);
	}
	Tcl_DStringAppend (ds, " Stopped at offset ", -1);
	Tcl_DStringAppend (ds, buf, -1);

	if (IN.header) {
	    sprintf (buf, "%d", IN.header);
	    Tcl_DStringAppend (ds, " (+", -1);
	    Tcl_DStringAppend (ds, buf, -1);
	    Tcl_DStringAppend (ds, " byte) ", -1);
	}
    }
}

static void
error_match_candidate (Tcl_DString *ds, marpatcl_rtc_p p)
{
    // TODO: Properly handle a partially read UTF character at the end
    //       IOW instead of 'after reading' use 'while x bytes in reading'
    // Maybe not, see IN.header us in `error_location` above. Might be enough.

    TRACE ("GATE LC %d|%d", GATE.lastchar, MARPATCL_RTC_BSMAX);
    TRACE ("LEXE # %d", marpatcl_rtc_stack_size (LEX.lexeme));

    if (marpatcl_rtc_stack_size (LEX.lexeme)) {
	// ATTENTION: This access to LEX.lexeme is destructive.
        Tcl_DStringAppend (ds, " after reading '", -1);
	while (marpatcl_rtc_stack_size (LEX.lexeme)) {
	    char c = marpatcl_rtc_stack_pop (LEX.lexeme);
	    Tcl_DStringAppend (ds, qcs (c), -1);
	}
	if (GATE.lastchar >= 0) {
	    ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	    Tcl_DStringAppend (ds, qcs (GATE.lastchar), -1);
	}
	Tcl_DStringAppend (ds, "'", -1);
    } else if (GATE.lastchar >= 0) {
	ASSERT_BOUNDS (GATE.lastchar, MARPATCL_RTC_BSMAX);
	Tcl_DStringAppend (ds, " after reading '", -1);
	Tcl_DStringAppend (ds, qcs (GATE.lastchar), -1);
	Tcl_DStringAppend (ds, "'", -1);
    }
    Tcl_DStringAppend (ds, ".", -1);
}

static void
error_lex_accept (Tcl_DString *ds, marpatcl_rtc_p p)
{
    TRACE ("GATE #acc %d", marpatcl_rtc_byteset_size (&GATE.acceptable));
    if (marpatcl_rtc_byteset_size (&GATE.acceptable)) {
	int k;
	Tcl_DStringAppend (ds, " Expected any character in [", -1);

	for (k=0; k < MARPATCL_RTC_BSMAX; k++) {
	    if (!marpatcl_rtc_byteset_contains (&GATE.acceptable, k)) continue;
	    Tcl_DStringAppend (ds, qcs (k), -1);
	}
	Tcl_DStringAppend (ds, "]", -1);
    }
}

static void
error_parse_accept (Tcl_DString *ds, marpatcl_rtc_p p)
{
    int chars = marpatcl_rtc_byteset_size (&GATE.acceptable);
    //char buf [30];

    TRACE ("LEXE #acc %d", marpatcl_rtc_symset_size (&LEX.acceptable));
    if (marpatcl_rtc_symset_size (&LEX.acceptable)) {
	int           k, n = marpatcl_rtc_symset_size  (&LEX.acceptable);
	Marpa_Symbol_ID* d = marpatcl_rtc_symset_dense (&LEX.acceptable);
	const char* sep = "";

	if (chars) {
	    Tcl_DStringAppend (ds, " while looking for any of (", -1);
	} else {
	    Tcl_DStringAppend (ds, " Looking for any of (", -1);
	}

	// ATTENTION: We are destructive on the symset
	// //
	// First conversion from G1 syms to L0 ACS to String ids.
	// Reuses symset space, destroys it.
	for (k=0; k < n; k++) {
	    d [k] = SPEC->l0->symbols.data [d [k] + 256];
	}
	// Second conversion from string ids to strings, after sorting the
	// ids. Based on the fact that the strings are stored sorted by the
	// generator (gen-common/runtime-c.tcl), causing the sort order of the
	// ids to match the lexicographic order.
	qsort (d, n, sizeof (Marpa_Symbol_ID), compare);
	for (k=0; k < n; k++) {
	    Marpa_Symbol_ID sym = d [k];
	    const char* sname = marpatcl_rtc_spec_string (SPEC->l0->sname, sym, 0);
	    TRACE ("LEX? %4d '%s'", sym, sname);
	    //sprintf (buf, "(%d) ", sym);
	    Tcl_DStringAppend (ds, sep, -1);
	    //Tcl_DStringAppend (ds, buf, -1);
	    Tcl_DStringAppend (ds, sname, -1);
	    sep = ", ";
	}

	Tcl_DStringAppend (ds, ").", -1);
    } else if (chars) {
	Tcl_DStringAppend (ds, ".", -1);
    }
}

static void
error_print (void* cdata, const char* string)
{
    Tcl_DString* ds = (Tcl_DString*) cdata;
    Tcl_DStringAppend (ds, string, -1);
}

static void
error_lex_progress (Tcl_DString *ds, marpatcl_rtc_p p)
{
    // Skip progress report if there is no recognizer to query
    if (!LEX.recce) return;

    Tcl_DStringAppend (ds, "\nL0 Report:\n", -1);
    // We need the rule_data for the/a readable progress report.  Generate it
    // if it was not made during regular setup (with progress tracing on).
    // That is the normal case, i.e. generate just for the error message.
    if (!LRD) {
	LRD = marpatcl_rtc_spec_setup_rd (SPEC->l0);
    }
    marpatcl_rtc_progress (error_print, ds,
			   p, SPEC->l0, LRD, LEX.recce, LEX.g,
			   marpa_r_latest_earley_set (LEX.recce));
}

static void
error_lex_mismatch (Tcl_DString *ds, marpatcl_rtc_p p)
{
    if (GATE.lastchar >= 0) {
	char buf [30];

	Tcl_DStringAppend (ds, "\nMismatch:\n'", -1);
	Tcl_DStringAppend (ds, qcs (GATE.lastchar), -1);
	Tcl_DStringAppend (ds, "' => (", -1);
	sprintf (buf, "%d", GATE.lastchar);
	Tcl_DStringAppend (ds, buf, -1);
	Tcl_DStringAppend (ds, ") ni", -1);

	if (marpatcl_rtc_byteset_size (&GATE.acceptable)) {
	    int k;
	    for (k=0; k < MARPATCL_RTC_BSMAX; k++) {
		if (!marpatcl_rtc_byteset_contains (&GATE.acceptable, k)) continue;
		Tcl_DStringAppend (ds, "\n ", -1);
		sprintf (buf, "%4d", k);
		Tcl_DStringAppend (ds, buf, -1);
		Tcl_DStringAppend (ds, ": '", -1);
		Tcl_DStringAppend (ds, qcs (k), -1);
		Tcl_DStringAppend (ds, "'", -1);
	    }
	}
    }
}

static void
make_err (Tcl_Interp* ip, marpatcl_rtc_p p)
{
    // *** ATTENTION ***
    //
    // While the Tcl engine uses chars and char offsets RTC primarily uses
    // bytes and byte offsets.  For testing this does not matter, operating
    // solely in the ASCII domain, where these things are identical.
    //
    // IN, GATE, and LEX additionally track chars and char offsets.
    // See `error_location` for the (GATE.lastcloc, IN.header).
    //
    // TODO: Maybe extend GATE to remember the bytes of a (partially) read character?

    Tcl_DString ds;

    TRACE_FUNC ("((rtc*) %p)", p);

    Tcl_DStringInit       (&ds);
    error_location        (&ds, p);
    error_match_candidate (&ds, p);
    error_lex_accept      (&ds, p);
    error_parse_accept    (&ds, p);
    error_lex_progress    (&ds, p);
    error_lex_mismatch    (&ds, p);

    Tcl_SetErrorCode  (ip, "SYNTAX", NULL);
    Tcl_DStringResult (ip, &ds);

    Tcl_DStringFree (&ds);
}

static const char*
qcs (int i)
{
    static const char* qcs_map [256] = {
	/*   0 = */ "\\0",
	/*   1 = */ "\\1",
	/*   2 = */ "\\2",
	/*   3 = */ "\\3",
	/*   4 = */ "\\4",
	/*   5 = */ "\\5",
	/*   6 = */ "\\6",
	/*   7 = */ "\\7",
	/*   8 = */ "\\10",
	/*   9 = */ "\\t",
	/*  10 = */ "\\n",
	/*  11 = */ "\\13",
	/*  12 = */ "\\14",
	/*  13 = */ "\\r",
	/*  14 = */ "\\16",
	/*  15 = */ "\\17",
	/*  16 = */ "\\20",
	/*  17 = */ "\\21",
	/*  18 = */ "\\22",
	/*  19 = */ "\\23",
	/*  20 = */ "\\24",
	/*  21 = */ "\\25",
	/*  22 = */ "\\26",
	/*  23 = */ "\\27",
	/*  24 = */ "\\30",
	/*  25 = */ "\\31",
	/*  26 = */ "\\32",
	/*  27 = */ "\\33",
	/*  28 = */ "\\34",
	/*  29 = */ "\\35",
	/*  30 = */ "\\36",
	/*  31 = */ "\\37",
	/*  32 = */ "\\40",
	/*  33 = */ "!",
	/*  34 = */ "\\42",
	/*  35 = */ "#",
	/*  36 = */ "$",
	/*  37 = */ "%",
	/*  38 = */ "&",
	/*  39 = */ "'",
	/*  40 = */ "\\50",
	/*  41 = */ "\\51",
	/*  42 = */ "*",
	/*  43 = */ "+",
	/*  44 = */ ",",
	/*  45 = */ "-",
	/*  46 = */ ".",
	/*  47 = */ "/",
	/*  48 = */ "0",
	/*  49 = */ "1",
	/*  50 = */ "2",
	/*  51 = */ "3",
	/*  52 = */ "4",
	/*  53 = */ "5",
	/*  54 = */ "6",
	/*  55 = */ "7",
	/*  56 = */ "8",
	/*  57 = */ "9",
	/*  58 = */ ":",
	/*  59 = */ "\\73",
	/*  60 = */ "<",
	/*  61 = */ "=",
	/*  62 = */ ">",
	/*  63 = */ "?",
	/*  64 = */ "@",
	/*  65 = */ "A",
	/*  66 = */ "B",
	/*  67 = */ "C",
	/*  68 = */ "D",
	/*  69 = */ "E",
	/*  70 = */ "F",
	/*  71 = */ "G",
	/*  72 = */ "H",
	/*  73 = */ "I",
	/*  74 = */ "J",
	/*  75 = */ "K",
	/*  76 = */ "L",
	/*  77 = */ "M",
	/*  78 = */ "N",
	/*  79 = */ "O",
	/*  80 = */ "P",
	/*  81 = */ "Q",
	/*  82 = */ "R",
	/*  83 = */ "S",
	/*  84 = */ "T",
	/*  85 = */ "U",
	/*  86 = */ "V",
	/*  87 = */ "W",
	/*  88 = */ "X",
	/*  89 = */ "Y",
	/*  90 = */ "Z",
	/*  91 = */ "\\133",
	/*  92 = */ "\\134",
	/*  93 = */ "\\135",
	/*  94 = */ "^",
	/*  95 = */ "_",
	/*  96 = */ "`",
	/*  97 = */ "a",
	/*  98 = */ "b",
	/*  99 = */ "c",
	/* 100 = */ "d",
	/* 101 = */ "e",
	/* 102 = */ "f",
	/* 103 = */ "g",
	/* 104 = */ "h",
	/* 105 = */ "i",
	/* 106 = */ "j",
	/* 107 = */ "k",
	/* 108 = */ "l",
	/* 109 = */ "m",
	/* 110 = */ "n",
	/* 111 = */ "o",
	/* 112 = */ "p",
	/* 113 = */ "q",
	/* 114 = */ "r",
	/* 115 = */ "s",
	/* 116 = */ "t",
	/* 117 = */ "u",
	/* 118 = */ "v",
	/* 119 = */ "w",
	/* 120 = */ "x",
	/* 121 = */ "y",
	/* 122 = */ "z",
	/* 123 = */ "\\173",
	/* 124 = */ "|",
	/* 125 = */ "\\175",
	/* 126 = */ "~",
	/* 127 = */ "\\177",
	/* 128 = */ "\\200",
	/* 129 = */ "\\201",
	/* 130 = */ "\\202",
	/* 131 = */ "\\203",
	/* 132 = */ "\\204",
	/* 133 = */ "\\205",
	/* 134 = */ "\\206",
	/* 135 = */ "\\207",
	/* 136 = */ "\\210",
	/* 137 = */ "\\211",
	/* 138 = */ "\\212",
	/* 139 = */ "\\213",
	/* 140 = */ "\\214",
	/* 141 = */ "\\215",
	/* 142 = */ "\\216",
	/* 143 = */ "\\217",
	/* 144 = */ "\\220",
	/* 145 = */ "\\221",
	/* 146 = */ "\\222",
	/* 147 = */ "\\223",
	/* 148 = */ "\\224",
	/* 149 = */ "\\225",
	/* 150 = */ "\\226",
	/* 151 = */ "\\227",
	/* 152 = */ "\\230",
	/* 153 = */ "\\231",
	/* 154 = */ "\\232",
	/* 155 = */ "\\233",
	/* 156 = */ "\\234",
	/* 157 = */ "\\235",
	/* 158 = */ "\\236",
	/* 159 = */ "\\237",
	/* 160 = */ "\\240",
	/* 161 = */ "\\241",
	/* 162 = */ "\\242",
	/* 163 = */ "\\243",
	/* 164 = */ "\\244",
	/* 165 = */ "\\245",
	/* 166 = */ "\\246",
	/* 167 = */ "\\247",
	/* 168 = */ "\\250",
	/* 169 = */ "\\251",
	/* 170 = */ "\\252",
	/* 171 = */ "\\253",
	/* 172 = */ "\\254",
	/* 173 = */ "\\255",
	/* 174 = */ "\\256",
	/* 175 = */ "\\257",
	/* 176 = */ "\\260",
	/* 177 = */ "\\261",
	/* 178 = */ "\\262",
	/* 179 = */ "\\263",
	/* 180 = */ "\\264",
	/* 181 = */ "\\265",
	/* 182 = */ "\\266",
	/* 183 = */ "\\267",
	/* 184 = */ "\\270",
	/* 185 = */ "\\271",
	/* 186 = */ "\\272",
	/* 187 = */ "\\273",
	/* 188 = */ "\\274",
	/* 189 = */ "\\275",
	/* 190 = */ "\\276",
	/* 191 = */ "\\277",
	/* 192 = */ "\\300",
	/* 193 = */ "\\301",
	/* 194 = */ "\\302",
	/* 195 = */ "\\303",
	/* 196 = */ "\\304",
	/* 197 = */ "\\305",
	/* 198 = */ "\\306",
	/* 199 = */ "\\307",
	/* 200 = */ "\\310",
	/* 201 = */ "\\311",
	/* 202 = */ "\\312",
	/* 203 = */ "\\313",
	/* 204 = */ "\\314",
	/* 205 = */ "\\315",
	/* 206 = */ "\\316",
	/* 207 = */ "\\317",
	/* 208 = */ "\\320",
	/* 209 = */ "\\321",
	/* 210 = */ "\\322",
	/* 211 = */ "\\323",
	/* 212 = */ "\\324",
	/* 213 = */ "\\325",
	/* 214 = */ "\\326",
	/* 215 = */ "\\327",
	/* 216 = */ "\\330",
	/* 217 = */ "\\331",
	/* 218 = */ "\\332",
	/* 219 = */ "\\333",
	/* 220 = */ "\\334",
	/* 221 = */ "\\335",
	/* 222 = */ "\\336",
	/* 223 = */ "\\337",
	/* 224 = */ "\\340",
	/* 225 = */ "\\341",
	/* 226 = */ "\\342",
	/* 227 = */ "\\343",
	/* 228 = */ "\\344",
	/* 229 = */ "\\345",
	/* 230 = */ "\\346",
	/* 231 = */ "\\347",
	/* 232 = */ "\\350",
	/* 233 = */ "\\351",
	/* 234 = */ "\\352",
	/* 235 = */ "\\353",
	/* 236 = */ "\\354",
	/* 237 = */ "\\355",
	/* 238 = */ "\\356",
	/* 239 = */ "\\357",
	/* 240 = */ "\\360",
	/* 241 = */ "\\361",
	/* 242 = */ "\\362",
	/* 243 = */ "\\363",
	/* 244 = */ "\\364",
	/* 245 = */ "\\365",
	/* 246 = */ "\\366",
	/* 247 = */ "\\367",
	/* 248 = */ "\\370",
	/* 249 = */ "\\371",
	/* 250 = */ "\\372",
	/* 251 = */ "\\373",
	/* 252 = */ "\\374",
	/* 253 = */ "\\375",
	/* 254 = */ "\\376",
	/* 255 = */ "\\377"
    };

    return qcs_map [i];
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
