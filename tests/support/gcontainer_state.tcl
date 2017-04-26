# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
## Pretty printing a serialization coming out of the SLIF container

proc gc-format {serial {step {    }}} {
    set lines {}
    gc-format-acc $serial {} $step / /
    return [string trimright [join $lines \n]] ;# chop trailing whitespace
}

proc gc-format-acc {serial indent step parent key} {
    upvar 1 lines lines

    #set key [lindex [split $parent /] end]

    switch -exact -- $parent {
	/ {
	    set block grammar
	    set attr  {global g1 lexeme l0}
	}
	//global {
	    set block $key
	    set attr  {start inaccessible}
	}
	//g1 {
	    set block $key
	    set attr [lsort -dict [dict keys $serial]]
	}
	//lexeme {
	    set block $key
	    set attr  {action bless}
	}
	//l0 {
	    set block $key
	    set attr [lsort -dict [dict keys $serial]]
	}
	//l0/latm - //l0/priority {
	    set block $key
	    set attr [lsort -dict [dict keys $serial]]
	}
	//l0/events - //g1/events {
	    if {![dict size $serial]} {
		# No symbols in this collection.
		gc-line "[list $key] \{\}"
		return
	    }
	    # serial :: dict (symbol -> when -> name -> state)
	    gc-line "[list $key] \{"
	    gc-indent {
		foreach symbol [lsort -dict [dict keys $serial]] {
		    set events [dict get $serial $symbol]
		    # events :: dict (when -> name -> state)
		    gc-line "[list $symbol] \{"
		    gc-indent {
			foreach when [lsort -dict [dict keys $events]] {
			    set specs [dict get $events $when]
			    # specs :: dict (name -> state)
			    gc-line "$when \{"
			    gc-indent {
				foreach name [lsort -dict [dict keys $specs]] {
				    gc-line "[list $name] [dict get $specs $name]"
				}
			    }
			    gc-line "\}"
			}
		    }
		    gc-line "\}"
		}
	    }
	    gc-line "\}"
	    return
	}
	//l0/ - //g1/ - //g1/terminal - //l0/lexeme - //l0/discard - //l0/literal {
	    #puts XXX.0|$serial|
	    if {![dict size $serial]} {
		# No symbols in this collection.
		gc-line "[list $key] \{\}"
		return
	    }
	    # serial :: dict (symbol -> spec...)
	    gc-line "[list $key] \{"
	    gc-indent {
		foreach symbol [lsort -dict [dict keys $serial]] {
		    set avalue [dict get $serial $symbol]
		    # avalue = list (spec)
		    if {[llength $avalue] < 2} {
			# No definition (impossible), or only one.
			set spec [gc-spec [lindex $avalue 0]]
			gc-line "[list $symbol] \{ [list $spec] \}"
		    } else {
			gc-line "[list $symbol] \{"
			gc-indent {
			    foreach spec $avalue {
				gc-line "[list [gc-spec $spec]]"
			    }
			}
			gc-line "\}"
		    }
		}
	    }
	    gc-line "\}"
	    return
	}
	default {
	    # Scalars are written as is, and stop.
	    gc-line [list $key $serial]
	    return
	}
    }

    gc-line "[list $block] \{"
    if {[info exist xparent]} {
	foreach a $attr {
	    if {![dict exists $serial $a]} continue
	    set v [dict get $serial $a]
	    gc-format-acc $v $indent$step $step $xparent $a
	}
    } else {
	foreach a $attr {
	    if {![dict exists $serial $a]} continue
	    set v [dict get $serial $a]
	    gc-format-acc $v $indent$step $step $parent/$a $a
	}
    }
    gc-line "\}"

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

proc gc-spec {spec} {
    upvar 1 indent indent step step
    switch -exact -- [lindex $spec 0] {
	quantified {
	    set dict [lrange $spec 3 end]
	    set spec [lrange $spec 0 2]

	    # dict sort integrated to result reconstruction
	    array set _ $dict
	    foreach k [lsort -dict [array names _]] {
		append spec \n$indent$step$step$k " " [list $_($k)]
	    }

	    return $spec
	}
	priority {
	    set dict [lrange $spec 3 end]
	    lassign [lrange $spec 0 2] type rhs precedence

	    set spec $type
	    if {[llength $rhs] < 2} {
		# Empty, or single-element RHS, keep as is.
		lappend spec $rhs
		set plus ""
	    } else {
		# Multi-line RHS for a priority rule, each part of the
		# sequence on its own line.
		append spec " \{"
		foreach el $rhs { append spec \n$indent$step$step[list $el] }
		append spec "\}"
		set plus $step
	    }
	    append spec " " $precedence

	    # dict sort integrated to result reconstruction
	    array set _ $dict
	    foreach k [lsort -dict [array names _]] {
		append spec \n$indent$step$step$plus$k " " [list $_($k)]
	    }

	    return $spec
	}
	terminal - \
	    string - %string - \
	    charclass - ^charclass - %charclass - ^%charclass - \
	    character - ^character - \
	    named-class - ^named-class - %named-class - ^%named-class - \
	    range - ^range - %range - ^%range {
		return $spec
	    }
	default {
	    error "Unknown spec type in: [list $spec]"
	}
    }
}

proc gc-indent {script} {
    upvar 1 indent indent step step
    set save $indent
    append indent $step
    uplevel 1 $script
    set indent $save
    return
}

proc gc-line {text} {
    upvar 1 lines lines indent indent
    lappend lines "${indent}$text"
    return
}


# # ## ### ##### ######## #############
return
