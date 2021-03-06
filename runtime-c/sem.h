/* Runtime for C-engine (RTC). Declarations. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SEM_H
#define MARPATCL_RTC_SEM_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <marpa.h>
#include <critcl_trace.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants, and types (mostly structures)
 */

/*
 * Opaque declarations for SV references and SV vectors (stack-like)
 */

typedef struct marpatcl_rtc_sv*  marpatcl_rtc_sv_p;
typedef struct marpatcl_rtc_sva* marpatcl_rtc_sv_vec;

/*
 * Structure of a single semantic value
 */

typedef struct marpatcl_rtc_sv {
    int tag;      /* type tag to identify what value field to, plus flags
		   * (type-dependent, (x)) */
    int refCount; /* number of references to the value */
    union {
	char*               string; /* value is a null-terminated UTF-8 string */
	int                 inum;   /* value is integer number */
	double              fnum;   /* value is floating point number */
	void*               user;   /* value is user-specific anything */
	marpatcl_rtc_sv_vec vec;    /* value is vector of values */
    } value;
#ifdef SEM_REF_DEBUG
    /* When debugging SV usage we track all allocated in a global list, with
     * origin nformation. These are are the fields for that */
    marpatcl_rtc_sv_p prev;
    marpatcl_rtc_sv_p next;
    const char*       ofile;
    int               oline;
#endif
} marpatcl_rtc_sv;

/*
 * (x) The lowest 4 bits of tag are the flags.
 *     The actual tag value is stored shifted 4 bits up.
 */

/*
 * Type tags, internal.
 * User tags must be >= 0.
 * Negative values are reserved for the internal tags.
 */

#define marpatcl_rtc_sv_type_string (-1)
#define marpatcl_rtc_sv_type_int    (-2)
#define marpatcl_rtc_sv_type_double (-3)
#define marpatcl_rtc_sv_type_user   (-4)
#define marpatcl_rtc_sv_type_vec    (-5)

/*
 * -- Note: The details of the vector type are hidden from users.
 * -- Note: The vector type is the key to ASTs.
 *          Each inner node of an AST is a vector-type semantic value
 *          referencing nodes and non-vector values (== leafs).
 */

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- SV -- lifecycle
 */

/* Stubs functions. Unchanging. The internal symbol has suffix `_i`.
 */

marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_evec  (int capacity);
void              marpatcl_rtc_sv_destroy    (marpatcl_rtc_sv_p sv);

#ifdef SEM_REF_DEBUG
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_int    (const char* ofile, int oline, int x);
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_double (const char* ofile, int oline, double x);
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_string (const char* ofile, int oline, const char* s, int own);
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_user   (const char* ofile, int oline, int tag, void* data);
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_vec    (const char* ofile, int oline, int capacity);
marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_vec_cp (const char* ofile, int oline, marpatcl_rtc_sv_vec v);

marpatcl_rtc_sv_p __marpatcl_rtc_sv_cons_evec   (const char* ofile, int oline, int capacity);
void              __marpatcl_rtc_sv_destroy     (const char* ofile, int oline, marpatcl_rtc_sv_p sv);

#define marpatcl_rtc_sv_cons_int(x)		__marpatcl_rtc_sv_cons_int    (__FILE__,__LINE__, x)
#define marpatcl_rtc_sv_cons_double(x)		__marpatcl_rtc_sv_cons_double (__FILE__,__LINE__, x)
#define marpatcl_rtc_sv_cons_string(s, own)	__marpatcl_rtc_sv_cons_string (__FILE__,__LINE__, s, own)
#define marpatcl_rtc_sv_cons_user(tag, data)	__marpatcl_rtc_sv_cons_user   (__FILE__,__LINE__, tag, data)
#define marpatcl_rtc_sv_cons_vec(capacity)	__marpatcl_rtc_sv_cons_vec    (__FILE__,__LINE__, capacity)
#define marpatcl_rtc_sv_cons_vec_cp(v)		__marpatcl_rtc_sv_cons_vec_cp (__FILE__,__LINE__, v)

#define marpatcl_rtc_sv_cons_evec_i(capacity)	__marpatcl_rtc_sv_cons_evec   (__FILE__,__LINE__, capacity)
#define marpatcl_rtc_sv_destroy_i(sv)		__marpatcl_rtc_sv_destroy     (__FILE__,__LINE__, sv)

#else
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_int    (int x);
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_double (double x);
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_string (const char* s, int own);
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_user   (int tag, void* data);
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_vec    (int capacity);
marpatcl_rtc_sv_p marpatcl_rtc_sv_cons_vec_cp (marpatcl_rtc_sv_vec v);

#define marpatcl_rtc_sv_cons_evec_i(capacity)	marpatcl_rtc_sv_cons_evec (capacity)
#define marpatcl_rtc_sv_destroy_i(sv)		marpatcl_rtc_sv_destroy (sv)
#endif

void marpatcl_rtc_sv_init_int    (marpatcl_rtc_sv_p sv, int x);
void marpatcl_rtc_sv_init_double (marpatcl_rtc_sv_p sv, double x);
void marpatcl_rtc_sv_init_string (marpatcl_rtc_sv_p sv, const char* s, int own);
void marpatcl_rtc_sv_init_user   (marpatcl_rtc_sv_p sv, int tag, void* data);
void marpatcl_rtc_sv_init_vec    (marpatcl_rtc_sv_p sv, int capacity);
void marpatcl_rtc_sv_init_vec_cp (marpatcl_rtc_sv_p sv, marpatcl_rtc_sv_vec v);
void marpatcl_rtc_sv_init_evec   (marpatcl_rtc_sv_p sv, int capacity);

void marpatcl_rtc_sv_free        (marpatcl_rtc_sv_p sv);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- SV -- lifecycle II, references
 */

marpatcl_rtc_sv_p marpatcl_rtc_sv_ref   (marpatcl_rtc_sv_p v);
void              marpatcl_rtc_sv_unref (marpatcl_rtc_sv_p v);

#ifdef SEM_REF_DEBUG

marpatcl_rtc_sv_p __marpatcl_rtc_sv_ref   (const char* ofile, int oline, marpatcl_rtc_sv_p v);
void              __marpatcl_rtc_sv_unref (const char* ofile, int oline, marpatcl_rtc_sv_p v);

#define marpatcl_rtc_sv_ref_i(v)	__marpatcl_rtc_sv_ref (__FILE__,__LINE__, v)
#define marpatcl_rtc_sv_unref_i(v)	__marpatcl_rtc_sv_unref (__FILE__,__LINE__, v)

#else

#define marpatcl_rtc_sv_ref_i(v)	marpatcl_rtc_sv_ref   (v)
#define marpatcl_rtc_sv_unref_i(v)	marpatcl_rtc_sv_unref (v)
#endif

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- SV -- accessors and mutators
 */

int               marpatcl_rtc_sv_get_int    (marpatcl_rtc_sv_p v);
double            marpatcl_rtc_sv_get_double (marpatcl_rtc_sv_p v);
const char*       marpatcl_rtc_sv_get_string (marpatcl_rtc_sv_p v);
void              marpatcl_rtc_sv_get_user   (marpatcl_rtc_sv_p v, int* tag, void** data);
int               marpatcl_rtc_sv_get_vec    (marpatcl_rtc_sv_p v, marpatcl_rtc_sv_p** data);
void              marpatcl_rtc_sv_vec_set    (marpatcl_rtc_sv_p v, int at, marpatcl_rtc_sv_p x);
marpatcl_rtc_sv_p marpatcl_rtc_sv_vec_get    (marpatcl_rtc_sv_p v, int at);
void              marpatcl_rtc_sv_vec_push   (marpatcl_rtc_sv_p v, marpatcl_rtc_sv_p x);
marpatcl_rtc_sv_p marpatcl_rtc_sv_vec_pop    (marpatcl_rtc_sv_p v);
void              marpatcl_rtc_sv_vec_clear  (marpatcl_rtc_sv_p v);
int               marpatcl_rtc_sv_vec_size   (marpatcl_rtc_sv_p v);

/* Generate string representation of an SV. Tracing support */
TRACE_RUN (char* marpatcl_rtc_sv_show     (marpatcl_rtc_sv_p   v, int* len));
TRACE_RUN (char* marpatcl_rtc_sv_vec_show (marpatcl_rtc_sv_vec v, int* len));
#endif

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
