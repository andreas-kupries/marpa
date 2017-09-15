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

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Debugging support.
 */

#define ASSERT_SV_TYPE(tag,msg)						\
    TRACE ("sv %p (%d/%s)", sv, T_GET, sv_type (sv));			\
    ASSERT (T_GET == (tag), "Bad " msg " access to non-" msg " sem.value")

#ifdef CRITCL_TRACER
static const char*
sv_type (marpatcl_rtc_sv_p sv)
{
    static const char* typename[] = {
	"user", "string", "int", "double", "user/", "vec",
	/* 0,   1,        2,     3,        4,       5 */
    };
    int type = T_GET;
    if (type < 0) {
	return typename[-type];
    } else {
	static char buf [30];
	sprintf (buf, "user(%d)", type);
	return buf;
    }
}
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_int (int x)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(x %d)", x);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_int (sv, x);

    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_double (double x)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(x %f)", x);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_double (sv, x);

    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_string (const char* s, int own)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(s '%s', own %d)", s, own);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_string (sv, s, own);

    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_user (int tag, void* data)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(tag %d, data %p)", tag, data);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_user (sv, tag, data);

    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_vec (int capacity)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(capacity %d)", capacity);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec (sv, capacity);

    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_vec_cp (marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(v %p (n %d))", v, v->size);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec_cp (sv, v);

    TRACE_RETURN ("(sv*) %p", sv);
}

void
marpatcl_rtc_sv_init_int (marpatcl_rtc_sv_p sv, int x)
{
    TRACE_FUNC ("((sv*) %p, x %d)", sv, x);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_int, 0);
    INT = x;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_init_double (marpatcl_rtc_sv_p sv, double x)
{
    TRACE_FUNC ("((sv*) %p, x %f)", sv, x);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_double, 0);
    FLT = x;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_init_string (marpatcl_rtc_sv_p sv, const char* s, int own)
{
    TRACE_FUNC ("((sv*) %p, s '%s', own %d)", sv, s, own);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_string, (own & OWN));
    STR = (char*) s;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_init_user (marpatcl_rtc_sv_p sv, int tag, void* data)
{
    TRACE_FUNC ("((sv*) %p, tag %d, data %p)", sv, tag, data);
    ASSERT (tag >= 0, "Forbidden use of internal/reserved tag value");

    REF = 0;
    T_SET (tag, 0);
    USR = data;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_init_vec (marpatcl_rtc_sv_p sv, int capacity)
{
    TRACE_FUNC ("((sv*) %p, capacity %d)", sv, capacity);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_vec, 0);
    VEC = marpatcl_rtc_sva_cons (capacity, 1);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_init_vec_cp (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_vec v)
{
    TRACE_FUNC ("((sv*) %p, (sv_vec) %p (n %d))", sv, v, v->size);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_vec, 0);
    VEC = marpatcl_rtc_sva_dup (v, 1);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_destroy (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p)", sv);

    marpatcl_rtc_sv_free (sv);
    FREE (sv);

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_sv_free (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p)", sv);

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
    
    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_ref (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p (up rc %d))", sv, REF+1);

    REF ++;

    TRACE_RETURN ("(sv*) %p", sv);
}

void
marpatcl_rtc_sv_unref (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p (down rc %d))", sv, REF);

    if (REF < 1) {
	marpatcl_rtc_sv_destroy (sv);
	TRACE_RETURN_VOID;
    }
    REF --;

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_sv_get_int (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p [int])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_int, "int");
    TRACE_RETURN ("%d", INT);
}

double 
marpatcl_rtc_sv_get_double (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p [double])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_double, "double");
    TRACE_RETURN ("%f", FLT);
}

const char*
marpatcl_rtc_sv_get_string (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p [string])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_string, "string");
    TRACE_RETURN ("'%s'", STR);
}

void 
marpatcl_rtc_sv_get_user (marpatcl_rtc_sv_p sv, int* tag, void** data)
{
    TRACE_FUNC ("((sv*) %p [user], (int*) tag %p, (void**) data %p)", sv, tag, data);
    ASSERT (TAG >= 0, "Unexpected access to non-user sem.value");

    *tag  = TAG;
    *data = USR;
    
    TRACE ("tag  (int*)   %p := %d", tag, *tag);
    TRACE ("data (void**) %p := %p", data, *data);
    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_sv_get_vec (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_p** data)
{
    TRACE_FUNC ("((sv*) %p [vec], (sv_p**) %p)", sv, data);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    *data = VEC->data;

    TRACE ("data (sv_p**) %p := (sv_p*) %p", data, *data);
    TRACE_RETURN ("%d", VEC->size);
}

void 
marpatcl_rtc_sv_vec_set (marpatcl_rtc_sv_p sv, int at, marpatcl_rtc_sv_p x)
{
    TRACE_FUNC ("((sv*) %p [vec], at %d, (sv*) x %p)", sv, at, x);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    marpatcl_rtc_sva_set (VEC, at, x);

    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_vec_get (marpatcl_rtc_sv_p sv, int at)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv*) %p [vec], int at)", sv, at);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    x = marpatcl_rtc_sva_get (VEC, at);

    TRACE_RETURN ("(sv*) %p", x);
}

void 
marpatcl_rtc_sv_vec_push (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_p x)
{
    TRACE_FUNC ("((sv*) %p [vec], (sv*) x %p)", sv, x);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    marpatcl_rtc_sva_push (VEC, x);

    TRACE_RETURN_VOID;
}

marpatcl_rtc_sv_p
marpatcl_rtc_sv_vec_pop (marpatcl_rtc_sv_p sv)
{
    marpatcl_rtc_sv_p x;
    TRACE_FUNC ("((sv*) %p [vec])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    x = marpatcl_rtc_sva_pop (VEC);

    TRACE_RETURN ("(sv*) %p", x);
}

void 
marpatcl_rtc_sv_vec_clear (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p [vec])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    marpatcl_rtc_sva_clear (VEC);

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_sv_vec_size (marpatcl_rtc_sv_p sv)
{
    int sz;
    TRACE_FUNC ("((sv*) %p [vec])", sv);
    ASSERT_SV_TYPE (marpatcl_rtc_sv_type_vec, "vector");

    sz = marpatcl_rtc_sva_size (VEC);

    TRACE_RETURN ("%d", sz);
}
#ifdef CRITCL_TRACER
/*
 * Generate string representation of an SV. Tracing support
 * No tracing inside due that.
 */
char*
marpatcl_rtc_sv_show (marpatcl_rtc_sv_p sv, int* slen)
{
    char* svs;
    int len;
    if (!sv) {
	const char* null = "<NULL>";
	svs = NALLOC (char, 2+strlen(null));
	len = sprintf (svs, "%s", null);
	if (slen) *slen = len;
	return svs;
	/**/
    }
    switch (T_GET) {
    case marpatcl_rtc_sv_type_string:
	svs = NALLOC (char, 1+2+strlen (STR));
	len = sprintf (svs, "'%s'", STR);
	if (slen) *slen = len;
	return svs;
	/**/
    case marpatcl_rtc_sv_type_int:
	svs = NALLOC (char, 30);
	len = sprintf (svs, "%d", INT);
	if (slen) *slen = len;
	return svs;
	/**/
    case marpatcl_rtc_sv_type_double:
	svs = NALLOC (char, 130);
	len = sprintf (svs, "%f", FLT);
	if (slen) *slen = len;
	return svs;
	/**/
    case marpatcl_rtc_sv_type_vec:
	return marpatcl_rtc_sv_vec_show (VEC, slen);
	/**/
    default:
	if (T_GET > 0) {
	    svs = NALLOC (char, 60);
	    len = sprintf (svs, "U(%d)/%p", T_GET, USR);
	} else {
	    svs = NALLOC (char, 40);
	    len = sprintf (svs, "BAD(%d)", T_GET);
	}
	if (slen) *slen = len;
	return svs;
    }
    ASSERT (0, "Should not happen");
}

char*
marpatcl_rtc_sv_vec_show (marpatcl_rtc_sv_vec v, int* slen)
{
    char* svs = NALLOC (char, 5);
    char* child;
    int   len, clen, nlen, k;

    len = sprintf (svs, "%s", "[");
    for (k = 0; k < v->size; k++) {
	child = marpatcl_rtc_sv_show (v->data [k], &clen);
	nlen = len + clen + 2 + 1;
	svs = REALLOC (svs, char, nlen);
	ASSERT (svs, "out of memory during SV stringification");
	strcat (svs+len,child);
	len += clen;
	strcat (svs+len,", ");
	len += 2;
	FREE (child);
    }
    /* Overwrite ", \0" with "]\0" */
    svs[len-2] = ']';
    svs[len-1] = '\0';
    len --;
    if (slen) *slen = len;
    return svs;
}
#endif


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
