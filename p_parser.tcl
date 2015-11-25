# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

    # State during configuration
    variable myparts value

    ##
    # API self:
    #   cons    (sem, upstream) - Create, link, attach to upstream.
    #   gate:   (lexer)         - Downstream lexer attaching for feedback.
    #                             This activates down 'acceptable' handling.
    #   symbols (symlist)       - (Downstream, self) bulk allocation of symbols
    #   export  (symlist)       - Bulk allocation of public symbols
    #   rules   (rules)         - Bulk specification of grammar rules
    #   parse   (start-sym)     - Complete parser spec
    #   enter   (syms val)      - Incoming sym set with semantic value
    #   eof     ()              - Incoming end of input signal
    ##
    # API lexer:
    #   discard    (discards)   - Declare set of discarded lexemes
    #   acceptable (symlist)    - Declare set of allowed symbols
    ##
    # API semantics:
    #   eval (treeinsn)         - Eval list of valuator instructions
    ##
    # API upstream:
    #   enter   (semval) - Push semantic value
    #   eof     ()       - Push end of input signal

    constructor {semstore semantics upstream} {
	debug.marpa/parser {[marpa::D {
	    marpa::import $semstore Store ;# Debugging only.
	}]}

	next $upstream

	marpa::import $semantics Semantics
	# Lexer will attach during setup.

	# Dynamic state for processing
	## superclass only (GRAMMAR)

	# Static configuration
	set myparts {}

	my ToStateStart

	debug.marpa/semcore {[marpa::D {
	    # Provide semcore with access to engine internals for use
	    # in its debug narrative (conversion of ids back to names)
	    Semantics engine: [namespace which -command my]
	}]}
	debug.marpa/parser {/ok}
	return
    }

    # # ## ### ##### ######## #############
    ## State methods for API methods
    #
    #  API ::=    Start       Parse        Eof        Done	   
    ## ---        ----------- ------------ ----------- -----------
    #  gate:      * GateSet     FailSetup    FailSetup   FailSetup
    #  symbols    * Symbols     FailSetup    FailSetup   FailSetup
    #  rules      * Rules       FailSetup    FailSetup   FailSetup
    #  parse      * Parse !     FailSetup    FailSetup   FailSetup
    #  enter        FailStart * Enter        FailEEof    FailEof  
    #  eof          FailStart * Eof        * Eof         FailEof  
    ## ---        ----------- ------------ ----------- -----------

    method GateSet {lexer} {
	debug.marpa/parser {}
	marpa::import $lexer Lexer
	return
    }

    method Action {args} {
	debug.marpa/parser {[debug caller] | }
	set myparts $args
	return
    }

    method :M {lhs __ mask args} {
	debug.marpa/parser {}

	# TODO: validate |mask| <= |args| |mask|
	# TODO: validate fa.i in mask: 0 <= i <= |args|-1

	# Alternate: boolean mask vector, possibly easier to filter
	# with, faster, at expense of memory. Definitely the way to go
	# for C.

	set rule [my := $lhs __ {*}$args]

	Semantics mask $rule $mask
	return $rule
    }

    method := {lhs __ args} {
	debug.marpa/parser {}
	set rule [next $lhs __ {*}$args]
	set lhsid [my 2ID1 $lhs]

	set parts [my CompleteParts $myparts $lhsid $rule]
	set cmd [list marpa::semstd::builtin $parts]
	Semantics add-rule $rule $cmd
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

    method Parse {name whitespace} {
	debug.marpa/parser {}
	# Set a start symbol. This makes the parser a parser.
	GRAMMAR sym-start: [my 2ID1 $name]

	my Freeze
	my ToStateParse

	# Pass whitespace downstream, convert that parser into a
	# lexer. Then create our recognizer and push the first
	# feedback about acceptable symbols down.
	Lexer discard $whitespace

	GRAMMAR recognizer create RECCE [mymethod Events]
	debug.marpa/parser {RECCE = [namespace which -command RECCE]}

	RECCE start-input

	Lexer acceptable [RECCE expected-terminals]
	return
    }

    method Enter {syms sv} {
	debug.marpa/parser {See '[join [my 2Name $syms] {' '}]' ([marpa::location::Show [Store get $sv]])}

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
	RECCE earleme-complete

	if {[RECCE exhausted?]} {
	    debug.marpa/parser {exhausted}
	    my Complete
	    return
	}

	# Not exhausted. Generate feedback for our lexer on the now
	# acceptable lexemes. This creates the new lexer RECCE (see
	# 'Acceptable').

	debug.marpa/parser {Feedback, lexemes}
	Lexer acceptable [RECCE expected-terminals]

	debug.marpa/parser {}
	return
    }

    method Eof {} {
	debug.marpa/parser {}

	# Flush everything pending in the local recognizer to the
	# backend before signaling eof upstream.
	my Complete

	# Note as the backend does not call us with 'acceptable' we
	# have no left-over RECCE to destroy, contrary to the lexer's
	# situation.

	my ToStateDone
	Forward eof
	return
    }

    method FailStart {args} {
	debug.marpa/parser {}
	my E "Unable to process input before setup" START
    }

    method FailSetup {args} {
	debug.marpa/parser {}
	my E "Grammar is frozen, unable to add further symbols or rules" \
	    SETUP
    }

    method FailEof {args} {
	debug.marpa/parser {}
	my E "Unable to process input after EOF" EOF
    }

    method FailEEof {args} {
	debug.marpa/parser {}
	my E "Unable to process input, expected EOF" EXPECTED-EOF
    }


    # # ## ### ##### ######## #############
    ## Completion of a rule, builtin semantic value operation.

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
		name    { lappend result [list $part [my 2Name1 $id]] }
		symbol  { lappend result [list $part $id] }
		lhs     { lappend result [list $part ??] }
	    }
	}
	return $result
    }

    # # ## ### ##### ######## #############
    ## Parse completion

    method Complete {} {
	debug.marpa/parser {}

	# For a parse we (must?) assume (for now?) that it must end at
	# the latest earleme. If not we generate suitable parse error
	# messages. (report ?)

	set latest [RECCE latest-earley-set]

	debug.marpa/parser {Check at $latest}
	if {[catch {
	    RECCE forest create FOREST $latest
	}]} {
	    TODO proper syntax error report
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
	my ToStateEof
	return
    }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/parser {}
	return -code error \
	    -errorcode [linsert $args 0 MARPA PARSER] \
	    $msg
    }

    # # ## ### ##### ######## #############
    ## State transitions

    method ToStateStart {} {
	# () :: Start
	debug.marpa/parser {}

	oo::objdefine [self] forward gate:       my GateSet
	oo::objdefine [self] forward symbols     my Symbols
	oo::objdefine [self] forward rules       my Rules
	oo::objdefine [self] forward action      my Action
	oo::objdefine [self] forward parse       my Parse
	oo::objdefine [self] forward enter       my FailStart
	oo::objdefine [self] forward eof         my FailStart
	return
    }

    method ToStateParse {} {
	# Start :: Parse
	debug.marpa/parser {}

	oo::objdefine [self] forward gate:       my FailSetup
	oo::objdefine [self] forward symbols     my FailSetup
	oo::objdefine [self] forward rules       my FailSetup
	oo::objdefine [self] forward action      my FailSetup
	oo::objdefine [self] forward parse       my FailSetup
	oo::objdefine [self] forward enter       my Enter
	oo::objdefine [self] forward eof         my Eof
	return
    }

    method ToStateEof {} {
	# Parse :: Eof
	debug.marpa/parser {}

	#oo::objdefine [self] forward gate:       my FailSetup
	#oo::objdefine [self] forward symbols     my FailSetup
	#oo::objdefine [self] forward rules       my FailSetup
	#oo::objdefine [self] forward action      my FailSetup
	#oo::objdefine [self] forward parse       my FailSetup
	oo::objdefine [self] forward enter       my FailEEof
	#oo::objdefine [self] forward eof         my EofParse
	return
    }

    method ToStateDone {} {
	# Eof :: Done
	debug.marpa/parser {}

	#oo::objdefine [self] forward gate:       my FailSetup
	#oo::objdefine [self] forward symbols     my FailSetup
	#oo::objdefine [self] forward rules       my FailSetup
	#oo::objdefine [self] forward action      my FailSetup
	#oo::objdefine [self] forward parse       my FailSetup
	oo::objdefine [self] forward enter       my FailEof
	oo::objdefine [self] forward eof         my FailEof
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
