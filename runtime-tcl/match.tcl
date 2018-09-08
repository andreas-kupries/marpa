# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
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

    # Full implementation of all the methods in question.
    # We want rtC and rt-Tcl to match in behaviour, as much as possible.
    # For the facade this means, check argument types (int, range, etc.) first,
    # before checking access permission.
    #
    # Still written strongly to look like a table

    # Access to input location: accessor & modifiers

    method location  {} { my Access * Gate location  }
    method last      {} { my Access * Gate last      }

    method from  {pos args} {
	my Location $pos
	foreach d $args { my Int $d ; incr pos $d }
	my Access sdba Gate from $pos
    }

    method from+     {delta} { my Int      $delta ; my Access sdba Gate relative $delta }
    method stop      {}      {                      my Access *    Gate stop         }
    method to        {pos}   { my Location $pos   ; my Access sdba Gate to    $pos   }
    method limit     {limit} { my Posint   $limit ; my Access sdba Gate limit $limit }
    method dont-stop {}      {                      my Access sdba Gate dont-stop }

    # Match/lexeme access

    method symbols {} { my Access sdba Store symbols }
    method sv      {} { my Access sdba Store sv      }

    method start   {} { my Access dba  Store start     }
    method length  {} { my Access dba  Store length    }
    method value   {} { my Access dba  Store value     }

    # Incremental rebuild of the symbol/sv set
    # First call clears and appends, further only appends
    method alternate {symbol sv} { my Access ba Store alternate $symbol $sv }
    method clear     {}          { my Access ba Store clear                 }

    # Barrier check. For use by stop handlers. Treat the stop location
    # like an eof lexemes cannot cross and the lexer may bounce off,
    # until it reaches it at the end of the last possible lexeme.

    method barrier {} {	my Access s Gate barrier }
    
    # Debug helper method, also testsuite
    method view {} {
	my ValidatePermissions
	my ValidateType sdba
	set     r [Store view {symbols sv start length value values}]
	lappend r "@location = [Gate location]"
    }

    # Internal helpers (Argument checks, access control)
    method Int {x} { incr x 0 }

    method Posint {x} {
	incr x 0
	if {$x > 0} return
	return -code error "expected int > 0, but got \"$x\""
    }

    method Posint0 {x} {
	incr x 0
	if {$x >= 0} return
	return -code error "expected int >= 0, but got \"$x\""
    }

    method Location {x} {
	incr x 0
	if {$x >= 0} return
	return -code error "expected location (>= 0), but got \"$x\""
    }

    method Access {code args} {
	debug.marpa/lexer/match {[debug caller] | }
	my ValidatePermissions
	my ValidateType $code
	return [{*}$args]
    }

    method ValidatePermissions {} {
	debug.marpa/lexer/match {[debug caller] | }
	if {[Store event] ne {}} return ; # Access permitted
	return -code error -errorcode {MARPA MATCH PERMIT} \
	    "Invalid access to match state, not inside event handler"
    }

    method ValidateType {code} {
	debug.marpa/lexer/match {[debug caller] | }
	# Fast handling when any event allowed
	if {$code eq "*"} return
	# Translate code to set of allowed events
	lassign [dict get {
	    s    {STOP_EVENT {stop}}
	    ba   {BA_EVENT   {before after}}
	    dba  {DBA_EVENT  {discard before after}}
	    sdba {SDBA_EVENT {stop discard before after}}
	} $code] ecode types
	# And check ...
	if {[Store event] in $types} return ; # Access permitted
	if {[llength $types] == 1} {
	    set x $types
	} {
	    set x [linsert [join $types {, }] end-1 or]
	}
	return -code error -errorcode [list MARPA MATCH $ecode] \
	    "Invalid access to match state, expected $x event"
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

    variable mylexeme ;# map (name -> latm)

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {} {
	# XXX g1start - argument, get from G1
	debug.marpa/lexer/match {[debug caller] | }
	set myparts {
	    g1start  {}	    g1length 1
	    start    {}	    length   {}	    value    {}
	    name     {}	    lhs      {}	    rule     {}
	    fresh    1
	    event    {}
	}
	# Other values: sv, symbols
	return
    }

    # # -- --- ----- -------- -------------
    ## API towards the lexer

    method lexemes {map} {
	debug.marpa/lexer/match {[debug caller] | }
	set mylexeme $map
	return
    }

    method start:? {location} {
	debug.marpa/lexer/match {[debug caller] | }
	if {[dict get $myparts start] ne {}} return
	dict set myparts start $location
	return
    }

    method has-match {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [expr {[dict get $myparts start] ne {}}]
    }

    method begin {} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts start {}
	return
    }

    method event! {type args} {
	debug.marpa/lexer/match {[debug caller] | }
	try {
	    dict set myparts event $type
	    uplevel 1 $args
	} finally {
	    dict set myparts event {}
	}
    }

    method event {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts event]
    }

    method value: {value} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts value  $value
	dict set myparts length [string length $value]
	return
    }

    method start {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts start]
    }

    method length {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts length]
    }

    method value {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts value]
    }

    method matched: {symbols {semvalues {}}} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts fresh 1

	if {[llength $semvalues]} {
	    # Assert: len(symbols) == len(semvalues)
	    dict set myparts symbols $symbols
	    dict set myparts sv      $semvalues
	} else {
	    dict set   myparts symbols $symbols
	    dict unset myparts sv
	}
	return
    }

    method rule: {symbol lhs rule} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts name   $symbol
	dict set myparts lhs    $lhs
	dict set myparts rule   $rule
	return
    }

    method symbols {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts symbols]
    }

    method sv {} {
	debug.marpa/lexer/match {[debug caller] | }
	return [dict get $myparts sv]
    }

    method pull {parts} {
	debug.marpa/lexer/match {[debug caller] | }
       return [lmap part $parts { dict get $myparts $part }]
    }

    # # -- --- ----- -------- -------------
    ## Public API - Facade accessors

    method alternate {symbol sv} {
	debug.marpa/lexer/match {[debug caller] | }
	if {![dict exists $mylexeme $symbol]} {
	    return -code error "Unknown lexeme \"$symbol\""
	}
	if {[dict get $myparts fresh]} {
	    my clear
	}
	dict lappend myparts symbols $symbol
	dict lappend myparts sv      $sv
	return
    }

    method clear {} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts symbols {}
	dict set myparts sv      {}
	dict set myparts fresh   0
	return
    }

    if 0 {
	## accessors for things not used by the lexer parse events ...
	foreach {part key} {
	    g1start  -		g1length -
	    name     symbol	lhs      -
	    symbol   -		rule     -
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
    }

    # # -- --- ----- -------- -------------
    ## State inspection for narrative tracing

    method view {{keys {}}} {
	debug.marpa/lexer/match {[debug caller] | }
	if {![llength $keys]} {
	    set keys [dict keys $myparts]
	}
	lmap k [lsort -dict $keys] {
	    if {![dict exists $myparts $k]} continue
	    set _ "$k = (([dict get $myparts $k]))"
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
