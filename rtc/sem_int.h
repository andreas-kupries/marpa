/*
 * RunTime C
 * Declarations.
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Sub header: vector of semantic values (dynamic array)
 */

#ifndef MARPA_RTC_SEM_INT_H
#define MARPA_RTC_SEM_INT_H

#include <sem.h>

/*
 * Structure of SV vectors (stack-like)
 */

typedef struct marpa_rtc_sv_array {
    int                   capacity; /* Number of elements allocated for `data` */
    int                   size;     /* Number of elements used in `data` */
    int                   strict;   /* Flag. `true` prevents vector expansion */
    marpa_rtc_semvalue_p* data;     /* Array of **pointers** to the sem values */
} marpa_rtc_sv_array;

/*
 * The `array of pointers` was chosen over an `array of structures` to prevent
 * breakage of external links to values, when the array is expanded. The
 * reallocation can move it around.
 */

/*
 * API -- lifecycle
 */

marpa_rtc_sv_vec marpa_rtc_sva_cons    (int capacity, int strict);
void             marpa_rtc_sva_destroy (marpa_rtc_sv_vec v);

void             marpa_rtc_sva_init (marpa_rtc_sv_vec v, int capacity, int strict);
void             marpa_rtc_sva_free (marpa_rtc_sv_vec v);

/*
 * API -- accessors and mutators
 */

void                 marpa_rtc_sva_push  (marpa_rtc_sv_vec v, marpa_rtc_semvalue_p x);
marpa_rtc_semvalue_p marpa_rtc_sva_pop   (marpa_rtc_sv_vec v);
void                 marpa_rtc_sva_clear (marpa_rtc_sv_vec v);
int                  marpa_rtc_sva_size  (marpa_rtc_sv_vec v);

void                 marpa_rtc_sva_set   (marpa_rtc_sv_vec v, int at, marpa_rtc_semvalue_p x);
marpa_rtc_semvalue_p marpa_rtc_sva_get   (marpa_rtc_sv_vec v, int at);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
