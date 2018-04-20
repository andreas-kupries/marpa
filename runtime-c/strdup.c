/* Runtime for C-engine (RTC). Implementation. String duplication
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
 *
 * Requirements - Allocation macros via an external environment header.
 */

#include <environment.h>
#include <string.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

char*
marpatcl_rtc_strdup (const char* s)
{
    TRACE_FUNC ("((char*) %p) = '%s'", s, s);

    int   n = 1 + strlen (s); // include the terminator
    char* c = NALLOC (char, n);

    memcpy (c, s, n);

    TRACE_RETURN ("((char*) %p)", c);
}

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
