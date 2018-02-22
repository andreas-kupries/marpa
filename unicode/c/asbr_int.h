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

/*
 * Debug API
 */

#ifdef CRITCL_TRACER
extern void __marpatcl_SBR_DUMP   (const char* msg, SBR*   sbr);
extern void __marpatcl_CCSBR_DUMP (const char* msg, ccSBR* ccsbr);
extern void __marpatcl_ASBR_DUMP  (const char* msg, ASBR*  asbr);

#define SBR_DUMP(sbr)     __marpatcl_SBR_DUMP(__func__,sbr)
#define CCSBR_DUMP(ccsbr) __marpatcl_CCSBR_DUMP(__func__,ccsbr)
#define ASBR_DUMP(asbr)   __marpatcl_ASBR_DUMP(__func__,asbr)
#else

#define SBR_DUMP(sbr)
#define CCSBR_DUMP(ccsbr)
#define ASBR_DUMP(asbr)
#endif

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
