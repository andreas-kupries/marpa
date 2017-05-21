# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Utilities to handle conversion of unicode classes into utf-8
# ASBRs. On the unicode side a class can be represented as a list of
# codepoints, or as a list of codepoint ranges.  On the utf-8 side the
# same class is represented as a list of alternatives, with each
# alternative a sequence of byte-ranges, and each byte-range given by
# start- and end-value, inclusive. Hence ASBR, for "Alternatives of
# Sequences of Byte-Ranges".

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller

debug define marpa/unicode
debug prefix marpa/unicode {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval marpa {
    namespace export unicode
    namespace ensemble create
}
namespace eval marpa::unicode {
    namespace export norm-class negate-class point unfold fold/c 2utf 2asbr asbr-format data mode max
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API
##
## - 2utf         - Convert uni(code)point to sequence of bytes
## - 2asbr        - Convert unicode class to utf8 asbr
## - asbr-format  - Convert the result of 2asbr into a human-readable form.
## - norm-class   - normalize a series of ranges and code points (i.e. a
##                  char class).
## - negate-class - Negate a series of ranges and code points (i.e. a
##                  char class). I.e. compute the complement over the
##                  unicode range.
## - point        - Convert Tcl character to uni(code)point
## - unfold       - Convert a set of uni(code)points to a set containing all
##                  case-equivalent uni(code)points
## - fold/c       - Convert a list of uni(code)points to a list of the primary
##                  case-equivalent uni(code)points.
## - mode, max    - Return name of supported unicode range, and the number of
##                  codepoints in that range

proc marpa::unicode::mode {} {
    debug.marpa/unicode {}
    variable mode
    return $mode
}

proc marpa::unicode::max {} {
    debug.marpa/unicode {}
    variable max
    return $max
}

proc marpa::unicode::2utf {code} {
    debug.marpa/unicode {}
    if {$code < 128} {
	return [list [expr {$code & 0x7f}]]
	# The expression does not change the value. It does normalize
	# the string representation to decimal however. As that
	# happens in all the fllowing branches as well having it
	# happen here makes things cleaner, more the same.
    }
    if {$code < 2048} {
	set a [expr {(($code >> 6) & 0x1f) | 0b11000000 }]
	set b [expr {(($code >> 0) & 0x3f) | 0b10000000 }]
	debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b])}
	return [list $a $b]
    }
    if {$code < 65536} {
	set a [expr {(($code >> 12) & 0x0f) | 0b11100000 }]
	set b [expr {(($code >>  6) & 0x3f) | 0b10000000 }]
	set c [expr {(($code >>  0) & 0x3f) | 0b10000000 }]
	debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b] 0x[format %02x $c])}
	return [list $a $b $c]
    }

    set a [expr {(($code >> 18) & 0x07) | 0b11110000 }]
    set b [expr {(($code >> 12) & 0x3f) | 0b10000000 }]
    set c [expr {(($code >>  6) & 0x3f) | 0b10000000 }]
    set d [expr {(($code >>  0) & 0x3f) | 0b10000000 }]
    debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b] 0x[format %02x $c] 0x[format %02x $d])}
    return [list $a $b $c $d]
}

proc marpa::unicode::norm-class {charclass} {
    debug.marpa/unicode {}
    # Each item is either a code point, or a range (specified by a
    # pair of codepoints, low and high borders, inclusive). The result
    # is a sorted list of minimal ranges and points covering the
    # input.

    set charclass [lsort -dict -unique $charclass]

    if {[llength $charclass] < 2} {
	return $charclass
    }
    # assert: llength $charclass >= 2
    foreach spec $charclass {
	if {[llength $spec] == 1} {
	    lappend spec [lindex $spec 0]
	}
	lappend tmp $spec
    }
    set charclass $tmp

    set charclass [lsort -index 1 -integer $charclass]
    set charclass [lsort -index 0 -integer $charclass]
    set charclass [lassign $charclass previous]

    foreach current $charclass {
	lassign $previous ps pe
	lassign $current  cs ce

	if {($ps <= $cs) && ($ce <= $pe)} {
	    # previous contains current, next
	    continue
	}
	if {($cs <= $ps) && ($pe <= $ce)} {
	    # current contains previous, replace
	    set previous current
	    continue
	}
	if {($ps <= $cs) && ($cs <= ($pe+1))} {
	    # current extends previous or is adjacent, extend
	    lset previous 1 $ce
	    continue
	}
	if {($cs <= $ps) && ($ps <= ($ce+1))} {
	    # previous extends current or is adjacent, extend
	    lset previous 0 $cs
	    continue
	}

	# No merge, save previous and use current as next candidate
	NA $previous
	set previous $current
    }

    NA $previous
    return $result
}

proc marpa::unicode::NA {range} {
    upvar 1 result result
    lassign $range s e
    if {$s == $e} {
	lappend result $s
    } else {
	lappend result $range
    }
    return
}

proc marpa::unicode::point {character} {
    debug.marpa/unicode {}
    # Convert first character if we got a string.
    scan [lindex [split $character {}] 0] %c codepoint
    return $codepoint
}

proc marpa::unicode::fold/c {codes} {
    debug.marpa/unicode {}
    lmap codepoint $codes { data fold/c $codepoint }
}

proc ::marpa::unicode::negate-class {charclass} {
    debug.marpa/slif/literal {}
    set charclass [norm-class $charclass]

    # Basic algorithm, predicated on codes normalized (sorted in
    # ascending order, without overlaps between elements):
    ##
    # Maintain a covering range (cmin, cmax) not processed yet.
    # For each code/range CR in the input
    # - cmin == min(CR) => CR is at the beginning of cover, negation is empty
    # - else (cmin <)   => The range from start of cover to CR is part of the negation.
    #                      output: (cmin ... min(CR)-1)
    # Always move forward, i.e. reduce cover to start after CR.
    #                      cmin := 1+ max(CR)
    # After the iteration check if the codes leave us a range at the end:
    # cmin < cmax ==> output: (cmin ... cmax)

    set cmin 0
    set cmax [max]

    set result {}
    foreach el $charclass {
	if {[llength $el] == 1} {
	    set min [set max $el]
	} else {
	    lassign $el min max
	}
	if {$min > $cmin} {
	    NA [list $cmin [incr min -1]]
	}
	set cmin [incr max]
    }

    if {$cmin < $cmax} {
	NA [list $cmin $cmax]
    }

    # Note how the result is normalized by construction, i.e. elements
    # are in ascending order, and do not overlap.

    return $result
}

proc marpa::unicode::unfold {codes} {
    debug.marpa/unicode {}
    set result {}
    foreach el $codes {
	if {[llength $el] == 1} {
	    lappend result {*}[data fold $el]
	} else {
	    lassign $el s e
	    for {} {$s <= $e} {incr s} {
		lappend result {*}[data fold $s]
	    }
	}
    }
    norm-class $result
}

proc marpa::unicode::2asbr {charclass} {
    debug.marpa/unicode {}
    u8c mk
    u8c add-cc $charclass
    set utf [u8c get]
    debug.marpa/unicode {==> ($utf)}
    return $utf
}

proc marpa::unicode::asbr-format {asbr {compact 0}} {
    debug.marpa/unicode {}
    set r {}
    set prefix " "
    foreach alternative $asbr {
	append r $prefix
	foreach range $alternative {
	    lassign $range s e
	    append r \[
	    append r [format %02x $s]
	    if {$s != $e} {
		append r - [format %02x $e] \]
	    } elseif {$compact} {
		append r \]
	    } else {
		append r \] {   }
	    }
	}
	append r \n
	set prefix |
    }
    return $r
}

# # ## ### ##### ######## #############
## Public API -- Access to the tables in "p_unidata.tcl"
##
## - data cc have
## - data cc have-tcl
## - data cc tcl-names
## - data cc names
## - data cc ranges
## - data cc asbr
## - data cc grammar
## - data range
## - data fold
## - data fold/c

namespace eval marpa::unicode::data {
    namespace export cc fold fold/c
    namespace ensemble create
    namespace import ::marpa::X
    namespace import ::marpa::unicode::norm-class
}
namespace eval marpa::unicode::data::cc {
    namespace export ranges asbr grammar names tcl-names have have-tcl
    namespace ensemble create
    namespace import ::marpa::X
}

proc marpa::unicode::data::cc::have-tcl {cclass} {
    return [dict exists {
	alnum . alpha . blank . cntrl  .
	digit . graph . lower . print  .
	punct . space . upper . xdigit .
    } $cclass]
}

proc marpa::unicode::data::cc::tcl-names {} {
    return {
	alnum alpha blank cntrl
	digit graph lower print
	punct space upper xdigit
    }
}

proc marpa::unicode::data::cc::have {cclass} {
    variable ::marpa::unicode::cc
    return [dict exists $cc $cclass]
}

proc marpa::unicode::data::cc::names {} {
    variable ::marpa::unicode::cc
    return [dict keys $cc]
}

proc marpa::unicode::data::cc::ranges {cclass} {
    variable ::marpa::unicode::cc
    if {![dict exists $cc $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    return [dict get $cc $cclass]
}

proc marpa::unicode::data::cc::asbr {cclass} {
    variable ::marpa::unicode::asbr
    variable ::marpa::unicode::range
    if {![dict exists $asbr $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    # asbr  :: list (alt)
    # alt   :: list (range)
    # range :: string ~ "R[0-9]+"

    # Decode range references into actuals
    return [lmap alternate [dict get $asbr $cclass] {
	lmap rangeid $alternate {
	    dict get $range $rangeid
	}
    }]
}

proc marpa::unicode::data::cc::grammar {cclass {base {}}} {
    variable ::marpa::unicode::gr
    variable ::marpa::unicode::range
    if {![dict exists $gr $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    # gr   :: list (rule)
    # rule :: list (sym := range|sym...)

    # Decode range references into actuals, and make them easily
    # distinguishable from symbols. Prefix symbols with the chosen
    # base (for uniqueness in the caller's context (if needed))
    set cbase $base
    if {$base ne {}} { set cbase ${base}: }

    return [lmap rule [dict get $gr $cclass] {
	set sequence [lassign $rule sym _]
	if {$sym eq {}} {
	    set sym $base
	} else {
	    set sym $cbase$sym
	}
	list $sym := {*}[lmap el $sequence {
	    switch -glob -- $el {
		R* { linsert [dict get $range $el] 0 range }
		A* { list symbol $cbase$el }
	    }
	}]
    }]
}

proc marpa::unicode::data::fold {codepoint} {
    variable ::marpa::unicode::foldmap
    variable ::marpa::unicode::foldset
    # normalize codepoint to decimal integer
    incr codepoint 0
    if {![dict exists $foldmap $codepoint]} {
	# Return character as its own fold class
	return [list $codepoint]
    }
    return [dict get $foldset [dict get $foldmap $codepoint]]
}

proc marpa::unicode::data::fold/c {codepoint} {
    # Locate the smallest entry in the fold set as the canonical form
    # of the codepoint under folding.
    return [lindex [fold $codepoint] 0]
}

# # ## ### ##### ######## #############
## Internals - Char class state
## ASBR compiler - Charclass to alternation of sequences of byte ranges
#
# A character class as a list of u8sequence's, each sequence an
# alternative matching part of the class.

namespace eval marpa::unicode::u8c {
    namespace export mk get add-cc add match debug-match
    namespace ensemble create
}

proc marpa::unicode::u8c::mk {} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates __last __last
    set __alternates {}
    set __last       -1
    return
}

proc marpa::unicode::u8c::get {} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates
    set result {}
    foreach alter $__alternates {
	if {$alter eq "."} continue
	lappend result $alter ;#$resranges
    }
    debug.marpa/unicode {==> ($result)}
    return $result
}

proc marpa::unicode::u8c::add-cc {charclass} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates __last __last
    foreach item [marpa unicode norm-class $charclass] {
	lassign $item s e
	if {$e eq {}} {
	    # Add point
	    add $s
	} else {
	    # Expand and add range
	    for {set code $s} {$code <= $e} {incr code} {
		add $code
	    }
	}
    }
    return
}

proc marpa::unicode::u8c::add {code} {
    # add a single uni(code)point to the class.  Must be added in
    # lexicographic order for the merge system to work.
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates __last __last
    # reject the addition of surrogate code points
    if {(0xD7FF < $code) && ($code < 0xE000)} {
	debug.marpa/unicode {Reject surrogate codepoint $code}
	return
    }

    if {$code > ($__last+1)} {
	# range gap - merge barrier - current top is final
	lappend __alternates .
    }
    set __last $code
    # push new alternate
    lappend __alternates [s-mk [marpa unicode 2utf $code]]
    # reduce alternates by merging adjoint ones
    while {[Merge]} {}
    return
}

proc marpa::unicode::u8c::match {code} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates
    set bytes [marpa unicode 2utf $code]
    foreach sequence $__alternates {
	if {$sequence eq "."} continue
	if {[s-match $sequence $bytes]} { return 1 }
    }
    return 0
}

proc marpa::unicode::u8c::debug-match {code} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates
    set bytes [marpa unicode 2utf $code]
    foreach sequence $__alternates {
	if {$sequence eq "."} continue
	incr matches [s-match $sequence $bytes]
    }
    if {$matches > 1} { return -code error "multi-match" }
    expr {$matches == 1}
}

proc marpa::unicode::u8c::Merge {} {
    debug.marpa/unicode {}
    upvar 1 __alternates __alternates
    # Bail if nothing can be done
    if {[llength $__alternates] < 2} { return 0 }
    lassign [lrange $__alternates end-1 end] previous current
    # Prevent merging across a barrier
    if {$previous eq "."} { return 0 }
    # Attempt merge
    if {![s-merge previous $current]} { return 0 }
    # and on success replace NXT,TOS with result.
    set __alternates [lreplace [K $__alternates [unset __alternates]] end-1 end $previous]
    return 1
}

proc marpa::unicode::u8c::K {x y} { set x }

# # ## ### ##### ######## #############
## Internals - Range sequences
## - Support for alternation of such (following, ASBR "compiler")
#
## sequence :: list (range)
## range    :: See following section

proc marpa::unicode::u8c::s-mk {items} {
    debug.marpa/unicode {}
    set sequence {}
    foreach spec $items {
	#if {[llength $spec] == 1} {}
	lappend spec [lindex $spec 0]
	lappend sequence [r-mk {*}$spec]
    }
    return $sequence
}

proc marpa::unicode::u8c::s-match {sequence bytes} {
    debug.marpa/unicode {}
    if {[llength $bytes] != [llength $sequence]} { return 0 }
    foreach range $sequence x $bytes {
	if {![r-match $range $x]} { return 0 }
    }
    return 1
}

proc marpa::unicode::u8c::s-merge {sv s} {
    debug.marpa/unicode {}
    upvar 1 $sv sequence

    # Reject length mismatches
    set n [llength $sequence]
    if {$n != [llength $s]} { return 0 }

    # actual merging is length dependent.
    # unroll the loops, small enough

    # equal     (a,b) : a == b
    # upper-adj (a,b) : a ## b

    switch -exact -- $n {
	1 {
	    lassign $sequence r
	    lassign $s sr
	    # Merging allowed for
	    # (a) r ## sr --> extend r

	    if {[r-adjacent $r $sr]} {
		lset sequence 0 [r-extend $r $sr]
		return 1
	    }
	    return 0
	}
	2 {
	    lassign $sequence r1  r2
	    lassign $s sr1 sr2

	    # Merging allowed for
	    # (a) sr1 == r1 && r2 ## sr2 -> extend r2
	    # (b) r1 ## sr1 && r2 == sr2 -> extend r1

	    if {[r-eq $r1 $sr1] && [r-adjacent $r2 $sr2]} {
		lset sequence 1 [r-extend $r2 $sr2]
		return 1
	    }
	    if {[r-adjacent $r1 $sr1] && [r-eq $r2 $sr2]} {
		lset sequence 0 [r-extend $r1 $sr1]
		return 1
	    }
	    return 0
	}
	3 {
	    lassign $sequence r1  r2  r3
	    lassign $s sr1 sr2 sr3

	    # Merging allowed for
	    # (a) sr1 == r1 && sr2 == r2 && r3 ## sr3 -> extend r3
	    # (b) sr1 == r1 && r2 ## sr2 && r3 == sr3 -> extend r2
	    # (c) r1 ## sr1 && r2 == sr2 && r3 == sr3 -> extend r1

	    if {[r-eq $r1 $sr1] && [r-eq $r2 $sr2] && [r-adjacent $r3 $sr3]} {
		lset sequence 2 [r-extend $r3 $sr3]
		return 1
	    }
	    if {[r-eq $r1 $sr1] && [r-adjacent $r2 $sr2] && [r-eq $r3 $sr3]} {
		lset sequence 1 [r-extend $r2 $sr2]
		return 1
	    }
	    if {[r-adjacent $r1 $sr1] && [r-eq $r2 $sr2] && [r-eq $r3 $sr3]} {
		lset sequence 0 [r-extend $r1 $sr1]
		return 1
	    }
	    return 0
	}
	4 {
	    lassign $sequence r1  r2  r3  r4
	    lassign $s sr1 sr2 sr3 sr4

	    # Merging allowed for
	    # (a) sr1 == r1 && sr2 == r2 && sr3 == r3 && r4 ## sr4 -> extend r4
	    # (b) sr1 == r1 && sr2 == r2 && r3 ## sr3 && r4 == sr4 -> extend r3
	    # (c) sr1 == r1 && r2 ## sr2 && r3 == sr3 && r4 == sr4 -> extend r2
	    # (d) r1 ## sr1 && r2 == sr2 && r3 == sr3 && r4 == sr4 -> extend r1

	    if {[r-eq $r1 $sr1] && [r-eq $r2 $sr2] && [r-eq $r3 $sr3] && [r-adjacent $r4 $sr4]} {
		lset sequence 3 [r-extend $r4 $sr4]
		return 1
	    }
	    if {[r-eq $r1 $sr1] && [r-eq $r2 $sr2] && [r-adjacent $r3 $sr3] && [r-eq $r4 $sr4]} {
		lset sequence 2 [r-extend $r3 $sr3]
		return 1
	    }
	    if {[r-eq $r1 $sr1] && [r-adjacent $r2 $sr2] && [r-eq $r3 $sr3] && [r-eq $r4 $sr4]} {
		lset sequence 1 [r-extend $r2 $sr2]
		return 1
	    }
	    if {[r-adjacent $r1 $sr1] && [r-eq $r2 $sr2] && [r-eq $r3 $sr3] && [r-eq $r4 $sr4]} {
		lset sequence 0 [r-extend $r1 $sr1]
		return 1
	    }
	    return 0
	}
    }
}

# # ## ### ##### ######## #############
## Internals - Byte Ranges
## - Support for Sequences of such (previous section)
#
## range :: pair (start end)
## start :: int
## end   :: int
## constraint: start <= end
## range is inclusive limits.

proc marpa::unicode::u8c::r-mk {s e} {
    debug.marpa/unicode {}
    if {$s > $e} { error "Bad order" }
    list $s $e
}

# check if byte is contained in the range
proc marpa::unicode::u8c::r-match {r x} {
    debug.marpa/unicode {}
    lassign $r s e
    set match [expr {($s <= $x) && ($x <= $e)}]
    debug.marpa/unicode {==> ($match)}
    return $match
}

# check two ranges for equality
proc marpa::unicode::u8c::r-eq {a b} {
    debug.marpa/unicode {}
    lassign $a as ae
    lassign $b bs be
    expr {($as == $bs) && ($ae == $be)}
}

# check if rb is adjacent to the upper border of r
proc marpa::unicode::u8c::r-adjacent {r rb} {
    debug.marpa/unicode {}
    expr {([lindex $r 1] + 1) == [lindex $rb 0]}
}

# extend r with rb and return result - proper only if rb is adjacent to r
proc marpa::unicode::u8c::r-extend {r rb} {
    debug.marpa/unicode {}
    list [lindex $r 0] [lindex $rb 1]
}

# # ## ### ##### ######## #############
return
