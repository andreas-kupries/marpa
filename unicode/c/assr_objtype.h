/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an ASSR representation.
 */

#ifndef MARAPA_UNICODE_ASSR_OBJTYPE_H
#define MARAPA_UNICODE_ASSR_OBJTYPE_H

#include <tcl.h>
#include <assr.h>

typedef struct OTASSR* OTASSR_p;

/*
 * API
 */

extern OTASSR_p marpatcl_otassr_new     (ASSR_p assr);
extern void     marpatcl_otassr_destroy (OTASSR_p otassr);
extern OTASSR_p marpatcl_otassr_take    (OTASSR_p otassr);
extern void     marpatcl_otassr_release (OTASSR_p otassr);
    
extern void marpatcl_assr_rep_free     (Tcl_Obj* o);
extern void marpatcl_assr_rep_dup      (Tcl_Obj* src, Tcl_Obj* dst);
extern void marpatcl_assr_rep_str      (Tcl_Obj* o);
/* from_any == shimmering -- not supported, use `2assr` */

extern Tcl_Obj* marpatcl_new_otassr_obj      (OTASSR_p otassr);
extern int      marpatcl_get_otassr_from_obj (Tcl_Interp* ip,
					      Tcl_Obj* o,
					      OTASSR_p* otassrPtr);
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
