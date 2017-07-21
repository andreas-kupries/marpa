/*
 * RunTime C
 * Implementation
 * Arrays/Vectors of semantic values.
 */

#include <sem_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

/*
 * Shorthands
 */

#define SZ     (v->size)
#define CAP    (v->capacity)
#define VAL    (v->data)
#define STRICT (v->strict)

/*
 */

marpa_rtc_sv_vec
marpa_rtc_sva_cons (int capacity, int strict)
{
    marpa_rtc_sv_vec v = ALLOC (marpa_rtc_sv_array);
    marpa_rtc_sva_init (v, capacity, strict);
    return v;
}

void
marpa_rtc_sva_destroy (marpa_rtc_sv_vec v)
{
    marpa_rtc_sva_free (v);
    FREE (v);
    return;
}

void
marpa_rtc_sva_init (marpa_rtc_sv_vec v, int capacity, int strict)
{
    SZ     = 0;
    CAP    = capacity;
    STRICT = strict;
    VAL    = NALLOC (marpa_rtc_semvalue_p, capacity);
    memset (VAL, '\0', sizeof(marpa_rtc_semvalue_p)*capacity);
    return;
}

void
marpa_rtc_sva_free (marpa_rtc_sv_vec v)
{
    int k;
    for (k=0; k < SZ; k++) {
	marpa_rtc_semvalue_unref (VAL [k]);
    }
    FREE (VAL);
    return;
}

void 
marpa_rtc_sva_push (marpa_rtc_sv_vec v, marpa_rtc_semvalue_p x)
{
    if (STRICT) {
	ASSERT (SZ < CAP, "Push into full vector");
    } else if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, marpa_rtc_semvalue_p, CAP);
    }
    if (x) {
	(void) marpa_rtc_semvalue_ref (x);
    }
    VAL [SZ] = x;
    SZ ++;
    return;
}

marpa_rtc_semvalue_p
marpa_rtc_sva_pop (marpa_rtc_sv_vec v)
{
    marpa_rtc_semvalue_p x;
    ASSERT (SZ > 0, "Pop from empty vector");
    SZ --;
    x = VAL [SZ];
    VAL [SZ] = 0;
    marpa_rtc_semvalue_unref (x);
    return x;
}

void
marpa_rtc_sva_clear (marpa_rtc_sv_vec v)
{
    /* Quick impl. - TODO FUTURE replace with loop to release, memchr to clear */
    while (SZ) { marpa_rtc_sva_pop (v); }
    ASSERT (SZ == 0, "vector clear left data behind");
    return;
}
int 
marpa_rtc_sva_size (marpa_rtc_sv_vec v)
{
    return SZ;
}

void
marpa_rtc_sva_set (marpa_rtc_sv_vec v, int at, marpa_rtc_semvalue_p x)
{
    marpa_rtc_semvalue_p old;
    ASSERT_BOUNDS (at, SZ);
    /*
     * This code relies on the fact that the vector starts nulled, and pop
     * nulls too.  Without that the checks for not-null here would break on
     * un-initialized bogus data.
     */
    old = VAL [at];
    VAL [at] = x;
    if (x) {
	(void) marpa_rtc_semvalue_ref (x);
    }
    if (old) {
	marpa_rtc_semvalue_unref (old);
    }
    return;    
}

marpa_rtc_semvalue_p
marpa_rtc_sva_get (marpa_rtc_sv_vec v, int at)
{
    /* Caller is responsible for ref-counting */
    ASSERT_BOUNDS (at, SZ);
    return VAL [at];
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
