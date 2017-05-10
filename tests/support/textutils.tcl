# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

kt require support fileutil

# Test suite support.
# # ## ### ##### ######## #############
## Normalize content of traces and other files, various forms and combinations
## - Remove comment lines (#)
## - Remove empty lines
## - Remove leading whitespace (indentation)
## - Remove trailing whitespace

proc norm-trace {path} {
    rejoin [strip-empty [strip-indent [strip-comments [strip-trailing [2lines $path]]]]]
}

proc norm-trace-gc {path} {
    rejoin [strip-empty \
		[strip-indent \
		     [strip-gc-comments \
			  [strip-comments [strip-trailing [2lines $path]]]]]]
}

proc rejoin {lines} {
    join $lines \n
}

proc 2lines {path} {
    split [string trimright [fileutil::cat $path]] \n
}

proc strip-gc-comments {lines} {
    lmap line $lines {
	if {[string match {*GC comment*} $line]} continue
	set line
    }
}

proc strip-comments {lines} {
    lmap line $lines {
	if {![string match *failed* $line]} {
	    regsub "^\\s*#.*\$" $line {} line
	    regsub  "\\s+#.*\$" $line {} line
	}
	set line
    }
}

proc strip-indent {lines} {
    lmap line $lines { string trimleft $line }
}

proc strip-whitespace {lines} {
    lmap line $lines { string trim $line }
}

proc strip-trailing {lines} {
    lmap line $lines { string trimright $line }
}

proc strip-empty {lines} {
    lmap line $lines {
	if {[regexp {^\s*$} $line]} continue
	set line
    }
}

# # ## ### ##### ######## #############
return
