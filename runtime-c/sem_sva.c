/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <sem_int.h>

TRACE_OFF;
TRACE_TAG_OFF (filter);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define SZ     (v->size)
#define CAP    (v->capacity)
#define VAL    (v->data)
#define STRICT (v->strict)

#define VECDUMP(tag,label,v) {						\
        int i;								\
	for (i=0; i < (v)->size; i++) {					\
	    TRACE_TAG (tag, "* %s [%3d] = %p", label, i, (v)->data[i]); \
	}								\
	TRACE_TAG (tag, "", 0);						\
    }

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Helper
 */

static void
expand (marpatcl_rtc_sv_vec v, int newcap)
{
    if (!CAP) {
	VAL = NALLOC (marpatcl_rtc_sv_p, newcap);
    } else {
	VAL = REALLOC (VAL, marpatcl_rtc_sv_p, newcap);
    }
    CAP = newcap;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_sv_vec
marpatcl_rtc_sva_cons (int capacity, int strict)
{
    marpatcl_rtc_sv_vec v;
    TRACE_FUNC ("(capacity %d, strict %d)", capacity, strict);

    v = ALLOC (marpatcl_rtc_sva);
    marpatcl_rtc_sva_init (v, capacity, strict);

    TRACE_RETURN ("(sv_vec) %p", v);
}

void
marpatcl_rtc_sva_destroy (marpatcl_rtc_sv_vec v)
{
    TRACE_FUNC ("((sv_vec) %p)", v);

    marpatcl_rtc_sva_free (v);
    FREE (v);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_init (marpatcl_rtc_sv_vec v, int capacity, int strict)
{
    TRACE_FUNC ("((sv_vec) %p, capacity %d, strict %d)", v, capacity, strict);

    SZ     = 0;
    CAP    = capacity;
    STRICT = strict;
    if (capacity) {
	VAL = NALLOC (marpatcl_rtc_sv_p, capacity);
	memset (VAL, '\0', sizeof(marpatcl_rtc_sv_p)*capacity);
    } else {
	VAL = NULL;
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_free (marpatcl_rtc_sv_vec v)
{
    int k;
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv_vec) %p)", v);

    if (VAL) {
	for (k=0; k < SZ; k++) {
	    x = VAL [k];
	    if (x) marpatcl_rtc_sv_unref_i (x);
	}
	FREE (VAL);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_push (marpatcl_rtc_sv_vec v, marpatcl_rtc_sv_p x)
{
    TRACE_FUNC ("((sv_vec) %p, (sv*) %p)", v, x);

    if (STRICT) {
	ASSERT (SZ < CAP, "Push into full vector");
    } else if (SZ == CAP) {
	expand (v, CAP ? (CAP+CAP) : 1);
    }
    if (x) {
	(void) marpatcl_rtc_sv_ref_i (x);
    }
    VAL [SZ] = x;
    SZ ++;

    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sva_pop (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv_vec) %p)", v);
    ASSERT (SZ > 0, "Pop from empty vector");

    SZ --;
    x = VAL [SZ];
    VAL [SZ] = 0;
    if (x) marpatcl_rtc_sv_unref_i (x);

    TRACE_RETURN ("(sv*) %p", x);
}

void
marpatcl_rtc_sva_clear (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv_vec) %p, (int) %d [sz])", v, SZ);

    while (SZ) {
	// inlined _pop
	SZ --;
	x = VAL [SZ];
	VAL [SZ] = 0;
	if (x) marpatcl_rtc_sv_unref_i (x);
    }
    ASSERT (SZ == 0, "vector clear left data behind");

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_sva_size (marpatcl_rtc_sv_vec v)
{
    TRACE_FUNC ("((sv_vec) %p)", v);
    TRACE_RETURN ("%d", SZ);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sva_get (marpatcl_rtc_sv_vec v, int at)
{
    /* Caller is responsible for ref-counting */
    TRACE_FUNC ("((sv_vec) %p, at %d)", v, at);
    ASSERT_BOUNDS (at, SZ);
    TRACE_RETURN ("(sv*) %p", VAL [at]);
}

void
marpatcl_rtc_sva_set (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
    TRACE_FUNC ("((sv_vec) %p, at %d, (sv*) %p)", v, at, x);
    ASSERT_BOUNDS (at, SZ);
    /*
     * This code relies on the fact that the vector starts nulled, and pop
     * nulls too.  Without that the checks for not-null here would break on
     * un-initialized bogus data.
     */
    old = VAL [at];
    VAL [at] = x;
    if (x) {
	(void) marpatcl_rtc_sv_ref_i (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref_i (old);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_set_fill (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
    TRACE_FUNC ("((sv_vec) %p, at %d, (sv*) %p)", v, at, x);
    ASSERT (!STRICT || (at < CAP), "Cannot fill beyond capacity");

    // Semi-inlined _push. The per-push check for expandability, and actual
    // expansion are factored out and pulled in front of the actual push ops.
    // Expand to hold the new slot.
    {
	int newcap;
	if (!CAP) {
	    newcap = at+1;
	} else {
	    newcap = CAP;
	    while (at >= newcap) {
		newcap += newcap;
	    }
	}
	expand (v, newcap);
    }
    ASSERT_BOUNDS (at, CAP);

    // Fill with nulls to the new slot
    while (SZ <= at) {
	VAL [SZ] = NULL;
	SZ ++;
    }
    ASSERT_BOUNDS (at, SZ);
    /*
     * This code relies on the fact that the vector starts nulled, and pop
     * nulls too.  Without that the checks for not-null here would break on
     * un-initialized bogus data.
     */
    old = VAL [at];
    VAL [at] = x;
    if (x) {
	(void) marpatcl_rtc_sv_ref_i (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref_i (old);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_set_trunc (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
    TRACE_FUNC ("((sv_vec) %p, at %d, (sv*) %p)", v, at, x);
    ASSERT_BOUNDS (at, SZ);
    /*
     * This code relies on the fact that the vector starts nulled, and pop
     * nulls too.  Without that the checks for not-null here would break on
     * un-initialized bogus data.
     */
    old = VAL [at];
    VAL [at] = x;
    if (x) {
	(void) marpatcl_rtc_sv_ref_i (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref_i (old);
    }

    while (SZ > (at+1)) {
	// inlined _pop
	SZ --;
	x = VAL [SZ];
	VAL [SZ] = 0;
	if (x) marpatcl_rtc_sv_unref_i (x);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_filter (marpatcl_rtc_sv_vec v, int c, marpatcl_rtc_sym* x)
{
    marpatcl_rtc_sv_p sv;
    int k, t, j; /* from, to, filter from */
    TRACE_FUNC ("((sv_vec) %p, #sym %d, (sym*) %p)", v, c, x);
    VECDUMP (filter, "vI", v);

    for (k=0, t=0, j=0; k < SZ; k++) {
	TRACE_TAG_HEADER (filter, 1);
	TRACE_TAG_ADD (filter, "[%3d <- %3d [%3d: %3d]]", t, k, j, ((j<c)?x[j]:-1));
	if ((j < c) && (k == x[j])) {
	    TRACE_TAG_ADD (filter, ", skip & unref %d", k);
	    /* (1) This element is filtered out, its reference gone, if it had
	     * any. Replace with null, and release. The null will be moved
	     * towards the end by (2).
	     */
	    if (VAL [k]) marpatcl_rtc_sv_unref_i (VAL [k]);
	    VAL [k] = NULL;
	    j ++;
	    /* From now on t < k */
	} else if (t < k) {
	    /* (2) Move the referenced element down. No change in count.
	     * Setting it to null effectively shifts that null from the
	     * destination slot towards the end of the vector.
	     */
	    TRACE_TAG_ADD (filter, ", save %d to %d", k, t);
	    VAL [t] = VAL [k];
	    VAL [k] = NULL;
	    t ++;
	} else {
	    /* (3) k == t, no copying needed to keep the element.
	     * We are here before the first element to filter out.
	     */
	    TRACE_TAG_ADD (filter, ", keep %d", k);
	    t ++;
	}
	TRACE_TAG_CLOSER (filter);
	VECDUMP (filter, "vT", v);
    }

    /* Truncate to t, which is the new, lesser, size of the vector.
    **
     * Note, the loop above nulled and released the removed elements (1), and
     * further shifted these nulls to the end of the vector (2). As nothing
     * has to be done with the elements anymore the truncation reduces to a
     * simple assignment of the new size.
     */
    TRACE_TAG (filter, "pop %d", SZ-t);
    SZ = t;

    VECDUMP (filter, "vO", v);
    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_copy (marpatcl_rtc_sv_vec dst,
		       marpatcl_rtc_sv_vec src,
		       int from, int to)
{
    int k, newsize;
    /* Shorthands not available, as they assume `v` */
    TRACE_FUNC ("((sv_vec) dst %p <- (sv_vec) src %p [%d|%d..%d])", dst, src, src->size, from, to);
    ASSERT_BOUNDS (from, src->size);
    ASSERT_BOUNDS (to,   src->size);
    ASSERT (from <= to, "Unable to copy twisted interval (start > end)");
    newsize = dst->size+(to-from+1);
    ASSERT (!dst->strict || (newsize <= dst->capacity), "Cannot fill beyond capacity");

    // Semi-inlined _push. The per-push check for expandability, and actual
    // expansion are factored out and pulled in front of the actual push ops.

    // Expand to hold all the new values
    while (newsize > dst->capacity) {
	dst->capacity += dst->capacity;
	dst->data = REALLOC (dst->data, marpatcl_rtc_sv_p, dst->capacity);
    }
    ASSERT_BOUNDS (newsize-1, dst->capacity);

    for (k = from; k <= to; k++) {
	marpatcl_rtc_sv_p x = src->data[k];
        if (x) {
	    (void) marpatcl_rtc_sv_ref_i (x);
	}
	dst->data [dst->size] = x;
	dst->size ++;
    }

    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_vec
marpatcl_rtc_sva_dup (marpatcl_rtc_sv_vec v, int strict)
{
    marpatcl_rtc_sv_vec copy;
    TRACE_FUNC ("((sv_vec) %p, strict %d)", v, strict);

    copy = marpatcl_rtc_sva_cons (SZ, strict);
    if (SZ) marpatcl_rtc_sva_copy (copy, v, 0, SZ-1);

    TRACE_RETURN ("(sv_vec) %p", copy);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
