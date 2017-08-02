/* Runtime for C-engine (RTC). Implementation. (Sets of bytes - max 256)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <byteset.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

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
    TRACE_ENTER ("marpatcl_rtc_byteset_clear");
    TRACE (("byteset %p", s));
    SZ = 0;
    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_byteset_contains (marpatcl_rtc_byteset* s, unsigned char c)
{
    // sizeof (unsigned char) == 8 --> max(c) = 255, no assertion required
    TRACE_ENTER ("marpatcl_rtc_byteset_contains");
    TRACE (("byteset %p testing %d", s, c));
    ASSERT (c < MARPATCL_RTC_BSMAX, "Symbol beyond set capacity");
    TRACE_RETURN ("%d", (XL [c] < SZ) && (DE [XL [c]] == c));
}

Marpa_Symbol_ID*
marpatcl_rtc_byteset_dense (marpatcl_rtc_byteset* s)
{
    TRACE_ENTER ("marpatcl_rtc_byteset_dense");
    TRACE (("byteset %p", s));
    TRACE_RETURN ("%p", DE);
}

void
marpatcl_rtc_byteset_link (marpatcl_rtc_byteset* s, int n)
{
    int k;
    TRACE_ENTER ("marpatcl_rtc_byteset_link");
    TRACE (("byteset %p, link %d", s, n));
    ASSERT_BOUNDS (n, MARPATCL_RTC_BSMAX);
    SZ = n;
    for (k = 0; k < n; k++) {
	TRACE (("byteset %p link [%d,%d] %d", s, SZ, k, DE[k]));
	ASSERT (DE [k] < MARPATCL_RTC_BSMAX, "Symbol out of byte range (> 255)");
	XL [DE [k]] = k;
    }
    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_byteset_size (marpatcl_rtc_byteset* s)
{
    TRACE_ENTER ("marpatcl_rtc_byteset_size");
    TRACE (("byteset %p", s));
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
