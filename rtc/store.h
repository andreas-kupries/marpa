/* Runtime for C-engine (RTC). Declarations. (Engine: Semantic store)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_STORE_H
#define MARPATCL_RTC_STORE_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <sem_int.h>
#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_store {
    marpatcl_rtc_sva content;
} marpatcl_rtc_store;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init  - initialize store
 * free  - release store state
 * add   - add value to store, return id
 * get   - get value from store, by id
 */

void              marpatcl_rtc_store_init (marpatcl_rtc_p p);
void              marpatcl_rtc_store_free (marpatcl_rtc_p p);
int               marpatcl_rtc_store_add  (marpatcl_rtc_p p, marpatcl_rtc_sv_p sv);
marpatcl_rtc_sv_p marpatcl_rtc_store_get  (marpatcl_rtc_p p, int at);

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
