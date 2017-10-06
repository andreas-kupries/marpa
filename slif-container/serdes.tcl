# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Base methods for (de)serialization, assignment and copying.
# Derived classes have to fill out the core serdes behaviour

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/serdes
debug prefix marpa/slif/container/serdes {[debug caller] | }

# # ## ### ##### ######## #############
## Managing a set of symbols and their rules.

oo::class create marpa::slif::container::serdes {
    marpa::E marpa/slif/container/serdes SLIF CONTAINER SERDES

    # - -- --- ----- -------- -------------
    ## Public API

    method serialize {} {
	my E "Missing definition of abstract method 'serialize'" \
	    VIRTUAL ABSTRACT
    }

    method deserialize {blob} {
	my E "Missing definition of abstract method 'deserialize'" \
	    VIRTUAL ABSTRACT
    }

    method := {origin} {
	debug.marpa/slif/container/grammar {}
	my deserialize [$origin serialize]
	return
    }

    method --> {destination} {
	debug.marpa/slif/container/grammar {}
	$destination deserialize [my serialize]
	return
    }

    export :=
    export -->

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
