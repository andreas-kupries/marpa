/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Definition of types and structures for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints) represented
 * by Alternate Sequences of Byte Ranges (ASBR).
 */

#ifndef MARAPA_UNICODE_ASBR_INT_H
#define MARAPA_UNICODE_ASBR_INT_H

#include <asbr.h>

#define MAX_BYTES (6)

/*
 * Character classes as Alternation of Sequences of Byte Ranges
 *
 * BR   : Single byte range
 * SBR  : Sequence of ranges
 * ASBR : Alternation of sequences
 */

typedef struct BR {
    unsigned char start; /* First byte in the range */
    unsigned char end;   /* Last  byte in the range */
} BR;

typedef struct SBR {
    unsigned char n;      /* Length of the sequence */
    BR  br[MAX_BYTES];    /* Ranges of the sequence */
} SBR;
	
typedef struct ASBR {
    int n;      /* Number of alternates in the class */
    SBR sbr[1]; /* Alternates allocated as part of structure */
} ASBR;

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
