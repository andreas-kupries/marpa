# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Lexer based on a low-level grammar and per-lexeme
# recognizer. Usually driven by a combination of "marpa::inbound" and
# "marpa::gate". Takes a stream of symbols (chars, char-classes) and
# runs them through a recognizer. Sets of acceptable char(classes) are
# fed back to the attached 'gate' pre-processor. Another point, this
# processor has its semantics integrated with itself.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/lexer
#debug prefix marpa/lexer {[debug caller] | }

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
    variable mydiscard    ;# Set of ACS for discarded lexemes

    # Dynamic
    variable myparts      ;# Sem value definition for the following exports
    variable mylatm       ;# Match discipline for the following exports

    # # -- --- ----- -------- -------------
    ## State

    # Dynamic
    variable myacceptable ;# Remembered (last call of 'Acceptable')
			   # set of parser acceptable symbols.
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
	set mylatm    yes   ;# Default: longest acceptable token match
	set mydiscard {}
	set mynull    [Store put [marpa location null]]
	set mystart   {}

	my SetupSemantics $semstore

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

    method latm {flag} {
	debug.marpa/lexer {[debug caller] | }
	# TODO: validate as boolean
	set mylatm $flag
	return
    }

    method action {names} {
	debug.marpa/lexer {[debug caller] | }
	set myparts $names
	return
    }

    method export {names} {
	debug.marpa/lexer {[debug caller] | }
	# Create base symbols.
	# Create the internal acceptability controls symbols (short: ACS) for the base
	# Get the same symbols from parser as well, the third set.

	# NOTE! the ACS are created regardless of LATM or not. The
	# LATM choice is made later, in "Discard", by adding it to the
	# main rule of the lexeme, or not.

	# We could possibly optimize by defering the operations below
	# until the whole grammaer is loaded. This would also force a
	# deferal in the handling of rules.

	# Might be easier to rewrite the system after the bootstrap,
	# when the lexer/parser is wholly generated from the SLIF,
	# instead of written manually.

	set local [my symbols $names]
	set acs   [my symbols [my ToACS $names]]
	set parse [Forward symbols $names]

	# Map from local to parser symbol     (id -> id)
	# Map from parser to local ACS symbol (id -> id)
	foreach s $local p $parse a $acs n $names {
	    dict set mypublic $s [list $p $myparts $mylatm]
	    dict set myacs    $p $a

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
	# Doing it here avoids cluttering the engine with
	# lexer-specific data and code. No special rules, no wrapper
	# rules for quantified rules. Only the helper rules here.

	# NOTE: This is the point where the difference between the
	# LATM and LTM match disciplines is injected into the runtime.

	# TODO: Get rid of the global flag and make it per-lexeme.
	# Currently we are fixed to a global LATM vs LTM setting.

	# Add the ACS in front of the rules of the exported symbols.
	# TODO: map of the lexemes

	# TODO: FUTURE: Need the ability to choose per-lexeme LATM vs
	# LTM for the discard symbols as well.

	foreach symid [dict keys $mypublic] {

	    lassign [dict get $mypublic $symid] pid parts latm
	    set acs [dict get $myacs $pid]

	    if {$latm} {
		set id [GRAMMAR rule-new $start $acs $symid]
	    } else {
		set id [GRAMMAR rule-new $start $symid]
	    }
	    my Rule $id $start ;# required for semantics debug narrative

	    set parts [my CompleteParts $parts $symid $pid $id]

	    # (:D:) Set semantic, lexeme parser symbol, and per-lexeme semantic value
	    GetSymbol add-rule $id [list marpa::semstd::K $pid]
	    GetString add-rule $id [list marpa::semstd::builtin $parts]
	}

	set mydiscard [my symbols [my ToACS $discards]]

	foreach sym $discards acs $mydiscard {
	    set id [my 2ID1 $sym]
	    set id [GRAMMAR rule-new $start   $acs $id]
	    my Rule $id $start ;# required for semantics debug narrative

	    # (:D:) set semantics, discard marker. Nothing for semantic value.
	    GetSymbol add-rule $id [list marpa::semstd::K -1]
	}

	my Freeze
	return
    }

    method enter {syms sv} {
	debug.marpa/lexer {[debug caller] | See '[join [my 2Name $syms] {' '}]' ([marpa location show [Store get $sv]])}

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

    method eof {} {
	debug.marpa/lexer {[debug caller] | }

	# Flush everything pending in the local recognizer to the
	# parser before signaling eof to the parser.
	my Complete

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
	if {[llength $syms] || [llength $mydiscard]} {
	    foreach s $syms {
		debug.marpa/lexer {[debug caller 1] | U ==> $s '[my 2Name1 $s]'}
		RECCE alternative [dict get $myacs $s] $mynull 1
	    }
	    foreach s $mydiscard {
		debug.marpa/lexer {[debug caller 1] | D ==> $s '[my 2Name1 $s]'}
		RECCE alternative $s $mynull 1
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

    # Helper for debug narrative. No other use.
    method ACS {idlist} {
	set r {}
	foreach id $idlist { lappend r [my 2Name1 [dict get $myacs $id]] }
	return $r
    }

    method ToACS {names} {
	debug.marpa/engine {[debug caller] | }
	set r {}
	foreach name $names { lappend r ACS:$name }
	return $r
    }

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
	    debug.marpa/lexer {[debug caller] | Check at $latest}
	    RECCE forest create FOREST $latest
	} msg o]} {
	    incr redo
	    incr latest -1
	    if {$latest < 0} {
		Forward fail [dict create \
				  msg "No lexeme found at $mystart" \
				  at  $mystart]

		# TODO: Here more information can be provided, i.e.
		#       where in the input we got stopped, and such.
		#       This could/should be made a method for every
		#       processor in the pipeline, to forward a problem
		#       and each stage adding its own information.

		# The current recognizer is done.
		RECCE destroy
		set myrecce {}
		return
	    }
	}
	debug.marpa/lexer {[debug caller] | Lexeme length: $latest}
	debug.marpa/lexer {[debug caller] | Redo:          $redo}

	# II. Pull all the valid parses at this location
	set forest {}
	while {![catch {
	    lappend forest [FOREST get-parse]
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
	debug.marpa/lexer {[debug caller] | Semantic:   $sv ([expr {($sv < 0) ? "" : [marpa location show [Store get $sv]]}])}

	# NOTE! Due to the usage of ACS when the RECCE was initalized
	# at this point we can have only a subset of the acceptable
	# symbols. We cannot generate invalid symbols (assuming we
	# have set everything up correctly).
	#
	# Exception: We may have come across discarded symbols.

	# The current recognizer is done.
	RECCE destroy
	set myrecce {}

	debug.marpa/lexer {[debug caller] | Have '[join [my ACS $found] {' '}]' ${sv}=([expr {($sv < 0) ? "" : [marpa location show [Store get $sv]]}])}

	if {($recognized > 0) && ($recognized == $discarded)} {
	    # We found symbols, and only discarded symbols.
	    # Restart lexing without informing the parser, keeping
	    # to the current set of acceptable symbols
	    debug.marpa/lexer {[debug caller] | Discard ...}

	    my acceptable $myacceptable

	    debug.marpa/lexer {[debug caller] | ... Ok}
	} else {
	    # Push the symbol set up to the parser. This will also
	    # give us feedback about the new set of acceptable
	    # symbols, and generate a new RECCE, see 'Acceptable'.

	    debug.marpa/lexer {[debug caller] | Push ...}

	    # ASSERT (sv >= 0)
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
    #         latm       made		    # latm    made        made
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

    method latm {flag} {
	my __Init
	my __FNot made ! "Lexer is frozen" FROZEN
	next $flag
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
