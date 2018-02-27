/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Definition of types and structures for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints) represented
 * by Alternate Sequences of Surrogate Ranges (ASSR).
 */

#ifndef MARAPA_UNICODE_ASSR_INT_H
#define MARAPA_UNICODE_ASSR_INT_H

#include <assr.h>

#define MAX_POINTS (2)

/*
 * Character classes as Alternation of Sequences of Surrogate Ranges
 *
 * SR   : Single surrogate range
 * SSR  : Sequence of ranges
 * ASSR : Alternation of sequences
 */

typedef struct SR {
    int start; /* First surrogate in the range */
    int end;   /* Last  surrogate in the range */
} SR;

typedef struct SSR {
    unsigned char n;      /* Length of the sequence */
    SR  sr[MAX_POINTS];    /* Ranges of the sequence */
} SSR;
	
typedef struct ASSR {
    int n;      /* Number of alternates in the class */
    SSR ssr[1]; /* Alternates allocated as part of structure */
} ASSR;

/*
 * Debug API
 */

#ifdef CRITCL_TRACER
extern void __marpatcl_SSR_DUMP   (const char* msg, SSR*   sbr);
extern void __marpatcl_CCSSR_DUMP (const char* msg, ccSSR* ccsbr);
extern void __marpatcl_ASSR_DUMP  (const char* msg, ASSR*  assr);

#define SSR_DUMP(sbr)     __marpatcl_SSR_DUMP(__func__,sbr)
#define CCSSR_DUMP(ccsbr) __marpatcl_CCSSR_DUMP(__func__,ccsbr)
#define ASSR_DUMP(assr)   __marpatcl_ASSR_DUMP(__func__,assr)
#else

#define SSR_DUMP(sbr)
#define CCSSR_DUMP(ccsbr)
#define ASSR_DUMP(assr)
#endif

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
