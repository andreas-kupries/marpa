# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Utilities to process locations and location ranges.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require char ;# quoting cstring - debugging narrative

debug define marpa/location
debug prefix marpa/location {[debug caller] | }

# # ## ### ##### ######## #############
## Support code for handling the semantic values (string + input range).
#
# location = tuple (start-offset, end-offset, string)
#
# * The range described by the offsets is inclusive.
#
# * The identity/null element for location merging is a tuple
#   containing the empty string and offsets.

namespace eval marpa {
    namespace export location
    namespace ensemble create
}
namespace eval marpa::location {
    namespace export merge merge2 show atom null null?
    namespace ensemble create
    namespace import ::marpa::X
}

proc marpa::location::show {x} {
    lassign $x s e str
    list $s $e '[char quote cstring $str]'
}

proc marpa::location::atom {pos ch} {
    debug.marpa/location {}
    return [list $pos $pos $ch]
    # assert: start <= end
}

proc marpa::location::null* {args} {
    debug.marpa/location {}
    return {{} {} {}}
}

proc marpa::location::null {} {
    debug.marpa/location {}
    return {{} {} {}}
}

proc marpa::location::null? {a} {
    debug.marpa/location {}
    lassign $a start end str
    expr {($start eq "") && ($end eq "") && ($str eq "")}
}

proc marpa::location::merge {a args} {
    debug.marpa/location {}
    foreach b $args {
	set a [marpa::location::merge2 $a $b]
    }
    return $a
}

proc marpa::location::merge2 {a b} {
    debug.marpa/location {}

    # Null's are special, adjacent to everything, and unity element
    if {[null? $a]} { return $b }
    if {[null? $b]} { return $a }
    # now: a, b not null

    # assert: as <= ae, bs <= be
    lassign $a as ae astr
    lassign $b bs be bstr

    # tets: a before b, adjacent.
    if {($ae + 1) != $bs} {
	X "Bad merge, non-adjacent locations" LOCATION MERGE NON-ADJACENT
    }

    # due: as <= ae < bs <= be
    # now: as < bs => as = Min (as, bs)
    # now: ae < be => be = Max (ae, be)

    set zs $as
    set ze $be
    set zstr $astr$bstr

    set z [list $zs $ze $zstr]
    debug.marpa/location {==> $z}
    return $z
}

# # ## ### ##### ######## #############
return
