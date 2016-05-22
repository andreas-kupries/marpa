# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Container for all data from a SLIF definition

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container
#debug prefix marpa/slif/container {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::container {
    marpa::E marpa/slif/container SLIF CONTAINER

    variable mywarnings ;# List of non-fatal issues found in the SLIF
			 # put into the container.
    variable myerrors   ;# List of fatal issues found in the SLIF
			 # put into the container.

    constructor {} {
	debug.marpa/slif/container {}

	marpa::slif::g1::grammar create G1 g1 [self]
	marpa::slif::l0::grammar create L0 l0 [self]

	# TODO semstore, used as a string pool

	debug.marpa/slif/container {/ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## External API, mostly by directly forwarding to the specific
    ## component and method

    forward g1-symbol      G1 new-symbol
    forward l0-symbol      L0 new-symbol

    forward start!         G1 start!

    forward new-string     L0 new-string
    forward new-charclass  L0 new-charclass

    # # -- --- ----- -------- -------------
    # Indirect APIs reachable from here
    #
    # SYMBOL add-bnf
    # SYMBOL add-quantified
    # SYMBOL ... (attributes)
    #
    # RULE extend-bnf
    # RULE extend-quantified
    # RULE ... (attributes)

    # # -- --- ----- -------- -------------
    ## Internal methods - Issue reporting.

    method record-error {code details locations} {
	# code      - any string - XXX match to message catalogs
	# details   - list of details, as strings.
	# locations - list of locations related to the details.

	lappend myerrors [list $code $details $locations]
    }

    method errors? {} {
	return $myerrors
    }

    method errors {} {
	return [llength $myerrors]
    }

    method record-warning {code details locations} {
	# code      - any string - XXX match to message catalogs
	# details   - list of details, as strings.
	# locations - list of locations related to the details.

	lappend mywarnings [list $code $details $locations]
    }

    method warnings? {} {
	return $mywarnings
    }

    method warnings {} {
	return [llength $mywarnings]
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
