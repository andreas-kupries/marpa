# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##
# Heredoc wrapper. Given one of the core parsers this class contains
# the event handling needed to complete the processing of heredocs

# # ## ### ##### ######## #############

package provide heredoc::parser 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug                  ;# Tracing
package require debug::caller          ;# Tracing

# # ## ### ##### ######## #############

debug define heredoc/parser
debug prefix heredoc/parser {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create heredoc::parser {

    variable mycore
    
    constructor {core} {
	set mycore $core
	return
    }

    destructor {
	$mycore destroy
    }

    method process {text} {
	$mycore on-event [self namespace]::my ProcessHereDoc $text
	set last_hd_end -1
	$mycore process $text
    }

    variable last_hd_end ;# int :: offset of the first character after
			  # the closing termination identifier of the
			  # last processed heredoc for the current
			  # line. -1 signals that no heredoc was seen
			  # so far on the current line.

    method ProcessHereDoc {text __ type __} {
	# This method is invoked for one of two reasons
	# (1) after a `heredoc` was recognized
	# (2) The end of a line containing heredoc declarations was reached.
	##
	# They can be distinguished by type: after vs stop.
	# We do not care about the engine object, that is ourselves.
	# Nor do we care about the event names.

	switch -exact -- $type {
	    after {
		# We have just read the termination identifier of a heredoc.
		# We are just behind it. Get the actual value, and pass that
		# to the parser.
		
		if {$last_hd_end < 0} {
		    # First heredoc on this line. Find its end.
		    set  last_hd_end [string first \n $text [$mycore match location]]

		    # Arrange for stop and jump.
		    $mycore match to $last_hd_end

		    # The next (first) heredoc begins at start of next
		    # line, i.e. just after the \n.
		    incr last_hd_end
		}

		# Extract heredoc and adjust marker for more on the
		# current line.

		set terminator [$mycore match value]
		set tlength    [$mycore match length]
		set hdstart    $last_hd_end
		set hdend      [string first \n$terminator\n $text $last_hd_end]

		if {$hdend < 0} {
		    # No terminator found, take all to the end of the file.
		    # This will likely run into a parse error immediately after.
		    # Note, direct error thrown swallowed by event processing in engine.
		    # Change?
		    set last_hd_end [string length $text]
		    set hdvalue     [string range  $text $hdstart end]
		} else {
		    set  last_hd_end $hdend
		    incr last_hd_end $tlength
		    incr last_hd_end 2 ;# \n\n
		    set  hdvalue     [string range $text $hdstart ${hdend}-1]
		}
		    
		# Pass to parser
		$mycore match start: $hdstart
		$mycore match value: $hdvalue
		# Note: The lexeme length is implicitly set by the
		# lexeme value. We could override it _now_, should we
		# wish to.
		$mycore match alternate heredoc
		# Note: It is this call without a sem.value specified
		# which causes the engine to create a sem.value from
		# the changed lexeme information.
	    }
	    stop {
		# We reached the end of the current line. That the
		# engine stopped means that it contained heredoc
		# declarations. We now have to jump over all the
		# extracted heredoc values for correct resumption
		# of regular input, and clear the marker

		$mycore match from $last_hd_end
		set last_hd_end -1
	    }
	    default {
		error "Should not happen"
		# This error is swallowed by the engine's event invoker.
		# See if we can do better.
	    }
	}
    }
}

# # ## ### ##### ######## #############
return
