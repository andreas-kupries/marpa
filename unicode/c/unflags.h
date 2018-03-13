/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Declaration of structures and functions for the manipulation of
 * unicodepoints
 */

#ifndef MARAPA_UNICODE_UNFLAGS_H
#define MARAPA_UNICODE_UNFLAGS_H

/*
 * API - Flags for to_utf and asbr_new
 */

#define MARPATCL_CESU (1)
#define MARPATCL_MUTF (2)
#define MARPATCL_TCL  (MARPATCL_CESU|MARPATCL_MUTF)

#endif

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
