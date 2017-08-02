/* Runtime for C-engine (RTC). Implementation. (Sets of marpa-symbols, dynamic)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <symset.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF

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
    TRACE_ENTER ("marpatcl_rtc_symset_init");
    TRACE ("symset %p capacity %d", s, capacity);
    SZ  = 0;
    CAP = capacity;
    XL  = NALLOC (marpatcl_rtc_sym, capacity);
    DE  = NALLOC (Marpa_Symbol_ID,  capacity);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_free (marpatcl_rtc_symset* s)
{
    TRACE_ENTER ("marpatcl_rtc_symset_free");
    TRACE ("symset %p", s);
    FREE (XL); XL = 0;
    FREE (DE); DE = 0;
    SZ = CAP = 0;
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_clear (marpatcl_rtc_symset* s)
{
    TRACE_ENTER ("marpatcl_rtc_symset_clear");
    TRACE ("symset %p", s);
    SZ = 0;
    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_symset_contains (marpatcl_rtc_symset* s, Marpa_Symbol_ID c)
{
    TRACE_ENTER ("marpatcl_rtc_symset_contains");
    TRACE ("symset %p testing %d", s, c);
    ASSERT (c < CAP, "Symbol beyond set capacity");
    TRACE_RETURN ("%d", (XL [c] < SZ) && (DE [XL [c]] == c));
}

int 
marpatcl_rtc_symset_size (marpatcl_rtc_symset* s)
{
    TRACE_ENTER ("marpatcl_rtc_symset_size");
    TRACE ("symset %p", s);
    TRACE_RETURN ("%d", SZ);
}

Marpa_Symbol_ID*
marpatcl_rtc_symset_dense (marpatcl_rtc_symset* s)
{
    TRACE_ENTER ("marpatcl_rtc_symset_dense");
    TRACE ("symset %p", s);
    TRACE_RETURN ("%p", DE);
}

void
marpatcl_rtc_symset_link (marpatcl_rtc_symset* s, int n)
{
    int k;
    TRACE_ENTER ("marpatcl_rtc_symset_link");
    TRACE ("symset %p, link %d", s, n);
    ASSERT_BOUNDS (n, CAP);
    SZ = n;
    for (k = 0; k < n; k++) {
	// TRACE ("symset %p link [%d,%d] %d", s, SZ, k, DE[k]);
	ASSERT (DE [k] < CAP, "Symbol beyond set capacity");
	XL [DE [k]] = k;
    }
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_include (marpatcl_rtc_symset* s, int c, marpatcl_rtc_sym* v)
{
    int k;
    Marpa_Symbol_ID x;
    TRACE_ENTER ("marpatcl_rtc_symset_include");
    TRACE ("symset %p add %d", s, c);
    for (k = 0; k < c; k++) {
	x = v[k];
	TRACE ("symset %p plus [%d,%d] %d", s, SZ, k, x);
	ASSERT (x < CAP, "Symbol beyond set capacity");
	/* Skip if already a member */
	if ((XL [x] < SZ) && (DE [XL [x]] == x)) continue;
	DE [SZ] = x;
	XL [x] = SZ;
	SZ ++;
    }
    TRACE_RETURN_VOID;
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
