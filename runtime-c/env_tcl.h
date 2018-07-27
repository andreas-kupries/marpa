/* Runtime for C-engine (RTC). Declarations. (Tcl Environment)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 */ 
#ifndef MARPATCL_RTC_ENVTCL_H
#define MARPATCL_RTC_ENVTCL_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Notes.
 **
 * An environment header is responsible for providing definitions for the
 * macros used by the RTC to perform memory management, tracing, and
 * assertions.
 **
 * This specific header imports the critcl::cutil'ity headers to satisfy these
 * requirements. This links the RTC to the Tcl runtime and environment as a
 * side-effect.
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <critcl_trace.h>
#include <critcl_assert.h>
/* API
 * - ASSERT        (bool, message)
 * - ASSERT_BOUNDS (index, size)
 * - STOPAFTER     (count)
 */
#include <critcl_alloc.h>
/* API
 * - ALLOC   (type)         -> ptr
 * - NALLOC  (type, n)      -> ptr
 * - REALLOC (ptr, type, n) -> ptr
 * - FREE    (ptr)          -> void
 */

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
