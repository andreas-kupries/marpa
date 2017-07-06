# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Lexer runtime assembled from the other classes in this directory.
# Runtime for a lexer-only engine.

# # ## ### ##### ######## #############
## Requisites

package require oo::util ;# mymethod
#package require char     ;# quoting

debug define marpa/engine/tcl/parse
debug prefix marpa/engine/tcl/parse {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::engine::tcl::parse {
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
	marpa::lexer    create LEX   STORE PARSE
	marpa::gate     create GATE  STORE LEX
	marpa::inbound  create IN    STORE GATE

	#           v-----+  v-----+                    #
	# IN --> GATE --> LEX ---> PARSE --> self       #
	#  \      \        \        \ \                 #
	#   \      \        \        \ \-> SEMA         #
	#    \      \        \        \     \           #
	#     \----> \------> \------> \---> \--> STORE #

	# IN - Nothing to configure
	SEMA  add-rule @default {marpa::semstd::builtin {name values}}
	GATE  def     [my Characters] [my Classes]
	LEX   action  [my L0.Semantics]
	LEX   export  [my Lexemes]
	LEX   symbols [my L0.Symbols]
	LEX   rules   [my L0.Rules]
	PARSE symbols [my G1.Symbols]
	PARSE action                   {name values} ; # TODO actual user semantics
	PARSE rules   [my G1.Rules]
	PARSE parse   [my Start] [my Discards]

	# TODO: Actual user semantics
	# TODO: L0 events
	# TODO: G1 events
	# TODO: tracing/reporting/red-ruby-slippers
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
    
    # # ## ### ##### ######## #############
    ## State

    variable myresult
    
    # # ## ### ##### ######## #############
    ## Public API
    
    method process-file {path} {
	debug.marpa/engine/tcl/parse {}
	set myresult {}
	set chan [open $path r]
	# Drive the pipeline from the channel.
	IN read $chan
	IN eof
	return $myresult
    }

    method process {string} {
	debug.marpa/engine/tcl/parse {}
	set myresult {}
	# Drive the pipeline from the string
	IN enter $string
	IN eof
	return $myresult
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

	# Expected keys
	# - l0 at         : current location (offset from start of input)
	# - l0 char       : current character
	# - l0 acceptable : list of characters the lexer gate looked for
	# - g1 acceptable : list of lexemes the lexer/parser looked for

	append msg "Parsing failed."

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

	    if {[dict exists $context l0 char]} {
		append msg " after reading '" [char quote cstring [dict get $context l0 char]] "'"
	    }
	    append msg "."
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

	my E $msg SYNTAX $context
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return