/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <sem_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

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

marpatcl_rtc_sv_p
marpatcl_rtc_sva_get (marpatcl_rtc_sv_vec v, int at)
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
