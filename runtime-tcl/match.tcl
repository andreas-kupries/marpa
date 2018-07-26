# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Match store helper class for lexer. Stores all the parts from which
# lexeme semantic values can be assembled, including, but not limited
# to: lexeme start, length, value. Additionally, when invoking parse
# event handlers, it further stores the matched symbols and their SVs.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/lexer/match
#debug prefix marpa/lexer/match {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create marpa::lexer::ped {
    marpa::E marpa/lexer/match LEXER MATCH

    # parse event descriptor facade to match store
    constructor {m g} {
	marpa::import $m Store
	marpa::import $g Gate
    }

    foreach m {location? moveto rewind moveby stop? stop-at limit} {
	# Access to input location: accessor & modifiers
	forward $m  my Access Gate $m
    } ; unset m

    # API
    foreach part {
	symbols  sv
	start    length
	value    values
    } {
	# Access to match information: modifier/accessor
	forward ${part}:  my Access Store ${part}:
	forward ${part}   my Access Store ${part}
    } ; unset part

    method Access {args} {
	my ValidatePermissions
	return [{*}$args]
    }
    
    # Debug helper method, also testsuite
    method view {} {
	my ValidatePermissions
	set     r [Store view {symbols sv start length value values}]
	lappend r "@location = [Gate location?]"
    }

    # Incremental rebuild of the symbol/sv set
    # First call clears and appends, further only appends
    method alternate {symbol sv} {
	my ValidatePermissions
	if {[Store fresh]} {
	    Store symbols: {}
	    Store sv:      {}
	    Store fresh: 0
	}
	Store symbols: [linsert [Store symbols] end $symbol]
	Store sv:      [linsert [Store sv]      end $sv]
	return
    }


    method ValidatePermissions {} {
	if {[Store event]} return ; # Access permitted
	return -code error -errorcode {MARPA MATCH PERMIT} \
	    "Invalid access to match state, not inside event handler"
    }
}

oo::class create marpa::lexer::match {
    marpa::E marpa/lexer/match LEXER MATCH

    # # -- --- ----- -------- -------------
    ## State

    variable myparts
    # parts dictionary:
    # 'start'	 (^mystart) offset where lexeme starts
    # 'length'	 (^latest) length of the lexeme
    # 'g1start'	 G1 offset of the lexeme (Get from parser (Forward ...))
    # 'g1length' G1 length of the lexeme (fixed: 1)
    # 'name'	 Symbol name of the lexeme, i.e. rule LHS /Pre-computable
    # 'lhs'	 LHS symbol id of the rule. Lexeme symbol (parser symbol)
    # 'rule'	 (^tree) Rule id of the matched lexeme
    # 'value'	 Token value of the lexeme, i.e. the matched string.

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {} {
	debug.marpa/lexer/match {[debug caller] | }
	set myparts {
	    start    {}	    length   {}	fresh 1
	    g1start  {}	    g1length {} event 0
	    symbol   {}	    lhs      {}
	    rule     {}	    value    {}
	}
	# Other values: sv, symbols
	return
    }

    # # -- --- ----- -------- -------------
    ## State inspection for narrative tracing

    method view {{keys {}}} {
	if {![llength $keys]} {
	    set keys [dict keys $myparts]
	}
	lmap k [lsort -dict $keys] {
	    if {![dict exists $myparts $k]} continue
	    set _ "$k = (([dict get $myparts $k]))"
	}
    }

    # # -- --- ----- -------- -------------
    ## Public API - Accessors and modifiers

    foreach {part key} {
	symbols  -	sv       -	fresh -
	start    -	length   -	event -
	g1start  -	g1length -
	name     symbol	lhs      -
	symbol   -	rule     -
	value    -	values   value
    } {
	if {$key eq "-"} { set key $part }
	forward ${part}:  my Set   $key
	forward ${part}   my Get   $key
	forward ${part}~  my Clear $key
    }
    unset part key

    method Set {key value} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts $key $value
	return
    }

    method Get {key} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts $key]
    }

    method Clear {key} {
	debug.marpa/lexer/match {[debug caller] | }
	dict unset myparts $key
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
