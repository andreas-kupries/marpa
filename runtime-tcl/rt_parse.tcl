# -*- tcl -*-
##
# (c) 2015-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Lexer runtime assembled from the other classes in this directory.
# Runtime for a lexer-only engine.

# # ## ### ##### ######## #############
## Requisites

#package require oo::util ;# mymethod
#package require char     ;# quoting

debug define marpa/engine/tcl/parse
debug prefix marpa/engine/tcl/parse {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::engine::tcl::parse {
    superclass marpa::engine::tcl::base

    # # ## ### ##### ######## #############
    marpa::E marpa/engine/tcl/parse ENGINE TCL PARSE

    constructor {} {
	debug.marpa/engine/tcl/parse {}

	# Build the processing pipeline, then configure the various
	# pieces.  Object creation is in backward direction, i.e. from
	# the end of the pipeline to the beginning.  Loading the
	# grammar specification then proceeds in forward direction.
	# The following initialization then foes backward again.

	# Parts
	# - IN    : Basic character processing (location for token, file handling)
	# - GATE  : Character to symbol mapping, incl. char classes, gating
	# - LEX   : Marpa core engine specialized for lexing (semantics, lexemes)
	# - PARSE : Marpa core engine specialized for parsing
	# - SEMA  : Semantics
	# - STORE : Store for token values (lexer semantic information)

	marpa::semstore create STORE
	marpa::semcore  create SEMA  STORE
	marpa::parser   create PARSE STORE SEMA [self]
	marpa::lexer    create LEX   [self] STORE PARSE
	marpa::gate     create GATE  LEX
	marpa::inbound  create IN    GATE

	#           v-----\ v------\                    #
	# IN --> GATE --> LEX ---> PARSE --> self       #
	#                  \        \ \                 #
	#                   \        \ \-> SEMA         #
	#                    \        \     \           #
	#                     \------> \---> \--> STORE #

	# IN - Nothing to configure
	SEMA  add-rule @default {marpa::semstd::builtin {name values}}
	GATE  def     [my Characters] [my Classes]
	LEX   action  [my L0.Semantics]
	LEX   export  [my Lexemes]
	LEX   symbols [my L0.Symbols]
	LEX   rules   [my L0.Rules]
	PARSE symbols [my G1.Symbols]
	PARSE rules   [my G1.Rules]
	PARSE parse   [my Start] [my Discards]
	LEX   events  [my L0.Events]
	PARSE events  [my G1.Events]

	# TODO: Actual user semantics
	# TODO: tracing/reporting/red-ruby-slippers
	next
	return
    }

    # # ## ### ##### ######## #############

    forward Characters   my API Characters
    forward Classes      my API Classes
    forward Lexemes      my API Lexemes
    forward Discards     my API Discards
    forward L0.Symbols   my API L0.Symbols
    forward L0.Rules     my API L0.Rules
    forward L0.Semantics my API L0.Semantics
    forward G1.Symbols   my API G1.Symbols
    forward G1.Rules     my API G1.Rules
    forward Start        my API Start

    method API {m} {
	debug.marpa/engine/tcl/parse {}
	my E "Missing implementation of virtual method \"$m\"" \
	    API VIRTUAL [string toupper $m]
    }

    forward match  LEX match

    # # ## ### ##### ######## #############
    ## State

    variable myresult

    # # ## ### ##### ######## #############
    ## Public API

    method process-file {path args} {
	debug.marpa/engine/tcl/parse {}
	set options [my Options $args]
	set myresult {}
	set chan [open $path r]
	# Drive the pipeline from the channel.
	IN read $chan {*}$options
	PARSE reset
	return $myresult
    }

    method process {string args} {
	debug.marpa/engine/tcl/parse {}
	set myresult {}
	# Drive the pipeline from the string
	IN enter $string {*}[my Options $args]
	PARSE reset
	return $myresult
    }

    method extend-file {path} {
	debug.marpa/engine/tcl/parse {}
	set chan [open $path r]
	set off [IN read-more $chan]
	close $chan
	return $off
    }

    method extend {string} {
	debug.marpa/engine/tcl/parse {}
	return [IN enter-more $string]
    }

    # # ## ### ##### ######## #############
    ## This wrapper acts as the AST handler to the embedded parse
    ## core. The methods below handle the parser/handler
    ## communication.

    method enter {ast} {
	debug.marpa/engine/tcl/parse {}
	set myresult $ast
	return
    }

    method eof {} {
	debug.marpa/engine/tcl/parse {}
	return
    }

    method fail {cv} {
	debug.marpa/engine/tcl/parse {}
	upvar 1 $cv context

	# Expected keys. All are optional. Existence depends on where
	# exactly a failure occured.
	#
	# - l0 at         : current location (offset from start of input)
	# - l0 char       : current character
	# - l0 acceptable : list of characters the lexer gate looked for
	# - l0 stream     : character string preceding the failed character,
	#                   for the failed lexeme
	# - l0 report     : list of progress reports for each matched character.
	# - g1 acceptable : list of lexemes the lexer/parser looked for
	# - g1 report     : progress report from the parser

	append msg "Parsing failed in [dict get $context origin]."

	if {[dict exists $context l0 at]} {
	    set at [dict get $context l0 at]
	    if {$at eq {}} {
		append msg " Unable to determine location in the input"
	    } else {
		if {$at < 0} {
		    append msg " No input"
		} else {
		    append msg " Stopped at offset " $at
		}
	    }

	    if {[dict exists $context l0 stream]} {
		set stream [dict get $context l0 stream]
		if {[dict exists $context l0 char]} {
		    append stream [dict get $context l0 char]
		}
		append msg " after reading '" [char quote cstring $stream] "'"
	    } elseif {[dict exists $context l0 char]} {
		append msg " after reading '" [char quote cstring [dict get $context l0 char]] "'"
	    }
	    append msg "."
	} elseif {[dict exists $context l0 stream]} {
	    set stream [dict get $context l0 stream]
	    if {[dict exists $context l0 char]} {
		append stream [dict get $context l0 char]
	    }
	    append msg "Stopped after reading '" [char quote cstring $stream] "'."
	} elseif {[dict exists $context l0 char]} {
	    append msg "Stopped after reading '" [char quote cstring [dict get $context l0 char]] "'."
	}

	set chars 0
	if {[dict exists $context l0 acceptable]} {
	    append msg " Expected any character in \["
	    append msg [char quote cstring [join [dict get $context l0 acceptable] {}]] "\]"
	    set chars 1
	}

	if {[dict exists $context g1 acceptable]} {
	    if {$chars} {
		append msg " while looking"
	    } else {
		append msg " Looking"
	    }
	    append msg " for any of (" [join [dict get $context g1 acceptable] {, }] ")."
	} elseif {$chars} {
	    append msg "."
	}

	if {[dict exists $context l0 report]} {
	    append msg "\nL0 Report:\n[lindex [dict get $context l0 report] end]"
	}

	if {[dict exists $context l0 char] &&
	    [dict exists $context l0 csym]} {
	    set ch [char quote cstring [dict get $context l0 char]]
	    append msg "\nMismatch:\n'$ch' => ([dict get $context l0 csym]) ni"
	    if {[dict exists $context l0 acceptmap]} {
		dict for {asym aname} [dict get $context l0 acceptmap] {
		    append msg "\n [format %4d $asym]: $aname"
		}
	    } elseif {[dict exists $context l0 acceptsym]} {
		append msg " (dict exists $context l0 acceptsym])"
	    }
	}

	if {0&&[dict exists $context g1 report]} {
	    append msg "\nG1 Report:\n[dict get $context g1 report]"
	}

	my E $msg SYNTAX $context
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
