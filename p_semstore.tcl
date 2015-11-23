# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# A store for semantic values. Alt description: Interning strings and
# making them available through (small) integer ids. Technically just
# a thin wrapper around a dictionary. Made into an object for a proper
# fit with the other pieces of the system.

# Beyond the in-memory interning of values the store also offers a
# scratchpad for storing and reading named values. This can be used
# for communication between components otherwise requiring custom
# coding/effort. -- Currently not used anywhere --

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

debug define marpa/semstore
debug prefix marpa/semstore {[debug caller] | }

# # ## ### ##### ######## #############
## Stores for token values.

oo::class create marpa::semstore {
    variable mycounter ;# Id counter for interned values
    variable myvalue   ;# Dict holding interned values
    variable myscratch ;# Scratchpad for named values

    constructor {} {
	debug.marpa/semstore {}
	my clear

	debug.marpa/semstore {/ok}
	return
    }

    method put {data} {
	debug.marpa/semstore {}
	dict set myvalue [incr mycounter] $data
	debug.marpa/semstore {==> $mycounter}
	return $mycounter
    }

    method get {id} {
	debug.marpa/semstore {==> ([dict get $myvalue $id])}
	return [dict get $myvalue $id]
    }

    method drop {id} {
	debug.marpa/semstore {}
	dict unset myvalue $id
	return
    }

    method clear {} {
	debug.marpa/semstore {}
	set mycounter 0
	set myvalue   {}
	set myscratch {}
	return
    }

    forward reset   my clear

    method write {name data} {
	debug.marpa/semstore {}
	dict set myscratch $name $data
	return
    }

    method read {name} {
	debug.marpa/semstore {}
	return [dict get $myscratch $name]
    }

    method unset {name} {
	debug.marpa/semstore {}
	dict unset myscratch $name
	return
    }
}

# # ## ### ##### ######## #############
return
