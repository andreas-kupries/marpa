# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Priority rules

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/priority
debug prefix marpa/slif/container/priority {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::container::priority {
    superclass marpa::slif::container::serdes

    variable myalternatives  ;# List of alternatives
    variable myminprecedence ;# Lowest precedence seen among the known alternatives
    variable myaf            ;# Attribute factory to pass to the alternatives.
    variable myalt           ;# Alternatives by rhs (find and reject identicals)
    variable mygrammar       ;# Grammar holding the symbol and rules.

    marpa::E marpa/slif/container/priority GRAMMAR CONTAINER PRIORITY

    constructor {grammar attrfactory rhs precedence args} {
	debug.marpa/slif/container/priority {}
	# grammar = marpa::slif::container::grammar
	marpa::import $grammar Grammar

	set myalternatives  {}
	set myminprecedence 0
	set myaf            $attrfactory
	set myalt           {}
	set mygrammar       $grammar

	my extend $rhs $precedence {*}$args

	debug.marpa/slif/container/priority {/ok}
	return
    }

    method validate {} {
	debug.marpa/slif/container/priority {}
	foreach alter $myalternatives {
	    $alter validate
	}
	return
    }

    method serialize {} {
	debug.marpa/slif/container/priority {}

	set result {}
	foreach alter $myalternatives {
	    lappend result [$alter serialize]
	}
	return $result
    }

    method deserialize {blob} { 
	debug.marpa/slif/container/priority {}
	my E "Priority rule deserialization forbidden, go through constructor" \
	    FORBIDDEN
    }

    method fixup {aliases} {
	debug.marpa/slif/container/priority {}

	foreach alter $myalternatives {
	    $alter fixup $aliases
	}
	return
    }
    
    method extend {rhs precedence args} {
	debug.marpa/slif/container/priority {}
	
	if {[dict exists $myalt $rhs]} {
	    my E "Cannot extend with identical rhs ($rhs)" MULTI RHS
	}

	if {$precedence < $myminprecedence} {
	    set myminprecedence $precedence
	}

	set alter [marpa::slif::container::alter new [self] $myaf \
		       $rhs $precedence {*}$args]

	lappend myalternatives $alter
	dict set myalt $rhs    $alter
	# Possible quick filtered access
	#dict set myrhs        $id [Grammar new-symbols $rhs]
	#dict set myaction     $id $action
	#dict set myname       $id $name
	#dict set myvisibility $id $visibility
	#dict set myprecedence $id $precedence

	debug.marpa/slif/container/priority {/ok}
    }

    # # ## ### ##### ######## #############

    method grammar {args} {
	debug.marpa/slif/container/priority {}
	if {[llength $args]} {
	    return [Grammar {*}$args]
	} else {
	    return $mygrammar
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
