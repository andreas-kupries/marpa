/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Pre-compiled grammar definition.
 */

#ifndef MARPA_RTC_SPEC_H
#define MARPA_RTC_SPEC_H

// stdint.h, cinttypes.h, inttypes.h, types.h

#include <stdint.h>
#include <marpa.h>
#include <sem.h>

/* Type and space for a single symbol reference/id.
 * uint32_t = 4 byte -- 4G symbols
 * uint16_t = 2 byte -- 64K symbols -- good enough
 *
 * 2 byte is also good enough for the string lengths used in symbol and rule names.
 * TODO: Add checks to export::rtc, that these limits hold.
 */

typedef uint16_t marpa_sym;
typedef uint16_t marpa_size;

/*
 * -- string pool --
 */

typedef struct marpa_rtc_string {
    marpa_size  length; /* Length of the string */
    const char* string; /* And the string data itself */
} marpa_rtc_string;

/*
 * -- static vectors of symbol references --
 */

typedef struct marpa_rtc_symvec {
    marpa_size size; /* Length of the vector */
    marpa_sym* data; /* Vector content */
} marpa_rtc_symvec;

/*
 * -- grammar definition -- symbols used, rules
 */

typedef struct marpa_rtc_rules {
    marpa_rtc_string* sname;   /* Table of strings, shared pool */
    marpa_rtc_symvec  symbols; /* Table of symbol(name)s. References into string pool */
    marpa_rtc_symvec  rules;   /* Table of rule(name)s. References into string pool */
    /*                          * Optional. Empty = (0, NULL) */
    marpa_sym*        rcode;   /* Bytecode specifying the rules */
} marpa_rtc_rules;

/* Rule encoding ... Virtual machine (Short codes)
 * Symbols are coded in 12bit -- 4096 maximum
 * Sizes ditto.
 *
 * Command	Arguments		Coding			Notes
 * SETUP	scratch size		0000.nnnn.nnnn.nnnn	First instruction, allocate scratch
 * DONE		start symbol		0001.ssss.ssss.ssss	Last instruction, start symbol, free scratch
 * PRIO_F	lhs, #rhs, rhs[...]	0010.nnnn.nnnn.nnnn	Priority rule, full information
 * PRIO_N	#rhs, rhs[...]		0011.nnnn.nnnn.nnnn	Priority rule, short, use last LHS
 * QUANT_NULL	lhs, rhs		0100.llll.llll.llll	Quantified rule 0+
 * QUANT_PLUS	lhs, rhs		0101.llll.llll.llll	Quantified rule 1+
 * QUANT_N_SEP	lhs, rhs, sep, proper	0110.llll.llll.llll	Quantified rule 0+ with separator/proper
 * QUANT_P_SEP	lhs, rhs, sep, proper	0111.llll.llll.llll	Quantified rule 1+ with separator/proper
 * BRAN		lhs, stat, stop		1000.llll.llll.llll	Byte range from start to stop, inclusive
 *
 * S/P					0001.ssssssssssssss
 *					0000.ssssssssssssss
 */

#define MARPA_RC_SETUP (0)
#define MARPA_RC_DONE  (1)
#define MARPA_RC_PRIO  (2)
#define MARPA_RC_PRIS  (3)
#define MARPA_RC_QUN   (4)
#define MARPA_RC_QUP   (5)
#define MARPA_RC_QUNS  (6)
#define MARPA_RC_QUPS  (7)
#define MARPA_RC_BRAN  (8)

#define MARPA_SYSZ  (sizeof(marpa_sym)*8)
#define MARPA_SYTOP ((~0) << (MARPA_SYSZ-4))
#define MARPA_SYLOW (~MARPA_SYTOP) 

#define MARPA_CMD(t,v)   (((t & 15) << (MARPA_SYSZ-4)) | ((v) & MARPA_SYLOW))

#define MARPA_RCMD_SETUP(n) (MARPA_CMD (MARPA_RC_SETUP, n))
#define MARPA_RCMD_DONE(n)  (MARPA_CMD (MARPA_RC_DONE, n))
#define MARPA_RCMD_PRIO(n)  (MARPA_CMD (MARPA_RC_PRIO, n))
#define MARPA_RCMD_PRIS(n)  (MARPA_CMD (MARPA_RC_PRIS, n))
#define MARPA_RCMD_QUN(s)   (MARPA_CMD (MARPA_RC_QUN, s))
#define MARPA_RCMD_QUP(s)   (MARPA_CMD (MARPA_RC_QUP, s))
#define MARPA_RCMD_QUNS(s)  (MARPA_CMD (MARPA_RC_QUNS, s))
#define MARPA_RCMD_QUPS(s)  (MARPA_CMD (MARPA_RC_QUPS, s))
#define MARPA_RCMD_BRAN(s)  (MARPA_CMD (MARPA_RC_BRAN, s))

#define MARPA_RCMD_SEP(s)  (MARPA_CMD (0, s))
#define MARPA_RCMD_SEPP(s) (MARPA_CMD (1, s))

#define MARPA_RCMD_UNBOX(x, tv, vv) { tv = (x) >> (MARPA_SYSZ-4) ; vv = (x) & MARPA_SYLOW ; }


/*
 * -- parser definition -- l0, g1 sub-grammars, 
 */

typedef struct marpa_rtc_spec {
    marpa_size       lexemes;   /* L: number of lexemes in l0 */
    marpa_size       discards;  /* D: number of discard symbols in l0 */
    marpa_size       l_symbols; /* X: number of symbols in l0 */
    /*                           * X = l0.syms */
    marpa_size       g_symbols; /* G: number of symbols in g1. */
    /*                           * G = g1.syms */
    marpa_rtc_symvec always;    /* A: number of symbols always active */
    /*                           * A = D + |x; x is lexeme, x is LTM| */
    marpa_rtc_rules* l0;
    marpa_rtc_rules* g1;
    marpa_rtc_symvec l0semantic; /* Key codes for creation of L0 semantic values */
    marpa_rtc_symvec g1semantic; /* Key codes for creation of G1 semantic values */
} marpa_rtc_spec;

/* G1 semantic coding -- ALTERNATE -- action handler knows coding, 2 predefined handlers
 * [0] == 0 global
 *     == 1 per-rule
 *     == >1 per-rule, fixed size (N-1 elements per rule)
 * global   [1...]       : key sequence
 * per-rule [1..#rule]   : references to key sequences
 *          [#rule+1...] : distinct key sequences, referenced from before.
 *                         First element in each KS is length.
 *
 * The `global` flag allows more compact coding, eliminating the per-rule
 * table of references, all identical.
 */

#define MARPA_SV_NOP       ((marpa_sym) (-1)) /* Do nothing */
#define MARPA_SV_START     ((marpa_sym) (0))  /* offset of lexeme start in input */
#define MARPA_SV_LENGTH    ((marpa_sym) (1))  /* length of lexeme in input */
#define MARPA_SV_G1START   ((marpa_sym) (2))  /* start of lexeme in G1 (token offset) */
#define MARPA_SV_G1LENGTH  ((marpa_sym) (3))  /* length of lexeme in G1 */
#define MARPA_SV_LHS_NAME  ((marpa_sym) (4))  /* Name of the lhs in the reduced rule, lexeme */
#define MARPA_SV_LHS_ID    ((marpa_sym) (5))  /* Id of the lhs in the reduced rule */
#define MARPA_SV_RULE_ID   ((marpa_sym) (6))  /* Id of the reduced rule */
#define MARPA_SV_VALUE     ((marpa_sym) (7))  /* Value of the lexeme, value of the children */
#define MARPA_SV_CMD       ((marpa_sym) (8))  /* User-specified semantic action */

/*
 * Tags for G1 semantic coding formats
 */

#define MARPA_S_SINGLE (-1)
#define MARPA_S_PER    (-2)

/* SV handler for user actions. Input value is a vector of children values.
 * Result is value from the action.
 */
typedef marpa_rtc_semvalue_p (*marpa_rtc_sv_cmd) (int action, const char* aname,
						  marpa_rtc_semvalue_p children);
/* TODO: Needs access to context:
 * - active marpa step instruction
 * - dynamic parser state (implies: static grammar structures)
 */

/* Notes:
 * - MARPA_SV_CMD : 2 arguments, string pool reference (action name)
 *                           and action code, counted from 0
 *   Dispatch function decides which to use.
 */

/*
 * See also export/rtc.tcl -- Keep In Sync
 *
 * -- symbol allocations in l0           -- in g1
 * --   0     ... 255         characters
 * -- 256     ... 256+L-1     lexemes    -- 0   ... L-1 terminals == lexemes
 * -- 256+L   ... 256+L+D-1   discards   -- L           start symbol
 * -- 256+L+D ... 256+L+D+X-1 other      -- L+1 ... G-1 other
 *
 * lexeme <-> terminal mapping   i.e. lexer vs parser
 *
 *   @ lexeme   <-- terminal + 256
 *   @ terminal <-- lexeme   - 256
 *
 * Further:
 *   In L0 the first L+D internal symbols are the actual lexeme and discard
 *   symbols. The first set actually are their ACS symbols. This means:
 *
 *   @ lex/dis symbol <-- ACS symbol     + (L+D)
 *   @ ACS symbol     <-- lex/dis symbol - (L+D)
 */

/*
 * API. Fill a grammar from the static code.
 */

void marpa_rtc_spec_setup (Marpa_Grammar g, marpa_rtc_rules* s);
		     
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
