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
#include <stack.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants, and types (mostly structures)
 *
 * Type and space for a single symbol reference/id.
 * uint32_t = 4 byte -- 4G symbols
 * uint16_t = 2 byte -- 64K symbols -- good enough
 *
 * 2 byte (64K) should be good enough for the string lengths used in symbol
 * and rule names. Number of symbols are limited to 12 bits, i.e. 4K.
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
    marpatcl_rtc_symvec  lhs;     /* Table of rule lhs ids. */
    marpatcl_rtc_sym*    rcode;   /* Bytecode specifying the rules */
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

#define MARPATCL_RC_SETUP (0)
#define MARPATCL_RC_DONE  (1)
#define MARPATCL_RC_PRIO  (2)
#define MARPATCL_RC_PRIS  (3)
#define MARPATCL_RC_QUN   (4)
#define MARPATCL_RC_QUP   (5)
#define MARPATCL_RC_QUNS  (6)
#define MARPATCL_RC_QUPS  (7)
#define MARPATCL_RC_BRAN  (8)

#define MARPATCL_SYSZ  (sizeof(marpatcl_rtc_sym)*8)
#define MARPATCL_SYTOP ((~0) << (MARPATCL_SYSZ-4))
#define MARPATCL_SYLOW (~MARPATCL_SYTOP) 

#define MARPATCL_CMD(t,v)   (((t & 15) << (MARPATCL_SYSZ-4)) | ((v) & MARPATCL_SYLOW))

#define MARPATCL_RCMD_SETUP(n) (MARPATCL_CMD (MARPATCL_RC_SETUP, n))
#define MARPATCL_RCMD_DONE(n)  (MARPATCL_CMD (MARPATCL_RC_DONE, n))
#define MARPATCL_RCMD_PRIO(n)  (MARPATCL_CMD (MARPATCL_RC_PRIO, n))
#define MARPATCL_RCMD_PRIS(n)  (MARPATCL_CMD (MARPATCL_RC_PRIS, n))
#define MARPATCL_RCMD_QUN(s)   (MARPATCL_CMD (MARPATCL_RC_QUN, s))
#define MARPATCL_RCMD_QUP(s)   (MARPATCL_CMD (MARPATCL_RC_QUP, s))
#define MARPATCL_RCMD_QUNS(s)  (MARPATCL_CMD (MARPATCL_RC_QUNS, s))
#define MARPATCL_RCMD_QUPS(s)  (MARPATCL_CMD (MARPATCL_RC_QUPS, s))
#define MARPATCL_RCMD_BRAN(s)  (MARPATCL_CMD (MARPATCL_RC_BRAN, s))

#define MARPATCL_RCMD_SEP(s)  (MARPATCL_CMD (0, s))
#define MARPATCL_RCMD_SEPP(s) (MARPATCL_CMD (1, s))

#define MARPATCL_RCMD_UNBOX(x, tv, vv) { tv = (x) >> (MARPATCL_SYSZ-4) ; vv = (x) & MARPATCL_SYLOW ; }

#define MARPATCL_RCMD_BOXR(a,b)      (((a) << 8)|(b))
#define MARPATCL_RCMD_UNBXR(x, a, b) { a = (x) >> 8 ; b = (x) & 255 ; }

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
    marpatcl_rtc_symvec l0semantic; /* Key codes for creation of L0 SVs */
    marpatcl_rtc_symvec g1semantic; /* Key codes for creation of G1 SVs */
    marpatcl_rtc_symvec g1mask;     /* Per-rule masking for creation of G1 SVs */
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

//#define MARPATCL_SV_NOP       ((marpatcl_rtc_sym) (-1)) /* Do nothing */
#define MARPATCL_SV_START     ((marpatcl_rtc_sym) (0))  /* start in input, char/byte offset */
#define MARPATCL_SV_END       ((marpatcl_rtc_sym) (1))  /* end in input, char/byte offset */
#define MARPATCL_SV_LENGTH    ((marpatcl_rtc_sym) (2))  /* length in input, char/byte delta */
#define MARPATCL_SV_G1START   ((marpatcl_rtc_sym) (3))  /* start in input, g1 locations */
#define MARPATCL_SV_G1END     ((marpatcl_rtc_sym) (4))  /* end in input, g1 locations */
#define MARPATCL_SV_G1LENGTH  ((marpatcl_rtc_sym) (5))  /* length in input, G1 location delta */
#define MARPATCL_SV_LHS_NAME  ((marpatcl_rtc_sym) (6))  /* Name of the lhs in the reduced rule, lexeme symbol name */
#define MARPATCL_SV_LHS_ID    ((marpatcl_rtc_sym) (7))  /* Id of the lhs symbol in the reduced rule */
#define MARPATCL_SV_RULE_NAME ((marpatcl_rtc_sym) (8))  /* Name of the reduced rule */
#define MARPATCL_SV_RULE_ID   ((marpatcl_rtc_sym) (9))  /* Id of the reduced rule */
#define MARPATCL_SV_VALUE     ((marpatcl_rtc_sym) (10)) /* Value of the lexeme, vector of the children */
#define MARPATCL_SV_CMD       ((marpatcl_rtc_sym) (11)) /* User-specified semantic action */

/*
 * Tags for G1 semantic coding formats
 */

#define MARPATCL_S_SINGLE (0) /* Single semantic, mask, rule-independent */
#define MARPATCL_S_PER    (1) /* Per-rule semantic, mask information */

/* SV handler for user actions. Input value is a vector of children values.
 * Result is value from the action.
 */
typedef marpatcl_rtc_sv_p (*marpatcl_rtc_sv_cmd) (int action, const char* aname,
						  marpatcl_rtc_sv_p children);
/*
 * TODO: G1 semantic handler needs access to more context:
 * TODO: - active marpa step instruction
 * TODO: - dynamic parser state (implies: static grammar structures)
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Notes:
 * - MARPATCL_SV_CMD : 2 arguments, string pool reference (action name)
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

marpatcl_rtc_stack_p marpatcl_rtc_spec_setup_rd (marpatcl_rtc_rules* s);
marpatcl_rtc_stack_p marpatcl_rtc_spec_setup    (Marpa_Grammar g, marpatcl_rtc_rules* s, int rd);
const char*          marpatcl_rtc_spec_symname  (marpatcl_rtc_rules* g,  marpatcl_rtc_sym id, int* len);
const char*          marpatcl_rtc_spec_rulename (marpatcl_rtc_rules* g,  marpatcl_rtc_sym id, int* len);
const char*          marpatcl_rtc_spec_string   (marpatcl_rtc_string* p, marpatcl_rtc_sym id, int* len);
marpatcl_rtc_sym*    marpatcl_rtc_spec_g1decode (marpatcl_rtc_symvec* coding, marpatcl_rtc_sym rule, int* len);
marpatcl_rtc_sym     marpatcl_rtc_spec_g1map    (marpatcl_rtc_symvec* map, marpatcl_rtc_sym id);

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
