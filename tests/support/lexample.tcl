# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Example of a lexer level grammar. Minimal.

proc GL1 {lexer} {
    GLBase $lexer
    $lexer discard {}
    # Name ACS Id Upstream
    # a        0
    # b        1
    # w        2
    # A     5  3  0
    # B     6  4  1
    # No discards
    return
}

proc GL {lexer} {
    GLBase $lexer W
    # Name ACS Id Upstream
    # a        0
    # b        1
    # w        2
    # W        3
    # A     6  4  0
    # B     7  5  1

    $lexer rules {
	{W +  w}
    }
    $lexer discard W
    return
}

proc GLBase {lexer args} {
    $lexer symbols {a b w}
    $lexer symbols $args
    $lexer export  {A B}
    $lexer rules {
	{A := a}
	{B := b}
    }
    return
}

# # ## ### ##### ######## #############
return
