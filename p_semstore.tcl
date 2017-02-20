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

    method names {} {
	debug.marpa/semstore {}
	set result [dict keys $myvalue]
	debug.marpa/semstore {==> $result}
	return $result
    }

    method put {data} {
	debug.marpa/semstore {}
	#
	# NOTE: The returned value id's start from 1 and go up.
	#       No semantic value has the id 0.
	# See the libmarpa documentation telling us
	#
	#    A value of 0 is reserved for a now-deprecated feature. Do
	#    not use it. For more details on that feature, see the
	#    section Valued and unvalued symbols.
	#
	# in the description of "marpa_r_alternative". In the
	# referenced section it is mentioned that the engine optimizes
	# things when it encouters unvalued symbols.
	#
	# I suspect that there are issues in these optimzations, for
	# when I used id 0 during testing I found RECCE to behave
	# irregular, doing things like
	#
	# - prematurely report "exhausted", when it truly could accept
	#   more input (parser.test, marpa-parser-7.1.0)
	#
	# - report exhausted properly, but fail to construct a forest
	#   (lexter.test, marpa-lexer-9.2.x)
	#
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

    method registers {} {
	debug.marpa/semstore {}
	set result [dict keys $myscratch]
	debug.marpa/semstore {==> $result}
	return $result
    }

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
