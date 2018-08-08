# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##
# Heredoc wrapper. Given one of the core parsers this class contains
# the event handling needed to complete the processing of heredocs.
# This makes this class nearly the main parser for the example.
# The true main class would be derived from the wrapper to specialize
# towards one of the core parsers.

# @@ Meta Begin
# Package heredoc::parser 1
# Meta author      {Andreas Kupries}
# Meta category    Parser
# Meta description A minimal HEREDOC parser.
# Meta description Returns the abstract syntax tree of
# Meta description the HEREDOC read from file or stdin.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     parsing heredoc {abstract syntax tree}
# Meta summary     A minimal HEREDOC parser based on the Tcl binding to
# Meta summary     Jeffrey Kegler's libmarpa.
# @@ Meta End

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
#debug prefix heredoc/parser {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create heredoc::parser {

    variable mycore

    constructor {core} {
	debug.heredoc/parser {[debug caller] | }
	set mycore $core
	return
    }

    destructor {
	debug.heredoc/parser {[debug caller] | }
	$mycore destroy
    }

    method process {text} {
	debug.heredoc/parser {[debug caller 0] | }
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
	debug.heredoc/parser {[debug caller 0 1 3] | }
	# This method is invoked for one of two reasons
	# (1) after a `heredoc` was recognized
	# (2) The end of a line containing heredoc declarations was reached.
	##
	# They can be distinguished by type: after vs stop.
	# We do not care about the engine object, that is ourselves.
	# Nor do we care about the event names.

	switch -exact -- $type {
	    after {
		debug.heredoc/parser {[debug caller 0 1 3] | LAST = $last_hd_end}
		# We have just read the termination identifier of a heredoc.
		# We are just behind it. Get the actual value, and pass that
		# to the parser.

		if {$last_hd_end < 0} {
		    set at [$mycore match location]
		    debug.heredoc/parser {[debug caller 0 1 3] | LOC  = $at}

		    # First heredoc on this line. Find its end.
		    set last_hd_end [string first \n $text $at]
		    debug.heredoc/parser {[debug caller 0 1 3] | EOL  = $last_hd_end}

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

		debug.heredoc/parser {[debug caller 0 1 3] | TERM = (($terminator))}
		debug.heredoc/parser {[debug caller 0 1 3] | TLEN = $tlength}
		debug.heredoc/parser {[debug caller 0 1 3] | START= $hdstart}
		debug.heredoc/parser {[debug caller 0 1 3] | END  = $hdend}

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

		set hdlength [string length $hdvalue]

		debug.heredoc/parser {[debug caller 0 1 3] | HDLEN= $hdlength}
		debug.heredoc/parser {[debug caller 0 1 3] | HDVAL= (($hdvalue))}

		# Pass to parser
		$mycore match alternate heredoc [list $hdstart $hdlength $hdvalue]

		debug.heredoc/parser {[debug caller 0 1 3] | NEXT = $last_hd_end}
		debug.heredoc/parser {[debug caller 0 1 3] | CONT = [$mycore match location]}
	    }
	    stop {
		# We reached the end of the current line. That the
		# engine stopped means that it contained heredoc
		# declarations. We now have to jump over all the
		# extracted heredoc values for correct resumption
		# of regular input, and clear the marker

		debug.heredoc/parser {[debug caller 0 1 3] | MOVE = $last_hd_end}

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
