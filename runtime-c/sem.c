/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-2018 Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <sem_int.h>

TRACE_OFF;
TRACE_TAG_OFF (show);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Debugging support.
 */

#define ASSERT_SV_TYPE(tag,msg)						\
    TRACE ("sv %p (%d/%s)", sv, T_GET, sv_type (sv));			\
    ASSERT (T_GET == (tag), "Bad " msg " access to non-" msg " sem.value")

#if defined(CRITCL_TRACER) || defined(SEM_REF_DEBUG)
#ifndef SEM_REF_DEBUG
static
#endif
const char*
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
API (marpatcl_rtc_sv_cons_int, int x)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(x %d)", x);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_int (sv, x);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_double, double x)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(x %f)", x);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_double (sv, x);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_string, const char* s, int own)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(s %p = '%s', own %d)", s, s, own);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_string (sv, s, own);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_user, int tag, void* data)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(tag %d, data %p)", tag, data);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_user (sv, tag, data);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_vec, int capacity)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(capacity %d)", capacity);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec (sv, capacity);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_vec_cp, marpatcl_rtc_sv_vec v)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("(v %p (n %d))", v, v->size);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_vec_cp (sv, v);
    SEM_LINK(sv);
    TRACE_RETURN ("(sv*) %p", sv);
}

#ifdef SEM_REF_DEBUG
marpatcl_rtc_sv_p
marpatcl_rtc_sv_cons_evec (int capacity)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("P (capacity %d)", capacity);

    sv = __marpatcl_rtc_sv_cons_evec ("((PARSER))", 0, capacity);

    TRACE_RETURN ("(sv*) %p", sv);
}
#endif

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_cons_evec, int capacity)
{
    marpatcl_rtc_sv_p sv;
    TRACE_FUNC ("I (capacity %d)", capacity);

    sv = ALLOC (marpatcl_rtc_sv);
    marpatcl_rtc_sv_init_evec (sv, capacity);
    SEM_LINK(sv);
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
    TRACE_FUNC ("((sv*) %p, s %p = '%s', own %d)", sv, s, s, own);

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
marpatcl_rtc_sv_init_evec (marpatcl_rtc_sv_p sv, int capacity)
{
    TRACE_FUNC ("((sv*) %p, capacity %d)", sv, capacity);

    REF = 0;
    T_SET (marpatcl_rtc_sv_type_vec, 0);
    VEC = marpatcl_rtc_sva_cons (capacity, 0);

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

#ifdef SEM_REF_DEBUG
void
marpatcl_rtc_sv_destroy (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("P ((sv*) %p)", sv);
    __marpatcl_rtc_sv_destroy ("((PARSER))", 0, sv);
    TRACE_RETURN_VOID;
}
#endif

void
API (marpatcl_rtc_sv_destroy, marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("I ((sv*) %p)", sv);

    SEM_UNLINK(sv);
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

#ifdef SEM_REF_DEBUG
marpatcl_rtc_sv_p
marpatcl_rtc_sv_ref (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("P ((sv*) %p (up rc %d))", sv, REF+1);

    sv = __marpatcl_rtc_sv_ref ("((PARSER))", 0, sv);

    TRACE_RETURN ("(sv*) %p", sv);
}

void
marpatcl_rtc_sv_unref (marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("P ((sv*) %p (down rc %d))", sv, REF);

    __marpatcl_rtc_sv_unref ("((PARSER))", 0, sv);

    TRACE_RETURN_VOID;
}
#endif

marpatcl_rtc_sv_p
API (marpatcl_rtc_sv_ref, marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("I ((sv*) %p (up rc %d))", sv, REF+1);

    SEM_TAKE (sv);
    REF ++;

    TRACE_RETURN ("(sv*) %p", sv);
}

void
API (marpatcl_rtc_sv_unref, marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("I ((sv*) %p (down rc %d))", sv, REF);

    SEM_RELE (sv);
    if (REF <= 1) {
	TRACE ("%s", "no more references");
	marpatcl_rtc_sv_destroy_i (sv);
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
    TRACE_FUNC ("((sv*) %p [vec], int %d [at])", sv, at);
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
#if defined (CRITCL_TRACER) || defined(SEM_REF_DEBUG)
/*
 * Generate string representation of an SV. Tracing support
 * No tracing inside due that. Also used for the SV reference
 * tracing.
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
    char* svs;
    char* child;
    int   len, clen, nlen, k;

    TRACE_TAG_FUNC (show, "((sv_vec) %p [%d:%d|%d], (int*) %p)",
		    v, v->size, v->capacity, v->strict, slen);

    if (!v->size) {
	svs = NALLOC (char, 5);
	len = snprintf (svs, 5, "%s", "[]");
	TRACE ("svs/a %p [%d] = %d:'%s'", svs, len, strlen(svs), svs);
    } else {
	svs = NALLOC (char, 5);
	len = snprintf (svs, 5, "%s", "[");
	TRACE ("svs/b %p [%d] = %d:'%s'", svs, len, strlen(svs), svs);

	for (k = 0; k < v->size; k++) {
	    TRACE_TAG (show, "child[%3d]", k);
	    child = marpatcl_rtc_sv_show (v->data [k], &clen);
	    nlen = len + clen + 2 + 1;
	    TRACE_TAG (show, "child[%3d] = %p [%d] ==> %d", k, child, clen, nlen);

	    svs = REALLOC (svs, char, nlen);
	    ASSERT (svs, "out of memory during SV stringification");

	    strcat (svs+len,child);
	    len += clen;
	    strcat (svs+len,", ");
	    len += 2;
	    TRACE_TAG (show, "svs/c %p [%d] = %d:'%s'", svs, len, strlen(svs), svs);
	    ASSERT (len == strlen(svs), "string length mismatch");

	    FREE (child);
	}

	/* Overwrite the closing suffix ", \0" with "]\0" */
	ASSERT (len > 2, "Short string, unable to close.");
	svs [len-2] = ']';
	svs [len-1] = '\0';
	len --;
    }

    TRACE_TAG (show, "svs/d %p [%d] = %d:'%s'", svs, len, strlen(svs), svs);
    ASSERT (len == strlen(svs), "string length mismatch");

    if (slen) {
	*slen = len;
	TRACE_TAG (show, "(int*) %p len = %d", slen, *slen);
    }
    TRACE_TAG_RETURN (show, "(char*) %p", svs);
}
#endif


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
