/* Runtime for C-engine (RTC). Declarations. (SV for Tcl)
 * - - -- --- ----- -------- ------------- -------------
 * (c) 2017-2018 Andreas Kupries
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
#include <critcl_callback/callback.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- SV -- conversion to Tcl structures
 *     --       generic parse completion
 */

extern Tcl_Obj* marpatcl_rtc_sv_astcl    (Tcl_Interp* ip, marpatcl_rtc_sv_p sv);
extern int      marpatcl_rtc_sv_complete (Tcl_Interp* ip, marpatcl_rtc_sv_p* sv, marpatcl_rtc_p p);

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- Generic lexer support
 */

extern void marpatcl_rtc_lex_init    (marpatcl_rtc_lex_p state);
extern void marpatcl_rtc_lex_release (marpatcl_rtc_lex_p state);
extern void marpatcl_rtc_lex_token   (void*             cdata,
				      marpatcl_rtc_sv_p sv);
// cdata = marpatcl_rtc_lex_p state

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API -- Generic event handling support
 */

extern void marpatcl_rtc_eh_init  (marpatcl_ehandlers_p     e,
				   Tcl_Interp*              ip,
				   marpatcl_events_to_names to_names);
extern void marpatcl_rtc_eh_clear (marpatcl_ehandlers_p e);
extern void marpatcl_rtc_eh_setup (marpatcl_ehandlers_p e,
				   int                  c,
				   Tcl_Obj* const*      v);
extern void marpatcl_rtc_eh_report (void*                  cdata,
				    marpatcl_rtc_eventtype type,
				    int                    c,
				    int*                   ids);
// cdata = marpatcl_ehandlers_p e

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
