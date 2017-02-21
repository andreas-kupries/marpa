# -*- tcl -*-
##
# (c) 2015-2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
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

# The symbol maps are build in cooperation with the postprocessor,
# with the postprocessor actually delivering the relevant integer ids.

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
    marpa::E marpa/gate GATE
    validate-sequencing

    # # Interaction sequences
    ##
    # * Lifecycle
    # ```
    # Driver  Gate    Postprocessor
    # |               |
    # +-cons--\       |
    # |       +-gate:->       (Internal backlinking from postprocessor to its gate)
    # |       |       |
    # ~~      ~~      ~~
    # ~~      ~~      ~~
    # |       |       |
    # |       <---acc-+       Postprocessor, initial gate initialization
    # |       |       |
    # ~~      ~~      ~~      Driven from input
    # ~~      ~~      ~~
    # |       |       |
    # +-eof--->       |
    # |       +-eof--->
    # |       <--redo-+       (Always called, even for n == 0)
    # |       |       |
    # ```
    #
    # * Operation during scanning of a lexeme
    # ```
    # Driver  Gate    Postprocessor
    # |               |
    # +-enter->       |
    # |       +-enter->
    # |       <---acc-+
    # |       |       |
    # ```
    #
    # * Operation at end of a lexeme
    # ```
    # Driver  Gate    Postprocessor
    # |               |
    # +-enter->       |
    # |       +-enter->
    # |       <---acc-+
    # |       <--redo-+       (Always called, even for n == 0)
    # |       |       |
    # ```

    # # -- --- ----- -------- -------------
    ## State

    variable myacceptable ;# sym -> .
    variable myhistory    ;# Entered characters and semantic values.

    # # -- --- ----- -------- -------------
    ## Configuration

    variable mymap        ;# char -> set of sym id
    variable myrmap       ;# sym id -> char(class)
    variable myclass      ;# name -> Tcl regex char class + sym id

    ##
    # API self:
    # 1 cons       (postprocessor)  - Create, link, attach to postprocessor
    # 2 def        (chars, classes) - Configuration
    # 3 enter      (char val)       - Incoming character with token value
    # 4 eof        ()               - End of input signal
    # 5 acceptable (syms)           - Postprocessor feedback, acceptable symbols
    # 6 redo       (n)              - Postprocessor feedback, re-enter last n characters
    ##
    # Sequence = 1(2(5(356?)*))?(46)
    # See mark <<s>>
    ##
    # API postprocessor:
    #   gate:   (self)     - Attach ourselves as the gate of the postprocessor (lexer),
    #                        for feedback on acceptables.
    #   enter   (syms val) - Push symbol set with token value
    #   eof     ()         - Push end of input signal
    #   symbols (symlist)  - Bulk allocate symbols for char and char classes.

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {semstore postprocessor} {
	debug.marpa/gate {[debug caller] | [marpa::D {
	    marpa::import $semstore Store ;# Debugging only.
	}]}

	marpa::import $postprocessor Forward

	# Dynamic state for processing
	set myhistory    {} ;# queue of processed characters
	set myacceptable {} ;# set of expected/allowed symbols,
			     # initially none

	# Static configuration
	set mymap        {}
	set myrmap       {}
	set myclass      {}

	# Attach ourselves to the postprocessor, as its gate.
	Forward gate: [self]

	debug.marpa/gate {[debug caller] | /ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method def {characters classes} {
	debug.marpa/gate {[debug caller] | }

	# Bulk definition of the whole gate.
	my SetupCharacters   $characters
	my SetupCharacterClasses $classes
	return
    }

    method eof {} {
	debug.marpa/gate {[debug caller] | }
	Forward eof
	return
    }

    method enter {char value} {
	debug.marpa/gate {[debug caller 1] | See '[char quote cstring $char]' ([marpa location show [Store get $value]])}

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
	# here, allow for _one_ re-try after a flush was forced to the
	# postprocessor.

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

		# ... Let the postprocessor deal with any ambiguity
		debug.marpa/gate {[debug caller 1] | push ($match)}
		Forward enter $match $value

		# We are good.
		return
	    }

	    # character is not acceptable. Flush to the postprocessor,
	    # except if we did it already, then we have to stop, the
	    # input completely bogus.
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

    method acceptable {syms} {
	debug.marpa/gate {[debug caller] | }
	# numeric ids, dict => dict exists// list(id)
	set myacceptable {}
	foreach s $syms {
	    debug.marpa/gate {[debug caller 1] | !! $s '[dict get $myrmap $s]'}
	    dict set myacceptable $s .
	}
	return
    }

    method redo {n} {
	debug.marpa/gate {[debug caller] | }
	if {$n} {
	    # Redo/enter the last n characters
	    incr n $n
	    incr n -1
	    set pending [lrange $myhistory end-$n end]
	    set myhistory {}
	    foreach {char value} $pending {
		my enter $char $value
	    }
	} else {
	    # Redo nothing
	    set myhistory {}
	}
	return
    }

    # # -- --- ----- -------- -------------
    ## Internal support - Data management (setup)

    method SetupCharacters {characters} {
	debug.marpa/gate {[debug caller 1] | }
	if {![llength $characters]} return
	# Bulk argument check, prevent duplicates
	foreach c $characters {
	    if {[dict exists $mymap $c]} {
		my E "Duplicate character \"$c\"" \
		    CHAR DUPLICATE $c
	    }
	    dict set mymap  $c ?
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
	if {![dict size $classes]} return
	# Bulk argument check, prevent duplicates
	set names {}
	foreach {name spec} $classes {
	    if {[dict exists $myclass $name]} {
		my E "Duplicate character class \"$name\"" \
		    CHARCLASS DUPLICATE $name
	    }
	    dict set myclass $name ?
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

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Mixin helper class. State machine checking the method call
## sequencing of marpa::inbound instances.

## The mixin is done on user request (method in main class).
## Uses: testing
##       debugging in production

oo::class create marpa::gate::sequencer {
    superclass sequencer

    # State machine for marpa::gate
    ##
    # Sequence = 1(2(5(356?)*))?(46)
    # See mark <<s>>
    ##
    # Non-deterministic state machine _____
    # Current Method --> New          Notes
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # -       <cons>     Made
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Made    def        Config
    #         eof        Done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Config  accept     Gated        [1]
    #         eof        Done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Gated   enter      Data
    #         eof        Done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Data    accept     Gated, Back  [2]
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Back    redo       Gated
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # Done    redo       Complete
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # *     *            /FAIL
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~
    # [1] initial accept, before all data, part of the setup, coming
    #     from the postprocessor
    # [2] the non-determinism is here

    # Deterministic state machine. Remap state sets
    ##
    # made     := Made
    # config   := Config
    # gated    := Gated
    # data     := Data
    # regated  := { Gated, Back }
    # done     := Done
    # complete := Complete
    ##
    # New transition table ____________ # Table re-sorted, by method
    # Current Method --> New      Notes # Method Current --> New
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # ~~~~~~ ~~~~~~~     ~~~~~~~~
    # -       <cons>     made	 	# <cons> -           made
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # ~~~~~~ ~~~~~~~     ~~~~~~~~
    # made    def        config	 	# def    made        config
    #         eof        done	 	# ~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # accept config      gated
    # config  accept     gated    [1]   #        data        regated
    #         eof        done	 	# ~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # enter  gated       data
    # gated   enter      data	 	#        regated     data
    #         eof        done	 	# ~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # redo   done        complete
    # data    accept     regated 	#        regated     gated
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # ~~~~~~ ~~~~~~~     ~~~~~~~~
    # regated enter      data	 	# eof    config      done
    #         redo       gated	 	#        gated       done
    #         eof        done           #        regated     done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ #        made        done
    # done    redo       complete	# ~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~ # *      *           /FAIL
    # *       *          /FAIL	 	# ~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~ ~~~~~

    # Notes
    ##
    # - During the scanning of a lexeme 'enter' triggers 'accept' from
    #   the post-processor (lexer). This means:
    #
    #     gated   -> regated,
    #     regated -> regated
    #
    #   The state 'data' is only temporary, visible only to 'accept'.
    ##
    # - At the end of a lexeme 'enter' triggers 'accept' and 'redo'
    #   from the post-processor (lexer). This means:
    #
    #     gated   -> gated,
    #     regated -> gated
    #
    #   The state 'data' is only temporary, visible only to 'accept'.
    ##
    # # -- --- ----- -------- -------------
    ## Mandatory overide of virtual base class method

    method __Init {} { my __States made config gated data regated done complete }

    # # -- --- ----- -------- -------------
    ## Checked API methods

    method def {characters classes} {
	my __Init
	my __FNot made   ! "Invalid redefinition" SETUP DOUBLE
	next $characters $classes

	my __On   made --> config
    }

    method eof {} {
	my __Init
	my __FNot {made config gated regated}   ! "Unexpected EOF" EOF EARLY
	next

	my __On   {made config gated regated} --> done
    }

    method enter {char value} {
	my __Init
	my __Fail made              ! "Setup missing"      SETUP MISSING
	my __Fail {config data}     ! "Gate missing"       GATE MISSING
	my __Fail {done complete}   ! "After end of input" EOF AFTER
	# Note: Early state change. This ensures that we are in the
	# proper state for the callbacks from the postprocessor
	# (i.e. acceptable, and redo)
	my __On   {gated regated} --> data
	next $char $value
    }

    method acceptable {syms} {
	my __Init
	my __Fail made            ! "Setup missing"      SETUP MISSING
	my __Fail {gated regated} ! "Data missing"       DATA MISSING
	my __Fail {done complete} ! "After end of input" EOF AFTER
	next $syms

	my __On   config        --> gated
	my __On   data          --> regated
    }

    method redo {n} {
	my __Init
	my __Fail made          ! "Setup missing"      SETUP MISSING
	my __Fail {config data} ! "Gate missing"       GATE MISSING
	my __Fail gated         ! "Data missing"       DATA MISSING
	my __Fail complete      ! "After end of input" EOF AFTER
	next $n

	my __On   regated     --> gated
	my __On   done        --> complete
    }

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
