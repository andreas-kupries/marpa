# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for literal decoding (part of parsing)

proc lit-decode {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL

    # lexeme details-as-class details-as-string
    
    ++ abcdef                 {{97 102}}            {97 98 99 100 101 102}
    ++ a-z                    {{97 122}}            {97 45 122}
    ++ {[:braille:]}          {braille}             {91 58 98 114 97 105 108 108 101 58 93}
    ++ --z                    {{45 122}}            {45 45 122}
    ++ %--                    {{37 45}}             {37 45 45}
    ++ a-z0-9%                {37 {48 57} {97 122}} {97 45 122 48 45 57 37}
    ++ {0-9[:alnum:]}         {{48 57} alnum}       {48 45 57 91 58 97 108 110 117 109 58 93}

    ++ {[:braille:][:alnum:]}
    ++ {alnum braille}
    ++ {91 58 98 114 97 105 108 108 101 58 93 91 58 97 108 110 117 109 58 93}

    ++ "\"\\\\\[:control:]"
    ++ {34 92 control}
    ++ {34 92 92 91 58 99 111 110 116 114 111 108 58 93}
    
    **
}

# # ## ### ##### ######## #############
return
