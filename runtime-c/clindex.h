/* Runtime for C-engine (RTC). Declarations. (Character location indexing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018-present Andreas Kupries
 */

#ifndef MARPATCL_RTC_CLINDEX_H
#define MARPATCL_RTC_CLINDEX_H

#include <rtc.h>
#include <bytestack.h>
#include <stack.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 * - Public structure for character location index
 */

typedef struct marpatcl_rtc_clindex {
    marpatcl_rtc_stack_p     cloc;     // Character locations (run starting points)
    marpatcl_rtc_stack_p     bloc;     // Associated byte locations
    marpatcl_rtc_bytestack_p blen;     // Associated byte lengths for the chars in the run
    int                      max_char; // Highest character location in the input visited
    int                      max_byte; // Associated byte location
    int                      max_blen; // Associated byte length of the character
} marpatcl_rtc_clindex;

/* Compute byte offset B from character offset C
 *
 *	b = bloc[i] + blen[i] * (c - cloc[i]),
 *		where i = max k for cloc[k] < c
 *
 * Compute character offset C from byte offset C
 *
 *	c = cloc[i] + (b - bloc[i]) / blen[i],
 *		where i = max k for bloc[k] < b
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init     - initialize the index
 * release  - release index element
 * update   - update for a character/byte location pair, plus byte length
 * find     - return byte location for character location
 */

void marpatcl_rtc_clindex_init   (marpatcl_rtc_p p);
void marpatcl_rtc_clindex_free   (marpatcl_rtc_p p);
void marpatcl_rtc_clindex_update (marpatcl_rtc_p p, int blen);
int  marpatcl_rtc_clindex_find   (marpatcl_rtc_p p, int cloc);
int  marpatcl_rtc_clindex_find_c (marpatcl_rtc_p p, int bloc);

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
