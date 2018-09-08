# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator) -- Core functionality see `marpa::gen::runtime::tcl`
##
# - Output format: Tcl code
#   Subclass of "marpa::engine::tcl::lex" with embedded deconstructed (*) grammar
#   (*) The various pieces used to configure the lexer base class.
#
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::format::tparse 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for parsers
# Meta description based on the Tcl runtime
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::gen::runtime::tcl
# Meta subject     marpa {parser generator} lexing {generator parser}
# Meta subject     {Tcl runtime parsing} {parsing Tcl runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::gen::runtime::tcl
package require marpa::util

debug define marpa/gen/format/tparse
debug prefix marpa/gen/format/tparse {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::tparse {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::tparse::container {gc} {
    debug.marpa/gen/format/tparse {}
    variable self
    marpa fqn gc

    set config [marpa::gen::runtime::tcl config [$gc serialize]]
    debug.marpa/gen/format/tparse {[set _ ""][join [lmap {k v} $config {set _ "$k = $v"}] \n][unset _]}

    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::tparse 0
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	`marpa::runtime::tcl`-derived Parser for grammar "@slif-name@".
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define @slif-name-tag@
debug prefix @slif-name-tag@ {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create @slif-name@ {
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
	debug.@slif-name-tag@
	# Literals: The directly referenced (allowed) characters.
	return {@characters@}
    }

    method Classes {} {
	debug.@slif-name-tag@
	# Literals: The character classes in use
	return {@classes@}
    }

    method Lexemes {} {
	debug.@slif-name-tag@
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {@lexemes@}
    }

    method Discards {} {
	debug.@slif-name-tag@
	# Discarded symbols (whitespace)
	return {@discards@}
    }

    method Events {} {
	debug.@slif-name-tag@
	# Map declared events to their initial activation status
	# :: dict (event name -> active)
	return {@events@}
    }

    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.@slif-name-tag@
	return {@l0-symbols@}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.@slif-name-tag@
	return {@l0-rules@}
    }

    method L0.Semantics {} {
	debug.@slif-name-tag@
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {@l0-semantics@}
    }

    method L0.Trigger {} {
	debug.@slif-name-tag@
	# L0 trigger definitions (pre-, post-lexeme, discard)
	# :: dict (symbol -> (type -> list (event name)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {@l0-trigger@}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.@slif-name-tag@
	return {@g1-symbols@}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.@slif-name-tag@
	return {@g1-rules@}
    }

    method G1.Trigger {} {
	debug.@slif-name-tag@
	# G1 parse event definitions (predicted, nulled, completed)
	# :: dict (symbol -> (type -> list (event name)))
	# Each symbol can have more than one event per type.
	return {@g1-trigger@}
    }

    method Start {} {
	debug.@slif-name-tag@
	# G1 start symbol
	return {@start@}
    }
}

# # ## ### ##### ######## #############
return
