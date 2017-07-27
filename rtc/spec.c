/* Runtime for C-engine (RTC). Implementation. (Grammar specification)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <spec.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_spec_setup (Marpa_Grammar g, marpatcl_rtc_rules* s)
{
    marpatcl_rtc_sym* pc;
    marpatcl_rtc_sym cmd, detail, proper, sep, start, stop;
    int k;
    Marpa_Symbol_ID* scratch;
    Marpa_Symbol_ID lastlhs;

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
	    scratch = NALLOC (Marpa_Symbol_ID, detail);
	    pc ++;
	    break;
	case MARPATCL_RC_DONE:
	    /* end of rules */
	    marpa_g_start_symbol_set (g, detail);
	    FREE (scratch);
	    return;
	case MARPATCL_RC_PRIO:
	    /* priority -- full spec */
	    // copy short marpatcl_rtc_sym over to full-length Marpa_Symbol_ID scratch
	    for (k=0;k<detail;k++) { scratch[k] = pc[2+k]; }
	    lastlhs = pc[1];
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 2 + detail;
	    break;
	case MARPATCL_RC_PRIS:
	    /* priority -- short spec, reuse previos lhs */
	    // copy short marpatcl_rtc_sym over to full-length Marpa_Symbol_ID scratch
	    for (k=0;k<detail;k++) { scratch[k] = pc[1+k]; }
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 1 + detail;
	    break;
	case MARPATCL_RC_QUN:
	    /* quantified star, pc[] = rhs */
	    marpa_g_sequence_new (g, detail, pc[1], -1, 0, 0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUP:
	    /* quantified plus, pc[] = rhs */
	    marpa_g_sequence_new (g, detail, pc[1], -1, 1, 0);
	    pc += 2;
	    break;
	case MARPATCL_RC_QUNS:
	    /* quantified star + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    marpa_g_sequence_new (g, detail, pc[1], sep, 0, proper);
	    pc += 3;
	    break;
	case MARPATCL_RC_QUPS:
	    /* quantified plus + separator, pc[] = rhs */
	    MARPATCL_RCMD_UNBOX (pc[2], proper, sep);
	    marpa_g_sequence_new (g, detail, pc[1], sep, 1, proper);
	    pc += 3;
	    break;
	case MARPATCL_RC_BRAN:
	    /* byte range - pc [1,2] = start, stop - expand into alternation */
	    MARPATCL_RCMD_UNBXR (pc[1], start, stop);
	    for (k = start; k <= stop; k++) {
		scratch[0] = k;
		marpa_g_rule_new (g, detail, scratch, 1);
	    }
	    pc += 3;
	    break;
	}
    }
}

const char*
marpatcl_rtc_spec_symname (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    marpatcl_rtc_spec_string (g->sname, g->symbols.data [id], len);
}

const char*
marpatcl_rtc_spec_rulename (marpatcl_rtc_rules* g, marpatcl_rtc_sym id, int* len)
{
    marpatcl_rtc_spec_string (g->sname, g->rules.data [id], len);
}

const char*
marpatcl_rtc_spec_string (marpatcl_rtc_string* pool, marpatcl_rtc_sym id, int* len)
{
    if (len) {
	*len = pool->length [id];
    }
    return pool->string + pool->offset [id];
}

marpatcl_rtc_sym
marpatcl_rtc_spec_g1map (marpatcl_rtc_symvec* map, marpatcl_rtc_sym id)
{
    ASSERT_BOUNDS (id, map->size);
    return map->data [id];
}

marpatcl_rtc_sym*
marpatcl_rtc_spec_g1decode (marpatcl_rtc_symvec* coding, marpatcl_rtc_sym rule, int* len)
{
    marpatcl_rtc_sym offset;
    marpatcl_rtc_sym tag;
    int length;

    ASSERT_BOUNDS (0, coding->size);
    tag = coding->data [0];
    
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

	*len = length;
	if (!length) { return NULL; }
	ASSERT_BOUNDS (2+length-1, coding->size);
	return coding->data + 2;

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
	if (!offset) {
	    *len = 0;
	    return NULL;
	}

	ASSERT_BOUNDS (1+offset, coding->size);
	length = coding->data[1+offset];
		
	*len = length;
	if (!length) { return NULL; }
	ASSERT_BOUNDS (1+offset+1+length-1, coding->size);

	return coding->data + 1 + offset + 1;
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
