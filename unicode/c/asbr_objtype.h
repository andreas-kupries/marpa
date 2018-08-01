/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an ASBR representation.
 */

#ifndef MARAPA_UNICODE_ASBR_OBJTYPE_H
#define MARAPA_UNICODE_ASBR_OBJTYPE_H

#include <tcl.h>
#include <asbr.h>

typedef struct OTASBR* OTASBR_p;

/*
 * API
 */

extern OTASBR_p marpatcl_otasbr_new     (ASBR_p asbr);
extern void     marpatcl_otasbr_destroy (OTASBR_p otasbr);
extern OTASBR_p marpatcl_otasbr_take    (OTASBR_p otasbr);
extern void     marpatcl_otasbr_release (OTASBR_p otasbr);

extern void marpatcl_asbr_rep_free     (Tcl_Obj* o);
extern void marpatcl_asbr_rep_dup      (Tcl_Obj* src, Tcl_Obj* dst);
extern void marpatcl_asbr_rep_str      (Tcl_Obj* o);
/* from_any == shimmering -- not supported, use `2asbr` */

extern Tcl_Obj* marpatcl_new_otasbr_obj      (OTASBR_p otasbr);
extern int      marpatcl_get_otasbr_from_obj (Tcl_Interp* ip,
					      Tcl_Obj* o,
					      OTASBR_p* otasbrPtr);
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
