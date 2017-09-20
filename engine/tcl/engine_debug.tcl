# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Mixin class containing debugging helper code. The class and code are
# used and activated only for certain debug tags. The main point is to
# keep debug dependencies (matrix) away from the main engine.

#oo::objdefine [self] mixin marpa::engine::debug
#oo::define marpa::engine mixin marpa::engine::debug

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.

# # ## ### ##### ######## #############

oo::class create marpa::engine::debug {
    # # ## ### ##### ######## #############
    ## I. Properly formatted debug reports for a location
    ##    - work horse method
    ##    - debug method

    method progress-report-current {} {
	my progress-report [RECCE latest-earley-set]
    }

    method progress-report {location} {
	# NOTE: This method is intended for use in debug.* commands.
	# Do __not__ add debug.* commands here.
	##
	set report {**undefined**}
	try {
	    set n [RECCE report-start $location]
	    package require struct::matrix
	    struct::matrix M
	    M add columns 6
	    # (%%) cols = (indent rule span lhs arrow rhs+dot)
	    for {} {$n > 0} {incr n -1} {
		lassign [RECCE report-next] rule dot origin
		# Compute human readable fields
		lassign [my RuleNameData $rule] lhs rhs
		lassign [my DRule $rule $dot $rhs] ddot drule
		set drhs [string map {<.> .} [join [my DNames [linsert $rhs $ddot .]] { }]]

		# And save...
		#(r$rule,d$dot,o$origin)
		M add row [list ______ $drule @$origin-${location} <${lhs}> --> $drhs]
		# (%%)          0      1      2                    3        4     5
		#               indent ^rule  ^span                lhs      arrow rhs+dot
	    }
	    set report [my TrimTrailingWS [M format 2string]]
	} on error {e o} {
	    set report [join [list "ERROR: $o" $e] \n]
	} finally {
	    catch { RECCE report-finish }
	    M destroy
	}
	return $report
    }

    method DRule {rule dot rhs} {
	# dot is the index of the rhs element the dot is in front of.
	# -1: before the first rhs element
	set ddot $dot
	if {($dot < 0) || ($dot >= [llength $rhs])} {
	    # Final / completed
	    set drule F$rule
	    set ddot [llength $rhs]
	} elseif {$dot == 0} {
	    # Predicted
	    set drule P$rule
	} else {
	    # Rule in flight
	    set drule R${rule}:$dot
	}
	return [list $ddot $drule]
    }
    
    method TrimTrailingWS {text} {
	return [join [lmap line [split $text \n] { string trimright $line }] \n]
    }
    
    # # ## ### ##### ######## #############
    ## II. Pretty print the evaluation steps of a parse tree.

    method dump-parse-tree {path instructions} {
	package require fileutil
	set sheet [my parse-tree $instructions]\n
	fileutil::writeFile $path $sheet
	return "Saved $path"
    }
    
    method parse-tree {instructions} {
	# instructions = list (type details ...)
	# where details = dict (key in (id, value, first, last, dst))

	set n     [expr {[llength $instructions]/2}]
	set width [string length $n]
	set format "STEP \[%${width}d\] %-5s: %s"
	set i 0
	set sheet {}

	foreach {type details} $instructions {
	    dict with details {} ;# Import into scope ...
	    #        token          rule           null
	    # ------ -----          ----           ----
	    # id     token-id       rule-id        sym-id
	    # value  stack src loc  -              -
	    # first  -              stack 1st loc  -
	    # last   -              stack end loc  -
	    # dst    stack dst loc  stack dst loc  stack dst loc
	    # ------ -----          ----           ----
	    switch -exact -- $type {
		token {
		    dict set details token [my 2Name1 $id]
		    #dict set details sv    [TSV [Store get $value]]
		}
		rule  {
		    dict set details lhs [lindex [my RuleNameData $id] 0]
		    #dict set details filter [dict exists $mymask $id]
		}
		null  {
		    dict set details symbol [my 2Name1 $id]
		}
	    }

	    lappend sheet [format $format $i $type $details]
	    incr i
	}
	return [join $sheet \n]
    }
    
    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
