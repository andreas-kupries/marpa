# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for generators. Formatting of a GC serialization for human
# readability.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::reformat 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Formatting of a GC
# Meta description serialization for human readability
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta subject     marpa {human readable serialization} {readable serialization}
# Meta subject     {serialization, readable} {formatted serialization}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/gen/reformat
debug prefix marpa/gen/reformat {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen {
    namespace export reformat
    namespace ensemble create
}

# # ## ### ##### ######## #############
## API

proc ::marpa::gen::reformat {serial {indent {	}} {step {    }}} {
    debug.marpa/gen/reformat {}
    set lines {}
    FormatInto lines $serial $indent $step / /
    return [string trimright [join $lines \n]] ;# chop trailing whitespace
}

proc ::marpa::gen::FormatInto {lv serial indent step parent key} {
    upvar 1 $lv lines
    #set key [lindex [split $parent /] end]

    switch -exact -- $parent {
	/ {
	    set block ""
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
		AddLine "[list $key] \{\}"
		return
	    }
	    # serial :: dict (symbol -> when -> name -> state)
	    AddLine "[list $key] \{"
	    Indent {
		foreach symbol [lsort -dict [dict keys $serial]] {
		    set events [dict get $serial $symbol]
		    # events :: dict (when -> name -> state)
		    AddLine "[list $symbol] \{"
		    Indent {
			foreach when [lsort -dict [dict keys $events]] {
			    set specs [dict get $events $when]
			    # specs :: dict (name -> state)
			    AddLine "$when \{"
			    Indent {
				foreach name [lsort -dict [dict keys $specs]] {
				    AddLine "[list $name] [dict get $specs $name]"
				}
			    }
			    AddLine "\}"
			}
		    }
		    AddLine "\}"
		}
	    }
	    AddLine "\}"
	    return
	}
	//l0/ - //g1/ - //g1/terminal - //l0/lexeme - //l0/discard - //l0/literal {
	    #puts XXX.0|$serial|
	    if {![dict size $serial]} {
		# No symbols in this collection.
		AddLine "[list $key] \{\}"
		return
	    }
	    # serial :: dict (symbol -> spec...)
	    AddLine "[list $key] \{"
	    Indent {
		foreach symbol [lsort -dict [dict keys $serial]] {
		    set avalue [dict get $serial $symbol]
		    # avalue = list (spec)
		    if {[llength $avalue] < 2} {
			# No definition (impossible), or only one.
			set spec [Spec [lindex $avalue 0]]
			AddLine "[list $symbol] \{ [list $spec] \}"
		    } else {
			AddLine "[list $symbol] \{"
			Indent {
			    foreach spec $avalue {
				AddLine "[list [Spec $spec]]"
			    }
			}
			AddLine "\}"
		    }
		}
	    }
	    AddLine "\}"
	    return
	}
	default {
	    # Scalars are written as is, and stop.
	    AddLine [list $key $serial]
	    return
	}
    }

    if {$block ne ""} {
	AddLine "[list $block] \{"
    }
    if {[info exist xparent]} {
	foreach a $attr {
	    if {![dict exists $serial $a]} continue
	    set v [dict get $serial $a]
	    FormatInto lines $v $indent$step $step $xparent $a
	}
    } else {
	foreach a $attr {
	    if {![dict exists $serial $a]} continue
	    set v [dict get $serial $a]
	    FormatInto lines $v $indent$step $step $parent/$a $a
	}
    }
    if {$block ne ""} {
	AddLine "\}"
    }

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

proc ::marpa::gen::Spec {spec} {
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
	    byte - brange - \
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

proc ::marpa::gen::Indent {script} {
    upvar 1 indent indent step step
    set save $indent
    append indent $step
    uplevel 1 $script
    set indent $save
    return
}

proc ::marpa::gen::AddLine {text} {
    upvar 1 lines lines indent indent
    lappend lines "${indent}$text"
    return
}

# # ## ### ##### ######## #############
package provide marpa::gen::reformat 1
return
