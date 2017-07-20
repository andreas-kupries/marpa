/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Grammar specification
 */

#include <spec.h>
#include <critcl_alloc.h>

/*
 * No functions available for the specification types.
 * This file is a dummy to force a check of the declared data structures
 * when building marpa.
 *
 * When functions become available/needed the comment will change.
 */


void
marpa_rtc_spec_setup (Marpa_Grammar g, marpa_rtc_rules* s)
{
    marpa_sym* pc;
    marpa_sym cmd, detail, proper, sep;
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
	MARPA_RCMD_UNBOX (pc[0], cmd, detail);
	switch (cmd) {
	case MARPA_RC_SETUP:
	    scratch = NALLOC (Marpa_Symbol_ID, detail);
	    pc ++;
	    break;
	case MARPA_RC_DONE:
	    /* end of rules */
	    marpa_g_start_symbol_set (g, detail);
	    FREE (scratch);
	    return;
	case MARPA_RC_PRIO:
	    /* priority -- full spec */
	    // copy short marpa_sym over to full-length Marpa_Symbol_ID scratch
	    for (k=0;k<detail;k++) { scratch[k] = pc[2+k]; }
	    lastlhs = pc[1];
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 2 + detail;
	    break;
	case MARPA_RC_PRIS:
	    /* priority -- short spec, reuse previos lhs */
	    // copy short marpa_sym over to full-length Marpa_Symbol_ID scratch
	    for (k=0;k<detail;k++) { scratch[k] = pc[1+k]; }
	    marpa_g_rule_new (g, lastlhs, scratch, detail);
	    pc += 1 + detail;
	    break;
	case MARPA_RC_QUN:
	    /* quantified star, pc[] = rhs */
	    marpa_g_sequence_new (g, detail, pc[1], -1, 0, 0);
	    pc += 2;
	    break;
	case MARPA_RC_QUP:
	    /* quantified plus, pc[] = rhs */
	    marpa_g_sequence_new (g, detail, pc[1], -1, 1, 0);
	    pc += 2;
	    break;
	case MARPA_RC_QUNS:
	    /* quantified star + separator, pc[] = rhs */
	    MARPA_RCMD_UNBOX (pc[2], proper, sep);
	    marpa_g_sequence_new (g, detail, pc[1], sep, 0, proper);
	    pc += 3;
	    break;
	case MARPA_RC_QUPS:
	    /* quantified plus + separator, pc[] = rhs */
	    MARPA_RCMD_UNBOX (pc[2], proper, sep);
	    marpa_g_sequence_new (g, detail, pc[1], sep, 1, proper);
	    pc += 3;
	    break;
	case MARPA_RC_BRAN:
	    /* byte range - pc [1,2] = start, stop - expand into alternation */
	    for (k = pc[1]; k <= pc[2]; k++) {
		scratch[0] = k;
		marpa_g_rule_new (g, detail, scratch, 1);
	    }
	    pc += 3;
	    break;
	}
    }
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
