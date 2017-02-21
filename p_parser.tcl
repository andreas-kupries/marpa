# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Parser based on a low-level grammar and recognizer. Usually driven
# by a "marpa::lexer". Takes a stream of symbols and runs them through
# a recognizer. Sets of acceptable symbols are fed back to the lexer
# for LATM.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/parser
debug prefix marpa/parser {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::parser {
    superclass marpa::engine

    marpa::E marpa/parser PARSER
    validate-sequencing

    # # -- --- ----- -------- -------------
    ## Configuration

    # Static
    variable myparts

    ##
    # API self:
    # 1 cons    (sem, asthandler) - Create, link, attach to asthandler.
    # 2 gate:   (lexer)           - Lexer driving the parser attaching to
    #                               it for feedback on acceptables.
    # 3 symbols (symlist)         - (lexer, self) bulk allocation of symbols
    # 4 action  (...)             - Semantic value definition
    # 5 rules   (rules)           - Bulk specification of grammar rules
    # 6 parse   (start-sym)       - Complete parser spec
    # 7 enter   (syms val)        - Incoming sym set with semantic value
    # 8 eof     ()                - Incoming end of input signal
    ##
    # Sequence = 1([345]*2[345]*67*)?8
    # See mark <<s>>
    ##
    # API lexer:
    #   discard    (discards)   - Declare set of discarded lexemes
    #   acceptable (symlist)    - Declare set of allowed symbols
    ##
    # API semantics:
    #   eval (treeinsn)         - Process list of valuator instructions, generate semantic value
    ##
    # API asthandler:
    #   enter   (semval) - Push semantic value of completed parse
    #   fail    ()       - Parse failed (TODO: error information)
    #   eof     ()       - Push end of input signal

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {semstore semantics asthandler} {
	debug.marpa/parser {[marpa::D {
	    marpa::import $semstore Store ;# Debugging only.
	}]}

	next $asthandler

	marpa::import $semantics Semantics
	# Lexer will attach during setup.

	# Dynamic state for processing
	## superclass only (GRAMMAR)

	# Static configuration
	set myparts       value
	set mypreviouslhs -1
	set myplhscount   0

	debug.marpa/semcore {[marpa::D {
	    # Provide semcore with access to engine internals for use
	    # in its debug narrative (conversion of ids back to names)
	    Semantics engine: [namespace which -command my]
	}]}
	debug.marpa/parser {/ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method gate: {lexer} {
	debug.marpa/parser {}
	marpa::import $lexer Lexer
	return
    }

    method action {names} {
	debug.marpa/parser {[debug caller] | }
	set myparts $names
	return
    }

    method parse {name whitespace} {
	debug.marpa/parser {}
	# Set a start symbol. This makes the parser a parser.
	GRAMMAR sym-start: [my 2ID1 $name]

	my Freeze

	# Pass whitespace to the lexer. Then create our recognizer and
	# push the first feedback about acceptable symbols up.
	Lexer discard $whitespace

	GRAMMAR recognizer create RECCE [mymethod Events]
	debug.marpa/parser {RECCE = [namespace which -command RECCE]}

	RECCE start-input

	Lexer acceptable [RECCE expected-terminals]
	return
    }

    method enter {syms sv} {
	debug.marpa/parser {See '[join [my 2Name $syms] {' '}]' ([marpa location show [Store get $sv]])}

	if {![llength $syms]} {
	    # The input has no acceptable symbols waiting.
	    # Complete the current parse tree and stop.

	    # TODO: FUTURE: This here is where the ruby slippers can
	    # take over instead and drive the machine until the input
	    # is suitable again, or nothing works anymore.
	    ##
	    # Note, when implementing ruby slippers support carefully
	    # check the whole feedback path for correctness, like with
	    # regard to lexeme redo, and/or character redo.

	    my Complete
	    return
	}

	# Drive the low-level recognizer
	debug.marpa/parser {forward recce}
	foreach sym $syms {
	    RECCE alternative $sym $sv 1
	}
	try {
	    RECCE earleme-complete
	} trap {MARPA PARSE_EXHAUSTED} {e o} {
	    # Do nothing. Exhaustion is checked below.
	} on error {e o} {
	    return {*}$o $e
	}

	if {[RECCE exhausted?]} {
	    debug.marpa/parser {exhausted}
	    my Complete
	    return
	}

	# Not exhausted. Generate feedback for our lexer on the now
	# acceptable lexemes. This creates the new lexer RECCE (see
	# p_lexer.tcl 'acceptable').

	debug.marpa/parser {Feedback, lexemes}
	Lexer acceptable [RECCE expected-terminals]

	debug.marpa/parser {}
	return
    }

    method eof {} {
	debug.marpa/parser {}

	# Flush everything pending in the local recognizer to the
	# backend before signaling eof to the asthandler.
	my Complete

	# Note, as the backend does not call us with 'acceptable' we
	# have no left-over RECCE to destroy, contrary to the lexer's
	# situation.

	Forward eof
	return
    }

    # # -- --- ----- -------- -------------
    ## Rule support

    method :M {lhs __ mask args} {
	debug.marpa/parser {}
	# TODO: validate |mask| <= |args| |mask|
	# TODO: validate fa.i in mask: 0 <= i <= |args|-1

	# Alternate: boolean mask vector, possibly easier to filter
	# with, faster, at expense of memory. Definitely the way to go
	# for C.

	set rule [my := $lhs __ {*}$args]

	Semantics add-mask $rule $mask
	return $rule
    }

    variable mypreviouslhs
    variable myplhscount
    method := {lhs __ args} {
	debug.marpa/parser {}
	set rule [next $lhs __ {*}$args]
	set lhsid [my 2ID1 $lhs]

	set parts [my CompleteParts $myparts $lhsid $rule]
	set cmd [list marpa::semstd::builtin $parts]
	Semantics add-rule $rule $cmd

	set mypreviouslhs $lhsid
	return $rule
    }

    method * {lhs args} {
	debug.marpa/parser {}
	set rule [next $lhs {*}$args]
	set lhsid [my 2ID1 $lhs]

	set parts [my CompleteParts $myparts $lhsid $rule]
	set cmd [list marpa::semstd::builtin $parts]
	Semantics add-rule $rule $cmd
	return $rule
    }

    method + {lhs args} {
	debug.marpa/parser {}
	set rule [next $lhs {*}$args]
	set lhsid [my 2ID1 $lhs]

	set parts [my CompleteParts $myparts $lhsid $rule]
	set cmd [list marpa::semstd::builtin $parts]
	Semantics add-rule $rule $cmd
	return $rule
    }

    # # -- --- ----- -------- -------------
    ## Rule runtime support - builtin construction of semantic value

    method CompleteParts {parts id rid} {
	set result {}
	foreach part $parts {
	    switch -exact -- $part {
		g1start -
		g1end   -
		values  -
		start   -
		end     -
		value   -
		length  -
		rule    { lappend result $part }
		name    {
		    if {$mypreviouslhs != $id} {
			set myplhscount 0
		    } else {
			incr myplhscount
		    }
		    # Generate differing names for the same lhs, using a sequence number.
		    # Allows semantics to distinguish the alternative rules
		    # TODO: See if that is covered by the existing array descriptor semantics
		    lappend result [list $part [my 2Name1 $id]/$myplhscount]
		}
		symbol  { lappend result [list $part $id] }
		lhs     { lappend result [list $part ??] }
	    }
	}
	return $result
    }

    # # -- --- ----- -------- -------------
    ## Parse completion

    method Complete {} {
	debug.marpa/parser {}

	# No RECCE implies that either the parser never got fully off
	# the ground yet, or that it already did all the completion
	# work. In either case, nothing has to be done.

	if {![llength [info commands RECCE]]} return

	# For a parse we (must?) assume (for now?) that it must end at
	# the latest earleme. If not we generate suitable parse error
	# messages. (report ?)

	set latest [RECCE latest-earley-set]
	while {[catch {
	    debug.marpa/parser {Check at $latest}
	    RECCE forest create FOREST $latest
	}]} {
	    incr latest -1
	    if {$latest < 0} {
		Forward fail
		# TODO: Here more information can be provided, i.e.
		#       where in the input we got stopped, and such.
		#       This could/should be made a method for every
		#       processor in the pipeline, to forward a problem
		#       and each stage adding its own information.

		# The parser is done.
		RECCE destroy
		return
	    }
	}

	# Pull all the valid parses
	set steps {}
	while {![catch {
	    lappend steps [FOREST get-parse]
	}]} {}
	FOREST destroy

	debug.marpa/parser {Trees: [llength $steps]}

	# The parser is done.
	RECCE destroy

	# Evaluate the parses with the configured semantics, and hand
	# the resulting semantic value to the backend, immediately.

	foreach tree $steps {
	    Forward enter [Semantics eval $tree]
	}

	# From here on only an eof signal may come from the input.
	return
    }

    # # -- --- ----- -------- -------------
    ## Helper for determination of dynamic destination state (enter).

    method exhausted {} {
	# 'enter' destroys RECCE when it is exhausted.
	string equal [info commands RECCE] {}
    }

    # # ## ### ##### ######## #############
}


# # ## ### ##### ######## #############
## Mixin helper class. State machine checking the method call
## sequencing of marpa::parser instances.

## The mixin is done on user request (method in main class).
## Uses: testing
##       debugging in production

oo::class create marpa::parser::sequencer {
    superclass sequencer

    # State machine for marpa::parser
    ##
    # Sequence = 1([345]*2[345]*67*)?8
    # See mark <<s>>
    ##
    # Deterministic state machine _________ # Table re-sorted, by method _
    # Current Method --> New          Notes # Method  Current --> New
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # -       <cons>     made               # -       <cons>      made
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # made    gate:      gated              # gate:   made        gated
    #         symbols    made               # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    #         action     made               # symbols made        made
    #         rules      made               #         gated       gated
    #         eof        done               # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # action  made        made
    # gated   symbols    gated              #         gated       gated
    #         action     gated              # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    #         rules      gated              # rules   made        made
    #         parse      active             #         gated       gated
    #         eof        done               # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # parse   gated       active
    # active  enter      active       [1]   # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    #         enter      exhausted    [1]   # enter   active/!ex  active
    #         eof        done               #         active/ex   exhausted
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # exhausted eof      done               # eof     made        done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ #         gated       done
    # *       *          /FAIL		    #         active      done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ #         exhausted   done
    #                                       # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    #                                       # *       *           /FAIL
    #                                       # ~~~~~~~ ~~~~~~~     ~~~~~~~~
    # [1] Destination state depends on recognizer state ((not) exhausted)

    # # -- --- ----- -------- -------------
    ## Mandatory overide of virtual base class method

    method __Init {} { my __States made gated active exhausted done }

    # # -- --- ----- -------- -------------
    ## Checked API methods

    method gate: {gate} {
	my __Init
	my __FNot {made gated} ! "Parser is frozen" FROZEN
	next $gate

	my __Goto gated
    }

    method symbols {names} {
	my __Init
	my __FNot {made gated} ! "Parser is frozen" FROZEN
	next $names
    }

    method action {names} {
	my __Init
	my __FNot {made gated} ! "Parser is frozen" FROZEN
	next $names
    }

    method rules {rules} {
	my __Init
	my __FNot {made gated} ! "Parser is frozen" FROZEN
	next $rules
    }

    method parse {name whitespace} {
	my __Init
	my __FNot {made gated} ! "Parser is frozen" FROZEN
	my __Fail made         ! "Lexer missing" MISSING LEXER
	next $name $whitespace
	# State move after main code. Internally calls on 'symbols'
	# etc. Would be broken by an early state change.
	my __On gated --> active
    }

    method eof {} {
	my __Init
	my __Fail done ! "After end of input" EOF
	next

	my __Goto done
    }

    method enter {syms sv} {
	my __Init
	my __Fail made             ! "Setup missing" MISSING SETUP
	my __Fail gated            ! "Lexer missing" MISSING LEXER
	my __Fail {exhausted done} ! "After end of input" EOF
	next $syms $sv

	my __On active --> [expr {[my exhausted]
				  ? "exhausted"
				  : "active"}]
    }
}

# # ## ### ##### ######## #############
return
