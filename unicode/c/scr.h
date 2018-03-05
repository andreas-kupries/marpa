/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints, and of character classes (sets of unicodepoints)
 * represented by a Sequence/set of Codepoints and Ranges (SCR).
 */

#ifndef MARAPA_UNICODE_SCR_H
#define MARAPA_UNICODE_SCR_H

/*
 * Opaque structures
 */

typedef struct SCR* SCR_p;

/*
 * API
 *
 * - constructor
 * - destructor
 * - extend
 * - normalize
 * - negate/complement/invert
 *
 * Future
 * - Expansion of case-equivalent codepoints (future) -- Requires access to
 *   unicode tables ... Requires tables in C, currently Tcl.
 */

extern SCR_p marpatcl_scr_new        (int n);
extern void  marpatcl_scr_destroy    (SCR_p scr);
extern void  marpatcl_scr_add_range  (SCR_p scr, int first, int last);
extern void  marpatcl_scr_add_code   (SCR_p scr, int codepoint);
extern void  marpatcl_scr_norm       (SCR_p scr);
extern SCR_p marpatcl_scr_complement (SCR_p scr, int smp);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
