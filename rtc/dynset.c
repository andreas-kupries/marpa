/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Dynset
 */

#include <dynset.h>

#define SZ s->n
#define XL s->sparse
#define DE s->dense

void
marpa_rtc_dynset_cons (marpa_rtc_dynset* s, int capacity)
{
    SZ = 0;
    XL = (Marpa_Symbol_ID*) ckalloc (capacity * sizeof (Marpa_Symbol_ID));
    DE = (Marpa_Symbol_ID*) ckalloc (capacity * sizeof (Marpa_Symbol_ID));
}

void
marpa_rtc_dynset_clear (marpa_rtc_dynset* s)
{
    SZ = 0;
}

int 
marpa_rtc_dynset_contains (marpa_rtc_dynset* s, char c)
{
    return (XL [c] < SZ) && (DE [XL [c]] == c)
}

Marpa_Symbol_ID*
marpa_rtc_dynset_dense (marpa_rtc_dynset* s)
{
    return &DE;
}

void
marpa_rtc_dynset_link (marpa_rtc_dynset* s, int n)
{
    int k;
    SZ = n;
    for (k = 0; k < n; k++) {
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
