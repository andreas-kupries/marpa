/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints) represented
 * by Alternate Sequences of Byte Ranges (ASBR).
 */

#ifndef MARAPA_UNICODE_ASBR_H
#define MARAPA_UNICODE_ASBR_H

#include <unflags.h> /* Flag values */
#include <scr.h>     /* SCR_p */

/*
 * Opaque structures
 */

typedef struct ASBR* ASBR_p;
typedef struct SBR*  SBR_p;
typedef struct BR*   BR_p;

/*
 * API
 * - constructor (from SCR_p)
 * - destructor
 */

extern ASBR_p marpatcl_asbr_new     (SCR_p scr, int flags);
extern void   marpatcl_asbr_destroy (ASBR_p asbr);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
