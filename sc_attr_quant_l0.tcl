# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar attributes for L0 quantified rule

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/slif/container/attribute/quantified/l0
#debug prefix marpa/slif/container/attribute/quantified/l0 {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::container::attribute::quantified::l0 {
    superclass marpa::slif::container::attribute

    marpa::E marpa/slif/container/attribute/quantified/l0 \
	SLIF CONTAINER ATTRIBUTE QUANTIFIED L0

    constructor {} {
	debug.marpa/slif/container/attribute/quantified/l0 {}

	# quantified: separator (includes proper)

	next separator {}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
