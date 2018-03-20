/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Validation functions for unicode points and ranges.
 */

#ifndef MARAPA_UNICODE_POINT_CHECK_H
#define MARAPA_UNICODE_POINT_CHECK_H

#include <tcl.h>

/*
 * API
 */

extern int marpatcl_get_codepoint_from_obj (Tcl_Interp* ip,
					    Tcl_Obj* obj,
					    int* codepoint);

extern int marpatcl_get_range_from_obj (Tcl_Interp* ip,
					Tcl_Obj* obj,
					int* start,
					int* end);
#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
