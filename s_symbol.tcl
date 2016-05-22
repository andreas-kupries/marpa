# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Basic symbols.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/symbol
debug prefix marpa/slif/symbol {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::symbol {
    variable myname      ;# Name of the symbol, as provided by the input SLIF
    variable mygrammar   ;# Grammar the symbol is a part of
    variable myrule      ;# Rule defining the symbol (possibly empty)
    variable myleaf      ;# State flag, leaf-ness: maybe, yes, no
    variable mytoplevel  ;# State flag, root-ness: maybe, yes, no
    variable mydef       ;# List of locations defining the symbol
    variable myuse       ;# List of location using the symbol

    marpa::E marpa/slif/symbol SLIF SYMBOL

    ##
    # API:
    # * constructor (name, -> grammar)
    # * add-bnf        (rhs)
    # * add-quantified (rhs, positive)
    # * maybe-leaf!
    # * maybe-toplevel!
    # * no-leaf!
    # * no-toplevel!
    # * is-leaf!
    # * is-toplevel!
    # * grammar () -> grammar
    # * leaf (?state?) -> state/bool
    # * toplevel (?state?) -> state/bool

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name grammar} {
	debug.marpa/slif/symbol {}

	marpa::import $grammar Grammar

	set myname     $name
	set mygrammar  $grammar
	set myrule     {}
	set myleaf     maybe
	set mytoplevel maybe
	set mydef      {}
	set myuse      {}

	debug.marpa/slif/symbol {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Issue reporting. Forward to the enclosing grammar.
    ## XXX Instead of simply forwarding, add the grammar name to the message ?

    forward record-error    Grammar record-error
    forward record-warning  Grammar record-warning

    # - -- --- ----- -------- -------------

    method name? {} {
	debug.marpa/slif/symbol {==> ($myname)}
	return $myname
    }

    # - -- --- ----- -------- -------------
    ## def/use information - locations where the symbol is
    ## defined/used.

    method def {start length} {
	debug.marpa/slif/symbol {}
	lappend mydef [list $start $length]
	return
    }

    method use {start length} {
	debug.marpa/slif/symbol {}
	lappend myuse [list $start $length]
	return
    }

    method last-use {} {
	set lu [lindex $myuse end]
	debug.marpa/slif/symbol {==> loc($lu)}
	return $lu
    }

    # - -- --- ----- -------- -------------
    ## rule management

    method add-bnf {rhs precedence} {
	debug.marpa/slif/symbol {}

	if {[my leaf yes]} { my E "Cannot add rule to leaf symbol" INVALID RULE }
	my no-leaf!

	if {$myrule eq {}} {
	    set myrule [Grammar add-bnf [self] $rhs $precedence]
	    marpa::import $myrule Rule
	} else {
	    Rule extend-bnf $rhs $precedence
	}

	debug.marpa/slif/symbol {/done}
	return $myrule
    }

    method add-quantified {rhs positive} {
	debug.marpa/slif/symbol {}

	if {[my leaf yes]} { my E "Cannot add rule to leaf symbol" INVALID RULE }
	my no-leaf!

	if {$myrule eq {}} {
	    set myrule [Grammar add-quantified [self] $rhs $positive]
	    marpa::import $myrule Rule
	} else {
	    Rule extend-quantified $name $rhs $positive
	}

	debug.marpa/slif/symbol {/done}
	return $myrule
    }

    # - -- --- ----- -------- -------------
    ## accessors

    method grammar {} {
	debug.marpa/slif/symbol {=> $mygrammar}
	return $mygrammar
    }

    method leaf {{state {}}} {
	debug.marpa/slif/symbol {}
	if {[llength [info level 0]] == 3} {
	    return [expr {$myleaf eq $state}]
	}
	return $myleaf
    }

    method toplevel {{state {}}} {
	debug.marpa/slif/symbol {}
	if {[llength [info level 0]] == 3} {
	    return [expr {$mytoplevel eq $state}]
	}
	return $mytoplevel
    }

    # - -- --- ----- -------- -------------
    ## state changes

    method no-leaf! {} {
	debug.marpa/slif/symbol {}
	switch -exact -- $myleaf {
	    maybe { set myleaf no }
	    yes   { my E "Invalid state change of leaf to interior" INVALID STATE-CHANGE LEAF }
	    no    { }
	}
    }

    method no-toplevel! {} {
	debug.marpa/slif/symbol {}
	switch -exact -- $myleaf {
	    maybe { set mytoplevel no }
	    yes   { my E "Invalid state change of toplevel to interior" INVALID STATE-CHANGE TOPLEVEL }
	    no    { }
	}
    }

    method is-leaf! {} {
	debug.marpa/slif/symbol {}
	switch -exact -- $myleaf {
	    maybe { set myleaf yes }
	    yes   { }
	    no    { my E "Invalid state change of interior to leaf" INVALID STATE-CHANGE LEAF }
	}
    }

    method is-toplevel! {} {
	debug.marpa/slif/symbol {}
	switch -exact -- $mytoplevel {
	    maybe { set mytoplevel yes }
	    yes   { }
	    no    { my E "Invalid state change of interior to toplevel" INVALID STATE-CHANGE TOPLEVEL }
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
