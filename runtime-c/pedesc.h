/* Runtime for C-engine (RTC). Declarations. (Parse Event Descriptor)
 * - - -- --- ----- -------- ------------- ---------------------
 * This is effectively part of the C/Tcl glue, see sem_tcl.*
 * May move over.
 *
 * (c) 2018 Andreas Kupries
 * Header for the public types
 */

#ifndef MARPATCL_RTC_PEDESC_H
#define MARPATCL_RTC_PEDESC_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>
#include <tcl.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API --  Parse Event Descriptor -- Limited view into the lexeme match state
 */

extern int  marpatcl_rtc_ped_location   (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_moveto     (marpatcl_rtc_p p, int location);
extern void marpatcl_rtc_ped_moveby     (marpatcl_rtc_p p, int delta);

extern int  marpatcl_rtc_ped_length_get (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_length_set (marpatcl_rtc_p p, int length);

extern int  marpatcl_rtc_ped_start_get  (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_start_set  (marpatcl_rtc_p p, int start);

extern void marpatcl_rtc_ped_sv_get     (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_sv_set     (marpatcl_rtc_p p, int fake);

extern void marpatcl_rtc_ped_syms_get   (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_syms_set   (marpatcl_rtc_p p, int fake);

extern void marpatcl_rtc_ped_value_get  (marpatcl_rtc_p p);
extern void marpatcl_rtc_ped_value_set  (marpatcl_rtc_p p, int fake);

extern void     marpatcl_rtc_ped_alternate  (marpatcl_rtc_p p, int fake);
extern Tcl_Obj* marpatcl_rtc_ped_view       (marpatcl_rtc_p p);

// symbols sv start length value values -- query, write
// alternate
// view (debug)

// TODO: Callbacks (errors?)
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
