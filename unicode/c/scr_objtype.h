/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an SCR representation.
 */

#ifndef MARAPA_UNICODE_SCR_OBJTYPE_H
#define MARAPA_UNICODE_SCR_OBJTYPE_H

#include <tcl.h>
#include <scr.h>

typedef struct OTSCR* OTSCR_p;

/*
 * API
 */

extern OTSCR_p marpatcl_otscr_new     (SCR_p scr);
extern void    marpatcl_otscr_destroy (OTSCR_p otscr);
extern OTSCR_p marpatcl_otscr_take    (OTSCR_p otscr);
extern void    marpatcl_otscr_release (OTSCR_p otscr);

extern void marpatcl_scr_rep_free     (Tcl_Obj* o);
extern void marpatcl_scr_rep_dup      (Tcl_Obj* src, Tcl_Obj* dst);
extern void marpatcl_scr_rep_str      (Tcl_Obj* o);
extern int  marpatcl_scr_rep_from_any (Tcl_Interp* ip, Tcl_Obj* o);

extern Tcl_Obj* marpatcl_new_otscr_obj      (OTSCR_p otscr);
extern int      marpatcl_get_otscr_from_obj (Tcl_Interp* ip,
					     Tcl_Obj* o,
					     OTSCR_p* otscrPtr);
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
