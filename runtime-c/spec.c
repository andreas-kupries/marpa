/* Runtime for C-engine (RTC). Implementation. (Grammar specification)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <spec.h>
#include <stack.h>

TRACE_OFF;
TRACE_TAG_OFF (names);
/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Helper definitions
 */

#define FLAGS(p) ((p) ? MARPA_PROPER_SEPARATION : 0)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 *
 * Regarding "rule_data".*
 * - Per rule we push 2 numbers. PC of the instruction first, and additional
 *   information. The latter is currently only used by
 *   - PRIS instructions to refer back to the PRIO instructions which provided
 *     their LHS.
 *   - BRAN instructions store the RHS byte.
 *   - Everything else just uses `0` as placeholder
 *
 * See `rtc_int.h` (`marpatcl_rtc.*_rule`) for there this information is
 * saved.
 *
 * See `sem_tcl.c` (`error_lex_progress`) and called functions for where it is
 * used (entrypoint). Actual use happens in `progress.c`
 * (`marpatcl_rtc_progress`, and `decode_rule`).
 */

marpatcl_rtc_stack_p
marpatcl_rtc_spec_setup (Marpa_Grammar g, marpatcl_rtc_rules* s, int rd)
{
#define NAME(sym) marpatcl_rtc_spec_symname (s, sym, 0)
#define PUSH(detail)							\
    if (rd) marpatcl_rtc_stack_push (rule_data, pc - s->rcode); \
    if (rd) marpatcl_rtc_stack_push (rule_data, detail);

    marpatcl_rtc_sym* pc;
    marpatcl_rtc_sym* lpc = 0;
    marpatcl_rtc_sym cmd, detail, proper, sep, start, stop;
    int k, ssz;
    Marpa_Symbol_ID* scratch;
    Marpa_Symbol_ID lastlhs;
    marpatcl_rtc_stack_p rule_data = 0;
    TRACE_FUNC ("((Marpa_Grammar) %p, (rules*) %p (symbols %d))",
		g, s, s->symbols.size);
    if (rd) rule_data = marpatcl_rtc_stack_cons (MARPATCL_RTC_STACK_DEFAULT_CAP);

    /* Generate the symbols, in bulk */
    for (k=0; k < s->symbols.size; k++) {
        marpa_g_symbol_new (g);
    }
    /* Short-code engine decoding the rules into the grammar */
    pc = s->rcode;
    while (1) {
	MARPATCL_RCMD_UNBOX (pc[0], cmd, detail);
	switch (cmd) {
	case MARPATCL_RC_SETUP:
	    /* start of rules, detail = size of scratch area */
	    TRACE ("x MARPATCL_RC_SETUP (scratch = %d)", detail);

	    ssz = detail;
	    scratch = NALLOC (Marpa_Symbol_ID, detail);
	    pc ++;
	    break;
	case MARPATCL_RC_DONE:
	    /* end of rules, detail = start symbol */
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_DONE (start = %d", detail);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    TRACE_ADD (" <%s>)", NAME (detail));
	    TRACE_CLOSER;

	    marpa_g_start_symbol_set (g, detail);
	    FREE (scratch);

	    if (rd) s->rules.size = marpatcl_rtc_stack_size (rule_data) / 2;
	    // TODO: Store this somewhere else. (s) are the const grammar
	    // TODO: structures, i.e. could quite possibly be RO, with the
	    // TODO: write here seg.faulting.
	    TRACE_RETURN ("(stack*) %p", rule_data);
	    
	case MARPATCL_RC_PRIO:
	    /* priority -- full spec */
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_PRIO (lhs = %d, #rhs = %d)", pc[1], detail);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    TRACE_ADD (" <%s> := ", NAME (pc[1]));
	    if (detail) {
		ASSERT_BOUNDS ((detail-1), ssz); /* max index is length-1 */
	    }
	    for (k=0; k < detail; k++) {
		ASSERT_BOUNDS (pc[2+k], s->symbols.size);
		scratch[k] = pc[2+k];
		TRACE_ADD (" %d <%s>", pc[2+k], NAME (pc[2+k]));
	    }
	    TRACE_CLOSER;
	    
	    lastlhs = pc[1];
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    if (rd) lpc = pc;
	    PUSH (0);
	    pc += 2 + detail;
	    break;
	case MARPATCL_RC_PRIS:
	    /* priority -- short spec, reuse previos lhs */
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_PRIS (lhs = %d, #rhs = %d)", lastlhs, detail);
	    TRACE_ADD (" <%s> := ", NAME (lastlhs));
	    if (detail) {
		ASSERT_BOUNDS ((detail-1), ssz); /* max index is length-1 */
	    }
	    for (k=0; k < detail; k++) {
		ASSERT_BOUNDS (pc[1+k], s->symbols.size);
		scratch[k] = pc[1+k];
		TRACE_ADD (" %d <%s>", pc[1+k], NAME (pc[1+k]));
	    }
	    TRACE_CLOSER;

	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    PUSH (lpc - s->rcode);
	    pc += 1 + detail;
	    break;
	case MARPATCL_RC_QUN:
	    /* quantified star, pc[] = rhs */
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_QUN  (lhs = %d, rhs = %d)", detail, pc[1]);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    TRACE_ADD (" <%s> := <%s>*", NAME (detail), NAME (pc[1]));
	    TRACE_CLOSER;

	    marpa_g_sequence_new (g, detail, pc[1], -1, 0, 0);
	    PUSH (0);
	    
	    pc += 2;
	    break;
	case MARPATCL_RC_QUP:
	    /* quantified plus, pc[] = rhs */
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_QUP  (lhs = %d, rhs = %d)", detail, pc[1]);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    TRACE_ADD (" <%s> := <%s>+", NAME (detail), NAME (pc[1]));
	    TRACE_CLOSER;

	    marpa_g_sequence_new (g, detail, pc[1], -1, 1, 0);
	    PUSH (0);
	    
	    pc += 2;
	    break;
	case MARPATCL_RC_QUNS:
	    /* quantified star + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_QUNS (lhs = %d, rhs = %d, sep = %d, proper %d)",
		   detail, pc[1], sep, proper);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    ASSERT_BOUNDS (sep, s->symbols.size);
	    TRACE_ADD (" <%s> := <%s>* (sep <%s>)",
		       NAME (detail), NAME (pc[1]), NAME (sep));
	    TRACE_CLOSER;

	    marpa_g_sequence_new (g, detail, pc[1], sep, 0, FLAGS(proper));
	    PUSH (0);
	    
	    pc += 3;
	    break;
	case MARPATCL_RC_QUPS:
	    /* quantified plus + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_QUPS (lhs = %d, rhs = %d, sep = %d, proper %d)",
		       detail, pc[1], sep, proper);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    ASSERT_BOUNDS (sep, s->symbols.size);
	    TRACE_ADD (" <%s> := <%s>+ (sep <%s> proper)",
		       NAME (detail), NAME (pc[1]), NAME (sep));
	    TRACE_CLOSER;

	    marpa_g_sequence_new (g, detail, pc[1], sep, 1, FLAGS(proper));
	    PUSH (0);
	    
	    pc += 3;
	    break;
	case MARPATCL_RC_BRAN:
	    /* byte range - pc [1] = start, stop - expand into alternation */
	    MARPATCL_RCMD_UNBXR (pc[1], start, stop);
	    TRACE_HEADER (1);
	    TRACE_ADD ("x MARPATCL_RC_BRAN (lhs = %d, %d .. %d)", detail, start, stop);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT (start <= stop, "Bad byte range");
	    TRACE_ADD (" <%s>)", NAME (detail));
	    TRACE_CLOSER;

	    for (k = start; k <= stop; k++) {
		scratch[0] = k;
		marpa_g_rule_new (g, detail, scratch, 1);
		PUSH (k);
	    }
	    pc += 2;
	    break;
	default:
	    TRACE ("x UNKNOWN (%d %d)", cmd, detail);
	    ASSERT (0, "Unknown instruction");
	}
    }

    ASSERT (0, "reached the unreachable");
    TRACE_RETURN ("(stack*) %p", rule_data);

#undef PUSH
}

const char*
marpatcl_rtc_spec_symname (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    const char* s;
    TRACE_TAG_FUNC (names, "((rules*) %p, sym %d, (len*) %p)", g, id, len);
    s = marpatcl_rtc_spec_string (g->sname, g->symbols.data [id], len);
    TRACE_TAG_RETURN (names, "%s", s);
}

const char*
marpatcl_rtc_spec_rulename (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    const char* s;
    TRACE_TAG_FUNC (names, "((rules*) %p, sym %d, (len*) %p)", g, id, len);
    s = marpatcl_rtc_spec_string (g->sname, g->rules.data [id], len);
    TRACE_TAG_RETURN (names, "%s", s);
}

const char*
marpatcl_rtc_spec_string (marpatcl_rtc_string* pool, marpatcl_rtc_sym id, int* len)
{
    TRACE_TAG_FUNC (names, "(string*) %p, sym %d, (len*) %p)", pool, id, len);

    if (len) {
	*len = pool->length [id];
	TRACE_TAG (names, "(len*) %p = %d", len, *len);
    }

    TRACE_TAG_RETURN (names, "%s", pool->string + pool->offset [id]);
}

marpatcl_rtc_sym
marpatcl_rtc_spec_g1map (marpatcl_rtc_symvec* map, marpatcl_rtc_sym id)
{
    TRACE_FUNC ("((symvec*) %p, sym %d)", map, id);
    ASSERT_BOUNDS (id, map->size);
    TRACE_RETURN ("%d", map->data [id]);
}

marpatcl_rtc_sym*
marpatcl_rtc_spec_g1decode (marpatcl_rtc_symvec* coding, marpatcl_rtc_sym rule, int* len)
{
    marpatcl_rtc_sym offset;
    marpatcl_rtc_sym tag;
    int length;

    TRACE_FUNC ("((symvec*) %p, rule %d, (len*) %p)", coding, rule, len);
    ASSERT_BOUNDS (0, coding->size);
    ASSERT (len, "No place for length")
    tag = coding->data [0];
    TRACE ("tag %d", tag);
    
    switch (tag) {
    case MARPATCL_S_SINGLE:
	/* Masks are identical for all rules, i.e. independent of the
	 * `rule` argument. Coding:
	 *
	 * coding'in = [MARPATCL_S_SINGLE, length, data'0, ... data'length-1]
	 * coding -------------------------^       ^
	 * coding'out -----------------------------^
	 */
	ASSERT_BOUNDS (1, coding->size);
	length = coding->data [1];
	TRACE ("single, length %d", length);
	    
	*len = length;
	if (!length) {
	    TRACE_RETURN ("(sym*) %p", NULL);
	}
	TRACE ("(len*) %p = %d", len, *len);
	ASSERT_BOUNDS (2+length-1, coding->size);
	TRACE_RETURN ("(sym*) %p", coding->data + 2);

    case MARPATCL_S_PER:
	/* Masks differ per rule, however some may be the same.
	 * Coding:
	 * coding'in = [MARPATCL_S_PER, 0'off ... #rules-1'off, ... len, data'0 ... data'#len-1 ...]
	 * coding ----------------------^   \-----------------------/^   ^
	 * coding'out ---------------------------------------------------^
	 * Special coding: Rules with nothing are coded with offset 0 for a bit more compression.
	 */
	ASSERT_BOUNDS (1+rule, coding->size);
	offset = coding->data[1+rule];
	TRACE ("per, offset %d", offset);
	if (!offset) {
	    *len = 0;
	    TRACE_RETURN ("(sym*) %p (len 0)",  NULL);
	}

	ASSERT_BOUNDS (1+offset, coding->size);
	length = coding->data[1+offset];
	TRACE ("per, length %d", length);
	
	*len = length;
	if (!length) {
	    TRACE_RETURN ("(sym*) %p (len 0)", NULL);
	}
	TRACE ("(len*) %p = %d", len, *len);
	ASSERT_BOUNDS (1+offset+1+length-1, coding->size);
	TRACE_RETURN ("(sym*) %p", coding->data + 1 + offset + 1);
    }
    ASSERT (0, "Unsupported type of g1 coding");
    TRACE_RETURN ("(sym*) %p FAIL", 0);
}

marpatcl_rtc_stack_p
marpatcl_rtc_spec_setup_rd (marpatcl_rtc_rules* s)
{
#define PUSH(detail)					\
    marpatcl_rtc_stack_push (rule_data, pc - s->rcode); \
    marpatcl_rtc_stack_push (rule_data, detail);

    marpatcl_rtc_sym* pc;
    marpatcl_rtc_sym* lpc = 0;
    marpatcl_rtc_sym cmd, detail, start, stop;
    int k;
    marpatcl_rtc_stack_p rule_data = 0;

    TRACE_FUNC ("((rules*) %p (symbols %d))", s, s->symbols.size);
    rule_data = marpatcl_rtc_stack_cons (MARPATCL_RTC_STACK_DEFAULT_CAP);

    /* Short-code engine decoding the rules into the grammar */
    pc = s->rcode;
    while (1) {
	MARPATCL_RCMD_UNBOX (pc[0], cmd, detail);
	switch (cmd) {
	case MARPATCL_RC_SETUP:
	    /* start of rules, detail = size of scratch area */
	    pc ++;
	    break;
	case MARPATCL_RC_DONE:
	    /* end of rules, detail = start symbol */
	    s->rules.size = marpatcl_rtc_stack_size (rule_data) / 2;
	    // TODO: Store this somewhere else. (s) are the const grammar
	    // TODO: structures, i.e. could quite possibly be in RO memory,
	    // TODO: with this write here seg.faulting.
	    
	    TRACE_RETURN ("(stack*) %p", rule_data);
	    
	case MARPATCL_RC_PRIO:
	    /* priority -- full spec */
	    lpc = pc;
	    PUSH (0);
	    pc += 2 + detail;
	    break;
	case MARPATCL_RC_PRIS:
	    /* priority -- short spec, reuse previos lhs */
	    PUSH (lpc - s->rcode);
	    pc += 1 + detail;
	    break;
	case MARPATCL_RC_QUN:
	    /* quantified star, pc[] = rhs */
	    PUSH (0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUP:
	    /* quantified plus, pc[] = rhs */
	    PUSH (0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUNS:
	    /* quantified star + separator, pc[] = rhs */
	    PUSH (0);
	    pc += 3;
	    break;
	case MARPATCL_RC_QUPS:
	    /* quantified plus + separator, pc[] = rhs */
	    PUSH (0);
	    pc += 3;
	    break;
	case MARPATCL_RC_BRAN:
	    /* byte range - pc [1] = start, stop - expand into alternation */
	    MARPATCL_RCMD_UNBXR (pc[1], start, stop);
	    for (k = start; k <= stop; k++) {
		PUSH (k);
	    }
	    pc += 2;
	    break;
	default:
	    TRACE ("x UNKNOWN (%d %d)", cmd, detail);
	    ASSERT (0, "Unknown instruction");
	}
    }

    ASSERT (0, "reached the unreachable");
    TRACE_RETURN ("(stack*) %p", rule_data);
}


int
marpatcl_rtc_spec_symid (marpatcl_rtc_rules* g, const char* symname)
{
    TRACE_FUNC ("((rules*) %p, %s)", g, symname ? symname : "<<null>>");
    marpatcl_rtc_events* e   = g->events;
    marpatcl_rtc_symid*  map = e->idmap;

    // Binary search for the symbol in the table, then return its id.
    
    int low, high;
    for (low = 0, high = map->size-1; low <= high; ) {
	int mid   = (low+high)/2;
	const char* probe = map->symbol [mid];
	
	TRACE ("probe [%d..%d] @%d = %s ~ %s", low, high, mid, probe, symname);

	int delta = strcmp (probe, symname);
	
	if (!delta) {
	    TRACE ("%s ==> %d", symname, map->id [mid]);
	    TRACE_RETURN ("%d", map->id [mid]);
	}
	if (delta > 0) {
	    high = mid-1;
	    continue;
	}

	low = mid+1;
    }

    TRACE ("%s not found", symname);
    TRACE_RETURN ("%d", -1);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
