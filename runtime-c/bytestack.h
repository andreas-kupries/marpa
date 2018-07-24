/* Runtime for C-engine (RTC). Declarations. (Stacks of bytes)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_BYTESTACK_H
#define MARPATCL_RTC_BYTESTACK_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Constants and structures
 * - Opaque bytestack definition
 * - Indicator to use the internal default for the initial capacity.
 */

#define MARPATCL_RTC_BYTESTACK_DEFAULT_CAP (-1)

typedef struct marpatcl_rtc_bytestack* marpatcl_rtc_bytestack_p;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API - lifecycle, accessors, mutators
 *
 * cons     - construct set with maximal capacity
 * release  - free the set and its contents
 */

marpatcl_rtc_bytestack_p marpatcl_rtc_bytestack_cons    (int initial_capacity);
void                     marpatcl_rtc_bytestack_destroy (marpatcl_rtc_bytestack_p s);
void                     marpatcl_rtc_bytestack_init    (marpatcl_rtc_bytestack_p s,
							 int initial_capacity);
void                     marpatcl_rtc_bytestack_free    (marpatcl_rtc_bytestack_p s);
int                      marpatcl_rtc_bytestack_size    (marpatcl_rtc_bytestack_p s);
void                     marpatcl_rtc_bytestack_push    (marpatcl_rtc_bytestack_p s, int v);
int                      marpatcl_rtc_bytestack_pop     (marpatcl_rtc_bytestack_p s);
int                      marpatcl_rtc_bytestack_get     (marpatcl_rtc_bytestack_p s, int at);
void                     marpatcl_rtc_bytestack_clear   (marpatcl_rtc_bytestack_p s);
void                     marpatcl_rtc_bytestack_move    (marpatcl_rtc_bytestack_p dst,
							 marpatcl_rtc_bytestack_p src, int n);
unsigned char*           marpatcl_rtc_bytestack_data    (marpatcl_rtc_bytestack_p s, int* sz);


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
