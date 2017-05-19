# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Priority rules, container for alternatives

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/alter
debug prefix marpa/slif/container/alter {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::alter {
    superclass marpa::slif::container::serdes

    variable myrhs           ;# List of RHS symbols
    variable myprecedence    ;# Precedence of this alternative

    marpa::E marpa/slif/container/alter GRAMMAR CONTAINER ALTER

    constructor {rule attrfactory rhs precedence args} {
	debug.marpa/slif/container/alter {}
	# rule = marpa::slif::container::priority
	marpa::import $rule Rule

	# Validate precedence (min-precedence <= x <= 0)

	set myrhs        $rhs
	set myprecedence $precedence

	$attrfactory create A [Rule grammar]
	A set {*}$args

	debug.marpa/slif/container/alter {/ok}
	return
    }

    method recursive {lhs} {
	debug.marpa/slif/container/alter {}
	foreach rhs $myrhs {
	    if {$rhs eq $lhs} { return 1 }
	}
	return 0
    }

    method validate {lhs} {
	debug.marpa/slif/container/alter {}
	foreach rhs $myrhs {
	    Rule grammar must-have $rhs
	}
	A validate
	return
    }

    method fixup {aliases} {
	debug.marpa/slif/container/alter {}
	set myrhs [lmap sym $myrhs {
	    if {[dict exists $aliases $sym]} {
		# Pass mapping
		dict get $aliases $sym
	    } else {
		# Pass unchanged
		set sym
	    }
	}]
	return
    }

    method serialize {} {
	debug.marpa/slif/container/alter {}
	set serial [list priority $myrhs $myprecedence {*}[A serialize]]
	debug.marpa/slif/container/alter {==> $serial}
	return $serial
    }

    method deserialize {blob} {
	debug.marpa/slif/container/alter {}
	my E "Alternative deserialization forbidden, go through constructor" \
	    FORBIDDEN
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
