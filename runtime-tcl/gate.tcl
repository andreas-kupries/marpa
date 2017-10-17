# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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
debug define marpa/gate/stream
#debug prefix marpa/gate/stream {[debug caller] | }

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

    variable myaccmemo
    variable myacceptable ;# sym -> .
    variable myhistory    ;# Entered characters and semantic values.
    variable mylastchar   ;# last character "enter"ed into the gate
    variable mylastloc    ;# and its location
    variable myflushed    ;# flush state

    # # -- --- ----- -------- -------------
    ## Configuration

    variable mymap        ;# char   -> set of sym-id
    variable myrmap       ;# sym-id -> char(class)
    variable myclass      ;# name   -> list (spec sym-id)
    # where                            spec = Tcl regex char class

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

    constructor {postprocessor} {
	method-benchmarking
	debug.marpa/gate {[debug caller] | }

	marpa::import $postprocessor Forward

	# Dynamic state for processing
	set mylastchar   {} ;# char/loc before anything was entered
	set mylastloc    -1 ;#
	set myhistory    {} ;# queue of processed characters (and locations)
	set myaccmemo    {}
	set myacceptable {} ;# set of expected/allowed symbols,
	# initially none
	set myflushed    0

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
	# characters :: map (sym -> char)
	# classes    :: map (sym -> class)
	debug.marpa/gate {[debug caller] | }
	# Bulk definition of the whole gate.
	my SetupCharacters       $characters
	my SetupCharacterClasses $classes
	return
    }

    method eof {} {
	debug.marpa/gate {[debug caller] | }
	debug.marpa/gate/stream {EOF}
	Forward eof
	return
    }

    method get-context {cv} {
	debug.marpa/gate {[debug caller] | }
	upvar 1 $cv context

	if {0&&[llength $myhistory]} {
	    # Pull location information out of the history.
	    lassign [lrange $myhistory end-1 end] char location
	} else {
	    # When history is not available try to pull information
	    # from the last character which went into the gate
	    # instead, as a last fallback.
	    set char     $mylastchar
	    set location $mylastloc
	}

	my ExtendContext context $char $location
	return
    }

    method enter {char location} {
	debug.marpa/gate {[debug caller 1] | See '[char quote cstring $char]' (@$location)}
	debug.marpa/gate/stream {'[char quote cstring $char]'	@ $location}

	set mylastchar $char
	set mylastloc  $location

	# Trick for lazy setup of the gate datastructures in the face
	# of unknown characters. These can only exist as part of some
	# character class. As a standalone they would have been
	# declared already and be known.
	##
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

	set myflushed 0
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
		lappend myhistory $char $location

		# ... Let the postprocessor deal with any ambiguity
		debug.marpa/gate {[debug caller 1] | push ($match)}
		# sub lexer gate sv - char + lcoation
		Forward enter $match $char $location

		# We are good.
		return
	    }

	    # The character we have is not acceptable. If we just
	    # reached it we flush our state to the postprocessor, so
	    # that it may check if it is has a lexeme, after which the
	    # character may be accepted. If we flushed already, then
	    # we have to error out, there is no forward from here.
	    if {$myflushed} {
		debug.marpa/gate {[debug caller 1] | ...flushed}
		
		my ExtendContext context $char $location
		Forward fail context

		# Note: This method must not return, but throw an
		# error at some point. If it returns we have an
		# internal problem at hand as well. In that case we
		# report that now, together with the context.

		my E "Unexpected return without error for problem: $context" \
		    INTERNAL ILLEGAL RETURN $context
	    }

	    incr myflushed
	    debug.marpa/gate {[debug caller 1] | flush ($myflushed) ...}
	    debug.marpa/gate {[debug caller 1] | push ($match)}

	    Forward enter $match $char $location
	    # Loop to retry
	}
	return
    }

    method acceptable {syms} {
	debug.marpa/gate {[debug caller] | }
	# numeric ids, dict => dict exists// list(id)
	if {0&&[dict exists $myaccmemo $syms]} {
	    set myacceptable [dict get $myaccmemo $syms]
	} else {
	    set myacceptable {}
	    foreach s $syms {
		debug.marpa/gate {[debug caller 1] | !! $s '[dict get $myrmap $s]'}
		dict set myacceptable $s .
	    }
	    dict set myaccmemo $syms $myacceptable
	}
	return
    }

    method redo {n} {
	debug.marpa/gate {[debug caller] | }
	if {$n} {
	    # Reset flush state. The redo implies that the flushed
	    # token did not cover the input till the character causing
	    # the flush. That means that we may have another token in
	    # the redone part of the input which the current character
	    # has to flush again.
	    debug.marpa/gate {[debug caller] | flush reset}
	    set myflushed 0
	    # Redo/enter the last n characters
	    # Note: 2 slots per char (char + value) => Times 2.
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

    method ExtendContext {cv char location} {
	debug.marpa/gate {[debug caller] | }
	upvar 1 $cv context

	if {![info exists context] ||
	    ![dict exists $context from]} {
	    dict set context origin gate
	}
	
	if {$location ne {}} {
	    dict set context l0 at $location
	}
	if {$char ne {}} {
	    dict set context l0 char $char
	    dict set context l0 csym [dict get $mymap $char]
	}

	set amap {}
	foreach sym [dict keys $myacceptable] {
	    set cname [dict get $myrmap $sym] ;# char or name of charclass
	    if {[dict exists $myclass $cname]} {
		# map charclass to the set of characters it contains.
		lassign [dict get $myclass $cname] cname __
		dict set amap $sym $cname
		#set cname [string range $cname 1 end-1]

		# TODO: Need package and commands to manipulate char
		# ranges and char classes.  (include, exclude, union,
		# intersect, merge, ...)

		# TODO: The above can be handled as a package to
		# handle integer sets, ranges, with characters mapped
		# in and out via their 'codepoints'.
		
		# NOTE: See `marpa::slif::literal`
	    } else {
		dict set amap $sym '[char quote cstring $cname]'
	    }
	    lappend acceptable $cname
	}

	dict set context l0 acceptable [lsort -dict $acceptable]
	dict set context l0 acceptsym  [lsort -integer [dict keys $myacceptable]]
	dict set context l0 acceptmap  $amap
	return
    }

    # # -- --- ----- -------- -------------
    ## Internal support - Data management (setup)

    method SetupCharacters {characters} {
	# characters :: map (sym -> char)
	debug.marpa/gate {[debug caller 1] | }
	if {![dict size $characters]} return
	# Bulk argument check, prevent duplicates
	foreach {sym c} $characters {
	    if {[dict exists $mymap $c]} {
		my E "Duplicate character \"$c\"" \
		    CHAR DUPLICATE $c
	    }
	    dict set mymap  $c ?
	}
	# We now know that the argument is a proper dictionary and can
	# be treated as such. We declare the symbols to the lexer and
	# get their ids back. These ids are then associated with the
	# proper character.

	set syms [dict keys $characters]
	set ids  [Forward symbols $syms]
	foreach id $ids sym $syms {
	    set c [dict get $characters $sym]
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
	    debug.marpa/gate {[debug caller 1] | Map $name = <<((${spec}))>>}
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

    method name-of {s} {
	dict get $myrmap $id
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

    method enter {char location} {
	my __Init
	my __Fail made              ! "Setup missing"      SETUP MISSING
	my __Fail {config data}     ! "Gate missing"       GATE MISSING
	my __Fail {done complete}   ! "After end of input" EOF AFTER
	# Note: Early state change. This ensures that we are in the
	# proper state for the callbacks from the postprocessor
	# (i.e. acceptable, and redo)
	my __On   {gated regated} --> data
	next $char $location
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
