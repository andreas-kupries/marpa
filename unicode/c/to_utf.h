/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints
 */

#ifndef MARAPA_UNICODE_TO_UTF_H
#define MARAPA_UNICODE_TO_UTF_H

#include <unflags.h> /* Flag values */
#include <asbr.h>    /* SBR_p */

/*
 * API
 */

extern void marpatcl_to_utf (SBR_p sbr, int codepoint, int flags);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
