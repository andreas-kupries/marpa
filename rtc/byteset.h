/* Runtime for C-engine (RTC). Declarations. (Sets of bytes - max 256)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_BYTESET_H
#define MARPATCL_RTC_BYTESET_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 */

#define MARPATCL_RTC_BSMAX 256

typedef struct marpatcl_rtc_byteset {
    /* NOTE. This structure works without memory initialization
     * Ref: https://core.tcl.tk/akupries/marpa/wiki?name=fast+sparse+integer+sets+in+C
     *
     * Note (%%). While using an `unsigned char` for `dense` would be more
     *            memory efficient the use of Marpa_Symbol_ID allows us to
     *            connect directly to some Marpa data structures (See
     *            marpa_r_terminals_expected()), avoiding a copying step.
     */
    int             n;
    Marpa_Symbol_ID dense  [MARPATCL_RTC_BSMAX]; /* (%%) */
    unsigned char   sparse [MARPATCL_RTC_BSMAX];
} marpatcl_rtc_byteset;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * clear    - empty the set
 * contains - check character (symbol) for presence
 * dense    - return reference to internal `dense` array
 * link     - treat first `n` entries as initialized and cross-link them as proper set
 */

void             marpatcl_rtc_byteset_clear    (marpatcl_rtc_byteset* s);
int              marpatcl_rtc_byteset_contains (marpatcl_rtc_byteset* s, unsigned char c);
Marpa_Symbol_ID* marpatcl_rtc_byteset_dense    (marpatcl_rtc_byteset* s);
void             marpatcl_rtc_byteset_link     (marpatcl_rtc_byteset* s, int n);
int              marpatcl_rtc_byteset_size     (marpatcl_rtc_byteset* s);

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
