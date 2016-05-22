# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Basic grammar (symbols and associated rules). Part of
# a SLIF container.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/grammar
debug prefix marpa/slif/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## Managing a set of symbols and their rules.

oo::class create marpa::slif::grammar {
    variable myname   ;# string
    variable mysymbol ;# dict: symbol name     -> instance
    variable myobj    ;# dict: symbol instance -> "."

    marpa::E marpa/slif/grammar SLIF GRAMMAR

    ##
    # API:
    # * constructor (name)
    # * new-symbol     (name) -> instance
    # * new-symbols    (names) -> instances
    # * has-symbol     (name) -> bool
    # * has-symbol-obj (obj) -> bool
    # * add-bnf        (name lhs rhs) -> instance
    # * add-quantified (name lhs rhs positive) -> instance

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {name container} {
	debug.marpa/slif/grammar {}

	marpa::import $container Container

	set myname   $name
	set mysymbol {}
	set myobj    {}

	debug.marpa/slif/grammar {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Issue reporting. Forward to the enclosing container.
    ## XXX Instead of simply forwarding, add the grammar name to the message ?

    forward record-error    Container record-error
    forward record-warning  Container record-warning

    # - -- --- ----- -------- -------------
    ## symbol creation and lookup

    method new-symbol {name} {
	debug.marpa/slif/grammar {}

	set obj [my New marpa::slif::symbol $name]

	debug.marpa/slif/grammar {==> $obj}
	return $obj
    }

    method new-symbols {names} {
	debug.marpa/slif/grammar {}

	set objs {}
	foreach name $names { lappend objs [my new-symbol $name] }

	debug.marpa/slif/grammar {==> $objs}
	return $objs
    }

    method has-symbol {name {objvar {}}} {
	set found [dict exists $mysymbol $name]
	debug.marpa/slif/grammar {==> $found}
	if {$found && ($objvar ne {})} {
	    upvar 1 $objvar obj
	    set obj [dict get $mysymbol $name]
	}
	return $found
    }

    method has-symbol-obj {obj} {
	set found [dict exists $myobj $obj]
	debug.marpa/slif/grammar {==> $found}
	return $found
    }

    method New {creator name args} {
	# For use by derived classes
	debug.marpa/slif/grammar {}

	if {$name eq {}} {
	    # Empty symbol, no instance, fast-track
	    set obj {}
	} elseif {![dict exists $mysymbol $name]} {
	    # Name not known, create instance
	    set obj [$creator new $name [self] {*}$args]
	    dict set mysymbol $name $obj
	    dict set myobj    $obj .
	} else {
	    # Name known, return associated instance.
	    set obj [dict get $mysymbol $name]
	}

	debug.marpa/slif/grammar {==> $obj}
	return $obj
    }

    # - -- --- ----- -------- -------------
    ## rule creation

    method add-bnf {lhs rhs precedence} {
	debug.marpa/slif/grammar {}
	set obj [marpa::slif::bnf new $lhs $rhs $precedence]

	debug.marpa/slif/grammar {==> $obj}
	return $obj
    }

    method add-quantified {lhs rhs positive} {
	debug.marpa/slif/grammar {}
	set obj [marpa::slif::quantified new $lhs $rhs $positive]

	debug.marpa/slif/grammar {==> $obj}
	return $obj
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
