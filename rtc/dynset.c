/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Dynset
 */

#include <dynset.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

#define SZ  (s->n)
#define XL  (s->sparse)
#define DE  (s->dense)
#define CAP (s->capacity)

/*
*/

void
marpa_rtc_dynset_cons (marpa_rtc_dynset* s, int capacity)
{
    SZ  = 0;
    CAP = capacity;
    XL  = NALLOC (Marpa_Symbol_ID, capacity);
    DE  = NALLOC (Marpa_Symbol_ID, capacity);
}

void
marpa_rtc_dynset_clear (marpa_rtc_dynset* s)
{
    SZ = 0;
}

void
marpa_rtc_dynset_release (marpa_rtc_dynset* s)
{
    FREE (XL); XL = 0;
    FREE (DE); DE = 0;
    SZ = CAP = 0;
}

int 
marpa_rtc_dynset_contains (marpa_rtc_dynset* s, Marpa_Symbol_ID c)
{
    ASSERT (c < CAP, "Symbol beyond set capacity");
    return (XL [c] < SZ) && (DE [XL [c]] == c);
}

int 
marpa_rtc_dynset_size (marpa_rtc_dynset* s)
{
    return SZ;
}

Marpa_Symbol_ID*
marpa_rtc_dynset_dense (marpa_rtc_dynset* s)
{
    return DE;
}

void
marpa_rtc_dynset_link (marpa_rtc_dynset* s, int n)
{
    int k;
    SZ = n;
    for (k = 0; k < n; k++) {
	ASSERT (DE [k] < CAP, "Symbol beyond set capacity");
	XL [DE [k]] = k;
    }
}

void
marpa_rtc_dynset_include (marpa_rtc_dynset* s, int n, Marpa_Symbol_ID* v)
{
    int k;
    Marpa_Symbol_ID x;
    for (k = 0; k < n; k++) {
	x = v[k];
	ASSERT (x < CAP, "Symbol beyond set capacity");
	/* Skip if already a member */
	if ((XL [x] < SZ) && (DE [XL [x]] == x)) continue;
	DE [SZ] = x;
	XL [x] = SZ;
	SZ ++;
    }
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
