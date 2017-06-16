# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Pretty printing an AST coming out of the SLIF parser

proc ast-format {ast {step {  }}} {
    set lines {}
    ast-format-acc $ast {} $step
    return [join $lines \n]
}

proc ast-format-acc {ast indent step} {
    upvar 1 lines lines
    lassign $ast symbol children

    if {[string is integer $symbol]} {
	# Terminal, Data is offset, length, and lexeme value.
	lappend lines ${indent}@[marpa location show $ast]
	return
    }

    lappend lines $indent$symbol
    append indent $step
    foreach child $children {
	ast-format-acc $child $indent $step
    }
    return
}

# # ## ### ##### ######## #############
return
