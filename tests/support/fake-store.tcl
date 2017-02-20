# -*- tcl -*-
##
# (c) 2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

package require TclOO

# Test suite support.
# # ## ### ##### ######## #############
## Fake semantic stores

proc fake-store  {} { global __store ; set __store [Marpa::Testing::S new] }
proc stored      {} { global __store ; $__store destroy ; unset __store }

# # ## ### ##### ######## #############
## Fake Store Engine.

oo::class create Marpa::Testing::S {
    variable acc
    variable sv
    constructor {} { set acc 0 ; set sv {} }
    method put {data} {
	incr acc
	# Never return 0 as an id for semantic values.
	# More information in p_semstore.tcl, method put.
	dict set sv $acc $data
	return $acc
    }
    method get {id} {
	dict get $sv $id
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
