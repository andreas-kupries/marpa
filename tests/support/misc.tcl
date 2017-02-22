# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Miscellaneous commands

proc iota {n} {
    set res {}
    for {set i 0} {$i < $n} {incr i} {
        lappend res $i
    }
    return $res
}

proc lmap {f list} {
    set res {}
    foreach x $list {
        lappend res [{*}$f $x]
    }
    return $res
}

# # ## ### ##### ######## #############
return
