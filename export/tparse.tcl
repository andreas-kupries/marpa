# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator) -- Core functionality see `export::core::tcl`
##
# - Output format: Tcl code
#   Subclass of "marpa::engine::tcl::lex" with embedded deconstructed (*) grammar
#   (*) The various pieces used to configure the lexer base class.
#
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::export::tparse 1
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
# Meta require     marpa::export::core::tcl
# Meta subject     marpa {parser generator} lexing {generator parser}
# Meta subject     {Tcl runtime parsing} {parsing Tcl runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::export::core::tcl
package require marpa::util

debug define marpa/export/tparse
debug prefix marpa/export/tparse {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::tparse {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::tparse::container {gc} {
    debug.marpa/export/tparse {}
    variable self
    marpa::fqn gc
    set config   [marpa::export::core::tcl config [$gc serialize]]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::export::tparse 1
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	rt_parse-derived Engine for grammar "@slif-name@". Lexing + Parsing.
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require marpa	      ;# marpa::engine::tcl::parse
package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#

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

    method Start {} {
	debug.@slif-name-tag@
	# G1 start symbol
	return {@start@}
    }
}

# # ## ### ##### ######## #############
return
