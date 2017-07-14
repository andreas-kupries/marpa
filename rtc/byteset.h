/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: byte sets (set of acceptable symbols, max 256)
 */

#ifndef MARPA_RTC_BYTESET_H
#define MARPA_RTC_BYTESET_H

#include <marpa.h>

/*
 * -- dynamic state of the byteset part of an rtc engine --
 */

#define MARPA_RTC_BSMAX 256

typedef struct marpa_rtc_byteset {
    /* NOTE. This structure works without memory initialization
     * Ref: https://core.tcl.tk/akupries/marpa/wiki?name=fast+sparse+integer+sets+in+C
     */
    int             n;
    Marpa_Symbol_ID dense  [MARPA_RTC_BSMAX]; /* (%%) */
    unsigned char   sparse [MARPA_RTC_BSMAX];
} marpa_rtc_byteset;

/* (Ad %%)
 * While using char here would be more memory-efficient the use of
 * Marpa_Symbol_ID allows us to connect directly to some Marpa data structures
 * (recognizer: array of expected terminals), avoiding a copying step/loop.
 */

/*
 * API seen by other parts.
 */

void             marpa_rtc_byteset_clear     (marpa_rtc_byteset* s);
int              marpa_rtc_byteset_contains  (marpa_rtc_byteset* s, unsigned char c);
Marpa_Symbol_ID* marpa_rtc_byteset_dense     (marpa_rtc_byteset* s);
void             marpa_rtc_byteset_link      (marpa_rtc_byteset* s, int n);

/* clear    - empty the set
 * contains - check character (symbol) for presence
 * dense    - return reference to internal `dense` array
 * link     - treat first `n` entries as initialized and cross-link them as proper set
 */


#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
