# -*- tcl -*-
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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
debug define marpa/lexer/events
#debug prefix marpa/lexer/events {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create marpa::lexer {
    superclass marpa::engine

    marpa::E marpa/lexer LEXER
    validate-sequencing

    # # -- --- ----- -------- -------------
    ## Configuration

    # Static
    variable mypublic     ;# sym id:local  -> id:parser
    variable myacs        ;# sym id:parser -> id:acs:local
    variable mylex        ;# sym id:parser -> id:local (lexeme, not acs)
    variable myalways     ;# Set (list) of ACS for discarded symbols
			   # and LTM lexemes, i.e. symbols which are
			   # always acceptable

    # Dynamic
    variable myparts      ;# Sem value definition for the following exports

    # # -- --- ----- -------- -------------
    ## State

    # Dynamic
    variable myaccmemo    ;# Cache of translations for sets of
			   # acceptable symbols.
    variable myacceptable ;# Remembered (last call of 'Acceptable')
			   # set of the parser's acceptable symbols.
			   # Required for the regeneration of our
			   # recognizer after a discarded lexeme was
			   # found in the input.
    variable mylexeme     ;# characters in the current lexeme.

    # M - Subordinate match information storage object.
    #     Exposed as parse event descriptor to parse event handlers.

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
    #   fail    (cvar)     - Lexer failed (Argument is varname for context information)
    #   eof     ()         - Push end of input signal
    #   symbols (symlist)  - Bulk allocate symbols for ruleschar and char classes.

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {semstore parser} {
	method-benchmarking
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
	set myaccmemo    {}   ;# Cache for gating.
	set myrecce      {}   ;# Local recce management

	# Static configuration and state
	set mypublic  {}
	set myacs     {}
	set mylex     {}
	set myparts   value ;# Default: lexeme literal semantics
	set myalways  {}
	set mynull    [Store put [marpa location null]]
	set mylexeme  ""

	# Match information storage, and public facade.
	# The latter is created and configured in `gate:`.
	marpa::lexer::match create M
	M event: 0
	M g1start: {} ; # XXX pull information from parser.
	M g1length: 1

	# Attach ourselves to parser, as gate.
	Forward gate: [self]

	debug.marpa/lexer {/ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    forward match PED

    method events {spec} {
	debug.marpa/lexer {[debug caller] | }
	# spec : sym -> (type -> (name -> active))

	# Convert the symbols to the relevant ids, then pass down into
	# the engine. Conversion is type dependent. Make use of the
	# fact that we can have only one event per type for a symbol.
	set cspec {}
	dict for {symbol def} $spec {
	    foreach type {discard before after} {
		if {![dict exists $def $type]} continue
		switch -exact -- $type {
		    discard {
			# Discard symbol name. Get relevant ACS id
			set id D.[my 2ID1 [my ToACS1 $symbol]]
		    }
		    before - after {
			# Lexeme symbol name. Get its parser symbol id.
			set id L.[dict get $mypublic [my 2ID1 $symbol]]
		    }
		}
		# Note, we used prefixes D. and P. to ensure that we
		# could not have conflicts between the local ACS ids
		# and the upstream parser ids.
		dict set cspec $id $def
	    }
	}

	next $cspec
	return
    }

    method gate: {gate} {
	debug.marpa/lexer {[debug caller] | }
	marpa::import $gate Gate
	marpa::lexer::ped   create PED M $gate
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
	# Map from parser to local symbol     (id -> id)
	foreach s $local p $parse a $acs n $allnames {
	    dict set mypublic $s $p
	    dict set myacs    $p $a
	    dict set mylex    $p $s

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
	    set pid [dict get $mypublic $symid]
	    set acs [dict get $myacs $pid]
	    set rid [my RuleP $start  $acs $symid]

	    # Extend for use in Complete (to determine parser symbol)
	    dict set mypublic $acs $pid
	}

	foreach sym $discards acs [my symbols [my ToACS $discards]] {
	    lappend myalways $acs
	    set id  [my 2ID1 $sym]
	    set rid [my RuleP $start  $acs $id]

	    dict set myacs $acs $acs

	    # Extend for use in Complete (:D: mark as discarded, no parser symbol)
	    dict set mypublic $acs -1
	}

	my Freeze
	return
    }

    method enter {syms thechar thelocation} {
	# sub-lexer sv = list(char location)
	debug.marpa/lexer        {[debug caller 2] | ([my DIds $syms]) @($thelocation) '[char quote cstring $thechar]'}
	debug.marpa/lexer/report {[my progress-report-current]}
	debug.marpa/lexer/stream {([my DIds $syms]) '[char quote cstring $thechar]' @ $thelocation}

	if {[M start] eq {}} {
	    M start: $thelocation
	}

	if {![llength $syms]} {
	    debug.marpa/lexer {[debug caller 2] | no acceptable symbols, close current lexeme}
	    # Input has no acceptable character waiting. Complete the
	    # current lexeme and then let the input try again.

	    ## TODO: Check if this happens again immediately ........
	    ## If yes we have a more serious problem and should stop.
	    my Complete

	    debug.marpa/lexer {[debug caller 2] | /ok:close}
	    return
	}

	# Extend the possible match and drive the low-level recognizer
	append mylexeme $thechar
	debug.marpa/lexer {[debug caller 2] | step recce engine}
	foreach sym $syms {
	    RECCE alternative $sym 1 1 ;# FAKE sv for the chars in the lexeme.
	}

	try {
	    RECCE earleme-complete
	} trap {MARPA PARSE_EXHAUSTED} {e o} {
	    # Do nothing. Exhaustion is checked below.
	} on error {e o} {
	    return {*}$o $e
	}

	if {[RECCE exhausted?]} {
	    debug.marpa/lexer {[debug caller 2] | exhausted}
	    my Complete

	    debug.marpa/lexer {[debug caller 2] | /ok:exhausted}
	    return
	}

	# Not exhausted. Generate feedback for our gate on the now
	# acceptable symbols, i.e. characters and classes.

	debug.marpa/lexer {[debug caller 2] | Feedback to gate, chars and classes}
	Gate acceptable [RECCE expected-terminals]

	debug.marpa/lexer {[debug caller 2] | /ok}
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
	dict set context origin lexer
	my ExtendContext context
	return
    }

    method eof {} {
	debug.marpa/lexer {[debug caller] | }

	# Flush everything pending in the local recognizer to the
	# parser before signaling eof to the parser. Do this if and
	# only if we actually saw something.
	if {[M start] ne {}} {
	    if {[my Complete]} {
		debug.marpa/lexer {[debug caller] | eof bounce, retry}
		return
	    }

	    # At this point the input may have been bounced away from
	    # the EOF.  This is signaled by a `true` return. If that
	    # is so we must not report to the parser yet. We will come
	    # to this method again, after the characters were
	    # re-processed.
	}

	debug.marpa/lexer/stream {EOF}

	#  Note that the flush leaves us with a just-started
	# recognizer, which we have to remove again.
	if {$myrecce ne {}} {
	    debug.marpa/lexer {[debug caller] | RECCE kill 1 [namespace which -command RECCE]}
	    RECCE destroy
	    set myrecce {}
	}

	Forward eof
	return
    }

    method acceptable {syms} {
	debug.marpa/lexer {[debug caller] | }
	# This lexer method is called by the parser.

	# `syms` is a list of parser symbol ids for the lexemes it can
	# accept. Transform this into a list of ACS ids, and insert
	# them into the recognizer.

	set myrecce [GRAMMAR recognizer create RECCE [mymethod Events]]
	debug.marpa/lexer {[debug caller 1] | RECCE ::=  [namespace which -command RECCE]}
	M start: {}
	set mylexeme {}

	RECCE start-input
	debug.marpa/lexer/report {[my progress-report-current]}
	debug.marpa/lexer/stream {START ([my DIds $syms])}

	set myacceptable $syms
	if {[llength $syms] || [llength $myalways]} {
	    if {[dict exists $myaccmemo $syms]} {
		# Employ the cache to quickly translate sets we have
		# seen before.
		set enter [dict get $myaccmemo $syms]
	    } else {
		# NOTE (%%): Here and method `export` are the two
		# points where the difference between the LATM and LTM
		# match disciplines is injected into the runtime. We
		# do this by always activating the ACS for LTM symbols
		# (and discards).
		foreach s [lsort -unique [concat $syms $myalways]] {
		    lappend enter [dict get $myacs $s]
		}
		dict set myaccmemo $syms $enter
	    }
	    foreach s $enter {
		debug.marpa/lexer {[debug caller 1] | U ==> $s <[my 2Name1 $s]>}
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

    method PEFill {found sv} {
	debug.marpa/lexer {[debug caller] | }
	set prehandler [lmap f $found {
	    my 2Name1 [dict get $mylex $f]
	}]
	M symbols: $prehandler
	M sv:      $sv
	M fresh:   1
	return $prehandler
    }

    method Post {type events} {
	debug.marpa/lexer {[debug caller] | }
	# Note, M is passed implicitly, made accessible through the
	# `match` method of the main object.
	M event: 1
	Forward post $type $events
	M event: 0
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

    # # ## ### ##### ######## #############
    ## Helper for debug narrative, and `ExtendedContext`.

    method FromParser {ids} {
	# For lexemes map the parser symbol ids back to their lexer
	# ACS symbols.
	lmap id $ids { dict get $myacs $id }
    }

    method ToACS1 {name} { return "ACS:$name" }
    method ToACS {names} {
	# Lexeme symbol names transformed into symbol names for ACS.
	debug.marpa/engine {[debug caller] | }
	lmap name $names { my ToACS1 $name }
    }

    # # ## ### ##### ######## #############

    method Complete {} {
	debug.marpa/lexer {[debug caller] | }

	if {$myrecce eq {}} {
	    debug.marpa/lexer {[debug caller] | Bail out. No recce available}
	    return 0
	}

	# I. Extract the location of longest lexeme from the
	#    recognizer state
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
		my Mismatch
	    }
	}

	M length: [expr {$latest-1}]
	M value:  [string range $mylexeme 0 end-$redo]

	debug.marpa/lexer {[debug caller] | Lexeme start:  [M start]}
	debug.marpa/lexer {[debug caller] | Lexeme length: [M length]}
	debug.marpa/lexer {[debug caller] | Lexeme:        (([char quote cstring [M value]]))}
	debug.marpa/lexer {[debug caller] | Redo:          $redo}

	# II. Pull all the valid parses at this location
	set forest [my Matches]
	debug.marpa/lexer {[debug caller] | Trees:         [llength $forest]}

	# III. Evaluate the parses with the configured semantics,
	#      getting one symbol and semantic value per.

	# Note, we assume that the 'sv' is the same for all symbols
	# and generate it only on first non-discarded symbol.

	# The construction of the @START symbol and its rules,
	# i.e. for all foo, foo lexeme or discard we have a single
	# rule `START ~ ACS:foo foo` has a few implications on the
	# list of instructions, i.e. the parse trees we get from the
	# forest. These are:

	# 1. The first instruction is for the token of the ACS
	#    symbol of the lexeme or discard we matched.
	# 2. The last instruction is a rule, the reduction to @START.
	# 3. The 2nd-to-last instruction is a rule, the reduction to foo.

	# That last item tells us where we get the rule id from,
	# should we need it for the semantics.

	set found     {}
	set discarded {}
	set fset      {}
	set sv        {}
	set svset     {} ;# Map from SV to their id, to prevent
			  # duplication. See KnownValue for user.

	foreach tree $forest {
	    # First instruction = lrange 0 1, 0 == type (assert: token), 1 == details
	    set details [lindex $tree 1]
	    set acs     [dict get $details id]    ;# id:acs:local
	    set symbol  [dict get $mypublic $acs] ;# id:parser

	    # Discarded symbols are signaled by marker -1, see (:D:)
	    if {$symbol < 0} {
		lappend discarded $acs
	    } elseif {[dict exists $fset $symbol]} {
		# Ignore, already handled
	    } else {
		M symbol: [my 2Name1 [dict get $mylex $symbol]]
		M lhs:    $symbol
		M rule:   [dict get [lindex $tree end-2] id]

		# Note that we reduce the symbols to the unique
		# subset. Lexing ambiguities may cause us see a single
		# lexeme multiple times, one per possible parse-tree
		# for it. We capture only the first. We do compute and
		# capture the semantic values for different lexeme
		# symbols matching here.
		dict set fset $symbol .
		lappend found $symbol
		# latest, tree, symbol, redo - upvar'd in GSV these as needed.
		# __sv_*                     - Reserved by GSV for caching.
		lappend sv [my GetSemanticValue]
	    }
	}

	debug.marpa/lexer {[debug caller] | Discarded:  $discarded}
	debug.marpa/lexer {[debug caller] | Symbols:    [llength $found] ($found)}
	debug.marpa/lexer {[debug caller] | Symbols:    [llength $found] (([set fs [my DIds [my FromParser $found]]]))}
	debug.marpa/lexer {[debug caller] | [marpa::D {
	    set fmax 0
	    foreach s $fs {
		set n [string length $s]
		if {$n > $fmax} { set fmax $n }
	    }
	}][join [lmap s $fs v $sv {
	    set __ "Semantic:   [format %${fmax}s $s] : ([char quote cstring $v])"
	}] \n]}

	# NOTE. Of the found lexemes only those with mode LTM may be
	# unacceptable to the parser. This is the only source of
	# invalid symbols the parser may get. Of the LATM lexemes we
	# can have only matched a subset of the acceptable ones. Which
	# is why it is recommended to go for LATM, and why that is the
	# default mode.

	# The current recognizer is done.
	debug.marpa/lexer {[debug caller] | RECCE kill 2 [namespace which -command RECCE]}
	RECCE destroy
	set myrecce {}

	# Reposition the gate/input so that the next lexeme match
	# starts just after the end of this one. We must do this here
	# because the handler for parse events may choose to
	# reposition again, and then our rewind would mess up their
	# choice. And we can do this here, because it is just a
	# repositioning, and not a synchronous re-enter.

	debug.marpa/lexer {[debug caller] | Rewind $redo ...}
	Gate redo $redo
	debug.marpa/lexer {[debug caller] | ... Rewound}

	# Talk to parser iff we have found lexemes, or if we have no
	# discarded. Conversely skip the parser iff no lexemes found
	# but discarded symbols.

	if {![llength $found] && [llength $discarded]} {
	    # We found discarded symbols, and no lexemes
	    debug.marpa/lexer        {[debug caller] | Discard ...}
	    debug.marpa/lexer/stream {FIN, discard}
	    debug.marpa/lexer/events {Discarded: $discarded ([my DIds $discarded])}

	    # First inform the environment of any discard events we
	    # may have associated with one or more of the matched
	    # symbols.

	    set events [my events? discard [lmap d $discarded {set _ D.$d}]]
	    if {[llength $events]} {
		debug.marpa/lexer/events {E Discard: $events}
		debug.marpa/lexer/events {E Discard: $discarded}

		M sv~
		M symbols: [lmap d $discarded {string map {ACS: {}} [my 2Name1 $d]}]
		M fresh: 1
		debug.marpa/lexer/events {E Discard Match: [join [M view] "\nE         Match:"]}

		# Note, any changes the event handler makes to M are ignored.
		my Post discard $events
	    }

	    # Second, restart lexing without informing the parser,
	    # keeping to the current set of acceptable symbols.

	    my acceptable $myacceptable

	    debug.marpa/lexer {[debug caller] | ... Ok}
	} else {
	    # Pushed the found lexemes (possibly none (*)) to the
	    # parser. This will also give us feedback about the new
	    # set of acceptable lexemes, and generate a new RECCE, see
	    # 'Acceptable'.
	    #
	    # (*) This happens when neither lexemes nor discards were
	    #     found. At that point the lexer is stuck and has to
	    #     report the issue to the parser.

	    debug.marpa/lexer        {[debug caller] | Push ...}
	    debug.marpa/lexer/stream {FIN, push: (([my DIds [my FromParser $found]]))}

	    set ef [lmap f $found {set _ L.$f}]

	    set events [my events? before $ef]
	    if {[llength $events]} {
		set prehandler [my PEFill $found $sv]
		# Move input location to just before start of lexeme
		Gate moveto [M start] -1
		my Post before $events
	    } else {
		set events [my events? after $ef]
		if {[llength $events]} {
		    set prehandler [my PEFill $found $sv]
		    my Post post after $events
		}
	    }

	    if {![llength $events]} {
		# Quick regular execution when no events were triggered.
		Forward enter $found [my KnownValue $sv]
	    } else {
		# Events were triggered. Analyze the symbols the
		# handler left in M. Might be same, modified, or none
		# left.

		set posthandler [M symbols]
		if {![llength $posthandler]} {
		    # No symbols left to push. This is a signal to discard
		    # the input.  Restart lexing without informing the
		    # parser, keeping to the current set of acceptable
		    # symbols. Note, discard events cannot trigger anymore.

		    my acceptable $myacceptable

		} elseif {$prehandler ne $posthandler} {
		    # The matched symbols were changed (Added, removed)
		    # Time to map the user's choices back to symbol ids

		    set found [lmap s $posthandler {
			dict get $mypublic [my 2ID1 $s]
		    }]
		    Forward enter $found [my KnownValue [M sv]]
		} else {
		    # The matched symbols did not change. Reuse `found`,
		    # no need to remap names to ids, we still have them.

		    Forward enter $found [my KnownValue [M sv]]
		}
	    }

	    debug.marpa/lexer {[debug caller] | ... Ok}
	}

	return [expr {$redo > 0}]
    }

    method Mismatch {} {
	debug.marpa/lexer {[debug caller] | }
	my get-context context

	# The current recognizer is done.
	if {$myrecce ne {}} {
	    debug.marpa/lexer {[debug caller] | RECCE kill 3 [namespace which -command RECCE]}
	    RECCE destroy
	    set myrecce {}
	}

	Forward fail context

	# Note: The call above must not return, but throw an error at
	# some point. If it returns we have an internal problem at
	# hand as well. In that case we report that now, together with
	# the context.

	my E "Unexpected return without error for problem: $context" \
	    INTERNAL ILLEGAL RETURN $context
    }

    method Matches {} {
	debug.marpa/lexer {[debug caller] | }
	while {![catch {
	    lappend forest [FOREST get-parse]
	    debug.marpa/lexer/forest {__________________________________________ Tree [incr fcounter] ([llength [lindex $forest end]])}
	    debug.marpa/lexer/forest {[my parse-tree [lindex $forest end]]}
	    debug.marpa/lexer/forest/save {[upvar 1 latest latest][my dump-parse-tree "TL.@[M start]+${latest}.$fcounter" [lindex $forest end]]}
	}]} {}
	FOREST destroy
	return $forest
    }

    method ExtendContext {cv} {
	debug.marpa/lexer {[debug caller] | }
	upvar 1 $cv context

	# Extend the context we got from the gate with lexeme
	# information, i.e. which were acceptable to the parser.
	# Then forward to the parser for his take.

	dict set context g1 acceptable [lsort -dict [lmap s [my 2Name [my FromParser [lsort -unique [concat $myacceptable $myalways]]]] {
	    string map {ACS: {}} $s
	}]]

	# Further extend the context with a report of the active rules
	# during the current match attempt, and the precending
	# characters.

	oo::objdefine [self] mixin marpa::engine::debug
	set max [RECCE latest-earley-set]
	set rep {}
	for {set k 0} {$k <= $max} {incr k} {
	    lappend rep [my progress-report $k]
	}
	dict set context l0 report $rep
	dict set context l0 stream $mylexeme
	dict set context l0 latest $max
	return
    }

    # # ## ### ##### ######## #############
    ## Lexer semantics

    method KnownValue {vs} {
	upvar 1 svset svset
	return [lmap v $vs {
	    if {[dict exists $svset $v]} {
		set vid [dict get $svset $v]
	    } else {
		set vid [Store put $v]
		dict set svset $v $vid
		set vid
	    }
	}]
    }

    method GetSemanticValue {} {
	debug.marpa/lexer {[debug caller] | }
	set result [lmap part $myparts { M $part }]
	if {[llength $result] == 1} {
	    set result [lindex $result 0]
	}
	return $result
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

    method enter {syms thechar thelocation} {
	my __Init
	my __Fail made            ! "Setup missing" MISSING SETUP
	my __Fail config          ! "Gate missing" MISSING GATE
	my __Fail {done complete} ! "After end of input" EOF
	# Note: Early state change. This ensures that we are in the
	# proper state for the callback from the postprocessor
	# (i.e. acceptable)
	my __On {gated data} --> data
	next $syms $thechar $thelocation
    }

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
