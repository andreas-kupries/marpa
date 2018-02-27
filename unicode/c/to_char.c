/*
 * (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *                               http://core.tcl.tk/akupries/
 * This code is BSD-licensed.
 *
 * Recording of unicodepoints to utf-8 sequences of bytes. Two flags
 * control the handling of \0, and of characters outside the BMP.
 */

#include <to_utf.h>
#include <scr_int.h>

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>
  
#define EMIT(v)					\
    ASSERT (index < 2, "too many characters");	\
    cr[index].start = cr[index].end = (v);	\
    index ++ ; *n = index

void
marpatcl_to_char (CR cr[2], int* n, int codepoint) {
    int index = 0;

    if (codepoint <= 65535) {
	EMIT (codepoint);
	return;
    }
    codepoint -= 0x10000;
    EMIT (((codepoint >> 10) & 0x03FF) | 0xD800);
    EMIT (( codepoint        & 0x03FF) | 0xDC00);
    return;
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

 /*
  * Local Variables:
  * mode: c
  * c-basic-offset: 4
  * fill-column: 78
  * End:
  */
