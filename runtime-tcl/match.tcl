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

    method location  {} { my Access *    Gate location  }
    method stop      {} { my Access *    Gate stop      }
    method dont-stop {} { my Access sdba Gate dont-stop }

    method relative {delta} { my Int $delta ; my Access sdba Gate relative $delta }
    method rewind   {delta} { my Int $delta ; my Access sdba Gate rewind   $delta }

    method from  {pos args} {
	my Location $pos
	foreach d $args { my Int $d }
	my Access sdba Gate from  $pos {*}$args
    }

    method to    {pos}   { my Location $pos   ; my Access sdba Gate to    $pos   }
    method limit {limit} { my Posint   $limit ; my Access sdba Gate limit $limit }

    # Match/lexeme access

    method symbols {} { my Access sdba Store m-symbols }
    method sv      {} { my Access sdba Store sv        }
    method start   {} { my Access dba  Store start     }
    method length  {} { my Access dba  Store length    }
    method value   {} { my Access dba  Store value     }
    method values  {} { my Access dba  Store values    }

    method symbols: {syms}  { my Access ba Store m-symbols: $syms  }
    method sv:      {svs}   { my Access ba Store sv:        $svs   }
    method value:   {value} { my Access ba Store value:     $value }
    method values:  {value} { my Access ba Store values:    $value }

    method start:   {start}  { my Location $start  ; my Access ba Store start:  $start }
    method length:  {length} { my Posint0  $length ; my Access ba Store length: $length }

    # Incremental rebuild of the symbol/sv set
    # First call clears and appends, further only appends
    method alternate {symbol sv} {
	my ValidatePermissions
	my ValidateType ba
	if {[Store fresh]} {
	    Store m-symbols: {}
	    Store sv:        {}
	    Store fresh: 0
	}
	Store m-symbols: [linsert [Store m-symbols] end $symbol]
	Store sv:        [linsert [Store sv]        end $sv]
	return
    }

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
	if {$x >= 0} return
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
	my ValidatePermissions
	my ValidateType $code
	return [{*}$args]
    }

    method ValidatePermissions {} {
	if {[Store event] ne {}} return ; # Access permitted
	return -code error -errorcode {MARPA MATCH PERMIT} \
	    "Invalid access to match state, not inside event handler"
    }

    method ValidateType {code} {
	# Fast handling when any event allowed
	if {$code eq "*"} return
	# Translate code to set of allowed events
	lassign [dict get {
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
	debug.marpa/lexer/match {[debug caller] | }
	set myparts {
	    start    {}	    length   {}	fresh 1
	    g1start  {}	    g1length {} event {}
	    symbol   {}	    lhs      {}
	    rule     {}	    value    {}
	}
	# Other values: sv, symbols
	return
    }

    method lexemes {map} {
	debug.marpa/lexer/match {[debug caller] | }
	set mylexeme $map
	return
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

    # # -- --- ----- -------- -------------
    ## Public API - Accessors and modifiers

    foreach {part key} {
	sv       -	symbols	 -	fresh -
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

    forward value:  my SetValue
    forward values: my SetValue

    forward m-symbols:  my SetSymbols
    forward m-symbols   my Get    symbols
    forward m-symbols~  my Clear  symbols

    method SetValue {value} {
	debug.marpa/lexer/match {[debug caller] | }
	dict set myparts value  $value
	dict set myparts length [string length $value]
	return
    }

    method SetSymbols {value} {
	debug.marpa/lexer/match {[debug caller] | }
	foreach sym $value {
	    if {[dict exists $mylexeme $sym]} continue
	    return -code error "Unknown lexeme \"$sym\""
	}
	dict set myparts symbols $value
	return
    }

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
