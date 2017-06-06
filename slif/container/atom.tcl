# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Grammar atoms.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom
debug prefix marpa/slif/container/atom {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::atom {
    superclass marpa::slif::container::serdes

    marpa::E marpa/slif/container/atom SLIF CONTAINER ATOM

    variable mytype    ;#
    variable mydetails ;# type-dependent

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {type args} {
	debug.marpa/slif/container/atom {}

	set mytype    $type
	set mydetails $args

	debug.marpa/slif/container/atom {/ok}
	return
    }

    method validate {lhs} {
	debug.marpa/slif/container/atom {}
	# Nothing ... Future: Type-dependent validation ?
	return
    }

    method min-precedence {} {
	debug.marpa/slif/container/atom {}
	# Atoms of any kind have no precedence.
	return 0
    }

    method recursive {lhs} {
	debug.marpa/slif/container/atom {}
	return 0
    }

    method fixup {aliases} {
	debug.marpa/slif/container/atom {}
	# Nothing to do. Atoms are literals, they do not have symbols
	# in their definition.
	return
    }

    method serialize {} {
	debug.marpa/slif/container/atom {}
	return [list [list $mytype {*}$mydetails]]
    }

    # - -- --- ----- -------- -------------

    method extend {args} {
	debug.marpa/slif/container/atom {}
	my E "Atom: Cannot be extended: $args" \
	    FORBIDDEN
    }

    method deserialize {blob} {
	debug.marpa/slif/container/atom {}
	my E "Atom: Deserialization forbidden, must go through constructor" \
	    FORBIDDEN
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
