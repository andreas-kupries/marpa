# -*- tcl -*-
# Pure Tcl charclass operations
# - normalization,
# - negation,
#
# Copyright 2017-2018 Andreas Kupries

proc norm-class {charclass} {
    # debug.marpa/unicode {}
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

proc negate-class {charclass} {
    # debug.marpa/slif/literal {}
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

proc NA {range} {
    upvar 1 result result
    lassign $range s e
    if {$s == $e} {
	lappend result $s
    } else {
	lappend result $range
    }
    return
}

proc 2utf {code} {
    # debug.marpa/unicode {}
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
	# debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b])}
	return [list $a $b]
    }
    if {$code < 65536} {
	set a [expr {(($code >> 12) & 0x0f) | 0b11100000 }]
	set b [expr {(($code >>  6) & 0x3f) | 0b10000000 }]
	set c [expr {(($code >>  0) & 0x3f) | 0b10000000 }]
	# debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b] 0x[format %02x $c])}
	return [list $a $b $c]
    }

    set a [expr {(($code >> 18) & 0x07) | 0b11110000 }]
    set b [expr {(($code >> 12) & 0x3f) | 0b10000000 }]
    set c [expr {(($code >>  6) & 0x3f) | 0b10000000 }]
    set d [expr {(($code >>  0) & 0x3f) | 0b10000000 }]
    # debug.marpa/unicode {==> (0x[format %02x $a] 0x[format %02x $b] 0x[format %02x $c] 0x[format %02x $d])}
    return [list $a $b $c $d]
}
