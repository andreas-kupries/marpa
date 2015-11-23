# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Second stream processor for characters to parse. Driven by an
# instance of "marpa::inbound" (or API compatible) it maps characters
# to grammar symbols (integers, set of), filters unacceptable symbols,
# and drives the rest of the chain (instance of "marpa::engine" or API
# compatible). The chain/engine will reach back to set the acceptable
# symbols, or rewind the input (when lexeme aggregation overshot). The
# incoming token information is simply passed through.

# Instances have maps from characters to sets of symbols, and char
# class names to specs. They further know the current set of
# acceptable symbols and keep a history of processed characters, in
# case a rewind is called.

# The symbol maps are build in cooperation with the upstream chain,
# with upstream actually delivering the relevant integer ids.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/gate
#debug prefix marpa/gate {[debug caller] | }

# # ## ### ##### ######## #############
## Entry object for character streams.
#
# Counts locations, saves token information, before driving the next
# element in the chain.

oo::class create marpa::gate {
    variable mymap        ;# char -> set of sym id
    variable myrmap       ;# sym id -> char(class)
    variable myclass      ;# name -> Tcl regex char class + sym id
    variable myacceptable ;# sym -> .
    variable myhistory    ;# Entered characters and semantic values.
    ##
    # API self:
    #   cons       (upstream)       - Create, link, attach to upstream
    #   =          (chars, classes) - Configuration
    #   enter      (char val)       - Incoming character with token value
    #   eof        ()               - End of input signal
    #   acceptable (syms)           - Upstream feedback, acceptable symbols
    #   redo       (n)              - Upstream feedback, re-enter last n characters
    ##
    # API upstream:
    #   gate:   (self)     - Attach to self as gate for upstream
    #   enter   (syms val) - Push symbol set with token value
    #   eof     ()         - Push end of input signal
    #   symbols (symlist)  - Bulk allocate symbols for char and char classes.

    constructor {semstore upstream} {
	debug.marpa/gate {[debug caller] | [marpa::D {
	    marpa::import $semstore Store ;# Debugging only.
	}]}

	marpa::import $upstream Forward

	# Dynamic state for processing
	set myhistory    {} ;# queue of processed characters
	set myacceptable {} ;# set of expected/allowed symbols,
			     # initially none

	# Static configuration
	set mymap        {}
	set myrmap       {}
	set myclass      {}

	# Attach ourselves to upstream, as gate.
	Forward gate: [self]

	my ToStart

	debug.marpa/gate {[debug caller] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## State methods for API methods
    #
    #  API ::=    Start        Active       Done
    ## ---        ------------ ------------ -----------
    # def         * Setup        FailSetup    FailSetup
    # eof         * EofStart   * Eof          FailEof
    # enter       * EnterStart * Enter        FailEof
    # acceptable    FailStart  * Acceptable   FailEof
    # redo          FailStart  * Redo         FailEof
    ## ---        ------------ ------------ -----------

    method Setup {characters classes} {
	debug.marpa/gate {[debug caller] | }

	# Bulk definition of the whole gate.
	my SetupCharacters   $characters
	my SetupCharacterClasses $classes

	# Setup complete, processing may begin.
	my ToActive
	return
    }

    method EofStart {} {
	debug.marpa/gate {[debug caller] | }
	my ToActive
	my Eof
	return
    }

    method Eof {} {
	debug.marpa/gate {[debug caller] | }
	Forward eof
	return
    }

    method EnterStart {char value} {
	debug.marpa/gate {[debug caller] | }
	my ToActive
	my Enter $char $value
	return
    }

    method Enter {char value} {
	debug.marpa/gate {[debug caller 1] | See '[char quote cstring $char]' ([marpa::location::Show [Store get $value]])}

	# Extend the map when encountering an unknown character, check
	# the char classes for one it may belong to. Note, this is the
	# only way an unknown character can appear in later stages.
	# Because being unknown means that it is not in the list of
	# individually recognized characters of the grammar
	if {![dict exists $mymap $char]} {
	    debug.marpa/gate {[debug caller 1] | Extend maps}
	    dict set mymap $char {}
	    dict for {name spec} $myclass {
		lassign $spec pattern classid
		if {![regexp -- $pattern $char]} continue
		dict lappend mymap $char $classid

		debug.marpa/gate {[debug caller 1] | + '[char quote cstring $char]' = $classid '$name'}
	    }
	}

	# Map the character to all its symbols, if any ...  Do a loop
	# here, allow for _one_ re-try after a flush was forced
	# upstream.

	set flushed 0
	while {1} {
	    debug.marpa/gate {[debug caller 1] | match ($myacceptable)}
	    set match {}

	    foreach possible [dict get $mymap $char] {
		# ... and check which of them are acceptable, if any
		if {![dict exists $myacceptable $possible]} {
		    debug.marpa/gate {[debug caller 1] | .test ($possible) FAIL}
		    continue
		}
		debug.marpa/gate {[debug caller 1] | .test ($possible) OK}
		# ... collect the acceptables
		lappend match $possible
	    }

	    if {[llength $match]} {
		# ... remember the char now for possible rewind request.
		##
		#     Note thay we cannot remember the match data,
		#     because that is predicated on myacceptable,
		#     which may have changed if the char is re-entered
		#     later via 'redo'.
		lappend myhistory $char $value

		# ... Let upstream deal with any ambiguity
		debug.marpa/gate {[debug caller 1] | push ($match)}
		Forward enter $match $value

		# We are good.
		return
	    }

	    # character is not acceptable. Flush upstream, except if
	    # we did it already, then we have to stop, the input
	    # completely bogus.
	    if {$flushed} {
		my E "Unable to handle '[char quote cstring $char]'" \
		    FLUSH $char
	    }

	    incr flushed
	    debug.marpa/gate {[debug caller 1] | push ($match)}
	    Forward enter $match $value

	    # Loop to retry
	}
	return
    }

    method Acceptable {syms} {
	debug.marpa/gate {[debug caller] | }
	# numeric ids, dict => dict exists// list(id)
	set myacceptable {}
	foreach s $syms {
	    debug.marpa/gate {[debug caller 1] | !! $s '[dict get $myrmap $s]'}
	    dict set myacceptable $s .
	}
	return
    }

    method Redo {n} {
	debug.marpa/gate {[debug caller] | }
	if {$n} {
	    # Redo/enter the last n characters
	    incr n $n
	    incr n -1
	    set pending [lrange $myhistory end-$n end]
	    set myhistory {}
	    foreach {char value} $pending {
		my Enter $char $value
	    }
	} else {
	    # Redo nothing
	    set myhistory {}
	}
	return
    }

    method FailStart {args} {
	debug.marpa/gate {[debug caller] | }
	my E "Unable to process feedback before activation" START
    }

    method FailSetup {args} {
	debug.marpa/gate {[debug caller] | }
	my E "Unable to accept configuration, already active" SETUP
    }

    method FailEof {args} {
	debug.marpa/gate {[debug caller] | }
	my E "Unable to process input after EOF" EOF
    }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/inbound {}
	return -code error \
	    -errorcode [linsert $args 0 MARPA GATE] \
	    $msg
    }

    # # ## ### ##### ######## #############
    ## Internal support - Data management (setup)

    method SetupCharacters {characters} {
	debug.marpa/gate {[debug caller 1] | }
	# Bulk argument check, prevent duplicates
	foreach c $characters {
	    if {[dict exists $mymap $c]} {
		my E "Duplicate character \"$c\"" \
		    CHAR DUPLICATE $c
	    }
	}
	# Bulk definition
	foreach \
	    c  $characters \
	    id [Forward symbols $characters] {
		dict set mymap  $c $id
		dict set myrmap $id $c
	    }
	return
    }

    method SetupCharacterClasses {classes} {
	debug.marpa/gate {[debug caller 1] | }
	# Bulk argument check, prevent duplicates
	set names {}
	foreach {name spec} $classes {
	    if {[dict exists $myclass $name]} {
		my E "Duplicate character class \"$name\"" \
		    CHARCLASS DUPLICATE $name
	    }
	    lappend names $name
	}
	# Bulk definition - Do not use 'dict keys' - must keep order!
	set syms [Forward symbols $names]

	# Remember the spec for future lazy membership tests on
	# unknown characters.
	foreach {name spec} $classes id $syms {
	    # Extend the character map with class membership
	    # information.
	    dict set myclass $name [list $spec $id]
	    dict set myrmap $id $name
	    dict for {char symbols} $mymap {
		if {![regexp -- $spec $char]} continue
		dict lappend mymap $char $id
	    }
	}
	return
    }

    # # ## ### ##### ######## #############
    ## State transitions

    method ToStart {} {
	debug.marpa/gate {[debug caller] | }
	# () :: Start
	oo::objdefine [self] forward def         my Setup
	oo::objdefine [self] forward eof         my EofStart
	oo::objdefine [self] forward enter       my EnterStart
	oo::objdefine [self] forward acceptable  my FailStart
	oo::objdefine [self] forward redo        my FailStart
	return
    }

    method ToActive {} {
	debug.marpa/gate {[debug caller] | }
	# Start :: Active
	oo::objdefine [self] forward def         my FailSetup
	oo::objdefine [self] forward eof         my Eof
	oo::objdefine [self] forward enter       my Enter
	oo::objdefine [self] forward acceptable  my Acceptable
	oo::objdefine [self] forward redo        my Redo
	return
    }

    method ToDone {} {
	debug.marpa/gate {[debug caller] | }
	# Active :: Done
	#oo::objdefine [self] forward def         my FailSetup
	oo::objdefine [self] forward eof         my FailEof
	oo::objdefine [self] forward enter       my FailEof
	oo::objdefine [self] forward acceptable  my FailEof
	oo::objdefine [self] forward redo        my FailEof
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
