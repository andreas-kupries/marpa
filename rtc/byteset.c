/* Runtime for C-engine (RTC). Implementation. (Sets of bytes - max 256)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <byteset.h>
#include <critcl_assert.h>

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
    SZ = 0;
}

int 
marpatcl_rtc_byteset_contains (marpatcl_rtc_byteset* s, unsigned char c)
{
    // sizeof (unsigned char) == 8 --> max(c) = 255, no assertion required
    return (XL [c] < SZ) && (DE [XL [c]] == c);
}

Marpatcl_Symbol_ID*
marpatcl_rtc_byteset_dense (marpatcl_rtc_byteset* s)
{
    return DE;
}

void
marpatcl_rtc_byteset_link (marpatcl_rtc_byteset* s, int n)
{
    int k;
    SZ = n;
    for (k = 0; k < n; k++) {
	ASSERT (DE [k] < MARPATCL_RTC_BSMAX, "Symbol out of byte range (> 255)");
	XL [DE [k]] = k;
    }
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
