# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# Normalization (Simplifications without breaking the literal into many)
# See doc/atoms.md
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::norm 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Simplify literals without breaking
# Meta description it apart into many.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::unicode
# Meta require     marpa::util
# Meta require     marpa::slif::literal::util
# Meta subject     marpa literal transform simplify normalize
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

# Unicode tables, classes, operations.
package require marpa::unicode
package require marpa::util
package require marpa::slif::literal::util

debug define marpa/slif/literal/norm

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export norm
    namespace ensemble create
}

namespace eval ::marpa::slif::literal::norm {
    namespace import ::marpa::X
    namespace import ::marpa::slif::literal::util::*
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::norm {literal} {
    norm::DO $literal
}

# # ## ### ##### ######## #############
## Internals

proc ::marpa::slif::literal::norm::DO {_literal} {
    debug.marpa/slif/literal/norm {}
    variable continue
    variable type
    variable details
    Init $_literal
    while {$continue} {
	if {![KnownType]} Fail
	#puts <<[linsert $details 0 $type]>>
	$type {*}$details
	# Recurse (tailcall -> loop)
    }
    return [Result]
}

# # ## ### ##### ######## #############
## Transformations by literal type.

proc ::marpa::slif::literal::norm::string {args} {
    if {[Single]} {
	IsA character ;# N01
    } else Stop ;# N02
}

proc ::marpa::slif::literal::norm::%string {args} {
    if {[Single]} {
	IsA %character ;# N03
    } else Stop ;# N03
}

proc ::marpa::slif::literal::norm::charclass {args} {
    if {[Single]} {
	set elt [lindex $args 0]
	IsA [eltype $elt] ;# N05, N06, N07
	Of  $elt
    } else Stop ;# N08
}

proc ::marpa::slif::literal::norm::%charclass {args} {
    if {[Single]} {
	set elt [lindex $args 0]
	IsA %[eltype $elt] ;# N09, N10, N11
	Of  $elt
    } else {
	IsA charclass ;# N12
	Of  [ccunfold $args]
    }
}

proc ::marpa::slif::literal::norm::^charclass {args} {
    if {[Single]} {
	set elt [lindex $args 0]
	IsA ^[eltype $elt] ;# N13, N14, N15
	Of  $elt
    } else Stop ;# N16
}

proc ::marpa::slif::literal::norm::^%charclass {args} {
    if {[Single]} {
	set elt [lindex $args 0]
	IsA ^%[eltype $elt] ;# N17, N18, N19
	Of  $elt
    } else {
	IsA ^charclass ;# N20
	Of  [ccunfold $args]
    }
}

proc ::marpa::slif::literal::norm::character {args} {
    Stop ;# N21
}

proc ::marpa::slif::literal::norm::%character {codepoint} {
    IsA charclass ;# N22
    Of  [marpa unicode data fold $codepoint]
}

proc ::marpa::slif::literal::norm::^character {args} {
    Stop ;# N23
}

proc ::marpa::slif::literal::norm::^%character {codepoint} {
    IsA ^charclass ;# N24
    Of  [marpa unicode data fold $codepoint]
}

proc ::marpa::slif::literal::norm::range {s e} {
    if {$s == $e} {
	IsA character ;# N25
	Of  $s
    } else Stop ;# N26
}

proc ::marpa::slif::literal::norm::%range {args} {
    IsA charclass ;# N28
    Of  [marpa unicode unfold [list $args]]
}

proc ::marpa::slif::literal::norm::^range {s e} {
    Stop ;# N29
}

proc ::marpa::slif::literal::norm::^%range {args} {
    IsA ^charclass ;# N30
    Of  [marpa unicode unfold [list $args]]
}

proc ::marpa::slif::literal::norm::named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA %named-class ;# N32
	    Of  [string range $ccname 1 end]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::%named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA %named-class ;# N36
	    Of  [string range $ccname 1 end]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::^named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA ^%named-class ;# N40
	    Of  [string range $ccname 1 end]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::^%named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA ^%named-class ;# N44
	    Of  [string range $ccname 1 end]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::byte {args} {
    Stop
}

proc ::marpa::slif::literal::norm::brange {args} {
    Stop
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::norm::Init {_literal} {
    debug.marpa/slif/literal/norm {}
    variable literal $_literal
    variable type
    variable details [lassign $literal type]
    variable continue 1
    return
}

proc ::marpa::slif::literal::norm::Result {} {
    debug.marpa/slif/literal/norm {}
    variable type
    variable details
    return [linsert $details 0 $type]
}

proc ::marpa::slif::literal::norm::Fail {} {
    debug.marpa/slif/literal/norm {}
    variable continue 0
    variable type
    variable details
    X "Unable to normalize type ($type ($details))" \
	SLIF LITERAL INTERNAL
}

proc ::marpa::slif::literal::norm::KnownType {} {
    variable type
    llength [info commands ::marpa::slif::literal::norm::$type]
}

proc ::marpa::slif::literal::norm::Single {} {
    variable details
    expr {[llength $details] == 1}
}

proc ::marpa::slif::literal::norm::IsA {new args} {
    debug.marpa/slif/literal/norm {}
    variable type $new
    variable continue 1
    return
}

proc ::marpa::slif::literal::norm::Of {_details} {
    debug.marpa/slif/literal/norm {}
    variable details $_details
    variable continue 1
    return
}

proc ::marpa::slif::literal::norm::Stop {} {
    debug.marpa/slif/literal/norm {}
    variable continue 0
    return
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::norm 0
return
