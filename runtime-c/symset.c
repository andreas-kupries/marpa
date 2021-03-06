/* Runtime for C-engine (RTC). Implementation. (Sets of marpa-symbols, dynamic)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 *
 * NOTE. This structure works without memory initialization and thus may cause
 *       memory checkers like valgrind to generate lots of false positives.
 * Ref:  https://core.tcl.tk/akupries/marpa/wiki?name=fast+sparse+integer+sets+in+C
 */

#include <environment.h>
#include <symset.h>

TRACE_OFF;
TRACE_TAG_OFF (details);

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
    TRACE_FUNC ("((symset*) %p, capacity %d)", s, capacity);

    SZ  = 0;
    CAP = capacity;
    XL  = NALLOC (marpatcl_rtc_sym, capacity);
    DE  = NALLOC (Marpa_Symbol_ID,  capacity);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_free (marpatcl_rtc_symset* s)
{
    TRACE_FUNC ("((symset*) %p)", s);

    FREE (XL); XL = 0;
    FREE (DE); DE = 0;
    SZ = 0;
    CAP = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_clear (marpatcl_rtc_symset* s)
{
    TRACE_FUNC ("((symset*) %p)", s);

    SZ = 0;

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_symset_contains (marpatcl_rtc_symset* s, Marpa_Symbol_ID c)
{
    TRACE_FUNC ("((symset*) %p, sym %d)", s, c);

    ASSERT (c < CAP, "Symbol beyond set capacity");

    TRACE_RETURN ("%d", (XL [c] < SZ) && (DE [XL [c]] == c));
}

int
marpatcl_rtc_symset_size (marpatcl_rtc_symset* s)
{
    TRACE_FUNC ("((symset*) %p)", s);
    TRACE_RETURN ("%d", SZ);
}

Marpa_Symbol_ID*
marpatcl_rtc_symset_dense (marpatcl_rtc_symset* s)
{
    TRACE_FUNC ("((symset*) %p)", s);
    TRACE_RETURN ("%p", DE);
}

void
marpatcl_rtc_symset_link (marpatcl_rtc_symset* s, int n)
{
    int k;
    TRACE_FUNC ("((symset*) %p, n %d)", s, n);
    ASSERT (0 <= n, "Size underflow");
    ASSERT (n <= CAP, "Size beyond capacity");

    SZ = n;
    for (k = 0; k < n; k++) {
	TRACE_TAG (details, "(symset*) %p, link [%d,%d] %d", s, SZ, k, DE[k]);
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
    TRACE_FUNC ("((symset*) %p, #sym %d, (sym*) %p)", s, c, v);

    for (k = 0; k < c; k++) {
	// Inlined _add
	x = v[k];
	TRACE_TAG (details, "(symset*) %p, plus [%d,%d] %d", s, SZ, k, x);
	ASSERT (x < CAP, "Symbol beyond set capacity");

	/* Skip if already a member */
	if ((XL [x] < SZ) && (DE [XL [x]] == x)) continue;
	DE [SZ] = x;
	XL [x] = SZ;
	SZ ++;
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_symset_add (marpatcl_rtc_symset* s, marpatcl_rtc_sym v)
{
    TRACE_FUNC ("((symset*) %p, #sym %d, (sym) %d)", s, v);

    TRACE_TAG (details, "(symset*) %p, plus [%d] %d", s, SZ, v);
    ASSERT (v < CAP, "Symbol beyond set capacity");

    /* Skip if already a member */
    if ((XL [v] < SZ) && (DE [XL [v]] == v)) {
	TRACE_RETURN_VOID;
    }
    DE [SZ] = v;
    XL [v] = SZ;
    SZ ++;

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
