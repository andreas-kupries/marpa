/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>

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
    marpatcl_rtc_sv_vec v = ALLOC (marpatcl_rtc_sva);
    marpatcl_rtc_sva_init (v, capacity, strict);
    return v;
}

void
marpatcl_rtc_sva_destroy (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sva_free (v);
    FREE (v);
    return;
}

void
marpatcl_rtc_sva_init (marpatcl_rtc_sv_vec v, int capacity, int strict)
{
    SZ     = 0;
    CAP    = capacity;
    STRICT = strict;
    VAL    = NALLOC (marpatcl_rtc_sv_p, capacity);
    memset (VAL, '\0', sizeof(marpatcl_rtc_sv_p)*capacity);
    return;
}

void
marpatcl_rtc_sva_free (marpatcl_rtc_sv_vec v)
{
    int k;
    for (k=0; k < SZ; k++) {
	marpatcl_rtc_sv_unref (VAL [k]);
    }
    FREE (VAL);
    return;
}

void 
marpatcl_rtc_sva_push (marpatcl_rtc_sv_vec v, marpatcl_rtc_sv_p x)
{
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
    return;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sva_pop (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p x;
    ASSERT (SZ > 0, "Pop from empty vector");
    SZ --;
    x = VAL [SZ];
    VAL [SZ] = 0;
    marpatcl_rtc_sv_unref (x);
    return x;
}

void
marpatcl_rtc_sva_clear (marpatcl_rtc_sv_vec v)
{
    /* Quick impl. - TODO FUTURE replace with loop to release, memchr to clear */
    while (SZ) { marpatcl_rtc_sva_pop (v); }
    ASSERT (SZ == 0, "vector clear left data behind");
    return;
}
int 
marpatcl_rtc_sva_size (marpatcl_rtc_sv_vec v)
{
    return SZ;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sva_get (marpatcl_rtc_sv_vec v, int at)
{
    /* Caller is responsible for ref-counting */
    ASSERT_BOUNDS (at, SZ);
    return VAL [at];
}

void
marpatcl_rtc_sva_set (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
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
    return;    
}

void
marpatcl_rtc_sva_set_fill (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
    while (SZ <= at) { marpatcl_rtc_sva_push (v, NULL); }
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
    return;    
}

void
marpatcl_rtc_sva_set_trunc (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x)
{
    marpatcl_rtc_sv_p old;
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

    while (SZ > (at+1)) { marpatcl_rtc_sva_pop (v); }
    return;    
}

void
marpatcl_rtc_sva_filter (marpatcl_rtc_sv_vec v, int c, marpatcl_rtc_sym* x)
{
    int k, t, j; /* from, to, filter from */
    for (k=0, t=0, j=0; k < SZ; k++) {
	if (t < k) {
	    VAL [t] = VAL [k];
	    VAL [k] = NULL;
	    /* Reference moved, no change in count
	     * Setting it to null in origin prevents
	     * miscounting during truncation at the end.
	     */
	}
	if (k == x[j]) {
	    /* This element filtered out, reference gone */
	    marpatcl_rtc_sv_unref (VAL [k]);
	    j ++;
	    /* From now on t < k */
	} else {
	    t ++;
	}
    }
    /* Truncate */
    while (SZ > (t+1)) { marpatcl_rtc_sva_pop (v); }
}

void
marpatcl_rtc_sva_transfer (marpatcl_rtc_sv_vec dst,
			   marpatcl_rtc_sv_vec src,
			   int from, int to)
{
    int k;
    /* Shorthands not available, as they assume `v` */
    ASSERT_BOUNDS (from, src->size);
    ASSERT_BOUNDS (to,   src->size);
    ASSERT_BOUNDS (from, to);

    for (k = from; k <= to; k++) {
	marpatcl_rtc_sva_push (dst, src->data[k]);
    }
}

marpatcl_rtc_sv_vec
marpatcl_rtc_sva_dup (marpatcl_rtc_sv_vec v, int strict)
{
    marpatcl_rtc_sv_vec copy = marpatcl_rtc_sva_cons (SZ, strict);
    marpatcl_rtc_sva_transfer (copy, v, 0, SZ-1);
    return copy;
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
