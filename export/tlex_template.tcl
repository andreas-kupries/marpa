# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter support (tl - Tcl Lexer Only): Template access.
##

# Note: The template is part of this file, after a ^Z character. Tcl's
# source command will not read beyond that character, and thus use
# only the package code itself, as it should. In the initialization
# code we the read file again, via introspection, and -eofchar
# shenanigans allow us to skip the package code and read the template
# instead.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/export/tlex/template
debug prefix marpa/export/tlex/template {[debug caller] | }

# # ## ### ##### ######## #############
## State

namespace eval ::marpa::export::tlex::template {
    namespace export get
    namespace ensemble create

    variable template
}

# # ## ### ##### ######## #############
## Initialization

apply {{self} {
    variable template
    set ch [open $self]
    # Skip package code, use special EOF handling analogous to `source`.
    fconfigure $ch -eofchar \x1A
    read $ch
    # Switch to regular EOF handling
    fconfigure $ch -eofchar {}
    # Skip the separator character
    read $ch 1
    # And then read the template into memory
    set template [string trim [read $ch]]
    close $ch
    return
} ::marpa::export::tlex::template} [info script]

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::tlex::template::get {} {
    debug.marpa/export/tlex/template {}
    variable template
    return $template
}

# # ## ### ##### ######## #############
return
##
## Template following (`source` will not process it)

# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	TLex (*) Engine for SLIF Grammar "@slif-name@"
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##
##	(*) Tcl-based Lexer-only

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require marpa	      ;# marpa::slif::container
package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#

# # ## ### ##### ######## #############

debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }

# # ## ### ##### ######## #############

oo::class @slif-name@ {
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
	debug.marpa/grammar/@slif-name@
	# Literals: The directly referenced (allowed) characters.
	return {@characters@}
    }
    
    method Classes {} {
	debug.marpa/grammar/@slif-name@
	# Literals: The character classes in use
	return {@classes@}
    }
    
    method Lexemes {} {
	debug.marpa/grammar/@slif-name@
	# Lexer API: Lexeme symbols (Cannot be terminal).
	return {@lexemes@}
    }
    
    method Discards {} {
	debug.marpa/grammar/@slif-name@
	# Discarded symbols (whitespace)
	return {@discards@}
    }
    
    method Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.marpa/grammar/@slif-name@
	return {@symbols@}
    }

    method Rules {} {
	# Rules for all symbols but the literals
	debug.marpa/grammar/@slif-name@
	return {@rules@}
    }

    method Semantics {} {
	debug.marpa/grammar/@slif-name@
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {@semantics@}
    }
}

# # ## ### ##### ######## #############
return
