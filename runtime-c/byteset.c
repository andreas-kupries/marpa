/* Runtime for C-engine (RTC). Implementation. (Sets of bytes - max 256)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements - Note, assertions and tracing via an external environment header.
 */

#include <environment.h>
#include <byteset.h>

TRACE_OFF;
TRACE_TAG_OFF (details);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define SZ (s->n)
#define XL (s->sparse)  /* XL = cross-link, which sparse does */
#define DE (s->dense)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_byteset_clear (marpatcl_rtc_byteset* s)
{
    TRACE_FUNC ("((byteset*) %p)", s);

    SZ = 0;

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_byteset_contains (marpatcl_rtc_byteset* s, unsigned char c)
{
    // sizeof (unsigned char) == 8 --> max(c) = 255, no assertion required
    TRACE_FUNC ("((byteset*) %p, byte %d)", s, c);
    ASSERT (c < MARPATCL_RTC_BSMAX, "Symbol beyond set capacity");
    TRACE_RETURN ("%d", (XL [c] < SZ) && (DE [XL [c]] == c));
}

Marpa_Symbol_ID*
marpatcl_rtc_byteset_dense (marpatcl_rtc_byteset* s)
{
    TRACE_FUNC ("((byteset*) %p)", s);
    TRACE_RETURN ("%p", DE);
}

void
marpatcl_rtc_byteset_link (marpatcl_rtc_byteset* s, int n)
{
    int k;
    TRACE_FUNC ("((byteset*) %p, n %d)", s, n);
    ASSERT (n, "Size underflow");
    ASSERT (n <= MARPATCL_RTC_BSMAX, "Size beyond capacity");

    SZ = n;
    for (k = 0; k < n; k++) {
	TRACE_TAG (details, "(byteset*) %p, link [%d,%d] %d", s, SZ, k, DE[k]);
	ASSERT (DE [k] < MARPATCL_RTC_BSMAX, "Symbol out of byte range (> 255)");
	XL [DE [k]] = k;
    }

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_byteset_size (marpatcl_rtc_byteset* s)
{
    TRACE_FUNC ("((byteset*) %p)", s);
    TRACE_RETURN ("%d", SZ);
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