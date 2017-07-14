/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Grammar specification
 */

#include <spec.h>

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
    int k;
    int* pc;
    for (k=0; k < s->syms; k++) {
        marpa_g_symbol_new (g);
    }

    /* Mini bytecode engine to decode and enter the rules */
    pc = s->rcode;
    while (1) {
	switch (*pc) {
	case MARPA_R_PRI:
	    /* priority -- pc [1...] = (lhs, #rhs, rhs ...) */
	    marpa_g_rule_new (g, pc[1], pc+3, pc[2]);
	    pc += 2 + pc[2];
	    break;
	case MARPA_R_SEQ:
	    /* quantified -- pc [1...5] = (lhs, rhs, sep, min, flags) */
	    marpa_g_sequence_new (g, pc[1], pc[2], pc[3], pc[4], pc[5]);
	    pc += 6;
	    break;
	case MARPA_R_EOR:
	    marpa_g_start_symbol_set (g, pc[1]);
	    /* end of rules */
	    return;
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
