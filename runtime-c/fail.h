/* Runtime for C-engine (RTC). Declarations. (Engine: Failures)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_FAIL_H
#define MARPATCL_RTC_FAIL_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures
 */

typedef struct marpatcl_rtc_fail {
    int fail; /* boolean */
    const char* origin;
    // v-- TODO: separate structure?!
    // origin        - string
    // l0 at         - LEX.lastloc
    // l0 char       - LEX.lastchar
    // l0 csym       - moot
    // l0 acceptable - GATE.acceptable
    //    acceptsym, acceptmap - moot, build from acceptable
    // g1 acceptable - LEX.acceptable
    // l0 report     - LEX.recce inside
    // l0 stream     - LEX.lexeme
    // l0 latest     - LEX.recce latest-earley-set
    // g1 report     - PAR.recce
} marpatcl_rtc_fail;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * init  - initialize fail
 * free  - release fail state
 * add   - add value to fail, return id
 * get   - get value from fail, by id
 */

void        marpatcl_rtc_fail_init     (marpatcl_rtc_p p);
void        marpatcl_rtc_fail_free     (marpatcl_rtc_p p);
void        marpatcl_rtc_failit        (marpatcl_rtc_p p, const char* origin);
int         marpatcl_rtc_failed        (marpatcl_rtc_p p);
const char* marpatcl_rtc_fail_origin   (marpatcl_rtc_p p);
void        marpatcl_rtc_fail_syscheck (marpatcl_rtc_p p,
					Marpa_Grammar g,
					int res, const char* label);

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
