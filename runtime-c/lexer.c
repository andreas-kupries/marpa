/* Runtime for C-engine (RTC). Implementation. (Engine: Lexing, Parser gating)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <lexer.h>
#include <spec.h>
#include <stack.h>
#include <symset.h>
#include <events.h>
#include <rtc_int.h>
#include <progress.h>
#include <strdup.h>
#include <marpatcl_steptype.h>

TRACE_OFF;
TRACE_TAG_OFF (accept);
TRACE_TAG_OFF (lexonly);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Local requirements
 */

static void              match_begin (marpatcl_rtc_p p);
static char*             get_lexeme (marpatcl_rtc_p p, int* len);
static int               lex_complete (marpatcl_rtc_p p);
static int               lex_parse (marpatcl_rtc_p    p,
				    Marpa_Tree        t,
				    marpatcl_rtc_sym* token,
				    marpatcl_rtc_sym* rule);
static void              mismatch  (marpatcl_rtc_p p);
static marpatcl_rtc_sv_p get_sv    (marpatcl_rtc_p   p,
				    marpatcl_rtc_sym token,
				    marpatcl_rtc_sym rule);
static int               lex_events (marpatcl_rtc_p p,
				     marpatcl_rtc_eventtype type,
				     marpatcl_rtc_symset* symbols);

static int num_utf_chars (const char *src);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define POST_EVENT(type) \
    TRACE ("PE %s %d -> (%p, cd %p)", #type, EVENTS->n, p->event, p->ecdata); \
    LEX.m_event = type; \
    p->event (p->ecdata, type, EVENTS->n, EVENTS->dense); \
    LEX.m_event = -1

#define STRDUP(s) marpatcl_rtc_strdup (s)

#define ACCEPT   (&LEX.acceptable)
#define FOUND    (&LEX.found)
#define EVENTS   (&LEX.events)
#define DISCARDS (&LEX.discards)

#define PARS_R (PAR.recce)
#define ALWAYS (SPEC->always)

#define TO_ACS(s)      ((s)+256)
#define TO_TERMINAL(s) ((s)-256)

#define LEX_START      (LEX.start)
#define LEX_LEN        (LEX.length)
#define LEX_END        (LEX_START + LEX_LEN - 1)

#define LEX_FREE					\
    if (LEX.lexemestr) { FREE (LEX.lexemestr); }	\
    LEX.lexemestr = 0

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - match state accessors and mutators
 */

int
marpatcl_rtc_lexer_pe_get_lexeme_start (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("%d", LEX.cstart);
}

int
marpatcl_rtc_lexer_pe_get_lexeme_length (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    if (LEX.clength < 0) {
	(void*) marpatcl_rtc_lexer_pe_get_lexeme_value (p);
    }

    TRACE_RETURN ("%d", LEX.clength);
}

const char*
marpatcl_rtc_lexer_pe_get_lexeme_value (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    if (!LEX.lexemestr) {
	LEX.lexemestr = get_lexeme (p, NULL);
	LEX.clength   = num_utf_chars (LEX.lexemestr);
    }

    TRACE_RETURN ("'%s'", LEX.lexemestr);
}

marpatcl_rtc_symset*
marpatcl_rtc_lexer_pe_get_symbols (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("(marpatcl_rtc_symset* %p)",
		  LEX.m_event == marpatcl_rtc_event_discard
		  ? &LEX.discards
		  : &LEX.found);
}

marpatcl_rtc_stack_p
marpatcl_rtc_lexer_pe_get_semvalues (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);
    TRACE_RETURN ("(marpatcl_stack_p %p)",
		  LEX.m_event == marpatcl_rtc_event_discard
		  ? 0
		  : LEX.m_sv);
}

void
marpatcl_rtc_lexer_pe_set_lexeme_start (marpatcl_rtc_p p, int start)
{
    TRACE_FUNC ("((rtc*) %p, start = %d)", p, start);

    LEX.cstart = start;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_pe_set_lexeme_length (marpatcl_rtc_p p, int length)
{
    TRACE_FUNC ("((rtc*) %p, len = %d)", p, length);

    LEX.clength = length;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_pe_set_lexeme_value (marpatcl_rtc_p p, const char* value)
{
    TRACE_FUNC ("((rtc*) %p, value = %d/%s)", p,
		value ? num_utf_chars (value) : -1,
		value ? value : "<null>");

    LEX_FREE;
    LEX.lexemestr = STRDUP (value);
    LEX.clength   = num_utf_chars (LEX.lexemestr);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, and mutators
 */

void
marpatcl_rtc_lexer_init (marpatcl_rtc_p p)
{
    int k, res;
    TRACE_FUNC ("((rtc*) %p (L %d D %d A %d LA %d))",
		p, SPEC->lexemes, SPEC->discards, ALWAYS.size,
		SPEC->lexemes + ALWAYS.size);

    /* Note (%%accept/always%%): The ACCEPT symset contains G1 terminal
     * symbols, plus pseudo-terminals for the L0 discard ymbols. Conversion to
     * L0 ACS symbols (+256, TO_ACS) happens on entering them into the L0
     * recognizer. It was done this way to avoid the memory penalty of keeping
     * 256 superfluous and never-used entries for the L0 character symbols.
     */

    LEX.g = marpa_g_new (CONF);
    (void) marpa_g_force_valued (LEX.g);
    LRD   = marpatcl_rtc_spec_setup (LEX.g, SPEC->l0, TRACE_TAG_VAR (lexer_progress));
    marpatcl_rtc_symset_init (ACCEPT, SPEC->lexemes + SPEC->discards);
    marpatcl_rtc_symset_init (FOUND,  SPEC->lexemes);
    // XXX mem-optimize the discard set ?
    // - currently sized to keep all possible lexer symbols, i.e
    // - (bytes + ACS L + ACS D + L + D + internal)
    // XXX - could shrink to count only lexemes and discards
    // XXX - would have to transform on enter/retrieve (offset: 256+A:L+A:D)
    marpatcl_rtc_symset_init (DISCARDS, SPEC->l_symbols);
    marpatcl_rtc_symset_init (EVENTS,   SPEC->l0->events ? SPEC->l0->events->size : 0);

    if (!SPEC->g1) {
	// Lexing only mode. Initialize ACCEPT to accept everything, always.
	int k, n = SPEC->lexemes + SPEC->discards;
	Marpa_Symbol_ID* buf = marpatcl_rtc_symset_dense (ACCEPT);
	for (k=0; k < n; k++) buf [k] = k;
	marpatcl_rtc_symset_link (ACCEPT, n);

	TRACE_TAG (lexonly, "%s", "lexer only");
    }

    LEX.lexeme       = marpatcl_rtc_stack_cons (80);
    LEX.lexemestr    = 0;
    LEX.start        = -1;
    LEX.length       = -1;
    LEX.cstart       = -1;
    LEX.clength      = -1;
    LEX.recce        = 0;
    LEX.m_clearfirst = 1;
    LEX.m_sv         = marpatcl_rtc_stack_cons (MARPATCL_RTC_STACK_DEFAULT_CAP);
    LEX.m_event = marpatcl_rtc_eventtype_LAST;

    LEX.single_sv = 1;
    for (k = 0; k < SPEC->l0semantic.size; k++) {
	int key = SPEC->l0semantic.data[k];
	if ((key == MARPATCL_SV_RULE_NAME) ||
	    (key == MARPATCL_SV_RULE_ID) ||
	    (key == MARPATCL_SV_LHS_NAME) ||
	    (key == MARPATCL_SV_LHS_ID)) {
	    LEX.single_sv = 0;
	}
    }

    TRACE ("single_sv := %d", LEX.single_sv);

    res = marpa_g_precompute (LEX.g);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 precompute");
    marpatcl_rtc_lexer_events (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_free (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpa_g_unref (LEX.g);
    marpatcl_rtc_symset_free (ACCEPT);
    marpatcl_rtc_symset_free (FOUND);
    marpatcl_rtc_stack_destroy (LEX.lexeme);
    marpatcl_rtc_stack_destroy (LEX.m_sv);

    if (LEX.lexemestr) {
	FREE (LEX.lexemestr);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_flush (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p, <einval> (@ %d))",
		 p, GATE.lastloc);
    LEX_P (p);

    if (LEX.start == -1) {
	match_begin (p);
    }

    (void) lex_complete (p);
    // MAYBE FAIL.
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_enter (marpatcl_rtc_p p, int ch)
{
#define NAME(sym) marpatcl_rtc_spec_symname (SPEC->l0, sym, 0)

    int res;
    TRACE_FUNC ("((rtc*) %p, byte %3d (@ %d) <%s>)",
		p, ch, GATE.lastloc, NAME (ch));
    LEX_P (p);
    /* Contrary to the Tcl runtime the C engine does not get multiple symbols,
     * only one, the current byte. Because byte-ranges are coded as rules in
     * the grammar instead of as input symbols.
     */

    if (LEX.start == -1) {
	match_begin (p);
    }

    marpatcl_rtc_stack_push (LEX.lexeme, ch);
    LEX.length ++;
    res = marpa_r_alternative (LEX.recce, ch, 1, 1);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 alternative");

    res = marpa_r_earleme_complete (LEX.recce);
    if (res && (marpa_g_error (LEX.g, NULL) != MARPA_ERR_PARSE_EXHAUSTED)) {
	// any error but exhausted is a hard failure
	marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 earleme_complete");
    }
    marpatcl_rtc_lexer_events (p);

    if (marpa_r_is_exhausted (LEX.recce)) {
	(void) lex_complete (p);
	// MAYBE FAIL
	TRACE_RETURN_VOID;
    }

    // Now the gate can update its (character) acceptables too.
    marpatcl_rtc_gate_acceptable (p);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_eof (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p (start B:%d, C:%d))", p, LEX.start, LEX.cstart);

    if (LEX.start >= 0) {
	if (lex_complete (p)) {
	    TRACE ("eof bounce, retry", 0);
	    TRACE_RETURN_VOID;
	}
	// At this point the input may have been bounced away from the EOF.
	// This is signaled by a `true` return. If that is so we must not
	// report to the parser yet. We will come to this method again, after
	// the characters were re-processed.
	
	// MAYBE FAIL - TODO Handling ?
    }

    if (LEX.recce) {
	marpa_r_unref (LEX.recce);
	LEX.recce = 0;
    }

    if (SPEC->g1) {
	marpatcl_rtc_parser_eof (p);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_lexer_acceptable (marpatcl_rtc_p p, int keep)
{
    int res;
    Marpa_Symbol_ID* buf;
    int              n;

    TRACE_FUNC ("((rtc*) %p, keep %d)", p, keep);
    ASSERT (!LEX.recce, "lexer: left over recognizer");

    // create new recognizer for next match, reset match state
    LEX.recce  = marpa_r_new (LEX.g);
    LEX.start  = -1;
    LEX.cstart = -1;
    marpatcl_rtc_stack_clear (LEX.lexeme);
    res = marpa_r_start_input (LEX.recce);
    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 start_input");
    marpatcl_rtc_lexer_events (p);
    LEX_P (p);

    /* This code puts information from the parser's recognizer directly into
     * the `dense` array of the lexer's symset. It then links the retrieved
     * symbols through `sparse` to make it a proper set. Overall this is a
     * bulk assignment of the set without superfluous loops and copying.
     *
     * See also marpatcl_rtc_gate_acceptable(). A small difference, we have to
     * convert from parser terminal ids to the lexer's lexeme (ACS) ids.
     */

    if (!keep) {
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	if (SPEC->g1) {
	    n = marpa_r_terminals_expected (PARS_R, buf);
	    marpatcl_rtc_fail_syscheck (p, PAR.g, n, "g1 terminals_expected");
	    marpatcl_rtc_symset_link    (ACCEPT, n);
	    marpatcl_rtc_symset_include (ACCEPT, ALWAYS.size, ALWAYS.data);
	}
	// Lexing-only mode was set up by `lexer_init`.
    }

    /* And feed the results into the new lexer recce */
    n = marpatcl_rtc_symset_size (ACCEPT);
    TRACE_TAG (accept, "ACCEPT# %d", n);
    if (n) {
	int k;
	buf = marpatcl_rtc_symset_dense (ACCEPT);
	for (k=0; k < n; k++) {
	    TRACE_TAG (accept, "ACCEPT [%d]: %d = %s",
		       k, TO_ACS (buf[k]),
		       marpatcl_rtc_spec_symname (SPEC->l0, TO_ACS (buf[k]), 0));

	    res = marpa_r_alternative (LEX.recce, TO_ACS (buf [k]), 1, 1);
	    marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 alternative/b");
	}
    }

    // Complete the feed.
    res = marpa_r_earleme_complete (LEX.recce);
    if (res && (marpa_g_error (LEX.g, NULL) != MARPA_ERR_PARSE_EXHAUSTED)) {
	// any error but exhausted is a hard failure
	marpatcl_rtc_fail_syscheck (p, LEX.g, res, "l0 earleme_complete/b");
    }
    marpatcl_rtc_lexer_events (p);

    // Now the gate can update its acceptables (byte symbols) too.
    marpatcl_rtc_gate_acceptable (p);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Internal
 */

#ifdef CRITCL_TRACER
#define SHOW_SV(sv) \
    {							\
	char* svs = marpatcl_rtc_sv_show (sv, 0);	\
	TRACE_ADD (" sv %p = %s", sv, svs);		\
	FREE (svs);					\
    }
#else
#define SHOW_SV(sv)
#endif

static void
match_begin (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    LEX.start   = GATE.lastloc;
    LEX.length  = 0;
    LEX.cstart  = GATE.lastcloc;
    LEX.clength = -1;

    TRACE_RETURN_VOID;
}

static int
lex_complete (marpatcl_rtc_p p)
{
    int status, redo, latest, res, discarded, svid;
    Marpa_Bocage b;
    Marpa_Order  o;
    Marpa_Tree   t;
    marpatcl_rtc_sym terminal;
    marpatcl_rtc_sym token;
    marpatcl_rtc_sym rule;
    marpatcl_rtc_sv_p sv = 0;
    marpatcl_rtc_sv_p lastsv = 0;
    TRACE_RUN (int trees = -1);
    TRACE_FUNC ("((rtc*) %p (lex.recce %p))", p, LEX.recce);

    if (!LEX.recce) {
	TRACE_RETURN ("%d", 0);
    }

    /* Find location with lexeme, work backwards from the end of the match */
    latest =  marpa_r_latest_earley_set (LEX.recce);
    redo = 0;
    while (1) {
	TRACE_HEADER (1);
	TRACE_ADD ("rtc %p ?? match %d |lex| %d", p, latest, LEX.length);

	b = marpa_b_new (LEX.recce, latest);
	if (b) break;
	redo ++;
	latest --;
	if (latest < 0) {
	    TRACE_ADD (" fail", 0);
	    TRACE_CLOSER;

	    mismatch (p);
	    // FAIL, aborting. Callers `lexer_enter`, `lexer_eof`, `lexer_flush`.
	    TRACE_RETURN ("%d", 0);
	}
	/* We can reach this point with an empty-valued lexeme, i.e. no bytes
	 * where entered into the lexer.
	 *
	 * This happens when the GATE found an invalid byte immediately after
	 * the end of the previous lexeme and signaled a flush.
	 *
	 * This is not necessarily a mismatch however, which is why we do not
	 * check and abort before the search loop. One or more of the
	 * currently acceptable lexemes may allow to have an empty value.  In
	 * that case we simply recognize these as usual, and then redo the
	 * rejected byte in the new context, where it may be valid.
	 *
	 * Here now, we simply skip trying to make an empty value even
	 * emptier.
	 */
	if (LEX.length) {
	    LEX.length --;
	    (void) marpatcl_rtc_stack_pop (LEX.lexeme);
	}
	TRACE_CLOSER;
    }

    TRACE_ADD (" ok, redo %d", redo);
    TRACE_CLOSER;

    /*
     * Get all the valid parses at the location and evaluate them.
     * Reset the match state we collect our results in.
     */

    o = marpa_o_new (b);
    ASSERT (o, "Marpa_Order creation failed");

    t = marpa_t_new (o);
    ASSERT (t, "Marpa_Tree creation failed");

    discarded = 0;
    marpatcl_rtc_symset_clear (DISCARDS);
    marpatcl_rtc_symset_clear (FOUND);
    marpatcl_rtc_stack_clear  (LEX.m_sv);
    LEX_FREE;

    while (1) {
	status = lex_parse (p, t, &token, &rule);
	if (status < 0) {
	    TRACE ("rtc %p parse %d /done", p, status);
	    break;
	}

	TRACE_RUN (trees ++);
	TRACE_HEADER (1);
	TRACE_ADD ("rtc %p parse [%d] %d", p, trees, status);
	TRACE_ADD (" lexeme %d (%s) rule %d",
		   token, marpatcl_rtc_spec_symname (SPEC->l0, token, 0), rule);

	/* rule = lexeme rule id
	 * token = ACS symbol id (lexeme or discard)
	 * Range'L0: 256 ... 256+L+D-1
	 * Range'G1: 0 ... L+D-1
	 */

	terminal = TO_TERMINAL (token);

	/* terminal = G1 terminal id (lexeme) or pseudo-terminal (discard)
	 * Range:   0 ... L+D-1
	 * Lexeme:  0 ... L-1
	 * Discard: L ... L+D-1
	 */

	ASSERT (terminal < (SPEC->lexemes+SPEC->discards), "pseudo-terminal out of bounds");
	if (terminal >= SPEC->lexemes) {
	    TRACE_ADD (" discarded", 0);
	    TRACE_CLOSER;

	    discarded ++;
	    // Collect the discarded symbols if we have parse events to take into account.
	    // Note that we look at the ACS symbol here, not the terminal, which is bogus.
	    if (!SPEC->l0->events) continue;
	    marpatcl_rtc_symset_include (DISCARDS, 1, &token);
	    continue;
	}

	if (SPEC->g1) {
	    TRACE_ADD (" terminal %d (%s)",
		       terminal, marpatcl_rtc_spec_symname (SPEC->g1, terminal, 0));
	}

	if (marpatcl_rtc_symset_contains (FOUND, terminal)) {
	    TRACE_ADD (" duplicate, skip", 0);
	    TRACE_CLOSER;

	    continue;
	}
	TRACE_ADD (" save", 0);

	if (!marpatcl_rtc_symset_size(FOUND)) {
	    // First non-discarded token.
	    if (SPEC->g1) {
		// Show the parser's progress for the location.
		PAR_P (p);
	    } else {
		// Lexing-only mode. Start "enter"
		TRACE_TAG (lexonly, "((void*) %p) enter", p->rcdata);
		p->result (p->rcdata, NULL);
	    }
	}

	marpatcl_rtc_symset_include (FOUND, 1, &terminal);
	// (**) See (xx) for where the SVs are collected (if not in lex-only mode).

	// SV deduplication: If the semantic codes are all for a value
	// independent if token/rule ids, a single SV is generated and used in
	// all the symbols. Otherwise an SV is generated for each unique
	// token.  Note that this will not catch a token with multiple rules,
	// for these only the first is captured and forwarded.

	if (!LEX.single_sv || !sv) {
	    sv = get_sv (p, terminal, rule);
	    // sv RC 1
	    SHOW_SV (sv);
	    if (SPEC->g1) {
		// Parsing. Convert semantic values to identifiers we can
		// carry within the marpa engine.
		svid = marpatcl_rtc_store_add (p, sv);
		marpatcl_rtc_sv_unref_i (sv); // Store now owns it.
		TRACE_ADD (" [%d] :=", svid);
	    }
	}
	TRACE_CLOSER;
	if (SPEC->g1) {
	    // (xx) Collect the id of the SV for the symbols.
	    // See (**) for where the terminals are collected.
	    marpatcl_rtc_stack_push (LEX.m_sv, svid);
	} else {
	    // Lexing-only mode. Post token/value through "enter"
	    const char*       s  = marpatcl_rtc_spec_symname (SPEC->l0, token, 0);
	    marpatcl_rtc_sv_p tv = marpatcl_rtc_sv_cons_string (STRDUP (s), 1);

	    TRACE_TAG (lexonly, "((void*) %p) token (sv*) %p rc %d = '%s'", p->rcdata, tv, tv->refCount, s);
	    p->result (p->rcdata, tv);
	    // Callback now owns it. No unref because we started at RC 0.

	    TRACE_TAG (lexonly, "((void*) %p) value (sv*) %p rc %d", p->rcdata, sv, sv->refCount);
	    p->result (p->rcdata, sv);
	    // sv != lastsv => sv is new, callback bumped RC, undo ours
	    // sv == lastsv => sv already pushed, our RC undone already,
	    //                 don't release, would wrongly remove the
	    //                 callback's bump
	    // This happens when we find multiple tokens at the same
	    // location, sharing the SV.
	    if (sv != lastsv) {
		marpatcl_rtc_sv_unref_i (sv); // Callback now owns it.
		// RC = 1
	    }
	    lastsv = sv;
	}
    }

    marpatcl_rtc_gate_redo (p, redo);

    marpa_t_unref (t);
    marpa_o_unref (o);
    marpa_r_unref (LEX.recce);
    LEX.recce = 0;

    if (!marpatcl_rtc_symset_size(FOUND) && discarded) {
	// No lexemes found. Therefore do not talk to the parser, instead
	// restart lexing with the current set of acceptable symbols. Check
	// for active discard events tough, and report all found before
	// restarting.
	//
	// __ATTENTION__ The event handler function may move in the input.
	if (lex_events (p, marpatcl_rtc_event_discard, DISCARDS)) {
	    POST_EVENT (marpatcl_rtc_event_discard);
	}
    restart_after_discard:
	TRACE ("(rtc*) %p restart", p);
	marpatcl_rtc_lexer_acceptable (p, 1);
    } else if (SPEC->g1) {
	// Lexemes found, with associated SV. Check for before and after
	// events. Note the before events suppress any after events.
	//
	// __ATTENTION__ The event handler function may move in the input.
	// The event handler may also change the lexeme, and the set of
	// symbols and their associated SVs. If the set of symbols is emptied
	// this is taken as a discard and handled as such. Exception, no
	// discard is posted for this case.

	if (lex_events (p, marpatcl_rtc_event_before, FOUND)) {
	    marpatcl_rtc_inbound_moveto (p, LEX.cstart-1);
	    POST_EVENT (marpatcl_rtc_event_before);
	} else if (lex_events (p, marpatcl_rtc_event_after, FOUND)) {
	    POST_EVENT (marpatcl_rtc_event_after);
	}

	if (!marpatcl_rtc_symset_size(FOUND)) {
	    marpatcl_rtc_stack_clear (LEX.m_sv);
	    goto restart_after_discard;
	}

	// Tell parser to pull and enter the found alternatives (See (%%))
	TRACE ("(rtc*) %p parse #%d (%d..%d/%d)", p, marpatcl_rtc_symset_size(FOUND),
	       LEX_START, LEX_END, LEX_LEN);
	marpatcl_rtc_parser_enter (p);
	// MAYBE FAIL
    } else {
	// Lexing-only mode. Complete "enter", and restart the lower parts
	// (normally done by the parser)
	TRACE_TAG (lexonly, "((void*) %p) enter /complete", p->rcdata);
	p->result (p->rcdata, ((marpatcl_rtc_sv_p) 1));

	marpatcl_rtc_lexer_acceptable (p, 0);
    }

    TRACE_RETURN ("%d", redo);
}

static int
lex_events (marpatcl_rtc_p p, marpatcl_rtc_eventtype type, marpatcl_rtc_symset* symbols)
{
    TRACE_FUNC ("(marpatcl_rtc_p) %p, event %d, (symset*) %p", p, type, symbols);
    if (!SPEC->l0->events) {
	TRACE_RETURN ("#events = %d", 0);
    }
    marpatcl_rtc_gather_events (p, SPEC->l0->events, type, symbols, /* --> */ EVENTS);
    TRACE_RETURN ("#events = %d", marpatcl_rtc_symset_size(EVENTS));
}

static int
lex_parse (marpatcl_rtc_p    p,
	   Marpa_Tree        t,
	   marpatcl_rtc_sym* token,
	   marpatcl_rtc_sym* rule)
{
    Marpa_Value v;
    marpatcl_rtc_sym rules[2] = {-1,-1};
    int stop, status, rslot = 0, captoken = 0;

    TRACE_RUN (const char* sts = 0);
    TRACE_RUN (int k = -1);
    TRACE_FUNC ("((rtc*) %p, (Marpa_Tree) %p, (token*) %p, (rule*) %p)",
		p, t, token, rule);

    status = marpa_t_next (t);
    if (status == -1) {
	TRACE_RETURN ("%d", -1);
    }
    marpatcl_rtc_fail_syscheck (p, LEX.g, status, "t_next");

    v = marpa_v_new (t);
    ASSERT (v, "Marpa_Value creation failed");
    //TRACE_DO (_marpa_v_trace (v, 1));

    stop = 0;
    while (!stop) {
	Marpa_Step_Type stype = marpa_v_step (v);
	ASSERT (stype >= 0, "Step failure");
	TRACE_RUN (sts = marpatcl_steptype_decode_cstr (stype); k++);
	TRACE_HEADER (1);
	TRACE_ADD ("(rtc*) %p step[%4d] %d %s", p, k, stype, sts ? sts : "<<null>>");

	switch (stype) {
	case MARPA_STEP_INITIAL:
	    /* Nothing to do */
	    break;
	case MARPA_STEP_INACTIVE:
	    /* Done */
	    stop = 1;
	    break;
	case MARPA_STEP_RULE:
	    /* Keep last two rules saved so that we have quick access to
	     * next-to-last later */
	    TRACE_ADD ("  -- [%1d] rule %4d, span (%d-%d), %d := (%d-%d)",
		       rslot,
		       marpa_v_rule(v),
		       marpa_v_rule_start_es_id(v),
		       marpa_v_es_id(v),
		       marpa_v_result(v),
		       marpa_v_arg_0(v),
		       marpa_v_arg_n(v));
	    rules[rslot] = marpa_v_rule(v);
	    rslot = 1 - rslot;
	    break;
	case MARPA_STEP_TOKEN:
	    /* First token instruction has the id of the ACS symbol of the
	     * matched lexeme => terminal symbol derivable from this. */
	    TRACE_ADD (" -- token    %4d, span (%d-%d) <%s>, %d := <%d>",
		   marpa_v_token(v),
		   marpa_v_token_start_es_id(v),
		   marpa_v_es_id(v),
		   marpatcl_rtc_spec_symname (SPEC->l0, marpa_v_token(v), 0),
		   marpa_v_result(v),
		   marpa_v_token_value(v));
	    if (!captoken) {
		TRACE_ADD (" captured", 0);
		*token = marpa_v_token(v);
	    }
	    captoken = 1;
	    break;
	case MARPA_STEP_NULLING_SYMBOL:
	case MARPA_STEP_INTERNAL1:
	case MARPA_STEP_INTERNAL2:
	case MARPA_STEP_TRACE:
	    break;
	default:
	    break;
	}
	TRACE_CLOSER;
    }
    marpa_v_unref (v);

    TRACE ("rtc %p rule[%d] %d", p, rslot, rules[rslot]);
    *rule = rules[rslot];

    TRACE_RETURN ("%d", 0);
}

static void
mismatch (marpatcl_rtc_p p)
{
    TRACE_FUNC ("((rtc*) %p)", p);

    marpatcl_rtc_failit (p, "lexer");
    /* Caller `complete` has to abort */

    marpa_r_unref (LEX.recce);
    LEX.recce = 0;

    TRACE_RETURN_VOID;
}

static marpatcl_rtc_sv_p
get_sv (marpatcl_rtc_p   p,
	marpatcl_rtc_sym token, /* G1 parser terminal symbol id */
	marpatcl_rtc_sym rule)
{
    int k;
    /* SV is vector of pieces indicated by the codes */
    marpatcl_rtc_sv_p sv;
    /* local cache to avoid duplicate memory for duplicate key codes */
    marpatcl_rtc_sv_p start    = 0;
    marpatcl_rtc_sv_p end      = 0;
    marpatcl_rtc_sv_p length   = 0;
    marpatcl_rtc_sv_p g1start  = 0;
    marpatcl_rtc_sv_p g1end    = 0;
    marpatcl_rtc_sv_p g1length = 0;
    marpatcl_rtc_sv_p lhsname  = 0;
    marpatcl_rtc_sv_p lhsid    = 0;
    marpatcl_rtc_sv_p ruleid   = 0;
    marpatcl_rtc_sv_p value    = 0;

    //TRACE_FUNC ("((rtc*) %p, token %d, rule %d)", p, token, rule);
    sv = marpatcl_rtc_sv_cons_vec (SPEC->l0semantic.size);
    marpatcl_rtc_sv_ref_i (sv); // RC 1

#define DO(cache,cmd)				\
    if (!(cache)) {				\
	TRACE_ADD (" !%s", #cache);		\
	(cache) = cmd;				\
    };						\
    marpatcl_rtc_sv_vec_push (sv, (cache))

#define L0_SNAME(token)  marpatcl_rtc_spec_symname (SPEC->l0, token, NULL)
#define G1_SNAME(token)  marpatcl_rtc_spec_symname (SPEC->g1, token, NULL)

#define LEX_STR          (STRDUP (marpatcl_rtc_lexer_pe_get_lexeme_value (p)))
#define LEX_START_C      (LEX.cstart)
#define LEX_LEN_C        (marpatcl_rtc_lexer_pe_get_lexeme_length (p))
#define LEX_END_C        (LEX_START_C + LEX_LEN_C - 1)

    for (k = 0; k < SPEC->l0semantic.size; k++) {
	switch (SPEC->l0semantic.data[k]) {
	case MARPATCL_SV_START:		DO (start,  marpatcl_rtc_sv_cons_int (LEX_START_C));	break;
	case MARPATCL_SV_END:		DO (end,    marpatcl_rtc_sv_cons_int (LEX_END_C));	break;
	case MARPATCL_SV_LENGTH:	DO (length, marpatcl_rtc_sv_cons_int (LEX_LEN_C));	break;
	case MARPATCL_SV_VALUE:		DO (value,  marpatcl_rtc_sv_cons_string (LEX_STR, 1));	break;
	    //
	case MARPATCL_SV_G1START:	DO (g1start,  marpatcl_rtc_sv_cons_string ("",0));	break;//TODO
	case MARPATCL_SV_G1END:		DO (g1end,    marpatcl_rtc_sv_cons_string ("",0));	break;//TODO
	case MARPATCL_SV_G1LENGTH:	DO (g1length, marpatcl_rtc_sv_cons_int (1));		break;
	    //
	case MARPATCL_SV_RULE_NAME:	/* See below, LHS_NAME -- Specific to lexer semantics */
	case MARPATCL_SV_LHS_NAME:
	    if (SPEC->g1) {
		DO (lhsname, marpatcl_rtc_sv_cons_string (G1_SNAME (token), 0));
	    } else {
		DO (lhsname, marpatcl_rtc_sv_cons_string (L0_SNAME (TO_ACS (token)), 0));
	    }
	    break;
	case MARPATCL_SV_RULE_ID:	DO (ruleid, marpatcl_rtc_sv_cons_int (rule));		break;
	case MARPATCL_SV_LHS_ID:	DO (lhsid,  marpatcl_rtc_sv_cons_int (token));		break;
	default: ASSERT (0, "Invalid array descriptor key");
	}
    }

    if (marpatcl_rtc_sv_vec_size (sv) == 1) {
	marpatcl_rtc_sv_p el = marpatcl_rtc_sv_vec_get (sv, 0);
	// el RC 1!
	marpatcl_rtc_sv_ref_i (el); // RC 2
	marpatcl_rtc_sv_unref_i (sv); // destroyed, el RC 1
	// no unref on el, would destroy
	sv = el;
    }

    return sv ;//TRACE_RETURN ("%p", sv);
    // RC 1
}

static char*
get_lexeme (marpatcl_rtc_p p, int* len)
{
    int   n;
    char* v;

    //TRACE_FUNC ("(rtc %p, (len*) %p)", p, len);
    TRACE_ADD (" get_lexeme", 0);

    n = marpatcl_rtc_stack_size (LEX.lexeme);
    TRACE_ADD (" len(%d)", n);

    v = NALLOC (char, n+1);

    if (len) {
	//TRACE ("rtc %p, (len*) %p := %d", p, len, n);
	*len = n;
    }

    v[n] = '\0';
    while (n) {
	n--;
	v[n] = marpatcl_rtc_stack_pop (LEX.lexeme);
    }

    return v;//TRACE_RETURN ("'%s'", v);
}

static int
num_utf_bytes (const char *src)
{
    /*
     * Unicode characters less than this value are represented by themselves in
     * UTF-8 strings.
     */
#define UNICODE_SELF	0x80

    int ch;
    register int byte;

    /*
     * Unroll 1 to 3 (or 4) byte UTF-8 sequences.
     */

    byte = *((unsigned char *) src);
    if (byte < 0xC0) {
	/*
	 * Handles properly formed UTF-8 characters between 0x01 and 0x7F.
	 * Also treats \0 and naked trail bytes 0x80 to 0xBF as valid
	 * characters representing themselves.
	 */

	return 1;
    } else if (byte < 0xE0) {
	if ((src[1] & 0xC0) == 0x80) {
	    /*
	     * Two-byte-character lead-byte followed by a trail-byte.
	     */

	    ch = (int) (((byte & 0x1F) << 6) | (src[1] & 0x3F));
	    if ((unsigned)(ch - 1) >= (UNICODE_SELF - 1)) {
		return 2;
	    }
	}

	/*
	 * A two-byte-character lead-byte not followed by trail-byte
	 * represents itself.
	 */
    } else if (byte < 0xF0) {
	if (((src[1] & 0xC0) == 0x80) && ((src[2] & 0xC0) == 0x80)) {
	    /*
	     * Three-byte-character lead byte followed by two trail bytes.
	     */

	    ch = (int) (((byte & 0x0F) << 12)
			| ((src[1] & 0x3F) << 6)
			| (src[2] & 0x3F));
	    if (ch > 0x7FF) {
		return 3;
	    }
	}

	/*
	 * A three-byte-character lead-byte not followed by two trail-bytes
	 * represents itself.
	 */
    } else if (byte < 0xF8) {
	if (((src[1] & 0xC0) == 0x80) && ((src[2] & 0xC0) == 0x80) && ((src[3] & 0xC0) == 0x80)) {
	    /*
	     * Four-byte-character lead byte followed by three trail bytes.
	     */
	    ch = (int) (((byte & 0x07) << 18) | ((src[1] & 0x3F) << 12)
		    | ((src[2] & 0x3F) << 6) | (src[3] & 0x3F));
	    if ((unsigned)(ch - 0x10000) <= 0xFFFFF) {
		return 4;
	    }
	}

	/*
	 * A four-byte-character lead-byte not followed by three trail-bytes
	 * represents itself.
	 */
    }

    return 1;
}

static int
num_utf_chars (const char *src)
{
    Tcl_UniChar ch = 0;
    register int i = 0;

    while (*src != '\0') {
	src += num_utf_bytes (src);
	i++;
    }
    if (i < 0) i = INT_MAX; /* Bug [2738427] */
    return i;
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
