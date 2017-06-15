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

# NOTE: Core functions (norm-class, negate-class, and 2asbr) are
# implemented on the C side for performance (See c/unicode.tcl,
# c/asbr_objtype.tcl, and c/cc_objtype.tcl)

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

# TODO: 2utf --> see c/unicode.tcl :: decode
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
return
