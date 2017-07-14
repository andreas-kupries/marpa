/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: dyn sets (set of acceptable symbols, dynamically allocated)
 */

#ifndef MARPA_RTC_DYNSET_H
#define MARPA_RTC_DYNSET_H

#include <marpa.h>

/*
 * -- dynamic state of the dynset part of an rtc engine --
 */

typedef struct marpa_rtc_dynset {
  /* NOTE. This structure works without memory initialization
   * Ref: https://core.tcl.tk/akupries/marpa/wiki?name=fast+sparse+integer+sets+in+C
   */
    int              n;
    int              capacity;
    Marpa_Symbol_ID* dense;
    Marpa_Symbol_ID* sparse;
} marpa_rtc_dynset;

/*
 * API seen by other parts.
 */

void             marpa_rtc_dynset_cons      (marpa_rtc_dynset* s, int capacity);
void             marpa_rtc_dynset_release   (marpa_rtc_dynset* s);
void             marpa_rtc_dynset_clear     (marpa_rtc_dynset* s);
int              marpa_rtc_dynset_contains  (marpa_rtc_dynset* s, Marpa_Symbol_ID c);
int              marpa_rtc_dynset_size      (marpa_rtc_dynset* s);
Marpa_Symbol_ID* marpa_rtc_dynset_dense     (marpa_rtc_dynset* s);
void             marpa_rtc_dynset_link      (marpa_rtc_dynset* s, int n);
void             marpa_rtc_dynset_include   (marpa_rtc_dynset* s, int n, Marpa_Symbol_ID* v);

/* cons     - construct set with maximal capacity
 * clear    - empty the set
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
