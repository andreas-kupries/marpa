# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar heredoc::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "heredoc::parser::tcl".
##	Generated On Sat Sep 08 15:04:28 PDT 2018
##		  By aku@hephaistos
##		 Via remeta

package provide heredoc::parser::tcl 0

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define heredoc/parser/tcl
debug prefix heredoc/parser/tcl {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create heredoc::parser::tcl {
    superclass marpa::engine::tcl::parse

    # Lifecycle: No constructor needed. No state.
    # All data is embedded as literals into methods

    # Declare the various things needed by the engine for its
    # operation.  To get the information the base class will call on
    # these methods in the proper order. The methods simply return the
    # requested information. Their base-class implementations simply
    # throw errors, thus preventing the construction of an incomplete
    # parser.

    method Characters {} {
	debug.heredoc/parser/tcl
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<,>       ,
	    @CHR:<<>       <
	    @CHR:<a>       a
	    @CHR:<s>       s
	    @CHR:<y>       y
	    {@CHR:<\73>}   \73
	}
    }

    method Classes {} {
	debug.heredoc/parser/tcl
	# Literals: The character classes in use
	return {
	    @CLS:<A-Za-z>         {[A-Za-z]}
	    {@CLS:<\t-\n\r\40>}   {[\t\n\r\40]}
	}
    }

    method Lexemes {} {
	debug.heredoc/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    comma             1
	    heredoc           1
	    say               1
	    semicolon         1
	    {heredoc start}   1
	}
    }

    method Discards {} {
	debug.heredoc/parser/tcl
	# Discarded symbols (whitespace)
	return {
	    whitespace
	}
    }

    method Events {} {
	debug.heredoc/parser/tcl
	# Map declared events to their initial activation status
	# :: dict (event name -> active)
	return {
	    heredoc   on
	}
    }

    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.heredoc/parser/tcl
	return {
	    @STR:<<<>
	    @STR:<say>
	    whitespace
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.heredoc/parser/tcl
	return {
	    {@STR:<<<> := @CHR:<<> @CHR:<<>}
	    {@STR:<say> := @CHR:<s> @CHR:<a> @CHR:<y>}
	    {comma := @CHR:<,>}
	    {heredoc + @CLS:<A-Za-z>}
	    {say := @STR:<say>}
	    {semicolon := {@CHR:<\73>}}
	    {whitespace + {@CLS:<\t-\n\r\40>}}
	    {{heredoc start} := @STR:<<<>}
	}
    }

    method L0.Semantics {} {
	debug.heredoc/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method L0.Trigger {} {
	debug.heredoc/parser/tcl
	# L0 trigger definitions (pre-, post-lexeme, discard)
	# :: dict (symbol -> (type -> list (event name)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {
	    heredoc {
	        after   heredoc
	    }
	}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.heredoc/parser/tcl
	return {
	    expression
	    expressions
	    {heredoc decl}
	    sayer
	    statement
	    statements
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.heredoc/parser/tcl
	return {
	    {__ :A {name values}}
	    {expression := sayer}
	    {__ :A Afirst}
	    {expression := {heredoc decl}}
	    {__ :A {name values}}
	    {expressions + expression comma 0}
	    {{heredoc decl} :M 0 {heredoc start} heredoc}
	    {sayer :M 0 say expressions}
	    {__ :A Afirst}
	    {statement :M 1 expressions semicolon}
	    {__ :A {name values}}
	    {statements + statement}
	}
    }

    method G1.Trigger {} {
	debug.heredoc/parser/tcl
	# G1 parse event definitions (predicted, nulled, completed)
	# :: dict (symbol -> (type -> list (event name)))
	# Each symbol can have more than one event per type.
	return {}
    }

    method Start {} {
	debug.heredoc/parser/tcl
	# G1 start symbol
	return {statements}
    }
}

# # ## ### ##### ######## #############
return