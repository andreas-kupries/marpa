# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Semantic core class. Processes step instructions, maps rules to
# actions, manages the reduction stack and access to the token store.

# NOTES -- Should I auto-store reduction results to the semstore ?
#          It does auto-load them for 'token' steps ...

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1
package require oo::util      ;# link

debug define marpa/semcore
debug prefix marpa/semcore {} ;# eval takes large argument, keep out.

# # ## ### ##### ######## #############
## Semantic core. 

oo::class create marpa::semcore {
    variable myactionmap ;# (rules|symbols|tokens) -> actions (cmdpfx)

    constructor {semstore actionmap} {
	debug.marpa/semcore {[debug caller] | [marpa::D {
	    # Make a transform for sem values available, for debug
	    # output customized by the engine.
	    set cn [namespace current]
	    if {[dict exists $actionmap sv]} {
		set transform [dict get $actionmap sv]
	    } else {
		set transform [mymethod ID]
	    }

	    interp alias {} ${cn}::TSV {} {*}$transform
	    unset cn transform
	}]}

	# Access to the store of semantic values
	marpa::import $semstore Store

	# Configuration
	set myactionmap $actionmap

	link {Put   Put}
	link {Get   Get}
	link {Get*  Range}

	debug.marpa/semcore {[debug caller 2] | }
	return
    }

    method engine: {engine} {
	debug.marpa/semcore {[debug caller] | [marpa::D {
	    # Access to engine using the semantics, for id conversion
	    # in debug output.
	    marpa::import $engine Engine
	}]}
	return
    }

    method eval {instructions} {
	debug.marpa/semcore {[debug caller 1] | [marpa::D {
	    set n [expr {[llength $instructions]/2}]
	    set w [string length $n]
	    set f "STEP \[%${w}d/$n\] %-5s: %s"
	    set i 0
	}]}

	foreach {type details} $instructions {
	    dict with details {} ;# Import into scope ...

	    # # # TODO Show instruction to be evaluated.

	    #        token          rule           null
	    # ------ -----          ----           ----
	    # id     token-id       rule-id        sym-id
	    # value  stack src loc  -              -
	    # first  -              stack 1st loc  -
	    # last   -              stack end loc  -
	    # dst    stack dst loc  stack dst loc  stack dst loc
	    # ------ -----          ----           ----

	    debug.marpa/semcore {[debug caller 1] | [marpa::D {
		switch -exact -- $type {
		    token {
			dict set details token  [Engine 2Name1 $id]
			dict set details sv     [TSV [Store get $value]]
		    }
		    rule  { dict set details lhs    [Engine LHSname $id] }
		    null  { dict set details symbol [Engine 2Name1  $id] }
		}
	    }][format $f $i $type $details]}

	    switch -exact -- $type {
		token {
		    # We try in order:
		    # 1. Custom action for the token.
		    # 2. Default action capturing any token
		    # 3. Hardwired action

		    if {[dict exists $myactionmap tok:$id]} {
			set cmd [dict get $myactionmap tok:$id]
			lappend cmd $id [Store get $value]
			set v [uplevel #0 $cmd]

		    } elseif {[dict exists $myactionmap tok:@default]} {
			set cmd [dict get $myactionmap tok:@default]
			lappend cmd $id [Store get $value]
			set v [uplevel #0 $cmd]

		    } else {
			set v [Store get $value]
		    }
		}
		rule {
		    # We try in order:
		    # 1. Custom action for the rule.
		    # 2. Default action capturing any rule
		    # 3. Hardwired action

		    if {[dict exists $myactionmap rule:$id]} {
			set cmd [dict get $myactionmap rule:$id]
			lappend cmd $id {*}[Get* $first $last]
			set v [uplevel #0 $cmd]

		    } elseif {[dict exists $myactionmap rule:@default]} {
			set cmd [dict get $myactionmap rule:@default]
			lappend cmd $id {*}[Get* $first $last]
			set v [uplevel #0 $cmd]

		    } else {
			# Essentially copying and aggregating token values
			# I.e. creation of an actual AST.
			set v [list $id {*}[Get* $first $last]]
		    }
		}
		null {
		    # We try in order:
		    # 1. Custom action for the symbol
		    # 2. Default action capturing any symbol
		    # 3. Hardwired action

		    if {[dict exists $myactionmap sym:$id]} {
			set cmd [dict get $myactionmap sym:$id]
			lappend cmd $id [Get $value]
			set v [uplevel #0 $cmd]

		    } elseif {[dict exists $myactionmap sym:@default]} {
			set cmd [dict get $myactionmap sym:@default]
			lappend cmd $id [Get $value]
			set v [uplevel #0 $cmd]

		    } else {
			set v {}
		    }
		}
	    }
	    Put $dst $v
	    debug.marpa/semcore {[debug caller 1] |   <$dst> := ($v)[marpa::D {
		incr i
	    }]}
	}

	# Return last stored semantic value as the semantics.
	set sv [Get $dst]
	debug.marpa/semcore {[debug caller 1] | ==> ([TSV $sv])}
	return $sv
    }

    # # ## ### ##### ######## #############
    ## Internal support - Stack accessors

    method Put {n v} {
	debug.marpa/semcore {[debug caller 2] | ([TSV $v]) }
	upvar 1 stack stack
	dict set stack $n $v
	return
    }

    method Get {n} {
	debug.marpa/semcore {[debug caller] | }
	upvar 1 stack stack
	if {![dict exists $stack $n]} {
	    set v {}
	} else {
	    set v [dict get $stack $n]
	}
	debug.marpa/semcore {[debug caller] | ==> ([TSV $v])}
	return $v
    }

    method Range {start end} {
	debug.marpa/semcore {[debug caller] | }
	upvar 1 stack stack
	set r {}
	for {set i $start} {$i <= $end} {incr i} {
	    lappend r [Get $i]
	}
	debug.marpa/semcore {[debug caller] | ==> ([TSV $r])}
	return $r
    }

    # Debug support, std sem value transform - no op
    method ID {x} { return $x }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/semcore {[debug caller] | }
	return -code error \
	    -errorcode [linsert $args 0 MARPA SEMCORE] \
	    $msg
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
