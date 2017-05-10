# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Locating the grammar test caes and their adjuncts
## (ast dump, container api trace (ctrace))

kt require support fileutil::traverse
kt require support fileutil
kt require support lambda

proc test-grammar-files {key __ iv varname script} {
    upvar 1 $iv id $varname iter

    set gdir [grdir]

    fileutil::traverse T $gdir -filter [lambda {key path} {
	string equal $key [file tail $path]
    } $key]
    set files [lreverse [T files]]
    # Reversal because T returns files in reverse lexicographical order.
    # This is also the reason for not using (T foreach).
    T destroy
    foreach iter $files {
	set stem  [file dirname $iter]
	set id    [string map {/ ,} [fileutil::stripPath $gdir $stem]]
	uplevel 1 $script
    }
    return
}

proc test-grammar-map {key __ iv varname basevar script} {
    upvar 1 $iv id $varname iter $basevar stem

    set gdir [grdir]

    fileutil::traverse T $gdir -filter [lambda {key path} {
	string equal $key [file tail $path]
    } $key]
    set files [lreverse [T files]]
    # Reversal because T returns files in reverse lexicographical order.
    # This is also the reason for not using (T foreach).
    T destroy
    foreach iter $files {
	set stem   [file dirname $iter]
	set id     [string map {/ ,} [fileutil::stripPath $gdir $stem]]
	uplevel 1 $script
    }
    return
}

# # ## ### ##### ######## #############
return
