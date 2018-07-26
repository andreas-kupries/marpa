/* Runtime for C-engine (RTC). Declarations. (Character location indexing)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
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
