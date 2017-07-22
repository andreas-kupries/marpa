/* Runtime for C-engine (RTC). Declarations. (Grammar specification)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SPEC_H
#define MARPATCL_RTC_SPEC_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

// stdint.h, cinttypes.h, inttypes.h, types.h
#include <stdint.h>
#include <marpa.h>
#include <sem.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants, and types (mostly structures)
 */

/* Type and space for a single symbol reference/id.
 * uint32_t = 4 byte -- 4G symbols
 * uint16_t = 2 byte -- 64K symbols -- good enough
 *
 * 2 byte is also good enough for the string lengths used in symbol and rule names.
 * TODO: Add checks to export::rtc, that these limits hold.
 */

typedef uint16_t marpatcl_rtc_sym;
typedef uint16_t marpatcl_rtc_size;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * -- String pool
 *
 * No special structures - 2 parallel arrays, lengths and string pointers. A
 * structure with both is 8 or 16 bytes (32/64 system, 4/8 byte pointers) due
 * to 4/8 alignment and padding. The two arrays eliminate the padding.  That
 * said, the pointers to the arrays are captured in a structure.
 */

typedef struct marpatcl_rtc_string {
    marpatcl_rtc_size*  length; /* Array of string lengths */
    marpatcl_rtc_size*  offset; /* Array of string offset */
    const char*  string; /* String data */
} marpatcl_rtc_string;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * -- static vectors of symbol references
 */

typedef struct marpatcl_rtc_symvec {
    marpatcl_rtc_size size; /* Length of the vector */
    marpatcl_rtc_sym* data; /* Vector content */
} marpatcl_rtc_symvec;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * -- grammar definition -- symbols used, rules (as a form of bytecode)
 */

typedef struct marpatcl_rtc_rules {
    marpatcl_rtc_string* sname;   /* Table of strings, shared pool */
    marpatcl_rtc_symvec  symbols; /* Table of symbol(name)s. References into string pool */
    marpatcl_rtc_symvec  rules;   /* Table of rule(name)s. References into string pool */
    /*                          * Optional. Empty = (0, NULL) */
    marpatcl_rtc_sym*        rcode;   /* Bytecode specifying the rules */
} marpatcl_rtc_rules;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Rule encoding ... Virtual machine (Short codes)
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
 * BRAN		lhs, start, stop	1000.llll.llll.llll	Byte range from start to stop, inclusive
 *
 * S/P					0001.ssssssssssssss
 *					0000.ssssssssssssss
 *
 * BRAN: arguments are in 0..255 => bytes, both can be placed into a single marpatcl_rtc_sym
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

#define MARPA_SYSZ  (sizeof(marpatcl_rtc_sym)*8)
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

#define MARPA_RCMD_BOXR(a,b)      (((a) << 8)|(b))
#define MARPA_RCMD_UNBXR(x, a, b) { a = (x) >> 8 ; b = (x) & 255 ; }

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * -- overarching parser definition --
 */

typedef struct marpatcl_rtc_spec {
    marpatcl_rtc_size   lexemes;   /* L: number of lexemes in l0 */
    marpatcl_rtc_size   discards;  /* D: number of discard symbols in l0 */
    marpatcl_rtc_size   l_symbols; /* X: number of symbols in l0 */
    /*                              * X = l0.syms */
    marpatcl_rtc_size   g_symbols; /* G: number of symbols in g1. */
    /*                              * G = g1.syms */
    marpatcl_rtc_symvec always;    /* A: number of symbols always active */
    /*                              * A = D + |x; x is lexeme, x is LTM| */
    marpatcl_rtc_rules* l0;
    marpatcl_rtc_rules* g1;
    marpatcl_rtc_symvec l0semantic; /* Key codes for creation of L0 semantic values */
    marpatcl_rtc_symvec g1semantic; /* Key codes for creation of G1 semantic values */
} marpatcl_rtc_spec;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * G1 semantic coding -- ALTERNATE -- action handler knows coding, 2 predefined handlers
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

#define MARPA_SV_NOP       ((marpatcl_rtc_sym) (-1)) /* Do nothing */
#define MARPA_SV_START     ((marpatcl_rtc_sym) (0))  /* offset of lexeme start in input */
#define MARPA_SV_LENGTH    ((marpatcl_rtc_sym) (1))  /* length of lexeme in input */
#define MARPA_SV_G1START   ((marpatcl_rtc_sym) (2))  /* start of lexeme in G1 (token offset) */
#define MARPA_SV_G1LENGTH  ((marpatcl_rtc_sym) (3))  /* length of lexeme in G1 */
#define MARPA_SV_LHS_NAME  ((marpatcl_rtc_sym) (4))  /* Name of the lhs in the reduced rule, lexeme */
#define MARPA_SV_LHS_ID    ((marpatcl_rtc_sym) (5))  /* Id of the lhs in the reduced rule */
#define MARPA_SV_RULE_NAME ((marpatcl_rtc_sym) (6))  /* Name of the reduced rule */
#define MARPA_SV_RULE_ID   ((marpatcl_rtc_sym) (7))  /* Id of the reduced rule */
#define MARPA_SV_VALUE     ((marpatcl_rtc_sym) (8))  /* Value of the lexeme, value of the children */
#define MARPA_SV_CMD       ((marpatcl_rtc_sym) (9))  /* User-specified semantic action */

/*
 * Tags for G1 semantic coding formats
 */

#define MARPA_S_SINGLE (-1)
#define MARPA_S_PER    (-2)

/* SV handler for user actions. Input value is a vector of children values.
 * Result is value from the action.
 */
typedef marpatcl_rtc_semvalue_p (*marpatcl_rtc_sv_cmd) (int action, const char* aname,
							marpatcl_rtc_semvalue_p children);
/* TODO: Needs access to context:
 * - active marpa step instruction
 * - dynamic parser state (implies: static grammar structures)
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Notes:
 * - MARPA_SV_CMD : 2 arguments, string pool reference (action name)
 *                           and action code, counted from 0
 *   Dispatch function decides which to use.
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
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
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 *
 * setup - Use the static structures to fill an active Marpa grammar
 */

void marpatcl_rtc_spec_setup (Marpa_Grammar g, marpatcl_rtc_rules* s);
		     
#endif

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
