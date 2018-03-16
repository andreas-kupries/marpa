# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Locating the grammar test caes and their adjuncts
## (ast dump, container api trace (ctrace))

kt require support fileutil::traverse
kt require support fileutil
kt require support lambda
kt local   support marpa::unicode

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
	set code [catch { uplevel 1 $script } msg]
	switch -exact -- $code {
	    0 {}
	    1 { return -code error $msg }
	    2 { return }
	    3 { break }
	    4 {}
	}
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
	set code [catch { uplevel 1 $script } msg]
	switch -exact -- $code {
	    0 {}
	    1 { return -code error $msg }
	    2 { return }
	    3 { break }
	    4 {}
	}
    }
    return
}

proc test-grammar-result {base key} {
    # Find the expected result. Look for mode-specific and plain
    # files. Prefer mode-specific over plain.

    set rfile  [file join $base $key]
    set mode   [marpa unicode mode]
    set rmfile ${rfile}-$mode

    if {[file exists $rmfile]} {
	return [string trimright [fget $rmfile]]
    }
    if {[file exists $rfile]} {
	return [string trimright [fget $rfile]]
    }

    return -code error "No result file found for $base/$key"
}

# # ## ### ##### ######## #############
return
