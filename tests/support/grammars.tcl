# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Locating the grammar test caes and their adjuncts (ast dump, container api trace (ctrace))

kt require support fileutil::traverse
kt require support fileutil
kt require support lambda

proc test-grammars {iv sv av cv script} {
    upvar 1 $iv id $sv slif $av ast $cv ctrace

    set gdir [file normalize [file join $::tcltest::testsDirectory grammars]]

    fileutil::traverse T $gdir -filter [lambda path {
	string equal "slif" [file tail $path]
    }]
    T foreach slif {
	set stem   [file dirname $slif]
	set id     [string map {/ ,} [fileutil::stripPath $gdir $stem]]
	set ast    [file join $stem ast]
	set ctrace [file join $stem ctrace]
	uplevel 1 $script
    }
    T destroy
    return
}

proc gr-expected {path} {
    set content [fileutil::cat $path]
    set content [string trimright $content]
    set r {}
    # Strip comment lines, and empty lines
    foreach line [split $content \n] {
	if {![string match *failed* $line]} {
	    regsub "#.*\$" $line {} line
	}
	set line [string trim $line]
	if {$line eq {}} continue
	lappend r $line
    }
    return [join $r \n]
}

# # ## ### ##### ######## #############
return
