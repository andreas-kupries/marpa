# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# See doc/atoms.md

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::reduce::2tcl 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Transform L0 literals into forms usable to
# Meta description the Tcl runtime. Codepoints outside of the BMP are handled with
# Meta description surrogate pairs.
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

# NOTES

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

debug define marpa/slif/literal/reduce/2tcl

# # ## ### ##### ######## #############
## Reducer callback
## - RT-Tcl (surrogate pairs for post-BMP characters)
## - Ensemble dispatch by literal type
#
## The callback can expect to be called only with normalized literals.

# # ## ### ##### ######## #############
## Public API

namespace eval ::marpa::slif::literal::reduce::2tcl {
    namespace export %* ^* !! cc/* string charclass character range named-class
    namespace ensemble create

    namespace import ::marpa::X
    namespace import ::marpa::unicode::2char
    namespace import ::marpa::unicode::2assr
    namespace import ::marpa::unicode::negate-class
    namespace import ::marpa::unicode::norm-class
    namespace import ::marpa::unicode::data
    namespace import ::marpa::unicode::unfold
    namespace import ::marpa::unicode::max
    namespace import ::marpa::unicode::bmp
    namespace import ::marpa::unicode::smp
    namespace import ::marpa::slif::literal::util::ccranges
    namespace import ::marpa::slif::literal::util::ccnorm
    namespace import ::marpa::slif::literal::util::eltype
}

# # ## ### ##### ######## #############
##
# A number of optimizations are not handled by the reducer.
# They are defered to the generator.
#
# 1. (range 0 [bmp]) == Tcl . (dot) regex
#

# # ## ### ##### ######## #############
## Type-specific handlers.
## Custom tags:
## - `cc/smp`
## - `!!`

proc ::marpa::slif::literal::reduce::2tcl::cc/smp {state args} {
    # charclass in the SMP, only.
    # NOTE: Can only handle a positive class definition.

    # Handle as an ASSR. (code ranges, not byte ranges).
    ##
    # Note: We cannot have a simple ASSR with a single-element single
    # .alternate. All the codepoints are post-BMP, coded as surrogate
    # pairs, making the simpleast ASSR a 2-element single alternate.

    # Everything is final
    $state rules! [lmap rhs [2assr [ccranges $args]] {
	lmap range $rhs { Lr $range }
    }]
}

proc ::marpa::slif::literal::reduce::2tcl::!! {state args} {
    # Finalize the marked literal
    $state is-a! {*}$args
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::reduce::2tcl::string {state args} {
    # strings are codepoint sequences
    # each codepoint may map to one or two BMP points
    # (surrogate pair for post-BMP codepoints)
    # we know that the resulting sequence contains only codepoints in
    # the BMP. That makes them final.

    $state rules*! [concat {*}[lmap codepoint $args {
	lmap c [2char $codepoint] { L character $c }
    }]]
}

proc ::marpa::slif::literal::reduce::2tcl::%string {state args} {
    # args = codepoints
    # convert into sequence of %character, to be reduced further, single alternative

    $state rules* [lmap codepoint $args { L %character $codepoint }]
}

proc ::marpa::slif::literal::reduce::2tcl::charclass {state args} {
    # args = codepoint|range|name ...

    $state {*}[CC 0 $args]
}

proc ::marpa::slif::literal::reduce::2tcl::^charclass {state args} {
    # args = codepoint|range|named-class ...
    # Complement class, then normalize and reduce further

    $state {*}[CC 1 $args]
}

proc ::marpa::slif::literal::reduce::2tcl::character {state codepoint} {
    # A codepoint may map to one or two characters in the BMP.
    # Regardless of which, the result is final
    set points [2char $codepoint]
    if {[llength $points] == 1} {
	$state keep
    }

    $state rules*! [lmap p $points { L character $p }]
}

# %character  | Handled by normalizer -> charclass
# ^%character | s.a
# ^%range     | s.a

proc ::marpa::slif::literal::reduce::2tcl::^character {state codepoint} {
    # A negated character generally is a class containing 2 ranges,
    # before and after the excluded character. This is then normalized
    # and reduced further.

    $state {*}[CC 1 [S $codepoint]]
}

proc ::marpa::slif::literal::reduce::2tcl::range {state start end} {
    # an empty range is illegal
    if {$end <= $start} EmptyRange

    $state {*}[CC 0 [S [R $start $end]]]
}

proc ::marpa::slif::literal::reduce::2tcl::%range {state start end} {
    # an empty range is illegal
    if {$end <= $start} EmptyRange
    
    # Unfold the character casing, then go through a charclass to
    # normalize and reduce further.

    $state is-a charclass {*}[unfold [S [R $start $end]]]
}

proc ::marpa::slif::literal::reduce::2tcl::^range {state start end} {
    # an empty range is illegal
    if {($start <= 0) && ($end >= [max])} EmptyRange

    $state {*}[CC 1 [S [R $start $end]]]
}

proc ::marpa::slif::literal::reduce::2tcl::named-class {state name} {
    $state {*}[CC 0 [S $name]]
}

proc ::marpa::slif::literal::reduce::2tcl::%named-class {state name} {
    # Must be unfolded and then goes through the regular CC reduction.
    # Tcl support of the name does not matter.
    $state is-a charclass {*}[unfold [data cc ranges $name]]
}

proc ::marpa::slif::literal::reduce::2tcl::^named-class {state name} {
    $state {*}[CC 1 [S $name]]
}

proc ::marpa::slif::literal::reduce::2tcl::^%named-class {state name} {
    # See %named-class. case-unfold and negate before sending it on.
    
    $state is-a charclass {*}[negate-class [unfold [data cc ranges $name]]]
}

# # ## ### ##### ######## #############
## Internal utilities

proc ::marpa::slif::literal::reduce::2tcl::Lr {range} {
    lassign $range s e
    if {$s == $e} {
	L character $s
    } else {
	L range $s $e
    }
}

proc ::marpa::slif::literal::reduce::2tcl::EmptyRange {} {
    upvar 1 start start end end
    X "Unable to reduce empty literal (range ($start $end))" \
	SLIF LITERAL EMPTY
}

proc ::marpa::slif::literal::reduce::2tcl::L {args} {
    # Nicer name for L'iteral construction
    return $args
}

proc ::marpa::slif::literal::reduce::2tcl::S {args} {
    # Nicer name for S'equence construction
    return $args
}

proc ::marpa::slif::literal::reduce::2tcl::R {start end} {
    # Nicer name for R'ange construction
    if {$end < $start} EmptyRange
    if {$start == $end} { return $start }
    list $start $end
}

# # ## ### ##### ######## #############
## Class utilities.

## Various literal types related to charclasses are all fed through
## this one central place to properly handle BMP and SMP areas, with
## BMP allowing for better optimization towards what is natively
## supported by Tcl.

proc ::marpa::slif::literal::reduce::2tcl::CC {neg pieces} {
    ##
    # 1. Split the incoming class into bmp vs smp, and also the
    #    different types of elements, i.e. characters, ranges, and
    #    named classes.
    ##
    # 2. Optimize each side separately, based on Tcl's capabilities,
    #    negation status, and complexity. I.e. singles can be made
    #    simpler.
    ##
    # 3. The result of this procedure is state method and arguments to
    #    invoke. It does not invoke these itself. This makes it
    #    possible to perform incremental buildup of the result.

    lassign [set __ [CC/split $pieces]] \
	bmpn bmpchars bmpranges bmpnames \
	smpn smpchars smpranges smpnames

    #puts AAA\t[join $__ \nAAA\t]
    
    if {$bmpn && $smpn} {
	# mixed elements
	set smpcc [CC/data $smpchars $smpranges $smpnames]
	if {$neg} {
	    # A mixture of negative elements. The BMP part can be
	    # handled by Tcl as is. The SMP part needs ASSR
	    # processing, and must be negated here for that to work.
	    set smpcc [negate-class [ccranges $smpcc] 1]
	    if {[llength $smpcc]} {
		lappend cc rules*
		lappend cc [S [CC/lit $bmpn $bmpchars $bmpranges $bmpnames {!! ^}]]
		lappend cc [S [L cc/smp {*}$smpcc]]
	    } else {
		lappend cc is-a! {*}[CC/lit $bmpn $bmpchars $bmpranges $bmpnames ^]
	    }
	    return $cc

	} else {
	    # A mixture of positive elements needs two clauses for the
	    # two areas. Each can be handled as is. The BMP part uses
	    # !! to mark it as final.

	    lappend cc rules*
	    lappend cc [S [CC/lit $bmpn $bmpchars $bmpranges $bmpnames {!! }]]
	    lappend cc [S [L cc/smp {*}$smpcc]]
	    return $cc
	}
    }

    if {$bmpn} {
	# Class elements touch only BMP
	if {$neg} {
	    # A negative class in the BMP has to match everything in
	    # the SMP as well, thus we need two clauses for the two
	    # areas. As the SMP clause needs further processing !! is
	    # used to protect the bmp part.
	    lappend cc rules*
	    lappend cc [S [CC/lit $bmpn $bmpchars $bmpranges $bmpnames {!! ^}]]
	    lappend cc [S [L cc/smp [R [smp] [max]]]]
	    return $cc
	} else {
	    # A positive class can be returned as is. The only
	    # simplifications left are to look out for singles and
	    # choose the appropriate type, plus normalization.

	    return [list is-a! {*}[CC/lit $bmpn $bmpchars $bmpranges $bmpnames]]
	}
    }
    
    if {$smpn} {
	# Class elements touch only SMP
	set smpcc [CC/data $smpchars $smpranges $smpnames]
	if {$neg} {
	    # For a negative class in the SMP we have to match
	    # everything in the BMP as well, thus two clauses. The BMP
	    # clause is marked final via !! as the SMP part requires
	    # further processing. It is also time to negate the definition
	    # because cc/smp does not handle negation.
	    set smpcc [negate-class [ccranges $smpcc] 1]
	    if {[llength $smpcc]} {
		lappend cc rules*
		lappend cc [S [L !! range 0 [bmp]]]
		lappend cc [S [L cc/smp {*}$smpcc]]
	    } else {
		lappend cc is-a! range 0 [bmp]
	    }
	    return $cc
	} else {
	    # A positive class is returned as is, marked for ASSR processing.
	    return [list is-a cc/smp {*}$smpcc]
	}
    }

    # Class is empty. Illegal.
    X "Unable to reduce empty literal ([expr {$neg ? "^":""}]charclass ($pieces))" \
	SLIF LITERAL BAD-CLASS
}

proc ::marpa::slif::literal::reduce::2tcl::CC/lit {n chars ranges names {prefix {}}} {
    if {$n == 1} {
	if {[llength $chars]} {
	    return [list {*}"${prefix}character" [lindex $chars 0]]
	}
	if {[llength $ranges]} {
	    return [list {*}"${prefix}range" {*}[lindex $ranges 0]]
	}
	if {[llength $names]} {
	    return [list {*}"${prefix}named-class" [lindex $names 0]]
	}
    }
    
    lappend cc {*}"${prefix}charclass"
    lappend cc {*}[CC/data $chars $ranges $names]
    return $cc
}

proc ::marpa::slif::literal::reduce::2tcl::CC/data {chars ranges names} {
    lappend cc {*}[norm-class [list {*}$chars {*}$ranges]]
    lappend cc {*}[lsort -dict $names]
    return $cc
}

proc ::marpa::slif::literal::reduce::2tcl::CC/split {pieces} {
    set bmpn      0  ; set smpn      0 
    set bmpchars  {} ; set smpchars  {}
    set bmpranges {} ; set smpranges {}
    set bmpnames  {} ; set smpnames  {}

    # Note: The ccnorm cleans up any input ambiguities, like
    # overlapping ranges, duplicate elements of any kind, and the
    # like. From now on we can assume that chars, ranges, and names
    # are unique, and properly separate. That makes the follow up
    # processing much easier.
    
    foreach el [ccnorm $pieces] {
	switch -exact -- [eltype $el] {
	    character {
		if {$el <= [bmp]} { ++ bmp chars $el } else { ++ smp chars $el }
	    }
	    range {
		lassign $el s e
		if {$e <= [bmp]} { ++ bmp ranges $el ; continue }
		if {$s >  [bmp]} { ++ smp ranges $el ; continue }

		if {$s == [bmp]} { ++ bmp chars $s } else { ++ bmp ranges [R $s [bmp]] }
		if {$e == [smp]} { ++ smp chars $e } else { ++ smp ranges [R [smp] $e] }
		
	    }
	    named-class {
		set b [data cc have ${el}:bmp]
		set h [data cc have ${el}:smp]
		# assert (b || h)
		
		if {$b && $h} {
		    if {[data cc have-tcl $el]} {
			++ bmp names $el
		    } else {
			+r bmp [data cc ranges ${el}:bmp]
		    }
		    ++ smp names ${el}:smp
		} elseif {$b} {
		    if {[data cc have-tcl $el]} {
			++ bmp names $el
		    } else {
			+r bmp [data cc ranges $el]
		    }
		} elseif {$h} {
		    ++ smp names $el
		} else {
		    X "Unable to classify ($el)" \
			SLIF LITERAL BAD-CLASS
		}
	    }
	}
    }

    list $bmpn $bmpchars $bmpranges $bmpnames $smpn $smpchars $smpranges $smpnames
}

proc ::marpa::slif::literal::reduce::2tcl::++ {area type value} {
    upvar 1 ${area}n n ${area}${type} l
    lappend l $value
    incr n
    return
}
proc ::marpa::slif::literal::reduce::2tcl::+r {area ranges} {
    upvar 1 ${area}n n ${area}chars c ${area}ranges r
    foreach el $ranges {
	switch -exact -- [eltype $el] {
	    character { incr n ; lappend c $el }
	    range     { incr n ; lappend r $el }
	}
    }
    return
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::reduce::2tcl 0
return
