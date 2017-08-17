/* Runtime for C-engine (RTC). Implementation. (Grammar specification)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <spec.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_spec_setup (Marpa_Grammar g, marpatcl_rtc_rules* s)
{
    marpatcl_rtc_sym* pc;
    marpatcl_rtc_sym cmd, detail, proper, sep, start, stop;
    int k, ssz;
    Marpa_Symbol_ID* scratch;
    Marpa_Symbol_ID lastlhs;

    TRACE_FUNC ("(grammar %p, rules %p (symbols: %d))", g, s, s->symbols.size);

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
	    TRACE ("x MARPATCL_RC_DONE (start = %d)", detail);
	    ASSERT_BOUNDS (detail, s->symbols.size);

	    marpa_g_start_symbol_set (g, detail);
	    FREE (scratch);
	    TRACE_RETURN_VOID;
	    return;
	case MARPATCL_RC_PRIO:
	    /* priority -- full spec */
	    TRACE ("x MARPATCL_RC_PRIO (lhs = %d, #rhs = %d)", pc[1], detail);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    if (detail) {
		ASSERT_BOUNDS ((detail-1), ssz); /* max index is length-1 */
	    }

	    for (k=0;k<detail;k++) {
		ASSERT_BOUNDS (pc[2+k], s->symbols.size);
		scratch[k] = pc[2+k];
	    }
	    lastlhs = pc[1];
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 2 + detail;
	    break;
	case MARPATCL_RC_PRIS:
	    /* priority -- short spec, reuse previos lhs */
	    TRACE ("x MARPATCL_RC_PRIS (lhs = %d, #rhs = %d)", lastlhs, detail);
	    if (detail) {
		ASSERT_BOUNDS ((detail-1), ssz); /* max index is length-1 */
	    }

	    for (k=0;k<detail;k++) {
		ASSERT_BOUNDS (pc[1+k], s->symbols.size);
		scratch[k] = pc[1+k];
	    }
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 1 + detail;
	    break;
	case MARPATCL_RC_QUN:
	    /* quantified star, pc[] = rhs */
	    TRACE ("x MARPATCL_RC_QUN  (lhs = %d, rhs = %d)", detail, pc[1]);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);

	    marpa_g_sequence_new (g, detail, pc[1], -1, 0, 0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUP:
	    /* quantified plus, pc[] = rhs */
	    TRACE ("x MARPATCL_RC_QUP  (lhs = %d, rhs = %d)", detail, pc[1]);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);

	    marpa_g_sequence_new (g, detail, pc[1], -1, 1, 0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUNS:
	    /* quantified star + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    TRACE ("x MARPATCL_RC_QUNS (lhs = %d, rhs = %d, sep = %d, proper %d)",
		   detail, pc[1], sep, proper);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    ASSERT_BOUNDS (sep, s->symbols.size);

	    marpa_g_sequence_new (g, detail, pc[1], sep, 0, proper);
	    pc += 3;
	    break;
	case MARPATCL_RC_QUPS:
	    /* quantified plus + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    TRACE ("x MARPATCL_RC_QUPS (lhs = %d, rhs = %d, sep = %d, proper %d)",
		   detail, pc[1], sep, proper);
	    ASSERT_BOUNDS (detail, s->symbols.size);
	    ASSERT_BOUNDS (pc[1], s->symbols.size);
	    ASSERT_BOUNDS (sep, s->symbols.size);

	    marpa_g_sequence_new (g, detail, pc[1], sep, 1, proper);
	    pc += 3;
	    break;
	case MARPATCL_RC_BRAN:
	    /* byte range - pc [1] = start, stop - expand into alternation */
	    MARPATCL_RCMD_UNBXR (pc[1], start, stop);
	    TRACE ("x MARPATCL_RC_BRAN (lhs = %d, %d .. %d)", detail, start, stop);
	    ASSERT (start <= stop, "Bad byte range");

	    for (k = start; k <= stop; k++) {
		scratch[0] = k;
		marpa_g_rule_new (g, detail, scratch, 1);
	    }
	    pc += 2;
	    break;
	default:
	    ASSERT (0, "Unknown instruction");
	}
    }

    TRACE_RETURN_VOID;
}

const char*
marpatcl_rtc_spec_symname (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    TRACE_FUNC ("(rules %p, sym %d, len^ %p)", g, id, len);
    TRACE_RETURN ("%s", marpatcl_rtc_spec_string (g->sname, g->symbols.data [id], len));
}

const char*
marpatcl_rtc_spec_rulename (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    TRACE_FUNC ("(rules %p, sym %d, len^ %p)", g, id, len);
    TRACE_RETURN ("%s", marpatcl_rtc_spec_string (g->sname, g->rules.data [id], len));
}

const char*
marpatcl_rtc_spec_string (marpatcl_rtc_string* pool, marpatcl_rtc_sym id, int* len)
{
    TRACE_FUNC ("(pool %p, sym %d, len^ %p)", pool, id, len);
    if (len) {
	*len = pool->length [id];
    }
    TRACE_RETURN ("%s", pool->string + pool->offset [id]);
}

marpatcl_rtc_sym
marpatcl_rtc_spec_g1map (marpatcl_rtc_symvec* map, marpatcl_rtc_sym id)
{
    TRACE_FUNC ("(map %p, id %d)", map, id);
    ASSERT_BOUNDS (id, map->size);
    TRACE_RETURN ("%d", map->data [id]);
}

marpatcl_rtc_sym*
marpatcl_rtc_spec_g1decode (marpatcl_rtc_symvec* coding, marpatcl_rtc_sym rule, int* len)
{
    marpatcl_rtc_sym offset;
    marpatcl_rtc_sym tag;
    int length;

    TRACE_FUNC ("(coding %p, rule %d, len^ %p)",
		 coding, rule, len);
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
	    TRACE_RETURN ("%p", NULL);
	}
	ASSERT_BOUNDS (2+length-1, coding->size);
	TRACE_RETURN ("%p", coding->data + 2);

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
	    TRACE_RETURN ("%p",  NULL);
	}

	ASSERT_BOUNDS (1+offset, coding->size);
	length = coding->data[1+offset];
	TRACE ("per, length %d", length);
	
	*len = length;
	if (!length) {
	    TRACE_RETURN ("%p", NULL);
	}
	ASSERT_BOUNDS (1+offset+1+length-1, coding->size);
	TRACE_RETURN ("%p", coding->data + 1 + offset + 1);
    }
    ASSERT (0, "Unsupported type of g1 coding");
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
