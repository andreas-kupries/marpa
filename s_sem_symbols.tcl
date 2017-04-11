# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Symbol management
## Symbols are classified (tagged) as per their use and definition.
## Conflicts between current class and class implied by action are
## reported as errors.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# link

debug define marpa/slif/semantics
#debug prefix marpa/slif/semantics {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::semantics::Symbol {
    # # ## ### ##### ######## #############
    ## Setup and state

    marpa::EP marpa/slif/semantics \
	{Grammar error.} \
	SLIF SEMANTICS SYMBOL

    variable mysym ;# dict (symbol -> tag) - State of the parallel engines
    variable myfa  ;# dict (tag -> (context -> action))
    #              ;# state transition table, where
    #              ;# action = (NOP)       - nop
    #              ;#        | (JMP state) - goto new state
    #              ;#        | (ERR code)  - throw error
    #              ;#        | (INT)       - throw internal error

    variable myerr ;# dict (code -> (txt ...))
    #              ;# Error map, shorthand to message and errorcode

    variable myscript ;# dict (code -> list(cmdprefix))
    #                 ;# action map, commands to perform on state
    #                 ;# transitions. See JMP for execution.

    # # ## ### ##### ######## #############
    ## Lifecycle

    constructor {container def use semantics} {
	marpa::import $container Container
	marpa::import $def       Definition
	marpa::import $use       Usage
	marpa::import $semantics Semantics
	debug.marpa/slif/semantics {}
	set mysym {}
	# Error map - See ERR for the mapping of the shorthand phrases
	#             into the full message
	set myerr {
	    undef/discard  {{LD <@> ND @use@}             UNDEFINED L0 DISCARD}
	    undef/lexeme   {{LL <@> ND @use@}             UNDEFINED L0 LEXEME }
	    undef/match    {{LS <@> ND @use@}             UNDEFINED L0 SYMBOL }
	    undef/g1       {{G1 <@> ND @use@}             UNDEFINED G1 SYMBOL }
	    discard/g1def  {{FR LD <@> as G1 @def@}       MISMATCH L0 DISCARD G1 DEF}
	    discard/g1use  {{FU LD <@> as G1 @def@ @use@} MISMATCH L0 DISCARD G1 USE}
	    discard/lexeme {{FU LD <@> as LL @def@ @use@} MISMATCH L0 DISCARD L0 LEXEME}
	    discard/match  {{FU LD <@> as LS @def@ @use@} MISMATCH L0 DISCARD L0 SYMBOL}
	    g1/discard     {{FU G1 <@> as LD @def@ @use@} MISMATCH G1 SYMBOL  L0 DISCARD}
	    g1/l0def       {{FR G1 <@> as LS @def@}       MISMATCH G1 SYMBOL  L0 DEF}
	    g1/l0use       {{FU G1 <@> as LS @def@ @use@} MISMATCH G1 SYMBOL  L0 USE}
	    g1/lexeme      {{FU G1 <@> as LL @def@ @use@} MISMATCH G1 SYMBOL  L0 LEXEME}
	    lexeme/discard {{FU LL <@> as LD @def@ @use@} MISMATCH L0 LEXEME  L0 DISCARD}
	    lexeme/g1def   {{FR LL <@> as G1 @def@}       MISMATCH L0 LEXEME  G1 DEF}
	    lexeme/g1miss  {{LL <@> not used as GT @def@} MISMATCH L0 LEXEME  G1 MISS}
	    lexeme/g1use   {{FU LL <@> as G1 @def@ @use@} MISMATCH L0 LEXEME  G1 USE}
	    lexeme/match   {{FU LL <@> as LS @def@ @use@} MISMATCH L0 LEXEME  L0 SYMBOL}
	    match/discard  {{FR LS <@> as LD @def@}       MISMATCH L0 SYMBOL  L0 DISCARD}
	    match/g1def    {{FR LS <@> as G1 @def@}       MISMATCH L0 SYMBOL  G1 DEF}
	    match/g1use    {{FU LS <@> as G1 @def@ @use@} MISMATCH L0 SYMBOL  G1 USE}
	    match/lexeme   {{FR LS <@> as LL @def@}       MISMATCH L0 SYMBOL  L0 LEXEME}
	}
	# Error        --> Test cases/grammars
	##
	# undef/discard  - discards/err-undefined-symbol
	# undef/lexeme   - lexemes/err-undefined-symbol
	# undef/match    - lexeme-vs-nonterminal/err-l0-symbol-undefined
	# undef/g1       - lexeme-vs-nonterminal/err-g1-terminal-not-a-lexeme,
	#                  start-symbol/err-no-definition,
	#                  g1-events/*-err-symbol-undef
	# discard/g1def  - discards/err-g1-definition
	# discard/g1use  - discards/err-g1-usage
	# discard/lexeme - lexeme-vs-discard/err-discard-lexeme
	# discard/match  - discards/err-l0-usage
	# g1/discard     - discards/err-g1-as-discard
	# g1/l0def       - lexeme-vs-nonterminal/err-l0-g1-both
	# g1/l0use       - lexeme-vs-nonterminal/err-g1-l0-both
	# g1/lexeme      - lexemes/err-g1-as-lexeme
	# lexeme/discard - lexeme-vs-discard/err-lexeme-discard
	# lexeme/g1def   - lexemes/err-g1-definition
	# lexeme/g1miss  - lexeme-vs-nonterminal/err-l0-lexeme-not-a-terminal
	# lexeme/g1use   - IMPOSSIBLE, and not used here
	# lexeme/match   - lexemes/err-l0-usage
	# match/discard  - l0-symbols/err-as-discard
	# match/g1def    - l0-symbols/err-g1-definition
	# match/g1use    - l0-symbols/err-g1-usage
	# match/lexeme   - l0-symbols/err-as-lexeme

	# Action map. See JMP for mapping and execution.
	set myscript {
	    make-lexeme {
		{Container l0 lexeme}
		{Container g1 terminal}
	    }
	    make-discard {{Container l0 discard}}
	}
	# State engine - transition table
	set myfa {
	    undef {
		g1-definition {JMP brick}
		g1-usage      {JMP floater}
		l0-definition {JMP match}
		l0-usage      {JMP strict:u}
		:lexeme       {JMP lexeme:u  make-lexeme}
		:discard      {JMP discard:u make-discard}
		<literal>     {JMP literal}
	    }
	    brick {
		g1-definition NOP
		g1-usage      NOP
		l0-definition {ERR g1/l0def}
		l0-usage      {ERR g1/l0use}
		:lexeme       {ERR g1/lexeme}
		:discard      {ERR g1/discard}
		<literal>     INT
	    }
	    match {
		g1-definition {ERR match/g1def}
		g1-usage      {JMP lexeme make-lexeme}
		l0-definition NOP
		l0-usage      {JMP strict}
		:lexeme       {JMP lexeme make-lexeme}
		:discard      {JMP discard make-discard}
		<literal>     INT
	    }
	    strict {
		g1-definition {ERR match/g1def}
		g1-usage      {ERR match/g1use}
		l0-definition NOP
		l0-usage      NOP
		:lexeme       {ERR match/lexeme}
		:discard      {ERR match/discard}
		<literal>     INT
	    }
	    lexeme {
		g1-definition {ERR lexeme/g1def}
		g1-usage      NOP
		l0-definition NOP
		l0-usage      {ERR lexeme/match}
		:lexeme       NOP
		:discard      {ERR lexeme/discard}
		<literal>     INT
	    }
	    discard {
		g1-definition {ERR discard/g1def}
		g1-usage      {ERR discard/g1use}
		l0-definition NOP
		l0-usage      NOP
		:lexeme       {ERR discard/lexeme}
		:discard      NOP
		<literal>     INT
	    }
	    floater {
		g1-definition {JMP brick}
		g1-usage      NOP
		l0-definition {JMP lexeme make-lexeme}
		l0-usage      {ERR g1/l0use}
		:lexeme       {JMP lexeme:u make-lexeme}
		:discard      {ERR g1/discard}
		<literal>     INT
	    }
	    strict:u {
		g1-definition {ERR match/g1def}
		g1-usage      {ERR match/g1use}
		l0-definition {JMP strict}
		l0-usage      NOP
		:lexeme       {ERR match/lexeme}
		:discard      {ERR match/discard}
		<literal>     INT
	    }
	    lexeme:u {
		g1-definition {ERR lexeme/g1def}
		g1-usage      NOP
		l0-definition {JMP lexeme}
		l0-usage      {ERR lexeme/match}
		:lexeme       NOP
		:discard      {ERR lexeme/discard}
		<literal>     INT
	    }
	    discard:u {
		g1-definition {ERR discard/g1def}
		g1-usage      {ERR discard/g1use}
		l0-definition {JMP discard}
		l0-usage      {ERR discard/match}
		:lexeme       {ERR discard/lexeme}
		:discard      NOP
		<literal>     INT
	    }
	    literal {
		g1-definition INT
		g1-usage      INT
		l0-definition INT
		l0-usage      NOP
		:lexeme       INT
		:discard      INT
		<literal>     NOP
	    }
	}
	# Shortcuts
	link {NOP NOP}
	link {JMP JMP}
	link {ERR ERR}
	link {INT INT}
	return
    }

    method @ {symbol} {
	debug.marpa/slif/semantics {}
	return [dict get $mysym $symbol]
    }
    export @

    method context {context args} {
	debug.marpa/slif/semantics {}
	foreach sym $args { my context1 $context $sym }
	return
    }
    method context1 {context sym} {
	debug.marpa/slif/semantics {}
	if {[dict exists $mysym $sym]} {
	    set current [dict get $mysym $sym]
	} else {
	    set current undef
	}
	set action [dict get $myfa $current $context]

	Container comment $context $sym $current --> $action
	eval $action
	return
    }

    method finalize {} {
	debug.marpa/slif/semantics {}
	dict for {sym tag} $mysym {
	    switch -exact -- $tag {
		match {
		    # As the item never became strict it is not used
		    # in any L0 RHS.  It also was never marked by
		    # :discard.  This is a toplevel item, therefore an
		    # (L0) lexeme!
		    ##
		    # However. As an L0 lexeme we expect it to be used
		    # in a G1 RHS. If such had occured the item would
		    # however be marked 'lexeme'. To be still tagged
		    # as a 'match' here at final means that this item
		    # is __not__ used in G1 RHS. That is a mismatch
		    # between the G1 lexeme set vs the L0 lexeme
		    # set. This is an error.
		    ERR lexeme/g1miss
		}
		floater {
		    # Symbol was found only on G1 RHS. No definition.
		    # Technically a G1 lexeme. However without a
		    # corresponding L0 definition (which would have
		    # induced floater --> lexeme) this is an error.
		    ERR undef/g1
		}
		strict:u {
		    # Symbol was found only on L0 RHS. No definition.
		    ERR undef/match
		}
		lexeme:u {
		    # Symbol was only used in :lexeme. No definition.
		    ERR undef/lexeme
		}
		discard:u {
		    # Symbol was only used in :discard. No definition.
		    ERR undef/discard
		}
	    }
	}
	return
    }

    method filter {matchtag} {
	debug.marpa/slif/semantics {}
	set result {}
	dict for {sym tag} $mysym {
	    if {$tag ne $matchtag} continue
	    lappend result $sym
	}
	return $result
    }

    # # ## ### ##### ######## #############
    ## Helper methods implementing the table.

    method NOP {} {}

    method JMP {newstate {code {}}} {
	upvar 1 sym sym
	dict set mysym $sym $newstate
	if {$code eq {}} return
	foreach cmd [dict get $myscript $code] {
	    {*}$cmd $sym
	}
	return
    }

    method ERR {code} {
	upvar 1 sym sym
	set def  [Definition where $sym]
	set use  [Usage where $sym]
	set code [lassign [dict get $myerr $code] msg]
	lappend code $sym $def $use

	if {[string match {* @def@*} $msg]} {
	    if {[llength $def]} {
		lappend map { @def@} \nDefinitions:\n[Semantics LOCFMT $def]
	    } else {
		lappend map { @def@} \nDefinitions:
	    }
	}
	if {[string match {* @use@*} $msg]} {
	    if {[llength $use]} {
		lappend map { @use@} \nUses:\n[Semantics LOCFMT $use]
	    } else {
		lappend map { @use@} \nUses:
	    }
	}

	lappend map  @ $sym
	lappend map LS {L0 symbol}
	lappend map LL {L0 lexeme}
	lappend map LD {L0 discard}
	lappend map G1 {G1 symbol}
	lappend map GT {G1 terminal}
	lappend map FR {Forbidden redefinition of}
	lappend map FU {Forbidden use of}
	lappend map ND {has no definition}

	my E [string map $map $msg] {*}$code
	return
    }

    method INT {} {
	upvar 1 sym sym context context
	my E "Internal error tracking <$sym> @[dict get $mysym $sym] in $context" \
	    INTERNAL
	return
    }

    # # ## ### ##### ######## #############
}

##
# # ## ### ##### ######## #############
return
