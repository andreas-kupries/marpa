/*
 * (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                          http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints
 */

#ifndef MARAPA_UNICODE_TO_CHAR_H
#define MARAPA_UNICODE_TO_CHAR_H

#include <scr_int.h>

/*
 * API
 */

extern void marpatcl_to_char (CR* cr, int*n, int codepoint);

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
