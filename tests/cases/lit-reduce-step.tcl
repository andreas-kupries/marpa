# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for single-step of literal reduction

proc lit-reduce-step {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL

    # Incrementally fill the table with cases.  The basic flow is
    # covered by what we have now. Extending this is not about
    # coverage anymore, but about seeing the whole deconstruction for
    # all literal types and possible rule-sets.

    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    lit-reduce-step-string
    lit-reduce-step-character
    lit-reduce-step-charclass
    lit-reduce-step-named-class
    lit-reduce-step-range
    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    //
}

# # ## ### ##### ######## #############
proc lit-reduce-step-string {} {
    L string

    +C {}     error RIL
    +C K-STR  error RIL
    +C D-STR1 error RIL
    +C D-STR2 error RIL

    L {string 65 66 300}

    +C {}     error RT
    +C K-STR  ok    {@q {string 65 66 300}}
    +C D-STR1 ok    {@! {composite {{character 65} {character 66} {character 300}}}}
    +C D-STR2 ok    {@! {composite {{byte 65} {byte 66} {byte 196} {byte 172}}}}

    L %string

    +C {}     error RIL
    +C K-%STR error RIL
    +C D-%STR error RIL

    L {%string 97 98}

    +C {}     error  RT
    +C K-%STR ok     {@q {%string 97 98}}
    +C D-%STR ok     {@! {composite {{%character 97} {%character 98}}}}
    #  !----- ------ - -- reduce1 ^^ does not normalize, rstate place does
}

# # ## ### ##### ######## #############
proc lit-reduce-step-character {} {
    L character

    +C {}    error RIL
    +C K-CHR error RIL
    +C D-CHR error RIL

    L {character 65}

    +C {}    error RT
    +C K-CHR ok    {@q {character 65}}
    +C D-CHR ok    {@q {byte 65}}

    L {character 300}

    +C {}    error RT
    +C K-CHR ok    {@q {character 300}}
    +C D-CHR ok    {@! {composite {{byte 196} {byte 172}}}}
    #  !---- ----- -                     ^110.00100 ^10.101100
    #  !---- ----- -                     = 0b'00100  0b'101100
    #  !---- ----- -                     = 0b'00100 101100 = 300

    L ^character

    +C {}     error RIL
    +C K-^CHR error RIL
    +C D-^CHR error RIL

    L {^character 300}

    +C {}     error RT
    +C K-^CHR ok    {@q {^character 300}}
    +C D-^CHR ok    {@x {charclass {0 299} {301 @@@}}}
    #  !----- ----- - using 2 ranges,    -^- 300 excluded

}

# # ## ### ##### ######## #############
proc lit-reduce-step-charclass {} {
    L charclass

    +C {}     error RIL
    +C K-CLS  error RIL
    +C D-CLS1 error RIL
    +C D-CLS2 error RIL
    +C D-CLS3 error RIL

    L {charclass {10 20} 300}

    +C {}     error RT
    +C K-CLS  ok    {@q {charclass {10 20} 300}}
    +C D-CLS1 ok    {@! {composite {{range 10 20}} {{character 300}}}}
    +C D-CLS2 ok    {@! {composite {{brange 10 20}} {{byte 196} {byte 172}}}}
    +C D-CLS3 ok    {@q {charclass {10 20} 300}}

    L {charclass {10 20} braille}

    +C {}     error RT
    +C K-CLS  ok    {@q {charclass {10 20} braille}}
    +C D-CLS1 ok    {@! {composite {{range 10 20}} {{named-class braille}}}}
    +C D-CLS2 ok    {@! {composite {{brange 10 20}} {{byte 226} {brange 160 163} {brange 128 191}}}}
    +C D-CLS3 ok    {@q {charclass {10 20} {10240 10495}}}

    L {charclass 300 braille}

    +C {}     error RT
    +C K-CLS  ok    {@q {charclass 300 braille}}
    +C D-CLS1 ok    {@! {composite {{character 300}} {{named-class braille}}}}
    +C D-CLS2 ok    {@! {composite {{byte 196} {byte 172}} {{byte 226} {brange 160 163} {brange 128 191}}}}
    +C D-CLS3 ok    {@q {charclass 300 {10240 10495}}}

    L {charclass 300 print}

    +C {}     error RT
    +C K-CLS  ok    {@q {charclass 300 print}}
    +C D-CLS1 ok    {@! {composite {{character 300}} {{named-class print}}}}
    #  !----- --    - D-CLS2 skipped, avoid large ASBR
    +C D-CLS3 ok    {@q {charclass 300 print}}

    L {charclass {10 20} 300 braille}

    +C {}     error RT
    +C K-CLS  ok    {@q {charclass {10 20} 300 braille}}
    +C D-CLS1 ok    {@! {composite {{range 10 20}} {{character 300}} {{named-class braille}}}}
    +C D-CLS2 ok    {@! {composite {{brange 10 20}} {{byte 196} {byte 172}} {{byte 226} {brange 160 163} {brange 128 191}}}}
    +C D-CLS3 ok    {@q {charclass {10 20} 300 {10240 10495}}}

    L ^charclass

    +C {}      error RIL
    +C K-^CLS  error RIL
    +C D-^CLS1 error RIL
    +C D-^CLS2 error RIL

    L {^charclass {10 20} 300}

    +C {}      error RT
    +C K-^CLS  ok    {@q {^charclass {10 20} 300}}
    +C D-^CLS1 ok    {@x {charclass {0 9} {21 299} {301 @@@}}}
    +C D-^CLS2 ok    {@q {^charclass {10 20} 300}}

    L {^charclass {10 20} braille}

    +C {}      error RT
    +C K-^CLS  ok    {@q {^charclass {10 20} braille}}
    +C D-^CLS1 ok    {@x {charclass {0 9} {21 10239} {10496 @@@}}}
    +C D-^CLS2 ok    {@q {^charclass {10 20} {10240 10495}}}

    L {^charclass 300 braille}

    +C {}      error RT
    +C K-^CLS  ok    {@q {^charclass 300 braille}}
    +C D-^CLS1 ok    {@x {charclass {0 299} {301 10239} {10496 @@@}}}
    +C D-^CLS2 ok    {@q {^charclass 300 {10240 10495}}}

    L {^charclass {10 20} 300 braille}

    +C {}      error RT
    +C K-^CLS  ok    {@q {^charclass {10 20} 300 braille}}
    +C D-^CLS1 ok    {@x {charclass {0 9} {21 299} {301 10239} {10496 @@@}}}
    +C D-^CLS2 ok    {@q {^charclass {10 20} 300 {10240 10495}}}

    L {^charclass 20 punct}

    +C D-^CLS2 ok {@q {^charclass 20 punct}}


    L {^charclass 34 92 control}

    +C {}      error RT
    +C K-^CLS  ok    {@q {^charclass 34 92 control}}
    +C D-^CLS1 ok    {@x {charclass {32 33} {35 91} {93 126} {160 172} {174 1535} {1542 1563} {1565 1756} {1758 1806} {1808 2273} {2275 6157} {6159 8202} {8208 8233} {8239 8287} 8293 {8304 57343} {63744 65278} {65280 65528} {65532 69820} {69822 113823} {113828 119154} {119163 917504} {917506 917535} {917632 983039} {1048574 1048575} {1114110 1114111}}}
    +C D-^CLS2 ok    {@q {^charclass {0 31} 34 92 {127 159} 173 {1536 1541} 1564 1757 1807 2274 6158 {8203 8207} {8234 8238} {8288 8292} {8294 8303} {57344 63743} 65279 {65529 65531} 69821 {113824 113827} {119155 119162} 917505 {917536 917631} {983040 1048573} {1048576 1114109}}}
}

# # ## ### ##### ######## #############
proc lit-reduce-step-named-class {} {
    L named-class

    +C {}     error RIL
    +C K-NCC  error RIL
    +C D-NCC1 error RIL
    +C D-NCC2 error RIL
    +C D-NCC3 error RIL

    L {named-class braille}

    +C {}     error RT
    +C K-NCC  ok    {@q {named-class braille}}
    +C D-NCC1 ok    {@x {charclass {0x2800 0x28FF}}}
    +C D-NCC2 ok    {@! {composite {{byte 226} {brange 160 163} {brange 128 191}}}}
    +C D-NCC3 ok    {@x {charclass {0x2800 0x28FF}}}

    L {named-class punct}

    +C D-NCC3 ok    {@q {named-class punct}}

    L %named-class

    +C {}      error RIL
    +C K-%NCC  error RIL
    +C D-%NCC1 error RIL
    +C D-%NCC2 error RIL

    L {%named-class braille}

    +C {}      error RT
    +C K-%NCC  ok    {@q {%named-class braille}}
    +C D-%NCC1 ok    {@x {charclass {10240 10495}}}
    +C D-%NCC2 ok    {@! {composite {{byte 226} {brange 160 163} {brange 128 191}}}}

    L {%named-class lu}

    +C {}      error RT
    +C K-%NCC  ok    {@q {%named-class lu}}
    +C D-%NCC1 ok    {@x {@result<lu.nocase.ncc1.<M>>}}
    +C D-%NCC2 ok    {@! {@result<lu.nocase.ncc2.<M>>}}

    L ^named-class

    +C {}      error RIL
    +C K-^NCC  error RIL
    +C D-^NCC1 error RIL
    +C D-^NCC2 error RIL

    L {^named-class braille}

    +C {}      error RT
    +C K-^NCC  ok    {@q {^named-class braille}}
    +C D-^NCC1 ok    {@x {charclass {0 10239} {10496 @@@}}}
    +C D-^NCC2 ok    {@x {charclass {0 10239} {10496 @@@}}}

    L {^named-class punct}

    +C D-^NCC2 ok    {@q {^named-class punct}}

    L ^%named-class

    +C {}       error RIL
    +C K-^%NCC  error RIL
    +C D-^%NCC1 error RIL
    +C D-^%NCC2 error RIL

    L {^%named-class braille}

    +C {}       error RT
    +C K-^%NCC  ok    {@q {^%named-class braille}}
    +C D-^%NCC1 ok    {@x {charclass {0 10239} {10496 @@@}}}
    +C D-^%NCC2 ok    {@! {@result<braille.neg.nocase.ncc2.<M>>}}

    L {^%named-class lu}

    +C {}       error RT
    +C K-^%NCC  ok    {@q {^%named-class lu}}
    +C D-^%NCC1 ok    {@x {@result<lu.neg.nocase.ncc1.<M>>}}
    +C D-^%NCC2 ok    {@! {@result<lu.neg.nocase.ncc2.<M>>}}
}

# # ## ### ##### ######## #############
proc lit-reduce-step-range {} {
    L range

    +C {}     error RIL
    +C K-RAN  error RIL
    +C D-RAN1 error RIL
    +C D-RAN2 error RIL

    L {range 20 10}

    +C {}     error REL
    +C K-RAN  error REL
    +C D-RAN1 error REL
    +C D-RAN2 error REL

    L {range 10 10}

    +C {}     error REL
    +C K-RAN  error REL
    +C D-RAN1 error REL
    +C D-RAN2 error REL

    L {range 10 11}

    +C {}     error RT
    +C K-RAN  ok    {@q {range 10 11}}
    +C D-RAN1 ok    {@! {composite {{character 10}} {{character 11}}}}
    +C D-RAN2 ok    {@q {brange 10 11}}

    L %range

    +C {}     error RIL
    +C K-%RAN error RIL
    +C D-%RAN error RIL

    L {%range 20 10}

    +C {}     error REL
    +C K-%RAN error REL
    +C D-%RAN error REL

    L {%range 10 10}

    +C {}     error REL
    +C K-%RAN error REL
    +C D-%RAN error REL

    L {%range 97 99}

    +C {}     error RT
    +C K-%RAN ok    {@q {%range 97 99}}
    +C D-%RAN ok    {@x {charclass {65 67} {97 99}}}

    L ^range

    +C {}      error RIL
    +C K-^RAN  error RIL
    +C D-^RAN1 error RIL
    +C D-^RAN2 error RIL

    L {^range 0 @@@}

    +C {}      error REL
    +C K-^RAN  error REL
    +C D-^RAN1 error REL
    +C D-^RAN2 error REL

    L {^range 0 10}

    +C {}      error RT
    +C K-^RAN  ok    {@q {^range 0 10}}
    +C D-^RAN1 ok    {@x {range 11 @@@}}
    +C D-^RAN2 ok    {@! {@result<range.0-10.neg.ran2.<M>>}}

    L {^range 20 @@@}

    +C {}      error RT
    +C K-^RAN  ok    {@q {^range 20 @@@}}
    +C D-^RAN1 ok    {@x {range 0 19}}
    +C D-^RAN2 ok    {@q {brange 0 19}}

    L {^range 10 20}

    +C {}      error RT
    +C K-^RAN  ok    {@q {^range 10 20}}
    +C D-^RAN1 ok    {@x {charclass {0 9} {21 @@@}}}
    +C D-^RAN2 ok    {@! {@result<range.10-20.neg.ran2.<M>>}}
}

# # ## ### ##### ######## #############
return
