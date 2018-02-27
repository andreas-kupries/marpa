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

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
