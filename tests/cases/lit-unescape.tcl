# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for handling of escapes in literal lexemes
# Part of literal decoding, of literal parsing

proc lit-unescape {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL
    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%%
    # Deal with \-escapes in literals (strings, and charclasses).
    # Convert to regular Tcl characters.
    # Attention: In BMP mode characters outside of the BMP
    # are coded as surrogate pair

    # Possibilities:
    # - unescaped regular
    # - named:   \[nrtfv\']-] (more ? ab...) CHECK Tcl docs
    # - hexes:   \xHH, \xHHHHHH...
    # - octals:  \O, \OO, \OOO
    # - unicode: \uHHHH, \uHHHHH, \uHHHHHH,
    
    ++ "abcdef"                            "abcdef"
    ++ "\\n\\r\\t\\f\\v\\a\\'\\\]\\-\\\\"  "\n\r\t\f\v\a'\]-\\"
    ++ "\xFFFFFFFFFFFF"                    [CORE "\xFF" "\377FFFFFFFFFF"]
    ++ "\\3"                               "\3"
    ++ "\\37"                              "\37"
    ++ "\\377"                             "\377"
    ++ "\\u2202"                           "\u2202"

    if 0 {  
	if 1 {
	    ++ "\\u10F60F" "\U0010F60F"
	} else {
	    ++ "\\u10F60F" "\u....\u...."
	}
    }

    **
}

# # ## ### ##### ######## #############
return
