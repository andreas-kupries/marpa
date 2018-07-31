# -*- tcl -*-
##
# (c) 2015-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
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
debug define marpa/parser/stream
debug prefix marpa/parser/stream {}
debug define marpa/parser/report
debug prefix marpa/parser/report {}
debug define marpa/parser/forest
debug prefix marpa/parser/forest {}
debug define marpa/parser/forest/save
debug prefix marpa/parser/forest/save {}

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
    variable mydone

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
	# Debugging and tag specific initializations
	debug.marpa/parser        {[marpa::D { marpa::import $semstore Store }]}
	debug.marpa/parser/stream {[marpa::D { catch { marpa::import $semstore Store } }]}
	debug.marpa/parser/report {[marpa DX {Activate progress reports...} {
	    oo::objdefine [self] mixin marpa::engine::debug
	}]}
	debug.marpa/parser/forest/save {[marpa DX {Activate saved forest reports...} {
	    debug on marpa/parser/forest
	}]}
	debug.marpa/parser/forest {[marpa DX {Activate forest reports...} {
	    oo::objdefine [self] mixin marpa::engine::debug
	}]}

	next $asthandler

	marpa::import $semantics Semantics
	# Lexer will attach during setup.

	# Dynamic state for processing
	## superclass only (GRAMMAR)

	# Static configuration
	set myparts       value
	set mypreviouslhs -1 ; # ord state
	set myplhscount   0  ; # ord counter
	set myname        {} ; # custom rule name
	set mydone        0  ; # parser not exhausted

	debug.marpa/semcore {[marpa::D {
	    # Provide semcore with access to engine internals for use
	    # in its debug narrative (conversion of ids back to names)
	    Semantics engine: [namespace which -command my]
	}]}
	debug.marpa/parser {/ok}
	return
    }

    destructor {
	# The parser is done.
	catch { PRECCE destroy } ; set ::errorInfo {}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method post {args} {
	debug.marpa/parser {}
	Forward post {*}$args
    }

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

	GRAMMAR recognizer create PRECCE [mymethod Events]
	debug.marpa/parser {PRECCE = [namespace which -command PRECCE]}

	PRECCE start-input

	Lexer acceptable [PRECCE expected-terminals]
	return
    }

    method enter {syms sv} {
	debug.marpa/parser {(([my DIds $syms])) @($sv)}
	debug.marpa/parser/report {[my progress-report-current]}
	debug.marpa/parser/stream {(([my DIds $syms])) @($sv)}

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
	foreach sym $syms v $sv {
	    PRECCE alternative $sym $v 1
	}
	try {
	    PRECCE earleme-complete
	} trap {MARPA PARSE_EXHAUSTED} {e o} {
	    # Do nothing. Exhaustion is checked below.
	} on error {e o} {
	    return {*}$o $e
	}

	if {[PRECCE exhausted?]} {
	    debug.marpa/parser {exhausted}
	    my Complete
	    return
	}

	# Not exhausted. Generate feedback for our lexer on the now
	# acceptable lexemes. This creates the new lexer RECCE (see
	# p_lexer.tcl 'acceptable').

	debug.marpa/parser {Feedback, lexemes}
	Lexer acceptable [PRECCE expected-terminals]

	debug.marpa/parser {}
	return
    }

    method eof {} {
	debug.marpa/parser {}
	debug.marpa/parser/stream {EOF}

	# Flush everything pending in the local recognizer to the
	# backend before signaling eof to the asthandler.
	my Complete

	# Note, as the backend does not call us with 'acceptable' we
	# have no left-over PRECCE to destroy, contrary to the lexer's
	# situation.

	Forward eof

	catch { PRECCE destroy } ; set ::errorInfo {}
	return
    }

    # TODO: XXX fail - integrate into sequencing
    method fail {cv} {
	debug.marpa/parser {}
	debug.marpa/parser/stream {FAIL}
	upvar 1 $cv context

	# The parser has nothing to say at the moment regarding the
	# failure context. Pass forward to the AST handler.

	oo::objdefine [self] mixin marpa::engine::debug
	dict set context g1 report [my progress-report-current]

	catch { PRECCE destroy } ; set ::errorInfo {}

	Forward fail context

	# Note: This method must not return, but throw an error at
	# some point. If it returns we have an internal problem at
	# hand as well. In that case we report that now, together with
	# the context.

	my E "Unexpected return without error for problem: $context" \
	    INTERNAL ILLEGAL RETURN $context
    }

    # # -- --- ----- -------- -------------
    ## Rule support

    variable myname
    method :N {lhs __ name} {
	debug.marpa/parser {}
	set myname $name
	return
    }

    method :A {lhs __ parts} {
	debug.marpa/parser {}
	set myparts $parts
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
    ## TODO: support for general command prefix.

    method CompleteParts {parts id rid} {
	debug.marpa/parser {}
	# 'start'	offset where lexeme starts
	# 'length'	length of the lexeme
	# 'g1start'	G1 offset
	# 'g1length'	G1 length
	# 'name'	Name of the rule, or LHS symbol name
	# 'lhs'		LHS symbol id of the rule.
	# 'symbol'	LHS symbol name, always
	# 'rule'	Id of the reduced rule
	# 'value'	Children of the reduced rule
	# 'values'	Alias of 'value'
	set result {}
	foreach part $parts {
	    switch -exact -- $part {
		Afirst  -
		g1start -
		g1end   -
		values  -
		start   -
		end     -
		value   -
		length  -
		rule    { lappend result $part }
		ord     {
		    # Generate differing a sequence number for the
		    # rules of the same LHS, per their declaration
		    # order.  Allows semantics to distinguish the
		    # alternative rules
		    if {$mypreviouslhs != $id} {
			set myplhscount 0
		    } else {
			incr myplhscount
		    }
		    lappend result [list $part $myplhscount]
		}
		name {
		    if {$myname eq {}} {
			set myname [my 2Name1 $id]
		    }
		    lappend result [list $part $myname]
		    set myname {}
		}
		lhs    { lappend result [list $part $id] }
		symbol { lappend result [list $part [my 2Name1 $id]] }
	    }
	}
	return $result
    }

    # # -- --- ----- -------- -------------
    ## Parse completion

    method Complete {} {
	debug.marpa/parser {}

	# No PRECCE implies that either the parser never got fully off
	# the ground yet, or that it already did all the completion
	# work. In either case, nothing has to be done.

	if {![llength [info commands PRECCE]]} return

	# For a parse we (must?) assume (for now?) that it must end at
	# the latest earleme. If not we generate suitable parse error
	# messages. (report ?)

	debug.marpa/parser/report {[my progress-report-current]}

	set latest [PRECCE latest-earley-set]
	while {[catch {
	    debug.marpa/parser        {Check @$latest}
	    debug.marpa/parser/forest {[debug caller] | Check @$latest}
	    PRECCE forest create FOREST $latest
	}]} {
	    incr latest -1
	    if {$latest < 0} {
		# Generate a context for the parse failure.  Get as
		# much information as we can from the lexer (and the
		# gate before it). Note that this may be called
		# before the lexer is known.

		set context {}
		catch { Lexer get-context context }
		dict set context origin parser

		set mydone 1 ; # Now exhausted

		Forward fail context
		return
	    }
	}

	debug.marpa/parser {Trees: ...}
	# Pull all the valid parses and evaluate them with the
	# configured semantics, hand the resulting semantic value to
	# the backend, immediately.
	while {![catch {
	    set tree [FOREST get-parse]
	    debug.marpa/parser {Tree [incr trees]}
	    debug.marpa/parser/forest {[my parse-tree $tree]}
	    debug.marpa/parser/forest/save {[my dump-parse-tree "TP.${latest}.[incr fcounter]" $tree]}
	}]} {
	    Forward enter [Semantics eval $tree]
	}
	FOREST destroy

	# From here on only an eof signal is allowed to come from the
	# input. Note however that we cannot assume that there is no
	# more input at all. The G1 end marker may still be followed
	# by L0 discards. As these do not make it to the parser's
	# enter.
	debug.marpa/parser {Feedback, lexemes, discard only}
	Lexer acceptable [PRECCE expected-terminals]

	# The parser is done. Destruction happens in "eof" or "fail".
	set mydone 1
	return
    }

    # # -- --- ----- -------- -------------
    ## Helper for determination of dynamic destination state (enter).

    method exhausted {} {
	# 'enter' destroys PRECCE when it is exhausted.
	return $mydone; #string equal [info commands PRECCE] {}
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
