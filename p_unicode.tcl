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
    namespace export norm 2utf 2asbr pretty-asbr data
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API
##
## - 2utf        - Convert unicode point to sequence of bytes
## - 2asbr       - Convert unicode class to utf8 asbr
## - pretty-asbr - Pretty print the result of 2asbr.
## - norm        - normalize a series of ranges and code points.

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

proc marpa::unicode::norm {items} {
    debug.marpa/unicode {}
    # Each item is either a code point, or a range The result is a
    # sorted list of minimal ranges and points covering the input.

    set items [lsort -unique $items]

    if {[llength $items] < 2} {
	return $items
    }
    # assert: llength $items >= 2
    foreach spec $items {
	if {[llength $spec] == 1} { 
	    lappend spec [lindex $spec 0]
	}
	lappend tmp $spec
    }
    set items $tmp

    set items [lsort -index 1 -integer $items]
    set items [lsort -index 0 -integer $items]
    set items [lassign $items previous]

    foreach current $items {
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

proc marpa::unicode::2asbr {items} {
    debug.marpa/unicode {}
    set c [u8class new]
    $c add-items $items
    set utf [$c get]
    $c destroy
    debug.marpa/unicode {==> ($utf)}
    return $utf
}

proc marpa::unicode::pretty-asbr {asbr {compact 0}} {
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
## - data cc ranges
## - data cc asbr
## - data cc grammar
## - data range
## - data fold
## - data fold/c

namespace eval marpa::unicode::data {
    namespace export cc range fold fold/c
    namespace ensemble create
    namespace import ::marpa::X
}
namespace eval marpa::unicode::data::cc {
    namespace export ranges asbr grammar
    namespace ensemble create
    namespace import ::marpa::X
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
    if {![dict exists $cc $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    return [dict get $asbr $cclass]
}

proc marpa::unicode::data::cc::grammar {cclass} {
    variable ::marpa::unicode::gr
    if {![dict exists $cc $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    return [dict get $gr $cclass]
}

proc marpa::unicode::data::range {id} {
    variable marpa::unicode::range
    # TODO: validate argument
    return [dict get $range $id]
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

oo::class create u8class {
    # A character class as a list of u8sequence's, each sequence an
    # alternative matching part of the class.

    variable myalternates
    variable mylast

    constructor {} {
	debug.marpa/unicode {}
	set myalternates {}
	set mylast       -1
	return
    }

    destructor {
	debug.marpa/unicode {}
	foreach alter $myalternates {
	    if {$alter eq "."} continue
	    $alter destroy
	}
	return
    }

    method get {} {
	debug.marpa/unicode {}
	set result {}
	foreach alter $myalternates {
	    if {$alter eq "."} continue
	    set resranges {}
	    foreach range [$alter get] {
		lappend resranges [$range get]
	    }
	    lappend result $resranges
	}
	debug.marpa/unicode {==> ($result)}
	return $result
    }

    method add-items {items} {
	debug.marpa/unicode {}
	foreach item [marpa unicode norm $items] {
	    lassign $item s e
	    if {$e eq {}} {
		# Add point
		my add $s
	    } else {
		# Expand and add range
		for {set code $s} {$code <= $e} {incr code} {
		    my add $code
		}
	    }
	}
	return
    }

    # add a single unicode point to the class.  Must be added in
    # lexicographic order for the merge system to work.
    method add {code} {
	debug.marpa/unicode {}
	# reject the addition of surrogate code points
	if {(0xD7FF < $code) && ($code < 0xE000)} {
	    debug.marpa/unicode {Reject surrogate codepoint $code}
	    return
	}

	if {$code > ($mylast+1)} {
	    # range gap - merge barrier
	    lappend myalternates .
	}
	set mylast $code
	# push new alternate
	lappend myalternates [u8sequence new [marpa unicode 2utf $code]]
	# reduce alternates by merging adjoint ones
	while {[my Merge]} {}
	return
    }

    # TODO: preload an entire utf class.

    method match {code} {
	debug.marpa/unicode {}
	set bytes [marpa unicode 2utf $code]
	foreach sequence $myalternates {
	    if {$sequence eq "."} continue
	    if {[$sequence match $bytes]} { return 1 }
	}
	return 0
    }

    method debug-match {code} {
	debug.marpa/unicode {}
	set bytes [marpa unicode 2utf $code]
	foreach sequence $myalternates {
	    if {$sequence eq "."} continue
	    incr matches [$sequence match $bytes]
	}
	if {$matches > 1} { return -code error "multi-match" }
	expr {$matches == 1}
    }

    method Merge {} {
	debug.marpa/unicode {}
	# Bail if nothing can be done
	if {[llength $myalternates] < 2} { return 0 }
	lassign [lrange $myalternates end-1 end] previous current
	# Prevent merging across a barrier
	if {$previous eq "."} { return 0 }
	if {![$previous merge $current]} { return 0 }
	$current destroy
	set myalternates [lreplace $myalternates end end]
	return 1
    }
}

# # ## ### ##### ######## #############
## Internals - Range sequences

oo::class create u8sequence {
    # sequence of u8range's
    variable myranges

    # make a sequence from ranges or bytes, or a mix thereof
    constructor {items} {
	debug.marpa/unicode {}
	foreach spec $items {
	    if {[llength $spec] == 1} {
		lappend spec [lindex $spec 0]
	    }
	    lappend myranges [u8range new {*}$spec]
	}
	return
    }

    destructor {
	debug.marpa/unicode {}
	foreach range $myranges { $range destroy }
	return
    }

    method match {bytes} {
	debug.marpa/unicode {}
	if {[llength $bytes] != [my len]} { return 0 }
	foreach range $myranges x $bytes {
	    if {![$range match $x]} { return 0 }
	}
	return 1
    }

    method get {} {
	debug.marpa/unicode {}
	return $myranges
    }

    method len {} {
	debug.marpa/unicode {}
	llength $myranges
    }

    method merge {s} {
	debug.marpa/unicode {}
	# Try to merge sequence s with self.

	# Reject length mismatches
	set n [llength $myranges]
	if {$n != [$s len]} { return 0 }

	# actual merging is length dependent.
	# unroll the loops, small enough

	# equal     (a,b) : a == b
	# upper-adj (a,b) : a # b

	switch -exact -- $n {
	    1 {
		lassign $myranges r
		lassign [$s get] sr
		# Merging allowed for
		# (a) r ## sr --> extend r

		if {[$r joint $sr]} {
		    $r extend $sr
		    return 1
		}
		return 0
	    }
	    2 {
		lassign $myranges r1  r2
		lassign [$s get] sr1 sr2

		# Merging allowed for
		# (a) sr1 == r1 && r2 ## sr2 -> extend r2
		# (b) r1 ## sr1 && r2 == sr2 -> extend r1

		if {[$r1 eq $sr1] && [$r2 joint $sr2]} {
		    $r2 extend $sr2
		    return 1
		}
		if {[$r1 joint $sr1] && [$r2 eq $sr2]} {
		    $r1 extend $sr1
		    return 1
		}
		return 0
	    }
	    3 {
		lassign $myranges r1  r2  r3
		lassign [$s get] sr1 sr2 sr3

		# Merging allowed for
		# (a) sr1 == r1 && sr2 == r2 && r3 ## sr3 -> extend r3
		# (b) sr1 == r1 && r2 ## sr2 && r3 == sr3 -> extend r2
		# (c) r1 ## sr1 && r2 == sr2 && r3 == sr3 -> extend r1

		if {[$r1 eq $sr1] && [$r2 eq $sr2] && [$r3 joint $sr3]} {
		    $r3 extend $sr3
		    return 1
		}
		if {[$r1 eq $sr1] && [$r2 joint $sr2] && [$r3 eq $sr3]} {
		    $r2 extend $sr2
		    return 1
		}
		if {[$r1 joint $sr1] && [$r2 eq $sr2] && [$r3 eq $sr3]} {
		    $r1 extend $sr1
		    return 1
		}
		return 0
	    }
	    4 {
		lassign $myranges r1  r2  r3  r4
		lassign [$s get] sr1 sr2 sr3 sr4

		# Merging allowed for
		# (a) sr1 == r1 && sr2 == r2 && sr3 == r3 && r4 ## sr4 -> extend r4
		# (b) sr1 == r1 && sr2 == r2 && r3 ## sr3 && r4 == sr4 -> extend r3
		# (c) sr1 == r1 && r2 ## sr2 && r3 == sr3 && r4 == sr4 -> extend r2
		# (d) r1 ## sr1 && r2 == sr2 && r3 == sr3 && r4 == sr4 -> extend r1

		if {[$r1 eq $sr1] && [$r2 eq $sr2] && [$r3 eq $sr3] && [$r4 joint $sr4]} {
		    $r4 extend $sr4
		    return 1
		}
		if {[$r1 eq $sr1] && [$r2 eq $sr2] && [$r3 joint $sr3] && [$r4 eq $sr4]} {
		    $r3 extend $sr3
		    return 1
		}
		if {[$r1 eq $sr1] && [$r2 joint $sr2] && [$r3 eq $sr3] && [$r4 eq $sr4]} {
		    $r2 extend $sr2
		    return 1
		}
		if {[$r1 joint $sr1] && [$r2 eq $sr2] && [$r3 eq $sr3] && [$r4 eq $sr4]} {
		    $r1 extend $sr1
		    return 1
		}
		return 0
	    }
	}
    }
}

# # ## ### ##### ######## #############
## Internals - Ranges

oo::class create u8range {
    # byte range
    variable mystart
    variable myend

    # make new
    constructor {s e} {
	debug.marpa/unicode {}
	if {$s > $e} {
	    set mystart $e
	    set myend   $s
	} else {
	    set mystart $s
	    set myend   $e
	}
	return
    }

    # check if byte is contained in the range
    method match {x} {
	debug.marpa/unicode {}
	set match [expr {($mystart <= $x) && ($x <= $myend)}]
	debug.marpa/unicode {==> ($match)}
	return $match
    }

    # check ranges for equality
    method eq {r} {
	debug.marpa/unicode {}
	lassign [$r get] s e
	expr {($s == $mystart) && ($e == $myend)}
    }

    # retrieve range data
    method get {} {
	debug.marpa/unicode {}
	list $mystart $myend
    }

    # check if argument is adjacent to upper border of self
    method joint {r} {
	debug.marpa/unicode {}
	lassign [$r get] s e
	expr {($myend + 1) == $s}
    }

    # extend self with range - proper only if r is joint
    method extend {r} {
	debug.marpa/unicode {}
	lassign [$r get] s e
	set myend $e
	return
    }
}

# # ## ### ##### ######## #############
return
