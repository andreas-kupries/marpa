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
#include <asbr_int.h>
#include <unidata.h> /* UNI_MAX */

#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>

TRACE_OFF;
  
#define EMIT(v)						\
    ASSERT (index < MAX_BYTES, "too many utf bytes");	\
    sbr->br[index].start = sbr->br[index].end = (v);	\
    index ++ ; sbr->n = index

void
marpatcl_to_utf (SBR* sbr, int codepoint, int flags) {
    int index = 0;

    if ((flags & MARPATCL_MUTF) && (codepoint == 0)) {
	EMIT (0xC0);
	EMIT (0x80);
	return;
    }
	
    if (codepoint < 128) {
	EMIT (codepoint & 0x7f);
	return;
    }

    if (codepoint < 2048) {
	EMIT (((codepoint >> 6) & 0x1F) | 0xC0);
	EMIT (((codepoint     ) & 0x3F) | 0x80);
	return;
    }

    if (codepoint < 65536) {
	EMIT (((codepoint >> 12) & 0x0F) | 0xE0);
	EMIT (((codepoint >>  6) & 0x3F) | 0x80);
	EMIT (((codepoint      ) & 0x3F) | 0x80);
	return;
    }

    if (flags & MARPATCL_CESU) {
	/* code = ___________yyyyy xxxxxxxxxxxxxxxx
	 *                         abcdefghijklmnop
	 * E   D    A   ....          E   D    B   ....
	 * 11101101 1010yyyy 10xxxxxx 11101101 1011xxxx 10xxxxxx
	 *                     abcdef              ghij   klmnop
	 *	
	 * The encoding of Unicode supplementary characters works out to
	 * the above. yyyy represents the "top five bits of the character"
	 * minus one.
	 */

	codepoint -= 0x10000;
	
	EMIT (                             0xED);
	EMIT (((codepoint >> 16) & 0x0F) | 0xA0);
	EMIT (((codepoint >> 10) & 0x3F) | 0x80);
	EMIT (                             0xED);
	EMIT (((codepoint >>  6) & 0x0F) | 0xB0);
	EMIT (((codepoint      ) & 0x3F) | 0x80);
	return;
    }

    EMIT (((codepoint >> 18) & 0x07) | 0xF0);
    EMIT (((codepoint >> 12) & 0x3F) | 0x80);
    EMIT (((codepoint >>  6) & 0x3F) | 0x80);
    EMIT (((codepoint      ) & 0x3F) | 0x80);
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
