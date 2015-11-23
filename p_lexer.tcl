# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

    variable myacceptable ;# Remembered (last call of 'Acceptable')
			   # set of upstream acceptable symbols.
			   # Required for the regeneration of our
			   # recognizer after a discarded lexeme was
			   # found in the input.
    variable mydiscard    ;# Set of ACS for discarded lexemes
    variable mynull       ;# Semantic value for ACS, empty string,
			   # floating location

    ##
    # API self:
    #   cons    (semstore, upstream)    - Create, link, attach to upstream.
    #   gate:   (gate)        - Downstream gate attaching for feedback.
    #                           This activates down 'acceptable' handling.
    #   symbols (symlist)     - (Downstream, self) bulk allocation of symbols
    #   export  (symlist)     - Bulk allocation of public symbols
    #   rules   (rules)       - Bulk specification of grammar rules
    #   discard (ignorelist)  - Complete lexer spec
    #   acceptable (symlist)  - Declare set of allowed symbols
    #   enter   (syms val)    - Incoming sym set with semantic value
    #   eof     ()            - Incoming end of input signal
    ##
    # API gate:
    #   lex        (discards) - Declare set of discarded lexemes
    #   acceptable (symlist)  - Declare set of allowed symbols
    #   redo       (n)        - Force re-entry of last n symbols
    ##
    # API upstream:
    #   gate:   (self)     - Attach to self as gate for upstream
    #   enter   (syms val) - Push symbol set with semantic value
    #   eof     ()         - Push end of input signal
    #   symbols (symlist)  - Bulk allocate symbols for ruleschar and char classes.

    constructor {semstore upstream} {
	debug.marpa/lexer {[debug caller] | }

	next $upstream

	marpa::import $semstore Store
	# Gate will attach during setup.

	# Dynamic state for processing
	set myacceptable {}   ;# Upstream gating.

	# Static configuration
	set myacceptable {}
	set mydiscard    {}
	set mynull       [Store put [my S.Null]]

	my ToStateStart
	my SetupSemantics $semstore

	# Attach ourselves to upstream, as gate.
	Forward gate: [self]

	debug.marpa/gate {/ok}
	return
    }

    # # ## ### ##### ######## #############
    ## State methods for API methods
    #
    #  API ::=    Start       Active       Done	   
    ## ---        ----------- ------------ -----------
    #  gate:      * GateSet     FailSetup    FailSetup
    #  symbols    * Symbols     FailSetup    FailSetup
    #  export     * Exports     FailSetup    FailSetup
    #  rules      * Rules       FailSetup    FailSetup
    #  discard    * Discard !   FailSetup    FailSetup
    #  enter        FailStart * Enter        FailEof  
    #  eof          FailStart * Eof          FailEof  
    #  acceptable   FailStart * Acceptable   FailFeed
    #  redo         FailStart * Redo         FailFeed
    ## ---        ----------- ------------ -----------

    method GateSet {gate} {
	debug.marpa/lexer {[debug caller] | }
	marpa::import $gate Gate
	return
    }

    method Discard {discards} {
	debug.marpa/lexer {[debug caller] | }
	# Set of discard symbols. This makes the lexer a
	# lexer. Creates an internal start symbol with rules mapping
	# it to all the public symbols, and the symbols in the discard
	# list. The lexer will repeat.

	foreach sym $discards {
	    set id [my 2ID1 $sym]
	    if {![my IsPublic $id]} continue
	    my E "Cannot discard exported symbol $sym" DISCARD-EXPORT $sym
	}

	set start [my Symbols [list @START]]
	GRAMMAR sym-start: $start

	# NOTE - Possible redo, stick the ACS here, into the
	#        start -> lexeme rules, instead of the lexeme
	#        rules itself.
	##
	# For sequence rules this gets rid of wrapper too!
	##
	# Moves handling of exported symbols out of the engine class

	foreach symid [my PublicSymbols] {
	    GRAMMAR rule-new $start $symid
	}

	set mydiscard [my Symbols [my ToACS $discards]]
	foreach sym $discards acs $mydiscard {
	    set id [my 2ID1 $sym]
	    GRAMMAR rule-new $start   $acs $id
	}

	my Freeze
	my ToStateActive
	return
    }

    method Enter {syms value} {
	debug.marpa/lexer {[debug caller] | See '[join [my 2Name $syms] {' '}]' ([marpa::location::Show [Store get $value]])}

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
	    RECCE alternative $sym $value 1
	}
	RECCE earleme-complete

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

    method Eof {} {
	debug.marpa/lexer {[debug caller] | }

	# Flush everything pending in the local recognizer to the
	# parser before signaling eof upstream.
	my Complete

	#  Note that the flush leaves us with a just-started
	# recognizer, which we have to remove again.
	RECCE destroy

	my ToStateDone
	Forward eof
	return
    }

    method Acceptable {syms} {
	debug.marpa/lexer {[debug caller] | }
	# Lexer method, called by parser.
	# syms is list of parser symbol ids.
	# transform into acs ids, and insert into the recognizer.

	set myacceptable $syms

	GRAMMAR recognizer create RECCE [mymethod Events]
	debug.marpa/lexer {[debug caller 1] | RECCE = [namespace which -command RECCE]}

	RECCE start-input

	if {[llength $syms] || [llength $mydiscard]} {
	    foreach s $syms {
		RECCE alternative [my ACS $s] $mynull 1
	    }
	    foreach s $mydiscard {
		debug.marpa/lexer {[debug caller 1] | ==> $s '[my 2Name1 $s]'}
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

    method Redo {n} {
	debug.marpa/lexer {[debug caller] | }
	# Lexer method, called by parser.

	my E "Lexer cannot redo symbols" REDO

	if {$n} {
	    # Redo/enter the last n symbols
	    incr n $n
	    incr n -1
	    set pending [lrange $myhistory end-$n end]
	    set myhistory {}
	    foreach {syms value} $pending {
		my enter $syms $value
	    }
	} else {
	    # Redo nothing
	    set myhistory {}
	}
	return
    }

    method FailStart {args} {
	debug.marpa/lexer {[debug caller] | }
	my E "Unable to process input before setup" START
    }

    method FailSetup {args} {
	debug.marpa/lexer {[debug caller] | }
	my E "Grammar is frozen, unable to add further symbols or rules" \
	    SETUP
    }

    method FailEof {args} {
	debug.marpa/lexer {[debug caller] | }
	my E "Unable to process input after EOF" EOF
    }

    method FailFeed {args} {
	debug.marpa/lexer {[debug caller] | }
	my E "Unable to process feedback after EOF" FEEDBACK EOF
    }

    # # ## ### ##### ######## #############
    ## Lexer - Completion of a lexeme

    method Complete {} {
	debug.marpa/lexer {[debug caller] | }

	# I. Pull the location of longest lexeme out of the recognizer
	#    state
	set latest [RECCE latest-earley-set]
	set redo   0

	while {[catch {
	    debug.marpa/lexer {[debug caller] | Check at $latest}
	    RECCE forest create FOREST $latest
	} msg]} {
	    incr redo
	    incr latest -1
	    if {!$latest} { my E "No lexeme found in input. Stopped." STOP }
	}
	debug.marpa/lexer {[debug caller] | Lexeme length: $latest}
	debug.marpa/lexer {[debug caller] | Redo:          $redo}

	# II. Pull all the valid parses at this location
	set steps {}
	while {![catch {
	    lappend steps [FOREST get-parse]
	}]} {}
	FOREST destroy

	debug.marpa/lexer {[debug caller] | Trees:         [llength $steps]}

	# III. Evaluate the parses with the configured semantics,
	#      getting one symbol and semantic value per.

	set found {}
	set sv    -1
	set first yes
	set recognized 0
	set discarded  0
	foreach tree $steps {
	    # Note, we assume that the 'sv' is the same for all
	    # symbols and generate it only on first.
	    my Extract $tree $first symbol sv
	    set first no

	    incr recognized
	    if {![my IsPublic $symbol]} {
		incr discarded
		continue
	    }

	    # Translate the found lexer symbol into the parser symbol
	    lappend found [my ParseSym $symbol]
	}

	# Reduce the symbol to the unique subset. Lexing ambiguities
	# may have us see lexeme multiple times, each per possible
	# parse-tree. In the SLIF grammar this is visible with
	# 'character class'.
	set found [lsort -uniq $found]

	debug.marpa/lexer {[debug caller] | Recognized: $recognized}
	debug.marpa/lexer {[debug caller] | Discarded:  $discarded}
	debug.marpa/lexer {[debug caller] | Symbols:    [llength $found] ($found)}
	debug.marpa/lexer {[debug caller] | Semantic:   $sv ([marpa::location::Show [Store get $sv]])}

	# NOTE! Due to the usage of ACS when the RECCE was initalized
	# at this point we can have only a subset of the acceptable
	# symbols. We cannot generate invalid symbols (assuming we
	# have set everything up correctly).
	#
	# Exception: We may have come across discarded symbols.

	# The current recognizer is done.
	RECCE destroy

	debug.marpa/lexer {[debug caller] | Have '[join [my 2Name [my ACSn $found]] {' '}]' ${sv}=([marpa::location::Show [Store get $sv]])}

	if {($recognized > 0) && ($recognized == $discarded)} {
	    # We found symbols, and only discarded symbols.
	    # Restart lexing without informing the parser, keeping
	    # to the current set of acceptable symbols

	    debug.marpa/lexer {[debug caller] | Discard ...}

	    my Acceptable $myacceptable

	    debug.marpa/lexer {[debug caller] | ... Ok}
	} else {
	    # Push the symbol set up to the parser. This will also
	    # give us feedback about the new set of acceptable
	    # symbols, and generate a new RECCE, see 'Acceptable'.

	    debug.marpa/lexer {[debug caller] | Push ...}

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
	marpa::semcore create GetSymbol \
	    $semstore \
	    [dict create \
		 rule:@default [mymethod S.Save] \
		 null:@default [mymethod S.Nop] \
		 tok:@default  [mymethod S.Nop]]
	     
	marpa::semcore create GetString \
	    $semstore \
	    [dict create \
		 rule:@default [mymethod S.Merge] \
		 null:@default [mymethod S.Null]  \
		 sv            marpa::location::Show]

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

    method Extract {steps first symv semv} {
	debug.marpa/lexer {[debug caller 1] | }
	upvar 1 $symv symbol $semv sv

	# NOTE! The last step is always the reduction of the lexeme to
	# @START.  We drop that step as we want the lexeme itself.
	set steps [lrange $steps 0 end-2]

	if {$first} {
	    # Calculate the string value of the lexeme.
	    set sv [Store put [GetString eval $steps]]
	}

	# Calculate lexeme symbol (id)
	set symbol [my LHSid [GetSymbol eval $steps]]

	debug.marpa/lexer {[debug caller 1] | symbol   = $symbol '[my 2Name1 $symbol]'}
	debug.marpa/lexer {[debug caller 1] | semantic = $sv ([marpa::location::Show [Store get $sv]])}
	return
    }

    method S.Null {args} {
	debug.marpa/lexer {[debug caller] | }
	return {{} {} {}}
    }

    method S.Merge {id args} {
	debug.marpa/lexer {[debug caller] | }
	foreach b [lassign $args a] {
	    set a [marpa::location merge $a $b]
	}
	return $a
    }

    method S.Save {id args} {
	debug.marpa/lexer {[debug caller] | -> '[my LHSname $id]'}
	return $id
    }

    method S.Nop {args} {
	debug.marpa/lexer {[debug caller] | }
	return {}
    }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/lexer {[debug caller] | }
	return -code error \
	    -errorcode [linsert $args 0 MARPA LEXER] \
	    $msg
    }

    # # ## ### ##### ######## #############
    ## State transitions

    method ToStateStart {} {
	# () :: Start
	debug.marpa/lexer {[debug caller] | }

	oo::objdefine [self] forward gate:       my GateSet
	oo::objdefine [self] forward symbols     my Symbols
	oo::objdefine [self] forward export      my Exports
	oo::objdefine [self] forward rules       my Rules
	oo::objdefine [self] forward discard     my Discard
	oo::objdefine [self] forward enter       my FailStart
	oo::objdefine [self] forward eof         my FailStart
	oo::objdefine [self] forward acceptable  my FailStart
	oo::objdefine [self] forward redo        my FailStart
	return
    }

    method ToStateActive {} {
	# Start :: Active
	debug.marpa/lexer {[debug caller] | }

	oo::objdefine [self] forward gate:       my FailSetup
	oo::objdefine [self] forward symbols     my FailSetup
	oo::objdefine [self] forward export      my FailSetup
	oo::objdefine [self] forward rules       my FailSetup
	oo::objdefine [self] forward discard     my FailSetup
	oo::objdefine [self] forward enter       my Enter
	oo::objdefine [self] forward eof         my Eof
	oo::objdefine [self] forward acceptable  my Acceptable
	oo::objdefine [self] forward redo        my Redo
	return
    }

    method ToStateDone {} {
	# Active :: Done
	debug.marpa/lexer {[debug caller] | }

	#oo::objdefine [self] forward gate:       my FailSetup
	#oo::objdefine [self] forward symbols     my FailSetup
	#oo::objdefine [self] forward export      my FailSetup
	#oo::objdefine [self] forward rules       my FailSetup
	#oo::objdefine [self] forward discard     my FailSetup
	oo::objdefine [self] forward enter       my FailEof
	oo::objdefine [self] forward eof         my FailEof
	oo::objdefine [self] forward acceptable  my FailFeed
	oo::objdefine [self] forward redo        my FailFeed
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
