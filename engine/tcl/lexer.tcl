# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Lexer based on a low-level grammar and per-lexeme recognizer.
# Usually driven by a combination of "marpa::inbound" and
# "marpa::gate" instances. Takes a stream of symbols (characters and
# character classes) and runs them through a recognizer. Sets of
# acceptable character(classes) are fed back to the attached 'gate'
# pre-processor. Another point, this processor has its semantics
# integrated with itself.

# More notes:
#
# - LTM  : Longest Token Match
# - LATM : Longest Acceptable Token Match
# - ACS  : Acceptability Control Symbol
#
# __All__ lexemes, regardless of mode, and discard have an ACS which
# controls if they can be matched or not. LTM mode (and discards) are
# handled by having their ACS symbol always an acceptable alternative
# (see method `acceptable`). The main point of always having an ACS
# symbol is to make other places simpler, i.e. without conditionals to
# handle LTM vs LATM, etc.
#
# The lexer RECCE has a single synthetic start symbol which has
# alternatives, i.e. rules for each lexeme or discard. The rule has a
# two element RHS, ACS first, and actual symbol to match second. I.e,
# as example, for lexeme `foo` the rule is
#
#  @START --> ACS:foo foo
#

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/lexer
#debug prefix marpa/lexer {[debug caller] | }
debug define marpa/lexer/stream
#debug prefix marpa/lexer/stream {[debug caller] | }
debug define marpa/lexer/report
#debug prefix marpa/lexer/report {[debug caller] | }
debug define marpa/lexer/forest
#debug prefix marpa/lexer/forest {[debug caller] | }
debug define marpa/lexer/forest/save
#debug prefix marpa/lexer/forest/save {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create marpa::lexer {
    superclass marpa::engine

    marpa::E marpa/lexer LEXER
    validate-sequencing

    # # -- --- ----- -------- -------------
    ## Configuration

    # Static
    variable mypublic     ;# sym id:local  -> (id:parser, parts)
    variable myacs        ;# sym id:parser -> id:acs:local
    variable myalways     ;# Set of ACS for discarded symbols and LTM
			   # lexemes, i.e. symbols which are always
			   # acceptable

    # Dynamic
    variable myparts      ;# Sem value definition for the following exports

    # # -- --- ----- -------- -------------
    ## State

    # Dynamic
    variable myacceptable ;# Remembered (last call of 'Acceptable')
			   # set of the parser's acceptable symbols.
			   # Required for the regeneration of our
			   # recognizer after a discarded lexeme was
			   # found in the input.
    variable mystart      ;# start offset for the current lexeme

    # Constant
    variable mynull       ;# Semantic value for ACS, empty string,
			   # floating location

    # RECCE - Local recognizer object.
    # - Created in acceptable.
    # - Destroyed in either eof or enter
    #   eof may encounter state where RECCE does not exist.
    variable myrecce ;# Store RECCE handle, for easier querying.

    ##
    # API self:
    # 1 cons    (semstore, parser) - Create, link, attach to parser.
    # 2 gate:   (gate)        - gate attaching to us for feedback on acceptables.
    # 3 symbols (symlist)     - (inbound/gate, self) bulk allocation of symbols
    # 4 export  (symlist)     - Bulk allocation of public symbols
    # 5 action  (...)         - Semantic value definition
    # 6 rules   (rules)       - Bulk specification of grammar rules
    # 7 discard (ignorelist)  - Complete lexer spec
    # 8 acceptable (symlist)  - Declare set of allowed symbols
    # 9 enter   (syms val)    - Incoming sym set with semantic value
    # A eof     ()            - Incoming end of input signal
    ##
    # Sequence = 1([23456]*7(8(98?)*)?)?A
    # See mark <<s>>
    ##
    # API gate:
    #   acceptable (symlist)  - Declare set of allowed symbols
    #   redo       (n)        - Force re-entry of last n symbols
    ##
    # API parser:
    #   gate:   (self)     - Self attaching to parser for feedback on acceptables.
    #   enter   (syms val) - Push symbol set with semantic value
    #   fail    ()         - Lexer failed (TODO: error information)
    #   eof     ()         - Push end of input signal
    #   symbols (symlist)  - Bulk allocate symbols for ruleschar and char classes.

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {semstore parser} {
	debug.marpa/lexer {[debug caller] | }
	debug.marpa/lexer/report {[marpa DX {Activate progress reports...} {
	    oo::objdefine [self] mixin marpa::engine::debug
	}]}
	debug.marpa/lexer/forest/save {[marpa DX {Activate saved forest reports...} {
	    debug on marpa/lexer/forest
	}]}
	debug.marpa/lexer/forest {[marpa DX {Activate forest reports...} {
	    catch { oo::objdefine [self] mixin marpa::engine::debug }
	}]}

	next $parser

	marpa::import $semstore Store
	# Gate will attach during setup.

	# Dynamic state for processing
	set myacceptable {}   ;# Parser gating.
	set myrecce      {}   ;# Local recce management

	# Static configuration and state
	set mypublic  {}
	set myacs     {}
	set myparts   value ;# Default: lexeme literal semantics
	set myalways  {}
	set mynull    [Store put [marpa location null]]
	set mystart   {}

	my SetupSemantics [marpa::fqn $semstore 2]

	# Attach ourselves to parser, as gate.
	Forward gate: [self]

	debug.marpa/gate {/ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method gate: {gate} {
	debug.marpa/lexer {[debug caller] | }
	marpa::import $gate Gate
	return
    }

    method action {names} {
	debug.marpa/lexer {[debug caller] | }
	set myparts $names
	return
    }
    
    method export {names} {
	# names :: map (sym -> latm)
	debug.marpa/lexer {[debug caller] | }
	# Create base symbols.
	# Create the internal acceptability controls symbols (short: ACS) for the base
	# Get the same symbols from parser as well, the third set.

	set allnames [dict keys $names]
	set local    [my symbols $allnames]
	set acs      [my symbols [my ToACS $allnames]]
	set parse    [Forward symbols $allnames]

	# Map from local to parser symbol     (id -> id)
	# Map from parser to local ACS symbol (id -> id)
	foreach s $local p $parse a $acs n $allnames {
	    dict set mypublic $s [list $p $myparts]
	    dict set myacs    $p $a

	    set latm [dict get $names $n]
	    if {!$latm} { lappend myalways $a }
	    # NOTE (%%): Here and method `acceptable` are the two
	    # points where the difference between the LATM and LTM
	    # match disciplines is injected into the runtime. We do
	    # this by always activating the ACS for LTM symbols.
	    
	    debug.marpa/lexer {[debug caller 1] | PUBLIC ($n) = local:$s --> up:$p}
	    debug.marpa/lexer {[debug caller 1] | ACS    ($n) = up:$p --> local:$a}
	}

	return $local
    }

    method discard {discards} {
	debug.marpa/lexer {[debug caller] | }
	# Set of discard symbols. This makes the lexer a
	# lexer. Creates an internal start symbol with rules mapping
	# it to all the public symbols, and the symbols in the discard
	# list. The lexer will repeat.

	foreach sym $discards {
	    set id [my 2ID1 $sym]
	    if {![dict exists $mypublic $id]} continue
	    my E "Cannot discard exported symbol $sym" DISCARD-EXPORT $sym
	}

	set start [my symbols [list @START]]
	GRAMMAR sym-start: $start

	# Note how the ACS is added to these internal rules from the
	# internal start symbol to the exported and discard symbols.
	# Doing it here avoids cluttering the base engine with
	# lexer-specific data and code. No special rules, no wrapper
	# rules for quantified rules. Only the helper rules here.

	foreach symid [dict keys $mypublic] {
	    lassign [dict get $mypublic $symid] pid parts
	    set acs [dict get $myacs $pid]
	    set rid [my RuleP $start  $acs $symid]

	    # TODO: Precompute the information for builtin semantics in the generator.
	    set parts [my CompleteParts $parts $symid $pid $rid]

	    # (:D:) Set semantic, lexeme parser symbol, and per-lexeme semantic value
	    GetSymbol add-rule $rid [list marpa::semstd::K $pid]
	    GetString add-rule $rid [list marpa::semstd::builtin $parts]
	}

	foreach sym $discards acs [my symbols [my ToACS $discards]] {
	    lappend myalways $acs
	    set id  [my 2ID1 $sym]
	    set rid [my RuleP $start  $acs $id]

	    dict set myacs $acs $acs

	    # (:D:) set semantics, discard marker. Nothing for semantic value.
	    GetSymbol add-rule $rid [list marpa::semstd::K -1]
	}

	my Freeze
	return
    }

    method enter {syms sv} {
	debug.marpa/lexer {[debug caller] | ([my DIds $syms]) @([my DLocation $sv])}
	debug.marpa/lexer/report {[my progress-report-current]}
	debug.marpa/lexer/stream {([my DIds $syms])	 @ [my DLocation $sv]}

	if {$mystart eq {}} {
	    lassign [Store get $sv] mystart __ __
	}

	if {![llength $syms]} {
	    debug.marpa/lexer {[debug caller] | no acceptable symbols, close current lexeme}

	    # Input has no acceptable character waiting. Complete the
	    # current lexeme, and then let the input try again.

	    ## TODO: Check if this happens again immediately ........
	    ## If yes we have a more serious problem and should stop.
	    my Complete

	    debug.marpa/lexer {[debug caller] | /ok:close}
	    return
	}

	# Drive the low-level recognizer
	debug.marpa/lexer {[debug caller] | step recce engine}
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
	    debug.marpa/lexer {[debug caller] | exhausted}
	    my Complete

	    debug.marpa/lexer {[debug caller] | /ok:exhausted}
	    return
	}

	# Not exhausted. Generate feedback for our gate on the now
	# acceptable characters and classes.

	debug.marpa/lexer {[debug caller] | Feedback to gate, chars and classes}
	Gate acceptable [RECCE expected-terminals]

	debug.marpa/lexer {[debug caller] | /ok}
	return
    }

    method fail {cv} {
	debug.marpa/lexer {[debug caller] | }
	upvar 1 $cv context

	my ExtendContext context
	debug.marpa/lexer/stream {FAIL}
	Forward fail context

	# Note: This method must not return, but throw an error at
	# some point. If it returns we have an internal problem at
	# hand as well. In that case we report that now, together with
	# the context.

	my E "Unexpected return without error for problem: $context" \
	    INTERNAL ILLEGAL RETURN $context
    }

    method get-context {cv} {
	debug.marpa/lexer {[debug caller] | }
	upvar 1 $cv context

	Gate get-context context
	my ExtendContext context
	return
    }

    method eof {} {
	debug.marpa/lexer {[debug caller] | }

	# Flush everything pending in the local recognizer to the
	# parser before signaling eof to the parser. Do this only if
	# we actually have seen something and thus pending.
	if {$mystart ne {}} {
	    my Complete
	}

	debug.marpa/lexer/stream {EOF}

	#  Note that the flush leaves us with a just-started
	# recognizer, which we have to remove again.
	if {$myrecce ne {}} {
	    RECCE destroy
	    set myrecce {}
	}

	Forward eof
	return
    }

    method acceptable {syms} {
	debug.marpa/lexer {[debug caller] | }
	# Lexer method, called by parser.
	# syms is list of parser symbol ids for lexemes.
	# transform into acs ids, and insert into the recognizer.
	# TODO: Handle case of LTM also, without ACS

	set myacceptable $syms
	set myrecce [GRAMMAR recognizer create RECCE [mymethod Events]]
	debug.marpa/lexer {[debug caller 1] | RECCE = [namespace which -command RECCE]}
	set mystart {}

	RECCE start-input
	debug.marpa/lexer/report {[my progress-report-current]}
	debug.marpa/lexer/stream {START ([my DIds $syms])}

	if {[llength $syms] || [llength $myalways]} {
	    # NOTE (%%): Here and method `export` are the two points
	    # where the difference between the LATM and LTM match
	    # disciplines is injected into the runtime. We do this by
	    # always activating the ACS for LTM symbols (and discards).
	    foreach s [lsort -unique [concat $syms $myalways]] {
		debug.marpa/lexer {[debug caller 1] | U ==> $s <[my 2Name1 $s]>}
		RECCE alternative [dict get $myacs $s] $mynull 1
	    }
	    RECCE earleme-complete
	    # Tcl 8.6: lmap
	}

	# Push the set of now acceptable lexer symbols down into the
	# gate instance
	Gate acceptable [RECCE expected-terminals]
	return
    }

    method redo {n} {
	debug.marpa/lexer {[debug caller] | }
	# Lexer method, called by parser.
	my E "Lexer cannot redo symbols" REDO
	return
    }

    # # ## ### ##### ######## #############
    ## Lexer - Completion of a lexeme

    method CompleteParts {parts id pid rid} {
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
		symbol  { lappend result [list $part $pid] }
		lhs     { lappend result [list $part ??] }
	    }
	}
	return $result
    }

    # # ## ### ##### ######## #############
    ## Helper for debug narrative. No other use.
    
    method FromACS {ids} {
	# For lexemes map the parser symbol ids back to their lexer
	# symbols. For LATM-mode lexemes this is their ACS symbol,
	# otherwise their regular lexer symbol.
	lmap id $ids { dict get $myacs $id }
    }

    method ToACS1 {name} { return "ACS:$name" }
    method ToACS {names} {
	# symbol names transformed into symbol names for ACS
	debug.marpa/engine {[debug caller] | }
	lmap name $names { my ToACS1 $name }
    }

    # # ## ### ##### ######## #############
    
    method Complete {} {
	debug.marpa/lexer {[debug caller] | }

	if {$myrecce eq {}} {
	    debug.marpa/lexer {[debug caller] | Bail out. No recce available}
	    return
	}

	# I. Pull the location of longest lexeme out of the recognizer
	#    state
	set latest [RECCE latest-earley-set]
	set redo   0

	while {[catch {
	    debug.marpa/lexer        {[debug caller] | Check @$latest}
	    debug.marpa/lexer/forest {[debug caller] | Check @$latest}
	    RECCE forest create FOREST $latest
	} msg o]} {
	    incr redo
	    incr latest -1
	    if {$latest < 0} {
		my get-context context

		# The current recognizer is done.
		RECCE destroy
		set myrecce {}

		Forward fail context

		# Note: This method must not return, but throw an
		# error at some point. If it returns we have an
		# internal problem at hand as well. In that case we
		# report that now, together with the context.

		my E "Unexpected return without error for problem: $context" \
		    INTERNAL ILLEGAL RETURN $context
	    }
	}
	debug.marpa/lexer {[debug caller] | Lexeme length: $latest}
	debug.marpa/lexer {[debug caller] | Redo:          $redo}

	# II. Pull all the valid parses at this location
	set forest {}
	while {![catch {
	    lappend forest [FOREST get-parse]
	    debug.marpa/lexer/forest {__________________________________________ Tree [incr fcounter] ([llength [lindex $forest end]])}
	    debug.marpa/lexer/forest {[my parse-tree [lindex $forest end]]}
	    debug.marpa/lexer/forest/save {[my dump-parse-tree "TL.@${mystart}+${latest}.$fcounter" [lindex $forest end]]}
	}]} {}
	FOREST destroy

	debug.marpa/lexer {[debug caller] | Trees:         [llength $forest]}

	# III. Evaluate the parses with the configured semantics,
	#      getting one symbol and semantic value per.

	set found {}
	set sv    -1
	set first yes
	set recognized 0
	set discarded  0
	foreach tree $forest {
	    # Note, we assume that the 'sv' is the same for all
	    # symbols and generate it only on first.

	    # NOTE! The last step is always the reduction of the lexeme to
	    # @START.  We drop that step as we want the lexeme itself.
	    #set tree [lrange $tree 0 end-2]

	    # Calculate lexeme parser symbol. See (:D:) for where the
	    # semantics are set to get it here. No further translation
	    # needed!
	    set symbol [GetSymbol eval $tree]

	    incr recognized
	    # Discarded symbols are signaled by marker -1, see (:D:)
	    if {$symbol < 0} {
		incr discarded
		continue
	    }

	    # Extract the semantic value iff not discarded and first.
	    if {$first} {
		# Calculate the string value of the lexeme.
		set sv [Store put [GetString eval $tree]]
	    }
	    set first no

	    lappend found $symbol
	}

	# Reduce the symbol to the unique subset. Lexing ambiguities
	# may have us see lexeme multiple times, each per possible
	# parse-tree. In the SLIF grammar this is visible with
	# 'character class'.
	set found [lsort -uniq $found]

	debug.marpa/lexer {[debug caller] | Recognized: $recognized}
	debug.marpa/lexer {[debug caller] | Discarded:  $discarded}
	debug.marpa/lexer {[debug caller] | Symbols:    [llength $found] ($found)}
	debug.marpa/lexer {[debug caller] | Semantic:   $sv ([expr {($sv < 0) ? "" : [my DLocation $sv]}])}

	# NOTE! Due to the usage of ACS when the RECCE was initalized
	# at this point we can have only a subset of the acceptable
	# symbols. We cannot generate invalid symbols (assuming we
	# have set everything up correctly).
	#
	# Exception: We may have come across discarded symbols.

	# The current recognizer is done.
	RECCE destroy
	set myrecce {}

	debug.marpa/lexer {[debug caller] | Have (([my DIds [my FromACS $found]])) ${sv}=([expr {($sv < 0) ? "" : [my DLocation $sv]}])}

	if {($recognized > 0) && ($recognized == $discarded)} {
	    # We found symbols, and only discarded symbols.
	    # Restart lexing without informing the parser, keeping
	    # to the current set of acceptable symbols
	    debug.marpa/lexer {[debug caller] | Discard ...}

	    debug.marpa/lexer/stream {FIN, discard}

	    my acceptable $myacceptable

	    debug.marpa/lexer {[debug caller] | ... Ok}
	} else {
	    # Push the symbol set up to the parser. This will also
	    # give us feedback about the new set of acceptable
	    # symbols, and generate a new RECCE, see 'Acceptable'.

	    debug.marpa/lexer {[debug caller] | Push ...}

	    # ASSERT (sv >= 0)
	    debug.marpa/lexer/stream {FIN, push: (([my DIds [my FromACS $found]]))}
	    Forward enter $found $sv

	    debug.marpa/lexer {[debug caller] | ... Ok}
	}

	# Last, not least, have our gate re-enter any characters we
	# were not able to process (see redo counter above).

	debug.marpa/lexer {[debug caller] | Re-process $redo ...}
	Gate redo $redo
	debug.marpa/lexer {[debug caller] | ... Reprocessed}
	return
    }

    method ExtendContext {cv} {
	debug.marpa/lexer {[debug caller] | }
	upvar 1 $cv context

	# Extend the context we got from the gate with lexeme
	# information, i.e. which were acceptable to the parser.
	# Then forward to the parser for his take.

	dict set context g1 acceptable [lsort -dict [lmap s [my 2Name [my FromACS [lsort -unique [concat $myacceptable $myalways]]]] {
	    string map {ACS: {}} $s
	}]]
	return
    }

    # # ## ### ##### ######## #############
    ## Lexer semantics

    method SetupSemantics {semstore} {
	debug.marpa/lexer {[debug caller] | }

	# Standard semantics for lexemes.
	# I. Extract lexeme symbol. The exported and discarded symbols
	#    override the rule default.
	marpa::semcore create GetSymbol $semstore
	GetSymbol add-rule  @default marpa::semstd::nop
	GetSymbol add-null  @default marpa::semstd::nop
	GetSymbol add-token @default marpa::semstd::nop

	# II. Extract the semantic value. The exported override the
	#     rule default with grammar data. The default simply
	#     merges lexeme ranges.

	marpa::semcore create GetString $semstore \
	    {sv marpa::location::show}
	GetString add-rule  @default marpa::semstd::locmerge
	GetString add-null  @default marpa::location::null*

	# The exported symbols will declare their own rules as per the
	# specification in the grammar.

	debug.marpa/semcore {[marpa::D {
	    # Provide semcore with access to engine internals for use
	    # in its debug narrative (conversion of ids back to names)
	    set my [namespace which -command my]
	    GetSymbol engine: $my
	    GetString engine: $my
	}]}
	debug.marpa/lexer {[debug caller] | /ok}
	return
    }

    # # ## ### ##### ######## #############
}


# # ## ### ##### ######## #############
## Mixin helper class. State machine checking the method call
## sequencing of marpa::lexer instances.

## The mixin is done on user request (method in main class).
## Uses: testing
##       debugging in production

oo::class create marpa::lexer::sequencer {
    superclass sequencer

    # State machine for marpa::lexer
    ##
    # Sequence = 1([23456]*7(8(98?)*)?)?A
    # See mark <<s>>
    ##
    # Deterministic state machine _________ # Table re-sorted, by method _
    # Current Method --> New          Notes # Method  Current --> New
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # -       <cons>     made		    # <cons>  -           made
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # made    gate:      made         [0]   # gate:   made        made
    #         symbols    made		    # symbols made        made
    #         export     made		    # export  made        made
    #         action     made		    # action  made        made
    #         rules      made		    # rules   made        made
    #         discard    config		    # discard made        config
    #         eof        done		    # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # accept  config      gated
    # config  accept     gated        [1]   #         data        gated
    #         eof        done		    #         done        complete
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # gated   enter      data		    # enter   gated       data
    #         eof        done		    #         data        data
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # data    accept     gated		    # eof     made        done
    #         enter      data		    #         config      done
    #         eof        done		    #         gated       done
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ #         data        done
    # done    accept     complete	    # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ # *       *           /FAIL
    # *       *          /FAIL		    # ~~~~~~  ~~~~~~~     ~~~~~~~~
    # ~~~~~~~ ~~~~~~     ~~~~~~~~~~~~ ~~~~~ #
    # [0] Gate declaration, coming from the gate.
    # [1] initial accept, before all data, part of the setup, coming from
    #     the parser

    # Notes
    ##
    # - At the end of a lexeme 'enter' triggers 'accept' from the
    #   post-processor (parser). This means:
    #
    #     gated -> gated
    #     data  -> gated
    #
    #   whereas during the scanning of a lexeme
    #
    #     gated -> data
    #     data  -> data
    #
    # - An 'eof' triggers a last 'accept' from the post-processor (parser).

    # # -- --- ----- -------- -------------
    ## Mandatory overide of virtual base class method

    method __Init {} { my __States made config gated data done complete }

    # # -- --- ----- -------- -------------
    ## Checked API methods

    method gate: {gate} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $gate
    }

    method symbols {names} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $names
    }

    method export {names} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $names
    }

    method action {names} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $names
    }

    method rules {rules} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $rules
    }

    method discard {discards} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $discards
	# State move after main code. Internally calls on 'symbols'
	# etc. Would be broken by an early state change
	my __On made --> config
    }

    method eof {} {
	my __Init
	my __Fail {done complete} ! "After end of input" EOF
	next

	my __On {made config gated data} --> done
    }

    method acceptable {syms} {
	my __Init
	my __Fail made     ! "Setup missing" MISSING SETUP
	# XXX Remove above, induce seg.fault - marpa-lexer-1.3.1
	# acceptable ... RECCE start-input ... NULL recognizer ptr
	# ... incomplete/bad recce construction ...
	# ... Empty grammar ?!
	my __Fail gated    ! "Data missing" MISSING DATA
	my __Fail complete ! "After end of input" EOF
	next $syms

	my __On {config data} --> gated
	my __On done          --> complete
    }

    method enter {syms sv} {
	my __Init
	my __Fail made            ! "Setup missing" MISSING SETUP
	my __Fail config          ! "Gate missing" MISSING GATE
	my __Fail {done complete} ! "After end of input" EOF
	# Note: Early state change. This ensures that we are in the
	# proper state for the callback from the postprocessor
	# (i.e. acceptable)
	my __On {gated data} --> data
	next $syms $sv
    }

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
