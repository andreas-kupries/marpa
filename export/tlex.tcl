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
# Package marpa::export::tlex 1
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
# Meta require     marpa::export::core::tcl
# Meta subject     marpa {lexer generator} lexing {generator lexer}
# Meta subject     {Tcl runtime lexing} {lexer Tcl runtime}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::util
package require marpa::export::core::tcl

debug define marpa/export/tlex
debug prefix marpa/export/tlex {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::tlex {
    namespace export container
    namespace ensemble create

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::tlex::container {gc} {
    debug.marpa/export/tlex {}
    variable self
    marpa::fqn gc
    set config   [marpa::export::core::tcl config [$gc serialize]]
    set template [string trim [marpa asset $self]]
    return [string map $config $template]
}

# # ## ### ##### ######## #############
package provide marpa::export::tlex 1
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
##	rt_lex-derived Engine for grammar "@slif-name@". Lexing only.
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require marpa	      ;# marpa::engine::tcl::lex
package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#

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
}

# # ## ### ##### ######## #############
return
