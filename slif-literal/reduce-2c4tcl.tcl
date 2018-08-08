# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# See doc/atoms.md

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::reduce::2c4tcl 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Transform L0 literals into forms usable to
# Meta description the C runtime, using char coding suitable for use with Tcl
# Meta description i.e. MUTF-8, and CESU-8.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::unicode
# Meta require     marpa::util
# Meta require     marpa::slif::literal::util
# Meta subject     marpa literal transform reduction
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

debug define marpa/slif/literal/reduce/2c4tcl

# # ## ### ##### ######## #############
## Reducer callback
## - RTC, with interfaces to Tcl -- CESU-8, MUTF-8
## - Ensemble dispatch by literal type
#
## The callback can expect to be called only with normalized literals.

# # ## ### ##### ######## #############
## Public API

namespace eval ::marpa::slif::literal::reduce::2c4tcl {
    namespace export reduce symbol
        namespace ensemble create
}

namespace eval ::marpa::slif::literal::reduce::2c4tcl::reduce {
    namespace export %* ^* cc/* string charclass character range named-class byte brange
    namespace ensemble create

    namespace import ::marpa::X
    namespace import ::marpa::unicode::2utf
    namespace import ::marpa::unicode::2asbr
    namespace import ::marpa::unicode::negate-class
    namespace import ::marpa::unicode::data
    namespace import ::marpa::unicode::unfold
    namespace import ::marpa::unicode::max
    namespace import ::marpa::slif::literal::util::ccranges
}

# # ## ### ##### ######## #############
## Custom symbol name callbacks for the custom tags below

proc ::marpa::slif::literal::reduce::2c4tcl::symbol {state literal} {
    switch -exact -- [lindex $literal 0] {
	cc/c {
	    # The literal is effectively a charclass, generate a symbol from that.
	    return [marpa::slif::literal::util::symbol [lreplace $literal 0 0 charclass]]
	}
    }
    # Standard tag and symbol
    marpa::slif::literal::util::symbol $literal
}

# # ## ### ##### ######## #############
## Type-specific handlers.
## Custom tag `cc/c`.

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::cc/c {state args} {
    # args = codepoint|range|named-class ...
    # convergence point for all charclass related tags, i.e ranges and
    # named classes as well.
    # Note: CESU-8, MUTF-8
    set asbr [marpa unicode 2asbr [ccranges $args] tcl]

    # The simplest ASBR has one alternate, with only one element in
    # the sequence. That we can rewrite directly without a new
    # composite symbol.

    if {([llength $asbr] == 1) && ([llength [lindex $asbr 0]] == 1)} {
	# asbr has one alternate, having only one element in the
	# sequence. No need to inject a priority rule. We can rewrite
	# the main symbol.
	$state is-a! brange {*}[lindex $asbr 0 0]
    }
    $state rules [lmap rhs $asbr {
	lmap range $rhs {
	    lassign $range s e
	    if {$s == $e} {
		L byte $s
	    } else {
		L brange $s $e
	    }
	}
    }]
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::string {state args} {
    # args = codepoints.
    # convert to sequence of byte sequences, flatten, single alternative
    # 2utf - tcl = mutf-8, cesu-8

    $state rules*! [concat {*}[lmap codepoint $args {
	lmap byte [2utf $codepoint tcl] {
	    L byte $byte }
    }]]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::%string {state args} {
    # args = codepoints
    # convert into sequence of %character, to be reduced further, single alternative

    $state rules* [lmap codepoint $args { L %character $codepoint }]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::charclass {state args} {
    # args = codepoint|range|named-class ...
    # Pass to the main converter.

    $state is-a cc/c {*}$args
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::^charclass {state args} {
    # args = codepoint|range|named-class ...
    # Complement class, then normalize and reduce further

    $state is-a cc/c {*}[negate-class [ccranges $args]]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::character {state codepoint} {
    # A single character, may translate into multiple bytes
    # In case of single byte we rewrite the definition directly and
    # avoid a superfluous composite helper.

    set bytes [marpa unicode 2utf $codepoint tcl]
    if {[llength $bytes] == 1} {
	$state is-a! byte {*}$bytes
    }
    # single alternative, sequence of bytes
    $state rules*! [lmap byte $bytes { L byte $byte }]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::^character {state codepoint} {
    # A negated character is a class containing 2 ranges, before and after
    # the excluded character. This is then normalized and reduced further.

    if {$codepoint == 0} {
	$state is-a cc/c [R 1 [max]]
    } elseif {$codepoint == [max]} {
	set last [max] ; incr last -1
	$state is-a cc/c [R 0 $last]
    } else {
	set before $codepoint ; incr before -1
	set after  $codepoint ; incr after

	$state is-a cc/c [R 0 $before] [R $after [max]]
    }
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::range {state start end} {
    # an empty range is illegal
    if {$end <= $start} EmptyRange
    # Send this to the final reducer. No normalization.  Going through
    # charclass would normalize back to range and then bounce forever.

    $state is-a cc/c [R $start $end]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::%range {state start end} {
    # an empty range is illegal
    if {$end <= $start} EmptyRange
    # Unfold the character casing, then go through a charclass to
    # normalize and reduce further.

    $state is-a cc/c {*}[unfold [S [R $start $end]]]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::^range {state start end} {
    # an empty range is illegal
    if {($start <= 0) && ($end >= [marpa unicode max])} EmptyRange

    # A negated range is a charclass of 2 ranges, before and after.
    # The general case of ^character. Go through charclass for
    # normalization and further reduction.

    set pre  $start ; incr pre -1
    set post $end   ; incr post

    if {$pre >= 0}      { lappend cc [R 0 $pre] }
    if {$post <= [max]} { lappend cc [R $post [max]] }

    if {[llength $cc] > 1} {
	$state is-a cc/c {*}$cc
    } else {
	set range [lindex $cc 0]
	if {[llength $range] == 1} {
	    $state is-a character [lindex $range 0]
	} else {
	    $state is-a cc/c $range
	}
    }
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::named-class {state name} {
    # Named class, pull the codepoint ranges and treat as explicit
    # character class.

    $state is-a cc/c $name
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::%named-class {state name} {
    # See named-class, plus case-unfolding

    $state is-a cc/c %$name
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::^named-class {state name} {
    # See named class, negate before sending it on.

    $state is-a cc/c {*}[negate-class [data cc ranges $name]]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::^%named-class {state name} {
    # See named-class. case-unfold and negate before sending it on.

    $state is-a cc/c {*}[negate-class [unfold [data cc ranges $name]]]
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::byte {state byte} {
    # Smallest unit for the RT-C, reduction ends.
    $state keep
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::brange {state start end} {
    # Smallest unit for the RT-C, reduction ends.
    $state keep
}

# # ## ### ##### ######## #############
## Internal utilities

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::EmptyRange {} {
    upvar 1 start start end end
    X "Unable to reduce empty literal (range ($start $end))" \
	SLIF LITERAL EMPTY
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::L {args} {
    return $args
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::R {start end} {
    # Nicer name for R'ange construction
    if {$end < $start} EmptyRange
    if {$start == $end} { return $start }
    list $start $end
}

proc ::marpa::slif::literal::reduce::2c4tcl::reduce::S {args} {
    # Nicer name for S'equence construction
    return $args
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::reduce::2c4tcl 0
return
