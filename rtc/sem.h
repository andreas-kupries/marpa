/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Semantic values, and AST of such.
 */

#ifndef MARPA_RTC_SEM_H
#define MARPA_RTC_SEM_H

#include <marpa.h>

/*
 * Opaque declarations for SV references and SV vectors (stack-like)
 */

typedef struct marpa_rtc_semvalue*  marpa_rtc_semvalue_p;
typedef struct marpa_rtc_sv_array*  marpa_rtc_sv_vec;

/*
 * Structure of a single semantic value
 */

typedef struct marpa_rtc_semvalue {
    int tag;      /* type tag to identify what value field to, plus flags
		   * (type-dependent, (x)) */
    int refCount; /* number of references to the value */
    union {
	char*            string; /* value is a null-terminated UTF-8 string */
	int              inum;   /* value is integer number */
	double           fnum;   /* value is floating point number */
	void*            user;   /* value is user-specific anything */
	marpa_rtc_sv_vec vec;    /* value is vector of values */
    } value;
} marpa_rtc_semvalue;

/*
 * (x) The lowest 4 bits of tag are the flags.
 *     The actual tag value is stored shifted 4 bits up.
 */

/*
 * Type tags, internal.
 * User tags must be >= 0.
 * Negative values are reserved for the internal tags.
 */

#define marpa_rtc_sv_type_string (-1)
#define marpa_rtc_sv_type_int    (-2)
#define marpa_rtc_sv_type_double (-3)
#define marpa_rtc_sv_type_user (-4)
#define marpa_rtc_sv_type_vec    (-5)

/*
 * -- Note: The details of the vector type are hidden from users.
 * -- Note: The vector type is the key to ASTs.
 *          Each inner node of an AST is a vector-type semantic value
 *          referencing nodes and non-vector values (== leafs).
 */

/*
 * API -- SV -- lifecycle
 */

marpa_rtc_semvalue_p marpa_rtc_semvalue_cons_int    (int x);
marpa_rtc_semvalue_p marpa_rtc_semvalue_cons_double (double x);
marpa_rtc_semvalue_p marpa_rtc_semvalue_cons_string (const char* s, int copy);
marpa_rtc_semvalue_p marpa_rtc_semvalue_cons_user   (int tag, void* data);
marpa_rtc_semvalue_p marpa_rtc_semvalue_cons_vec    (int capacity);

void marpa_rtc_semvalue_init_int    (marpa_rtc_semvalue_p v, int x);
void marpa_rtc_semvalue_init_double (marpa_rtc_semvalue_p v, double x);
void marpa_rtc_semvalue_init_string (marpa_rtc_semvalue_p v, const char* s, int copy);
void marpa_rtc_semvalue_init_user   (marpa_rtc_semvalue_p v, int tag, void* data);
void marpa_rtc_semvalue_init_vec    (marpa_rtc_semvalue_p v, int capacity);

void marpa_rtc_semvalue_destroy (marpa_rtc_semvalue_p v);
void marpa_rtc_semvalue_free    (marpa_rtc_semvalue_p v);

/*
 * API -- SV -- lifecycle II, references
 */

marpa_rtc_semvalue_p marpa_rtc_semvalue_ref   (marpa_rtc_semvalue_p v);
void                 marpa_rtc_semvalue_unref (marpa_rtc_semvalue_p v);

/*
 * API -- SV -- accessors and mutators
 */

int         marpa_rtc_semvalue_get_int    (marpa_rtc_semvalue_p v);
double      marpa_rtc_semvalue_get_double (marpa_rtc_semvalue_p v);
const char* marpa_rtc_semvalue_get_string (marpa_rtc_semvalue_p v);
void        marpa_rtc_semvalue_get_user   (marpa_rtc_semvalue_p v, int* tag, void** data);
int         marpa_rtc_semvalue_get_vec    (marpa_rtc_semvalue_p v, marpa_rtc_semvalue_p** data);

void                 marpa_rtc_semvalue_vec_set   (marpa_rtc_semvalue_p v, int at, marpa_rtc_semvalue_p x);
marpa_rtc_semvalue_p marpa_rtc_semvalue_vec_get   (marpa_rtc_semvalue_p v, int at);
void                 marpa_rtc_semvalue_vec_push  (marpa_rtc_semvalue_p v, marpa_rtc_semvalue_p x);
marpa_rtc_semvalue_p marpa_rtc_semvalue_vec_pop   (marpa_rtc_semvalue_p v);
void                 marpa_rtc_semvalue_vec_clear (marpa_rtc_semvalue_p v);
int                  marpa_rtc_semvalue_vec_size  (marpa_rtc_semvalue_p v);
		     
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
