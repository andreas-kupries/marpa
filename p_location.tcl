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

namespace eval marpa::location {
    namespace export merge
    namespace ensemble create
}

proc marpa::location::Show {x} {
    lassign $x s e str
    list $s $e '[char quote cstring $str]'
}

proc marpa::location::null {args} {
    debug.marpa/location {}
    return {{} {} {}}
}

proc marpa::location::merge {args} {
    debug.marpa/location {}
    foreach b [lassign $args a] {
	set a [marpa::location::merge2 $a $b]
    }
    return $a
}

proc marpa::location::merge2 {a b} {
    debug.marpa/location {}

    # Assume: a before b, adjacent.
    lassign $a as ae astr
    lassign $b bs be bstr

    set zs   [Min $as $bs]
    set ze   [Max $be $ae]
    set zstr $astr$bstr

    set z [list $zs $ze $zstr]
    debug.marpa/location {==> $z}
    return $z
}

proc marpa::location::Max {a b} {
    if {$a eq {}} { return $b }
    if {$b eq {}} { return $a }
    if {$a < $b}  { return $b }
    return $a
}

proc marpa::location::Min {a b} {
    if {$a eq {}} { return $b }
    if {$b eq {}} { return $a }
    if {$a < $b}  { return $a }
    return $b
}

# # ## ### ##### ######## #############
return
