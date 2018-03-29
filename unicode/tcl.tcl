# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Utilities to handle conversion of unicode classes into utf-8
# ASBRs. On the unicode side a class can be represented as a list of
# codepoints, or as a list of codepoint ranges.  On the utf-8 side the
# same class is represented as a list of alternatives, with each
# alternative a sequence of byte-ranges, and each byte-range given by
# start- and end-value, inclusive. Hence ASBR, for "Alternatives of
# Sequences of Byte-Ranges".

# NOTE: Core functions (norm-class, negate-class, 2assr, and 2asbr)
# are implemented on the C side for performance (See unicode.tcl,
# unichar.tcl, asbr_objtype.tcl, assr_objtype.tcl, and cc_objtype.tcl)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller
package require marpa::util

debug define marpa/unicode
debug prefix marpa/unicode {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval marpa {
    namespace export unicode
    namespace ensemble create
}
namespace eval marpa::unicode {
    namespace export \
	norm-class negate-class point unfold fold/c \
	2char 2utf 2asbr asbr-format data max bmp smp \
	2assr assr-format
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API
##
## - 2char        - Convert uni(code)point to sequence of points in the BMP
## - 2utf         - Convert uni(code)point to sequence of bytes
## - 2asbr        - Convert unicode class to utf8 asbr
## - asbr-format  - Convert the result of 2asbr into a human-readable form.
## - 2assr        - Convert unicode class to ASSR
## - assr-format  - Convert the result of 2assr into a human-readable form.
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
## - max          - Return the number of supported codepoints.

proc marpa::unicode::point {character} {
    debug.marpa/unicode {}
    # Convert first character if we got a string.
    scan [lindex [split $character {}] 0] %c codepoint
    return $codepoint
}

if 0 {proc marpa::unicode::fold/c {codes} {
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
}}

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

proc marpa::unicode::assr-format {assr {compact 0}} {
    debug.marpa/unicode {}
    set r {}
    set prefix " "
    foreach alternative $assr {
	append r $prefix
	foreach range $alternative {
	    lassign $range s e
	    append r \[
	    append r [format %04x $s]
	    if {$s != $e} {
		append r - [format %04x $e] \]
	    } elseif {$compact} {
		append r \]
	    } else {
		append r \] {     }
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
## - data range
## - data fold   \ see unifold.tcl (Critcl glue)
## - data fold/c /

namespace eval marpa::unicode::data {
    namespace export cc fold fold/c
    namespace ensemble create
    namespace import ::marpa::X
    namespace import ::marpa::unicode::norm-class
}
namespace eval marpa::unicode::data::cc {
    namespace export ranges names tcl-names have have-tcl
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
    variable ::marpa::unicode::ccalias
    if {[string match %* $cclass]} {
	set cclass [string range $cclass 1 end]
    }
    return [expr {[dict exists $cc      $cclass]
	       || [dict exists $ccalias $cclass]}]
}

proc marpa::unicode::data::cc::names {} {
    variable ::marpa::unicode::cc
    variable ::marpa::unicode::ccalias
    lappend r {*}[dict keys $cc]
    lappend r {*}[dict keys $ccalias]
    return [lsort -dict -unique $r]
}

proc marpa::unicode::data::cc::ranges {cclass} {
    variable ::marpa::unicode::cc
    variable ::marpa::unicode::ccalias

    if {[string match %* $cclass]} {
	set cclass [string range $cclass 1 end]
	return [marpa::unicode::unfold [ranges $cclass]]
    }
    
    if {[dict exists $ccalias $cclass]} {
	return [dict get $cc [dict get $ccalias $cclass]]
    }
    if {![dict exists $cc $cclass]} {
	X "Bad character class $cclass" UNICODE BAD CLASS
    }
    return [dict get $cc $cclass]
}

# # ## ### ##### ######## #############
return
