/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Structures for a Tcl_ObjType wrapped around an ASSR representation.
 */

#ifndef MARAPA_UNICODE_ASSR_OBJTYPE_INT_H
#define MARAPA_UNICODE_ASSR_OBJTYPE_INT_H

#include <assr_objtype.h>

#define INT_REP       internalRep.otherValuePtr
#define OTASSR_REP(o) ((OTASSR*) (o)->INT_REP)

/*
 * The structure we use for the int rep
 */
    
typedef struct OTASSR {
    int    refCount; /* Counter indicating sharing status of the structure */
    ASSR_p assr;     /* Actual intrep, heap allocated */
} OTASSR;

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
