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
# Package marpa::gen::format::tlex 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for lexers
# Meta description based on the Tcl runtime
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::gen::runtime::tcl
# Meta subject     marpa {lexer generator} lexing {generator lexer}
# Meta subject     {Tcl runtime lexing} {lexer Tcl runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::util
package require marpa::gen::runtime::tcl

debug define marpa/gen/format/tlex
debug prefix marpa/gen/format/tlex {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::tlex {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::tlex::container {gc} {
    debug.marpa/gen/format/tlex {}
    variable self
    marpa fqn gc
    set config   [marpa::gen::runtime::tcl config [$gc serialize]]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::tlex 0
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
##	`marpa::runtime::tcl`-derived Lexer for grammar "@slif-name@".
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
    superclass marpa::engine::tcl::lex

    # Lifecycle: No constructor needed. No state.
    # All data is embedded as literals into methods

    # Declare the various things needed by the engine for its
    # operation.  To get the information the base class will call on
    # these methods in the proper order. The methods simply return the
    # requested information. Their base-class implementations simply
    # throw errors, thus preventing the construction of an incomplete
    # lexer.

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
	# Lexer API: Lexeme symbols (Cannot be terminal).
	return {@lexemes@}
    }

    method Discards {} {
	debug.@slif-name-tag@
	# Discarded symbols (whitespace)
	return {@discards@}
    }

    method Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.@slif-name-tag@
	return {@l0-symbols@}
    }

    method Rules {} {
	# Rules for all symbols but the literals
	debug.@slif-name-tag@
	return {@l0-rules@}
    }

    method Semantics {} {
	debug.@slif-name-tag@
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {@l0-semantics@}
    }

    method Events {} {
	debug.@slif-name-tag@
	# L0 parse event definitions (pre-, post-lexeme, discard)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {@l0-events@}
    }
}

# # ## ### ##### ######## #############
return
