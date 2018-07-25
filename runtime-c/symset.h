/* Runtime for C-engine (RTC). Declarations. (Sets of marpa-symbols, dynamic)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SYMSET_H
#define MARPATCL_RTC_SYMSET_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <spec.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 */

typedef struct marpatcl_rtc_symset {
    /* NOTE. This structure works without memory initialization
     * Ref: https://core.tcl.tk/akupries/marpa/wiki?name=fast+sparse+integer+sets+in+C
     *
     * Note (%%). While using a `marpatcl_rtc_sym` for `dense` would be more memory
     *            efficient the use of Marpa_Symbol_ID allows us to connect
     *            directly to some Marpa data structures (See
     *            marpa_r_terminals_expected()), avoiding a copying step.
     */
    int               n;
    int               capacity;
    Marpa_Symbol_ID*  dense;    /* (%%) */
    marpatcl_rtc_sym* sparse;
} marpatcl_rtc_symset;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init     - initialize set for a specific capacity
 * release  - free the set contents
 * clear    - empty the set
 * contains - check character (symbol) for presence
 * dense    - return reference to internal `dense` array
 * link     - treat first `n` entries as initialized and cross-link them as proper set
 * include  - add elements to the set, from a vector
 */

void             marpatcl_rtc_symset_init     (marpatcl_rtc_symset* s, int capacity);
void             marpatcl_rtc_symset_free     (marpatcl_rtc_symset* s);
void             marpatcl_rtc_symset_clear    (marpatcl_rtc_symset* s);
int              marpatcl_rtc_symset_contains (marpatcl_rtc_symset* s, Marpa_Symbol_ID c);
int              marpatcl_rtc_symset_size     (marpatcl_rtc_symset* s);
Marpa_Symbol_ID* marpatcl_rtc_symset_dense    (marpatcl_rtc_symset* s);
void             marpatcl_rtc_symset_link     (marpatcl_rtc_symset* s, int n);
void             marpatcl_rtc_symset_include  (marpatcl_rtc_symset* s,
					       int c, marpatcl_rtc_sym* v);
void             marpatcl_rtc_symset_add      (marpatcl_rtc_symset* s,
					       marpatcl_rtc_sym     v);

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
