# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Transformation of precedenced priority rules into
#               non-precedenced form.
##
# See doc/precedence-rewrite
# See doc.1/facts-precedence.txt
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::precedence 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Grammar transformer.
# Meta description Rewrites precedenced priority rules into sets where
# Meta description the precedence is directly encoded in the structure
# Meta description of the rules
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta subject     marpa transform precedence
# @@ Meta End

# Notes
# - Precedences are integers <= 0.
# - The tightest precedence is 0.
# - The loosest  precedence is some K <= 0
#
# - tighter x --> x+1 for x < 0, 0 for x == 0
# - looser  x --> x-1 for K < x, K for x == K
#
# Assumptions:
# - E's loosest precedence is K < 0
# - E is the LHS of the precedenced rules
# - E is recursive, i.e. appears in at least one RHS
#
# Rewrite rules
##
# 1. Replace E with
#	(( E ::= E[K] ))
#
# 2. Add
#	(( E[x] ::= E[tighter(x)] ))
#	for all x in [K...1]
#
# 3. Add
#	(( E[x] ::= ... E[x] ... E[tighter(x)] ... ))
#	for (( E ::= ... E ... E ... ))
#	[left-assoc, at precedence x]
#
# 4. Add
#	(( E[x] ::= ... E[tighter(x)] ... E[x] ... ))
#	for (( E ::= ... E ... E ... ))
#	[right-assoc, at precedence x]
#
# 5. Add
#	(( E[x] ::= ... E[K] ... ))	/f.a E in the input
#	for (( E ::= ... E ... ))
#	    [group-assoc, at precedence x]
#
# Notes on the priority rules in the result:
# - All are at precedence level 0, assoc "left".
# - In case of L0 the attributes action, mask and assoc are
#   left out, otherwise see below.
# - All from (3,4,5) have the
#   -	action,
#   -	mask, and
#   -	name
#   of their origin rule.
# - All from (1, 2) have
#   -	action {special hide}, --  A form of `first` which prevents the
#                                \ symbol from making its own AST node.
#   -	mask {0}, and
#   -	no name.

# In generated symbols, i.e. FOO((x)) for origin FOO at level x the
# levels are inverted (0-x), stting -K the loosest precedence.
# Precedence 0 keeps being the tightest. This is easier to read, while
# the negative precedence levels were easier to generate from within
# the semantics.

# Thinking about this now I am not sure what I was thinking at the
# time. Incrementing up to mean `looser precedence` should work just
# as well. <-- Consider FUTURE TODO to redo this part of the
# semantics, and here, of course.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require marpa::util

debug define marpa/slif/precedence

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::precedence {
    namespace export rewrite rewrite1 2container
    namespace ensemble create
    namespace import ::marpa::X
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::precedence::rewrite {container} {
    debug.marpa/slif/precedence {}
    set commands {}
    foreach layer {g1 l0} {
	foreach sym [$container $layer symbols] {
	    # Without an actual range of precedences a rewrite is not
	    # worth it. This also automatically exludes the trivially
	    # non-recursive rules (atoms and quantified) from
	    # consideration.
	    set min_p [$container $layer min-precedence $sym]
	    if {$min_p == 0} continue

	    # Exclude priority rules which are not recursive.  This is
	    # a more expensive check, iterating over all the
	    # alternates and their elements, thus why it is the second
	    # check after the easier test for a precedence range.
	    if {![$container $layer recursive $sym]} continue

	    lappend commands {*}[rewrite1 $layer $sym $min_p [$container $layer get $sym]]
	}
    }
    return $commands
}

proc ::marpa::slif::precedence::2container {rewrite container} {
    debug.marpa/slif/precedence {}
    foreach command $rewrite {
	$container {*}$command
    }
    return
}

proc ::marpa::slif::precedence::rewrite1 {grcode lhs min alternatives} {
    debug.marpa/slif/precedence {}
    # alternatives :: list(alter)
    # alter        :: tuple(rhs precedence ...)
    # rhs          :: list(symbol)
    # ...          :: {*}dict ( name action assoc mask )
    # action, assoc, mask are G1 only
    # assoc defaults to "left".

    # result :: list(commands)

    set result {}
    R $lhs

    # Note:
    # - "attr" is used by "P" to fill in the attributes of the new
    #   priority rules.

    set smin [S $min]
    set attr [list action {special hide} mask {0}]

    # Rewrite (1) - Ground
    P $lhs [list $smin]

    # Rewrite (2) - Spine
    for {
	set current $min
	set tighter [expr {$min + 1}]
    } {$current < 0} {
	incr current
	incr tighter} {
	P [S $current] [list [S $tighter]]
    }

    # Rewrite (3-5) - Rules per assoc type
    foreach alter $alternatives {
	P {*}[MapAlter $lhs $alter $smin]
    }

    return $result
}

# # ## ### ##### ######## #############
## Internal helpers

proc ::marpa::slif::precedence::MapAlter {lhs alter smin} {
    debug.marpa/slif/precedence {}
    # Export to caller for import into the following P.
    upvar 1 attr attr

    set attr [lassign $alter __type__ rhs precedence]
    if {[dict exists $attr assoc]} {
	set assoc [dict get $attr assoc]
    } else {
	set assoc left
    }

    set scurrent [S $precedence]
    set stighter [S [expr {min($precedence + 1,0)}]]

    switch -exact -- $assoc {
	left {
	    # Rewrite (3)
	    # E[x] ::= ... E[x] ... E[tighter(x)]...
	    set newrhs [MapFirst $rhs $lhs $scurrent $stighter]
	}
	right {
	    # Rewrite (4)
	    # E[x] ::= ... E[tighter(x)] ... E[x]...
	    # Like left, but in reverse.
	    set newrhs [lreverse [MapFirst [lreverse $rhs] $lhs $scurrent $stighter]]
	}
	group {
	    # Rewrite (5)
	    # E[x] ::= ... E[K] ..., for all E in rhs
	   set newrhs [MapAll $rhs $lhs $smin]
       }
	default {
	    X "Bad assocation $assoc" SLIF PRECEDENCE BAD ASSOC
	}
    }
    return [list $scurrent $newrhs]
}

proc ::marpa::slif::precedence::MapFirst {rhs lhs newfirst newplus} {
    debug.marpa/slif/precedence {}
    set new $newfirst
    return [lmap sym $rhs {
	if {$sym eq $lhs} {
	    set res $new
	    set new $newplus
	    set res
	} else {
	    set sym
	}
    }]
}

proc ::marpa::slif::precedence::MapAll {rhs lhs new} {
    debug.marpa/slif/precedence {}
    return [lmap sym $rhs {
	if {$sym eq $lhs} {
	    set new
	} else {
	    set sym
	}
    }]
}

proc ::marpa::slif::precedence::S {k} {
    debug.marpa/slif/precedence {}
    upvar 1 lhs lhs
    return "${lhs}(([expr {-$k}]))"
}

proc ::marpa::slif::precedence::R {sym} {
    debug.marpa/slif/precedence {}
    upvar 1 grcode grcode result result
    lappend result [list $grcode remove $sym]
    return
}

proc ::marpa::slif::precedence::P {sym rhs} {
    debug.marpa/slif/precedence {}
    upvar 1 grcode grcode result result attr attr

    set newattr $attr
    dict set newattr assoc left
    if {$grcode eq "l0"} {
	dict unset newattr action
	dict unset newattr mask
	dict unset newattr assoc
    }

    lappend result [list $grcode priority-rule $sym $rhs 0 {*}$newattr]
    return
}

# # ## ### ##### ######## #############
package provide marpa::slif::precedence 1
return
