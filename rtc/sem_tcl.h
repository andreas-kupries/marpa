/* Runtime for C-engine (RTC). Declarations. (SV for Tcl)
 * - - -- --- ----- -------- ------------- -------------
 * (c) 2017 Andreas Kupries
 */

#ifndef MARPATCL_RTC_SEM_TCL_H
#define MARPATCL_RTC_SEM_TCL_H

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Requirements
 */

#include <rtc.h>
#include <sem.h>
#include <tcl.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- SV -- conversion to Tcl structures
 *     --       generic parse completion
 */

extern Tcl_Obj* marpatcl_rtc_sv_astcl    (Tcl_Interp* ip, marpatcl_rtc_sv_p sv);
extern int      marpatcl_rtc_sv_complete (Tcl_Interp* ip, marpatcl_rtc_sv_p* sv, marpatcl_rtc_p p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
