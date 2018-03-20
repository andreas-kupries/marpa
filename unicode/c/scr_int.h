/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Definition of types and structures for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints)
 * represented by a Sequence/set of Codepoints and Ranges (SCR).
 */

#ifndef MARAPA_UNICODE_SCR_INT_H
#define MARAPA_UNICODE_SCR_INT_H

#include <scr.h>

/*
 * Character classes as sequence of codepoints and ranges
 *
 * CR  : Single character range (codepoint for start == end)
 * SCR : Sequence/Set of ranges (size, status, ranges)
 */

typedef struct CR {
    int start; /* First uni(code)point in the range */
    int end;   /* Last  uni(code)point in the range */
} CR;

typedef struct SCR {
    int n;     /* #ranges in the class, cr[0...n-1] */
    int max;   /* Allocated #ranges (n <= max) */
    int canon; /* Boolean flag, class is normalized, in canonical form */
    CR* cr;    /* Ranges in the class, may be allocated as part of the structure */
} SCR;

/*
 * Debug API
 */

#ifdef CRITCL_TRACER
extern void
__marpatcl_SCR_DUMP (const char* msg, SCR* scr);
#define SCR_DUMP(m,scr) __marpatcl_SCR_DUMP(m,scr)
#else
#define SCR_DUMP(m,scr)
#endif

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
