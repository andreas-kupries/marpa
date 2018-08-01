# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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
	# Unknown tags are passed as-is. This allows reducers to use
	# custom tags to control chains of reductions.
	if {![KnownType]} break
	#puts <<[linsert $details 0 $type]>>
	$type {*}$details
	# Recurse (tailcall -> loop)
    }
    return [Result]
}

# # ## ### ##### ######## #############
## Transformations by literal type.
## Attention
## - The local `string` shadows the global builtin.

proc ::marpa::slif::literal::norm::string {c args} {
    if {[Single]} {
	IsA character ;# N01
    } else Stop ;# N02
}

proc ::marpa::slif::literal::norm::%string {c args} {
    if {[Single]} {
	IsA %character ;# N03
    } else Stop ;# N03
    # TODO XXX: If all elements of the string have no case folding
    # TODO XXX: then we can go to plain `string`.
}

proc ::marpa::slif::literal::norm::charclass {elt args} {
    if {[Single]} {
	IsA [eltype $elt] ;# N05, N06, N07
	Of  $elt
    } else {
	Of [ccnorm [linsert $args 0 $elt]]
	if {![Single]} Stop ; #N08
	# Single -> iterate, return to above.
    }
}

proc ::marpa::slif::literal::norm::%charclass {elt args} {
    if {[Single]} {
	IsA %[eltype $elt] ;# N09, N10, N11
	Of  $elt
    } else {
	IsA charclass ;# N12
	Of  [ccunfold [linsert $args 0 $elt]]
    }
}

proc ::marpa::slif::literal::norm::^charclass {elt args} {
    if {[Single]} {
	IsA ^[eltype $elt] ;# N13, N14, N15
	Of  $elt
    } else {
	Of [ccnorm [linsert $args 0 $elt]]
	if {![Single]} Stop ; #N16
	# Single -> iterate, return to above.
    }
}

proc ::marpa::slif::literal::norm::^%charclass {elt args} {
    if {[Single]} {
	IsA ^%[eltype $elt] ;# N17, N18, N19
	Of  $elt
    } else {
	IsA ^charclass ;# N20
	Of  [ccunfold [linsert $args 0 $elt]]
    }
}

proc ::marpa::slif::literal::norm::character {codepoint} {
    Stop ;# N21
}

proc ::marpa::slif::literal::norm::%character {codepoint} {
    IsA charclass ;# N22
    Of  [marpa unicode data fold $codepoint]
}

proc ::marpa::slif::literal::norm::^character {codepoint} {
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

proc ::marpa::slif::literal::norm::%range {s e} {
    IsA charclass ;# N28
    Of  [marpa unicode unfold [C [R $s $e]]]
}

proc ::marpa::slif::literal::norm::^range {s e} {
    Stop ;# N29
}

proc ::marpa::slif::literal::norm::^%range {s e} {
    IsA ^charclass ;# N30
    Of  [marpa unicode unfold [C [R $s $e]]]
}

proc ::marpa::slif::literal::norm::named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA %named-class ;# N32
	    Of  [StringTail $ccname]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::%named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA %named-class ;# N36
	    Of  [StringTail $ccname]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::^named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA ^%named-class ;# N40
	    Of  [StringTail $ccname]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::^%named-class {ccname} {
    switch -glob -- $ccname {
	^*  Fail
	%*  {
	    IsA ^%named-class ;# N44
	    Of  [StringTail $ccname]
	}
	*   Stop
    }
}

proc ::marpa::slif::literal::norm::byte {b} {
    Stop
}

proc ::marpa::slif::literal::norm::brange {s e} {
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

proc ::marpa::slif::literal::norm::StringTail {str} {
    debug.marpa/slif/literal/norm {}
    ::string range $str 1 end
}

proc ::marpa::slif::literal::norm::C {args} {
    debug.marpa/slif/literal/norm {}
    return $args
}

proc ::marpa::slif::literal::norm::R {s e} {
    debug.marpa/slif/literal/norm {}
    list $s $e
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::norm 0
return
