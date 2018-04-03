# -*- tcl -*-
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Lexer runtime assembled from the other classes in this directory.
# Runtime for a lexer-only engine.

# # ## ### ##### ######## #############
## Requisites

package require oo::util ;# mymethod
#package require char     ;# quoting

debug define marpa/engine/tcl/lex
debug prefix marpa/engine/tcl/lex {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::engine::tcl::lex {
    # # ## ### ##### ######## #############
    marpa::E marpa/engine/tcl/lex ENGINE TCL LEX

    constructor {} {
	debug.marpa/engine/tcl/lex {}
	set myid          {}
	set myeventprefix {}

	# Build the processing pipeline, then configure the various
	# pieces.  Object creation is in backward direction, i.e. from
	# the end of the pipeline to the beginning.  Loading the
	# grammar specification then proceeds in forward direction.
	# The following initialization then goes backward again.

	# Parts
	# - IN    : Basic character processing (location for token, file handling)
	# - GATE  : Character to symbol mapping, incl. char classes, gating
	# - LEX   : Marpa core engine specialized for lexing (semantics, lexemes)
	# - STORE : Store for token values (lexer semantic information)

	marpa::semstore create STORE
	marpa::lexer    create LEX   STORE [self]
	marpa::gate     create GATE  LEX
	marpa::inbound  create IN    GATE

	#           v-----\ v------\
	# IN --> GATE --> LEX ---> Self --> output
	#                 \        \               .
	#                  \------> \--> STORE

	# IN - Nothing to configure
	GATE def    [my Characters] [my Classes]
	LEX action  [my Semantics]
	LEX export  [my Lexemes]
	LEX symbols [my Symbols]
	LEX rules   [my Rules]
	LEX discard [my Discards]
	LEX events  [my Events]

	# Initial acceptability
	LEX acceptable $mylex
	return
    }

    # # ## ### ##### ######## #############

    forward Characters   my API Characters
    forward Classes      my API Classes
    forward Lexemes      my API Lexemes
    forward Discards     my API Discards
    forward Symbols      my API Symbols
    forward Rules        my API Rules
    forward Semantics    my API Semantics

    method API {m} {
	debug.marpa/engine/tcl/lex {}
	my E "Missing implementation of virtual method \"$m\"" \
	    API VIRTUAL [string toupper $m]
    }

    # # ## ### ##### ######## #############
    ## State

    variable myid mylex myeventprefix
    # myid          :: map (id -> string) - Lexemes
    # mylex         :: list (id) - dict keys of myid
    # myeventprefix :: list (word...)

    # myeventprefix - Callback command to handle parse events
        
    # # ## ### ##### ######## #############
    ## Public API

    method on-event {args} {
	debug.marpa/engine/tcl/lex {}
	set myeventprefix $args
	return
    }

    method process-file {path out} {
	debug.marpa/engine/tcl/lex {}
	marpa::import $out Forward
	set chan [open $path r]
	# Drive the pipeline from the channel.
	IN read $chan
	IN eof
	return
    }

    method process {string out} {
	debug.marpa/engine/tcl/lex {}
	marpa::import $out Forward
	# Drive the pipeline from the string
	IN enter $string
	IN eof
	return
    }

    # # ## ### ##### ######## #############
    ## This wrapper acts as the parser to the embedded lexer core. The
    ## methods below handle the lexer/parser communication, and
    ## talking to the configured output driver.

    method post {args} {
	debug.marpa/engine/tcl/lex {}
	if {![llength $myeventprefix]} {
	    debug.marpa/engine/tcl/lex { Ignored }
	    return
	}
	# XXX try ? ignore errors ?
	debug.marpa/engine/tcl/lex { Invoke }
	uplevel #0 [linsert $args 0 {*}$myeventprefix [self]]
	return
    }
    
    method gate: {lexcore} {
	debug.marpa/engine/tcl/lex {}
	return
    }

    method symbols {lexemes} {
	debug.marpa/engine/tcl/lex {}
	return [set mylex [lmap w $lexemes {
	    set id [dict size $myid]
	    dict set myid $id $w
	    set id
	}]]
    }

    method enter {symbols values} {
	debug.marpa/engine/tcl/lex {}
	Forward enter \
	    [lmap s $symbols { dict get $myid $s }] \
	    [lmap v $values  { STORE get $v }]
	LEX acceptable $mylex
	return
    }

    method eof {} {
	debug.marpa/engine/tcl/lex {}
	Forward eof
	return
    }

    method fail {cv} {
	debug.marpa/engine/tcl/lex {}
	upvar 1 $cv context

	Forward fail context

	my E "Unexpected return without error for problem: $context" \
	    INTERNAL ILLEGAL RETURN $context
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
