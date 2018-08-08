
# # ## ### ##### ######## ############# #####################
## Test case support - Lexer creation and cleanup, data capture

proc setup {} {
    global TRACE
    [gen cget cl] create LEX
    set TRACE {}
}

proc cleanup {} {
    global TRACE
    LEX destroy
    unset TRACE
}

proc capture {m args} {
    if {$m ne "enter"} return
    # args = list (list(symbol), list(value))
    lassign $args symbols svalues
    set svalues [lsort -uniq $svalues]
    if {[llength $svalues] == 1} {
	set svalues [lindex $svalues 0]
    }
    lappend ::TRACE $svalues
    return
}

# # ## ### ##### ######## ############# #####################
## Lexer class generation and cleanup

proc lex-setup {lexaction} {
    global clsave
    set clsave [gen cget cl]
    set grsave [gen cget gr]

    set gr [td]/g_$lexaction
    set cl ${clsave}-$lexaction

    # Override the lexer semantics specified by the origin grammar
    # with what we wish to test.
    lappend map "lexeme default =\n  action => \[start,length,value\]"
    lappend map "lexeme default = action => \[$lexaction\]"
    fileutil::writeFile $gr [string map $map [fget $grsave]]

    gen setup cl $cl gr $gr

    # Cleanup of helper grammar
    gen configure gr $grsave
    file delete $gr
    return
}

proc lex-cleanup {lexaction} {
    global clsave
    # Destroy class in memory
    rename [gen cget cl] {}
    # and its disk files
    gen cleanup
    gen configure cl $clsave
    return
}

# # ## ### ##### ######## ############# #####################
