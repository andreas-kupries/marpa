# -*- tcl -*-
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Semantics, standard functionality for actions.

## See also the methods "CompleteParts" in marpa::lexer and
## marpa::parser. This is where some of the parts get their detail
## information from.

## FUTURE: Consider 'compiling' the builtin into partially evaluated
## code, i.e. specialized to the parts + detail information. More
## code, custom action per rule, however also no interpretation of the
## parts list, i.e. small speed boost. Issue would be where to store
## these dynamic procedures, must be grammar-specific as the procs are
## that.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1
package require oo::util      ;# link

debug define marpa/semstd
debug prefix marpa/semstd {} ;# eval takes large argument, keep out.

# # ## ### ##### ######## #############

namespace eval marpa {
    namespace export semstd
    namespace ensemble create
}
namespace eval marpa::semstd {
    namespace export {[a-z]*}
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Support procedures implementing various standard semantics

proc marpa::semstd::nop {args} {
    debug.marpa/semstd {}
    return {}
}

proc marpa::semstd::K {x args} {
    debug.marpa/semstd {}
    return $x
}

proc marpa::semstd::locmerge {id args} {
    debug.marpa/semstd {}
    marpa location merge {*}$args
}

proc marpa::semstd::builtin {parts id args} {
    debug.marpa/semstd {}

    set result {}
    foreach item $parts {
	lassign $item part detail

	# Compute range if needed, once.
	switch -exact -- $part {
	    start  -
	    end    -
	    value  -
	    length {
		if {![info exists range]} {
		    set range [marpa::location merge {*}$args]
		}
	    }
	}

	# Assemble parts ...
	switch -exact -- $part {
	    Afirst   { lappend result [lindex $args 0] }
	    g1start  {}
	    g1length { lappend result 1 }
	    values   { lappend result $args }
	    start    { lappend result [lindex $range 0] }
	    end      { lappend result [lindex $range 1] }
	    value    { lappend result [lindex $range 2] }
	    length   {
		lassign $range s e
		lappend result [expr {$e - $s + 1}]
	    }
	    rule   { lappend result $id }
	    ord    -
	    name   -
	    symbol -
	    lhs    { lappend result $detail }
	    default {
		return -code error \
		    -errorcode [list MARPA SEMSTD PART $part] \
		    "Unsupported part \"$part\", expected one of g1start, g1length, values, start, end, value, length, rule, name, symbol, ord, or lhs"
	    }
	}
    }

    if {[llength $parts] == 1} {
	return [lindex $result 0]
    } else {
	return $result
    }
}

# # ## ### ##### ######## #############
return
