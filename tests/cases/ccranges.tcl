# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for literal ccranges
##
# Uses the DSL implemented by support/lit.tcl

proc cc-ranges {} {
    ++ 10
    ++ 10

    ++ {{10 20}}
    ++ {{10 20}}

    ++ braille
    ++ {{10240 10495}}

    ++ %braille
    ++ {{10240 10495}}

    ++ {10245 braille}
    ++ {{10240 10495}}

    ++ {34 92 control}
    >>
    ++ {0 31} 34 92 {127 159} 173 {1536 1541} 1564 1757 1807 2274 6158
    ++ {8203 8207} {8234 8238} {8288 8292} {8294 8303} {57344 63743}
    ++ 65279 {65529 65531} 69821 {113824 113827} {119155 119162} 917505
    ++ {917536 917631} {983040 1048573} {1048576 1114109}
    <<

    **
}

# # ## ### ##### ######## #############
return
