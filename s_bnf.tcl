# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - BNF rules

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/bnf
debug prefix marpa/slif/bnf {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::bnf {
    superclass marpa::slif::rule

    variable myalternatives  ;# List of keys
    variable myrhs           ;# Dict of per-alternative RHS vector
    variable myprecedence    ;# Dict of per-alternative precedence value
    variable myvisibility    ;# Dict of per-alternative visibility vector
    variable myname          ;# Dict of per-alternative rule name
    variable myaction        ;# Dict of per-alternative rule action
    variable myminprecedence ;# Lowest precedence seen among the known alternatives

    marpa::E GRAMMAR RULE BNF

    ##
    # API:
    # * constructor (-> lhs, rhs-name, positive, separator-name, proper)
    #
    # API (grammar):
    # * get symbol object

    constructor {lhs rhs precedence} {
	debug.marpa/slif/bnf {}

	marpa::slif::id create [self namespace]::Id

	next $lhs
	# Now we have the Grammar command.

	set myminprecedence 0

	# Enter the first alternative
	my extend-bnf $rhs $precedence

	debug.marpa/slif/bnf {/ok}
	return
    }

    method extend-bnf {rhs precedence} {
	debug.marpa/slif/bnf {}

	lappend myalternatives [set id [Id next]]
	dict set myrhs        $id [Grammar new-symbols $rhs]
	#dict set myaction     $id $action
	#dict set myname       $id $name
	#dict set myvisibility $id $visibility
	dict set myprecedence $id $precedence

	if {$precedence < $myminprecedence} {
	    set myminprecedence $precedence
	}

	debug.marpa/slif/bnf {/ok}
    }

    # extend-quantified - Keep base method - error

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
