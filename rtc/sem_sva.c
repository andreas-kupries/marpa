/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_ON;
TRACE_TAG_ON (filter);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define SZ     (v->size)
#define CAP    (v->capacity)
#define VAL    (v->data)
#define STRICT (v->strict)

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
    VAL    = NALLOC (marpatcl_rtc_sv_p, capacity);
    memset (VAL, '\0', sizeof(marpatcl_rtc_sv_p)*capacity);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_free (marpatcl_rtc_sv_vec v)
{
    int k;
    TRACE_FUNC ("((sv_vec) %p)", v);

    for (k=0; k < SZ; k++) {
	marpatcl_rtc_sv_unref (VAL [k]);
    }
    FREE (VAL);

    TRACE_RETURN_VOID;
}

void 
marpatcl_rtc_sva_push (marpatcl_rtc_sv_vec v, marpatcl_rtc_sv_p x)
{
    TRACE_FUNC ("((sv_vec) %p, (sv*) %p)", v, x);

    if (STRICT) {
	ASSERT (SZ < CAP, "Push into full vector");
    } else if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, marpatcl_rtc_sv_p, CAP);
    }
    if (x) {
	(void) marpatcl_rtc_sv_ref (x);
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
    if (x) marpatcl_rtc_sv_unref (x);

    TRACE_RETURN ("(sv*) %p", x);
}

void
marpatcl_rtc_sva_clear (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv_vec) %p)", v);

    while (SZ) {
	// inlined _pop
	SZ --;
	x = VAL [SZ];
	VAL [SZ] = 0;
	if (x) marpatcl_rtc_sv_unref (x);
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
	(void) marpatcl_rtc_sv_ref (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref (old);
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
    while (at >= CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, marpatcl_rtc_sv_p, CAP);
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
	(void) marpatcl_rtc_sv_ref (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref (old);
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
	(void) marpatcl_rtc_sv_ref (x);
    }
    if (old) {
	marpatcl_rtc_sv_unref (old);
    }

    while (SZ > (at+1)) {
	// inlined _pop
	SZ --;
	x = VAL [SZ];
	VAL [SZ] = 0;
	if (x) marpatcl_rtc_sv_unref (x);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_filter (marpatcl_rtc_sv_vec v, int c, marpatcl_rtc_sym* x)
{
    marpatcl_rtc_sv_p sv;
    int k, t, j; /* from, to, filter from */
    TRACE_FUNC ("((sv_vec) %p, #sym %d, (sym*) %p)", v, c, x);

    for (k=0, t=0, j=0; k < SZ; k++) {
	TRACE_TAG_HEADER (filter, 1);
	TRACE_TAG_ADD (filter, "[%3d <- %3d [%3d: %3d]]", k, t, j, x[j]);
	if (t < k) {
	    TRACE_TAG_ADD (filter, " keep, copy down", 0);
	    VAL [t] = VAL [k];
	    VAL [k] = NULL;
	    /* Reference moved, no change in count
	     * Setting it to null in origin prevents
	     * miscounting during truncation at the end.
	     */
	}
	if (k == x[j]) {
	    TRACE_TAG_ADD (filter, " skip, unref", 0);
	    /* This element filtered out, reference gone */
	    marpatcl_rtc_sv_unref (VAL [k]);
	    j ++;
	    /* From now on t < k */
	} else {
	    TRACE_TAG_ADD (filter, " keep", 0);
	    t ++;
	}
	TRACE_TAG_CLOSER (filter);
    }
    /* Truncate */
    while (SZ > (t+1)) {
	// inlined _pop
	SZ --;
	sv = VAL [SZ];
	TRACE_TAG (filter, "pop (sv*) %p", sv);
	VAL [SZ] = 0;
	if (sv) marpatcl_rtc_sv_unref (sv);
    }

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sva_copy (marpatcl_rtc_sv_vec dst,
		       marpatcl_rtc_sv_vec src,
		       int from, int to)
{
    int k, at;
    /* Shorthands not available, as they assume `v` */
    TRACE_FUNC ("((sv_vec) dst %p <- (sv_vec) src %p [%d-%d])", dst, src, from, to);
    ASSERT_BOUNDS (from, src->size);
    ASSERT_BOUNDS (to,   src->size);
    ASSERT_BOUNDS (from, to);
    at = dst->size+(to-from+1);
    ASSERT (!dst->strict || (at < dst->capacity), "Cannot fill beyond capacity");

    // Semi-inlined _push. The per-push check for expandability, and actual
    // expansion are factored out and pulled in front of the actual push ops.

    // Expand to hold all the new values
    while (at >= dst->capacity) {
	dst->capacity += dst->capacity;
	dst->data = REALLOC (dst->data, marpatcl_rtc_sv_p, dst->capacity);
    }
    ASSERT_BOUNDS (at, dst->capacity);
    
    for (k = from; k <= to; k++) {
	marpatcl_rtc_sv_p x = src->data[k];
        if (x) {
	    (void) marpatcl_rtc_sv_ref (x);
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
    marpatcl_rtc_sva_copy (copy, v, 0, SZ-1);

    TRACE_RETURN ("(sv_vec) %p", copy);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
