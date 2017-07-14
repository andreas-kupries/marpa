/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Pre-compiled grammar definition.
 */

#ifndef MARPA_RTC_BYTESET_H
#define MARPA_RTC_GSPEC_H

/*
 * -- string pool --
 */

/* A plain (static const char*) with all strings concatenated.

/*
 * -- symbol definition -- offset into string pool, and length of the name
 */

typedef struct marpa_rtc_string {
    int offset; /* Start of the string in the string pool */
    int length; /* Length of the string */
} marpa_rtc_string;

/*
 * -- grammar definition -- symbols used, rules
 */

typedef struct marpa_rtc_rules {
    marpa_rtc_string* sname;  /* Table of symbol names, string pool */
    int*              symbol; /* Table of references into the pool, one per symbol */
    int               syms;   /* Number of symbols, #elements in `symbol */
    int*              rcode;  /* Bytecode specifying the rules */
    // TODO: Rule names, rule actions //
} marpa_rtc_rules;

#define MARPA_R_PRI (-1) /* priority     -- 2+N arguments: lhs, #rhs, rhs... */
#define MARPA_R_SEQ (-2) /* quantified   -- 5 arguments: lhs, loop, sep, positive, proper */
#define MARPA_R_EOR (-3  /* end of rules -- 1 argument: start symbol */

/*
 * -- parser definition -- l0, g1 sub-grammars, 
 */

typedef struct marpa_rtc_spec {
    int             lexemes;   /* L: number of lexemes in l0 */
    int             discards;  /* D: number of discard symbols in l0 */
    int             l_symbols; /* X: number of internal symbols in l0 */
    /*                          * L+D+X = l0.syms */
    int             g_symbols; /* G: number of symbols in g1. */
    /*                          * G = g1.syms */
    marpa_rtc_rules l0;
    marpa_rtc_rules g1;
} marpa_rtc_spec;

/*
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
 *   symbols. The first set actually are the ACS symbols. This means:
 *
 *   @ lex/dis symbol <-- ACS symbol     + (L+D)
 *   @ ACS symbol     <-- lex/dis symbol - (L+D)
 */

/*
 * No API. The above structures are statically defined, with the definitions
 * created by a generator.
 */

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
