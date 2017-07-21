/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Semantic values.
 */

#include <sem_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

/*
 * Shorthands
 */

#define TAG (v->tag)
#define REF (v->refCount)
#define STR (v->value.string)
#define INT (v->value.inum)
#define FLT (v->value.fnum)
#define USR (v->value.user)
#define VEC (v->value.vec)

#define T_SET(t,f) TAG = (((t) << 4) | (f))
#define T_GET     (TAG >> 4)
#define FLAGS     (TAG & 0xF)
#define COPY (1)

/*
 */

marpa_rtc_semvalue_p
marpa_rtc_semvalue_cons_int (int x)
{
    marpa_rtc_semvalue_p v = ALLOC (marpa_rtc_semvalue);
    marpa_rtc_semvalue_init_int (v, x);
    return v;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_cons_double (double x)
{
    marpa_rtc_semvalue_p v = ALLOC (marpa_rtc_semvalue);
    marpa_rtc_semvalue_init_double (v, x);
    return v;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_cons_string (const char* s, int copy)
{
    marpa_rtc_semvalue_p v = ALLOC (marpa_rtc_semvalue);
    marpa_rtc_semvalue_init_string (v, s, copy);
    return v;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_cons_user (int tag, void* data)
{
    marpa_rtc_semvalue_p v = ALLOC (marpa_rtc_semvalue);
    marpa_rtc_semvalue_init_user (v, tag, data);
    return v;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_cons_vec (int capacity)
{
    marpa_rtc_semvalue_p v = ALLOC (marpa_rtc_semvalue);
    marpa_rtc_semvalue_init_vec (v, capacity);
    return v;
}

void
marpa_rtc_semvalue_init_int (marpa_rtc_semvalue_p v, int x)
{
    REF = 0;
    T_SET (marpa_rtc_sv_type_int, 0);
    INT = x;
}

void
marpa_rtc_semvalue_init_double (marpa_rtc_semvalue_p v, double x)
{
    REF = 0;
    T_SET (marpa_rtc_sv_type_double, 0);
    FLT = x;
}

void
marpa_rtc_semvalue_init_string (marpa_rtc_semvalue_p v, const char* s, int copy)
{
    REF = 0;
    T_SET (marpa_rtc_sv_type_string, (copy & COPY));
    STR = (copy & COPY) ? strdup (s) : (char*) s;
}

void
marpa_rtc_semvalue_init_user (marpa_rtc_semvalue_p v, int tag, void* data)
{
    ASSERT (tag >= 0, "Forbidden use of internal/reserved tag value");
    REF = 0;
    T_SET (tag, 0);
    USR = data;
}

void
marpa_rtc_semvalue_init_vec (marpa_rtc_semvalue_p v, int capacity)
{
    REF = 0;
    T_SET (marpa_rtc_sv_type_vec, 0);
    VEC = marpa_rtc_sva_cons (capacity, 1);
    return;
}

void
marpa_rtc_semvalue_destroy (marpa_rtc_semvalue_p v)
{
    marpa_rtc_semvalue_free (v);
    FREE (v);
}

void
marpa_rtc_semvalue_free (marpa_rtc_semvalue_p v)
{
    switch (T_GET) {
    case marpa_rtc_sv_type_vec:
	marpa_rtc_sva_destroy (VEC);
	break;
    case marpa_rtc_sv_type_string:
	if (FLAGS & COPY) {
	    FREE (STR);
	}
	break;
    default:
	/* nothing for scalar types */
	break;
    }
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_ref (marpa_rtc_semvalue_p v)
{
    REF ++;
    return v;
}

void
marpa_rtc_semvalue_unref (marpa_rtc_semvalue_p v)
{
    if (REF < 1) {
	marpa_rtc_semvalue_destroy (v);
	return;
    }
    REF --;
    return;
}

int 
marpa_rtc_semvalue_get_int (marpa_rtc_semvalue_p v)
{
    ASSERT (TAG == marpa_rtc_sv_type_int, "Unexpected access to non-int sem.value");
    return INT;
}

double 
marpa_rtc_semvalue_get_double (marpa_rtc_semvalue_p v)
{
    ASSERT (TAG == marpa_rtc_sv_type_double, "Unexpected access to non-double sem.value");
    return FLT;
}

const char*
marpa_rtc_semvalue_get_string (marpa_rtc_semvalue_p v)
{
    ASSERT (TAG == marpa_rtc_sv_type_string, "Unexpected access to non-string sem.value");
    return STR;
}

void 
marpa_rtc_semvalue_get_user (marpa_rtc_semvalue_p v, int* tag, void** data)
{
    ASSERT (TAG >= 0, "Unexpected access to non-user sem.value");
    *tag  = TAG;
    *data = USR;
    return;
}

int 
marpa_rtc_semvalue_get_vec (marpa_rtc_semvalue_p v, marpa_rtc_semvalue_p** data)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    *data = VEC->data;
    return VEC->size;
}

void 
marpa_rtc_semvalue_vec_set (marpa_rtc_semvalue_p v, int at, marpa_rtc_semvalue_p x)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpa_rtc_sva_set (VEC, at, x);
    return;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_vec_get (marpa_rtc_semvalue_p v, int at)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpa_rtc_sva_get (VEC, at);
}

void 
marpa_rtc_semvalue_vec_push (marpa_rtc_semvalue_p v, marpa_rtc_semvalue_p x)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpa_rtc_sva_push (VEC, x);
    return;
}

marpa_rtc_semvalue_p
marpa_rtc_semvalue_vec_pop (marpa_rtc_semvalue_p v)
{
    marpa_rtc_semvalue_p x;
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpa_rtc_sva_pop (VEC);
}

void 
marpa_rtc_semvalue_vec_clear (marpa_rtc_semvalue_p v)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpa_rtc_sva_clear (VEC);
    return;
}

int 
marpa_rtc_semvalue_vec_size (marpa_rtc_semvalue_p v)
{
    ASSERT (TAG == marpa_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpa_rtc_sva_size (VEC);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
