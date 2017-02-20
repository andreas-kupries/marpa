# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Example of a parser level grammar. Minimal.

proc GG1 {parser} {
    GGBase $parser
    $parser parse NAME {}
    # Name Id
    # ---- --
    # NAME 0
    # A    1
    # B    2
    # a    3
    # b    4
    return
}

proc GG {parser} {
    GGBase $parser W
    # Name Id
    # ---- --
    # NAME 0
    # A    1
    # B    2
    # a    3
    # b    4
    # W    5
    # w    6
    $parser rules {
	{W + w}
    }
    $parser gate: [log GATE]
    $parser parse NAME {}
    return
}

proc GGBase {parser args} {
    $parser symbols {NAME A B a b w}
    $parser symbols $args
    $parser rules {
	{A := a w}
	{B := b}
	{NAME := A}
	{NAME := B}
    }
    return
}

# # ## ### ##### ######## #############
return
