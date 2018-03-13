/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints) represented
 * by Alternate Sequences of Surrogate Ranges (ASSR).
 *
 * Note, only post-BMP codepoints and ranges need such a representation.
 * It works for BMP as well, however. These are no surrogates however.
 */

#ifndef MARAPA_UNICODE_ASSR_H
#define MARAPA_UNICODE_ASSR_H

#include <scr.h>     /* SCR_p */

/*
 * Opaque structures
 */

typedef struct ASSR* ASSR_p;
typedef struct SSR*  SSR_p;
typedef struct SR*   SR_p;

/*
 * API
 * - constructor (from SCR_p)
 * - destructor
 */

extern ASSR_p marpatcl_assr_new     (SCR_p scr);
extern void   marpatcl_assr_destroy (ASSR_p assr);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
