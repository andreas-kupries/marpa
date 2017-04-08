# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Pretty printing a serialization coming out of the SLIF container

proc pretty-gcstate {serial {step {    }}} {
    set lines {}
    pretty-gcstate-acc $serial {} $step {}
    return [join $lines \n]
}

proc pretty-gcstate-acc {serial indent step parent} {
    upvar 1 lines lines

    set key [lindex [split $parent /] end]

    switch -exact -- $parent {
	{} {
	    set block grammar
	    set attr  {global g1 lexeme l0}
	}
	/global {
	    set block $key
	    set attr  {start inaccessible}
	}
	/g1 {
	    set block $key
	    set attr [lsort -dict [dict keys $serial]]
	    # TODO: override parent
	}
	/lexeme {
	    set block $key
	    set attr  {action bless}
	}
	/l0 {
	    set block $key
	    set attr [lsort -dict [dict keys $serial]]
	    # TODO: override parent
	}
	default {
	    # Scalars are written as is, and stop.
	    pretty-gcs [list $key $serial]
	    return
	}
    }

    pretty-gcs "[list $block] \{"
    foreach a $attr {
	if {![dict exists $serial $a]} continue
	set v [dict get $serial $a]
	pretty-gcstate-acc $v $indent$step $step $parent/$a
    }
    pretty-gcs "\}"

    # serial = dict (... nested ...)
    # Keys:
    # - global
    # - g1
    # - l0
    # - lexeme

    # Sub keys to manage in the recursions
    # -(global) start, inacessible
    # -(g1)     <symbols>
    # -(l0)     <symbols>
    # -(lexeme) action, bless
    return
}

proc pretty-gcs {text} {
    upvar 1 lines lines indent indent
    lappend lines "${indent}$text"
    return
}


# # ## ### ##### ######## #############
return
