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

# - dictsort -
#
#  Sort a dictionary by its keys. I.e. reorder the contents of the
#  dictionary so that in its list representation the keys are found in
#  ascending alphabetical order. In other words, this command creates
#  a canonical list representation of the input dictionary, suitable
#  for direct comparison.
#
# Arguments:
#       dict:   The dictionary to sort.
#
# Result:
#       The canonical representation of the dictionary.

proc dictsort {dict} {
    array set a $dict
    set out [list]
    foreach key [lsort [array names a]] {
        lappend out $key $a($key)
    }
    return $out
}

# # ## ### ##### ######## #############
return
