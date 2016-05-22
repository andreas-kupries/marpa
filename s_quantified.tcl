# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container support - Quantified rules

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/quantified
debug prefix marpa/slif/quantified {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::quantified {
    superclass marpa::slif::rule

    variable myrhs
    variable mypositive
    variable myseparator
    variable myproper

    marpa::E GRAMMAR RULE QUANTIFIED

    ##
    # API:
    # * constructor (-> lhs, rhs-name, positive, separator-name, proper)
    #
    # API (grammar):
    # * get symbol object

    constructor {lhs rhs positive} {
	debug.marpa/slif/quantified {}

	next $lhs
	# Now we have Grammar.

	set myrhs       [Grammar new-symbol $rhs]
	set mypositive  $positive
	#set myseparator [Grammar new-symbol $separator]
	#set myproper    $proper

	debug.marpa/slif/quantified {/ok}
	return
    }

    # extend-bnf        - Keep base method, error
    # extend-quantified - Keep base method, error

    # # -- --- ----- -------- -------------
    ## Adverbs for quantified rules

    method set-separator {v} {
	debug.marpa/slif/quantified {}
	return
    }

    method set-proper {v} {
	debug.marpa/slif/quantified {}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
