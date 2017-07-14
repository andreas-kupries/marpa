/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Byteset
 */

#include <byteset.h>
#include <critcl_assert.h>

#define SZ (s->n)
#define XL (s->sparse)
#define DE (s->dense)

void
marpa_rtc_byteset_clear (marpa_rtc_byteset* s)
{
    SZ = 0;
}

int 
marpa_rtc_byteset_contains (marpa_rtc_byteset* s, unsigned char c)
{
    // sizeof (unsigned char) == 8 --> max(c) = 255, no assertion required
    return (XL [c] < SZ) && (DE [XL [c]] == c);
}

Marpa_Symbol_ID*
marpa_rtc_byteset_dense (marpa_rtc_byteset* s)
{
    return DE;
}

void
marpa_rtc_byteset_link (marpa_rtc_byteset* s, int n)
{
    int k;
    SZ = n;
    for (k = 0; k < n; k++) {
	ASSERT (DE [k] < MARPA_RTC_BSMAX, "Symbol out of byte range (> 255)");
	XL [DE [k]] = k;
    }
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
