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

#define TAG (sv->tag)
#define REF (sv->refCount)
#define STR (sv->value.string)
#define INT (sv->value.inum)
#define FLT (sv->value.fnum)
#define USR (sv->value.user)
#define VEC (sv->value.vec)

#define T_SET(t,f) TAG = (((t) << 4) | (f))
#define T_GET     (TAG >> 4)
#define FLAGS     (TAG & 0xF)
#define OWN (1)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_int (int x)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_int (sv, x);
    return sv;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_double (double x)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_double (sv, x);
    return sv;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_string (const char* s, int own)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_string (sv, s, own);
    return sv;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_user (int tag, void* data)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_user (sv, tag, data);
    return sv;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_vec (int capacity)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec (sv, capacity);
    return sv;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_vec_cp (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec_cp (sv, v);
    return sv;
}

void
marpatcl_rtc_sv_init_int (marpatcl_rtc_sv_p sv, int x)
{
    REF = 0;
    T_SET (marpatcl_rtc_sv_type_int, 0);
    INT = x;
}

void
marpatcl_rtc_sv_init_double (marpatcl_rtc_sv_p sv, double x)
{
    REF = 0;
    T_SET (marpatcl_rtc_sv_type_double, 0);
    FLT = x;
}

void
marpatcl_rtc_sv_init_string (marpatcl_rtc_sv_p sv, const char* s, int own)
{
    REF = 0;
    T_SET (marpatcl_rtc_sv_type_string, (own & OWN));
    STR = (char*) s;
}

void
marpatcl_rtc_sv_init_user (marpatcl_rtc_sv_p sv, int tag, void* data)
{
    ASSERT (tag >= 0, "Forbidden use of internal/reserved tag value");
    REF = 0;
    T_SET (tag, 0);
    USR = data;
}

void
marpatcl_rtc_sv_init_vec (marpatcl_rtc_sv_p sv, int capacity)
{
    REF = 0;
    T_SET (marpatcl_rtc_sv_type_vec, 0);
    VEC = marpatcl_rtc_sva_cons (capacity, 1);
    return;
}

void
marpatcl_rtc_sv_init_vec_cp (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_vec v)
{
    REF = 0;
    T_SET (marpatcl_rtc_sv_type_vec, 0);
    VEC = marpatcl_rtc_sva_dup (v, 1);
    return;
}

void
marpatcl_rtc_sv_destroy (marpatcl_rtc_sv_p sv)
{
    marpatcl_rtc_sv_free (sv);
    FREE (sv);
}

void
marpatcl_rtc_sv_free (marpatcl_rtc_sv_p sv)
{
    switch (T_GET) {
    case marpatcl_rtc_sv_type_vec:
	marpatcl_rtc_sva_destroy (VEC);
	break;
    case marpatcl_rtc_sv_type_string:
	if (FLAGS & OWN) {
	    FREE (STR);
	}
	break;
    default:
	/* nothing for scalar types */
	break;
    }
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_ref (marpatcl_rtc_sv_p sv)
{
    REF ++;
    return sv;
}

void
marpatcl_rtc_sv_unref (marpatcl_rtc_sv_p sv)
{
    if (REF < 1) {
	marpatcl_rtc_sv_destroy (sv);
	return;
    }
    REF --;
    return;
}

int 
marpatcl_rtc_sv_get_int (marpatcl_rtc_sv_p sv)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_int, "Unexpected access to non-int sem.value");
    return INT;
}

double 
marpatcl_rtc_sv_get_double (marpatcl_rtc_sv_p sv)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_double, "Unexpected access to non-double sem.value");
    return FLT;
}

const char*
marpatcl_rtc_sv_get_string (marpatcl_rtc_sv_p sv)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_string, "Unexpected access to non-string sem.value");
    return STR;
}

void 
marpatcl_rtc_sv_get_user (marpatcl_rtc_sv_p sv, int* tag, void** data)
{
    ASSERT (TAG >= 0, "Unexpected access to non-user sem.value");
    *tag  = TAG;
    *data = USR;
    return;
}

int 
marpatcl_rtc_sv_get_vec (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_p** data)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    *data = VEC->data;
    return VEC->size;
}

void 
marpatcl_rtc_sv_vec_set (marpatcl_rtc_sv_p sv, int at, marpatcl_rtc_sv_p x)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpatcl_rtc_sva_set (VEC, at, x);
    return;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_vec_get (marpatcl_rtc_sv_p sv, int at)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpatcl_rtc_sva_get (VEC, at);
}

void 
marpatcl_rtc_sv_vec_push (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_p x)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpatcl_rtc_sva_push (VEC, x);
    return;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_vec_pop (marpatcl_rtc_sv_p sv)
{
    marpatcl_rtc_sv_p x;
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpatcl_rtc_sva_pop (VEC);
}

void 
marpatcl_rtc_sv_vec_clear (marpatcl_rtc_sv_p sv)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    marpatcl_rtc_sva_clear (VEC);
    return;
}

int 
marpatcl_rtc_sv_vec_size (marpatcl_rtc_sv_p sv)
{
    ASSERT (TAG == marpatcl_rtc_sv_type_vec, "Unexpected access to non-vector sem.value");
    return marpatcl_rtc_sva_size (VEC);
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
