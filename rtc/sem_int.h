/* Runtime for C-engine (RTC). Declarations. (Semantic values, and ASTs)
 *                             Internal.
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SEM_INT_H
#define MARPATCL_RTC_SEM_INT_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <sem.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Structures -- SV vectors (stack-like)
 */

typedef struct marpatcl_rtc_sva {
    int                capacity; /* Number of elements allocated for `data` */
    int                size;     /* Number of elements used in `data` */
    int                strict;   /* Flag. `true` prevents vector expansion */
    marpatcl_rtc_sv_p* data;     /* Array of **pointers** to the sem values */
/*
 * The `array of pointers` was chosen over an `array of structures` to prevent
 * breakage of external links to values, when the array is expanded. The
 * reallocation can move it around.
 */
} marpatcl_rtc_sva;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- lifecycle, accessor, mutators
 *
 * cons    - create an SV vector (with predefined capacity, strict vs expandable)
 * destroy - release an SV vector
 * init    - initialize a pre-existing SV vector structure
 * free    - release SV vector content
 * push    - Add SV at end of vector. Fail if hitting capacity and not expandable
 * pop     - Return SV at end of vector, remove from vector
 * clear   - Remove everything from the vector
 * size    - Return current size of vector
 * set     - Store SV into a specific slot of the vector
 * get     - Get SV stored in specififc slot of the vector
 */

marpatcl_rtc_sv_vec marpatcl_rtc_sva_cons    (int capacity, int strict);
void                marpatcl_rtc_sva_destroy (marpatcl_rtc_sv_vec v);
void                marpatcl_rtc_sva_init    (marpatcl_rtc_sv_vec v, int capacity, int strict);
void                marpatcl_rtc_sva_free    (marpatcl_rtc_sv_vec v);
void                marpatcl_rtc_sva_push    (marpatcl_rtc_sv_vec v, marpatcl_rtc_sv_p x);
marpatcl_rtc_sv_p   marpatcl_rtc_sva_pop     (marpatcl_rtc_sv_vec v);
void                marpatcl_rtc_sva_clear   (marpatcl_rtc_sv_vec v);
int                 marpatcl_rtc_sva_size    (marpatcl_rtc_sv_vec v);
void                marpatcl_rtc_sva_set     (marpatcl_rtc_sv_vec v, int at, marpatcl_rtc_sv_p x);
marpatcl_rtc_sv_p   marpatcl_rtc_sva_get     (marpatcl_rtc_sv_vec v, int at);

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
