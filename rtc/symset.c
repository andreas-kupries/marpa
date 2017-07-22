/* Runtime for C-engine (RTC). Implementation. (Sets of marpa-symbols, dynamic)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <symset.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define SZ  (s->n)
#define XL  (s->sparse)
#define DE  (s->dense)
#define CAP (s->capacity)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

void
marpatcl_rtc_symset_init (marpatcl_rtc_symset* s, int capacity)
{
    SZ  = 0;
    CAP = capacity;
    XL  = NALLOC (marpatcl_rtc_sym, capacity);
    DE  = NALLOC (Marpa_Symbol_ID,  capacity);
}

void
marpatcl_rtc_symset_free (marpatcl_rtc_symset* s)
{
    FREE (XL); XL = 0;
    FREE (DE); DE = 0;
    SZ = CAP = 0;
}

void
marpatcl_rtc_symset_clear (marpatcl_rtc_symset* s)
{
    SZ = 0;
}

int 
marpatcl_rtc_symset_contains (marpatcl_rtc_symset* s, Marpa_Symbol_ID c)
{
    ASSERT (c < CAP, "Symbol beyond set capacity");
    return (XL [c] < SZ) && (DE [XL [c]] == c);
}

int 
marpatcl_rtc_symset_size (marpatcl_rtc_symset* s)
{
    return SZ;
}

Marpa_Symbol_ID*
marpatcl_rtc_symset_dense (marpatcl_rtc_symset* s)
{
    return DE;
}

void
marpatcl_rtc_symset_link (marpatcl_rtc_symset* s, int n)
{
    int k;
    SZ = n;
    for (k = 0; k < n; k++) {
	ASSERT (DE [k] < CAP, "Symbol beyond set capacity");
	XL [DE [k]] = k;
    }
}

void
marpatcl_rtc_symset_include (marpatcl_rtc_symset* s, int c, marpatcl_rtc_sym* v)
{
    int k;
    Marpa_Symbol_ID x;
    for (k = 0; k < c; k++) {
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
 * - - -- --- ----- -------- ------------- ---------------------
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
