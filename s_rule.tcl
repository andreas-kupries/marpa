# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support - Rule base class
# 

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/rule
debug prefix marpa/slif/rule {[debug caller] | }

# # ## ### ##### ######## #############
## Managing rule information

oo::class create marpa::slif::rule {
    variable mygrammar
    variable mylhs
    # common attributes ...
    # specific attributes in sub-classes

    marpa::E marpa/slif/rule SLIF RULE

    ##
    # API:
    # * constructor (lhs)

    constructor {lhs} {
	debug.marpa/slif/rule {}

	set mylhs     $lhs
	set mygrammar [$lhs grammar]

	marpa::import $lhs       LHS
	marpa::import $mygrammar Grammar

	debug.marpa/slif/rule {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Issue reporting. Forward to the LHS symbol.
    ## XXX Instead of simply forwarding, add the grammar name to the message ?

    forward record-error    LHS record-error
    forward record-warning  LHS record-warning

    # - -- --- ----- -------- -------------

    method grammar {} {
	debug.marpa/slif/rule {=> $mygrammar}
	return $mygrammar
    }

    # - -- --- ----- -------- -------------

    method extend-bnf {args} {
	debug.marpa/slif/rule {}
	my E "Rule not extensible with BNF" EXTEND BNF
    }

    method extend-quantified {args} {
	debug.marpa/slif/rule {}
	my E "Rule not extensible with quantification" EXTEND QUANTIFIED
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
