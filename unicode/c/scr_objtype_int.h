/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an SCR representation.
 */

#ifndef MARAPA_UNICODE_SCR_OBJTYPE_INT_H
#define MARAPA_UNICODE_SCR_OBJTYPE_INT_H

#include <scr_objtype.h>

#define INT_REP       internalRep.otherValuePtr
#define OTSCR_REP(o) ((OTSCR*) (o)->INT_REP)

/*
 * The structure we use for the int rep
 */
    
typedef struct OTSCR {
    int   refCount; /* Counter indicating sharing status of the structure */
    SCR_p scr;      /* Actual intrep, heap allocated */
} OTSCR;

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
