/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an ASBR representation.
 */

#ifndef MARAPA_UNICODE_ASBR_OBJTYPE_INT_H
#define MARAPA_UNICODE_ASBR_OBJTYPE_INT_H

#include <asbr_objtype.h>

#define INT_REP       internalRep.otherValuePtr
#define OTASBR_REP(o) ((OTASBR*) (o)->INT_REP)

/*
 * The structure we use for the int rep
 */

typedef struct OTASBR {
    int    refCount; /* Counter indicating sharing status of the structure */
    ASBR_p asbr;     /* Actual intrep, heap allocated */
} OTASBR;

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
