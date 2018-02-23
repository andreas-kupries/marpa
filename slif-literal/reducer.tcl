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
# Package marpa::slif::literal::reducer 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Utilities operate on
# Meta description and transform L0 literals.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::unicode
# Meta require     marpa::util
# Meta require     marpa::slif::literal::rstate
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
package require marpa::slif::literal::rstate
package require marpa::slif::literal::util

debug define marpa/slif/literal/reducer

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export reduce reduce1 r2container
    namespace ensemble create
    namespace import ::marpa::X
    namespace import ::marpa::slif::literal::util::*
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::r2container {reductions container} {
    debug.marpa/slif/literal/reducer {}
    lassign $reductions worklist aliases

    foreach {litsymbol literal} $worklist {
	$container l0 remove $litsymbol

	# Do not re-create symbols without definition. This is how
	# they symbols optimized away get removed.
	if {$literal eq {}} continue

	set data [lassign $literal type]
	switch -exact -- $type {
	    composite {
		# Alternation of sequences of elements
		# alt == data
		foreach rhsequence $data {
		    $container l0 priority-rule $litsymbol $rhsequence 0
		}
	    }
	    default {
		# Regular literal, (re)create
		$container l0 literal $litsymbol $type {*}$data
	    }
	}
    }

    if {![dict size $aliases]} return
    # Pass the alias table to the relevant grammar so that it can
    # rewrite the rules which have the aliased symbols in their RHS.
    $container l0 fixup $aliases
    return
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::reduce {worklist rules} {
    debug.marpa/slif/literal/reducer {}
    set rstate [rstate new $worklist]
    while {[$rstate work?]} {
	reduce1 {*}[$rstate take] $rules $rstate
    }
    set result [$rstate results]
    $rstate destroy
    return $result
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::reduce1 {litsymbol literal rules state} {
    debug.marpa/slif/literal/reducer {}
    set data [lassign $literal type]

    # Incomplete literal is forbidden
    if {![llength $data]} FAILI

    # ON     - rule check
    # FAILR  - Reduction error, bad type
    # FAILE  - Reduction error, empty literal
    # FAILI  - Reduction error, incomplete literal
    ##
    # DSL for construction of composites.
    ##
    # KEEP       - save input back to state, no changes, mark final
    # RULES      - collect rhs of a composite, save to state
    # DEF        - define single rhs for a collection of rules
    # DEF*       - ditto, argument is list.
    # L          - Shorthand for literal construction (list)
    # IS-A       - Save converted representation of input
    # CC-ASBR    - Save an ASBR. Already in alt/seq format,
    #              only ranges need conversion to proper literals.
    #
    # Notes:
    # - RULES/DEF inserts a new layer of symbols.
    # - IS-A keeps the existing symbol and changes its definition,
    #   without a new layer. Prevents formation of definition chains
    #   like A -> B -> C ...

    switch -exact -- $type {
	byte - brange {
	    KEEP
	    return
	}
	string {
	    ON D-STR1 {
		# string == sequence (character)
		RULES {
		    DEF* [lmap codepoint $data { L character $codepoint }]
		}
	    }
	    ON D-STR2 {
		# string == sequence (bytes)
		# converts the characters into byte-sequences, then
		# flattens the whole into a single sequence of bytes.
		RULES {
		    DEF* [concat {*}[lmap codepoint $data {
			lmap byte [marpa unicode 2utf $codepoint] { L byte $byte }
		    }]]
		}
	    }
	    ON K-STR KEEP
	}
	%string {
	    ON D-%STR {
		# %string == sequence (%character)
		RULES {
		    DEF* [lmap codepoint $data { L %character $codepoint }]
		}
	    }
	    ON K-%STR KEEP
	}
	charclass {
	    ON D-CLS3 {
		# charclass == tcl | non-tcl
		# convert the named classes not directly supported by
		# Tcl to numeric ranges and merge into the codes
		# section of the class (if any). That is a final
		# form. (Because it is usable by Tcl)

		IS-A/ charclass {*}[CC-TCL $data]
	    }
	    ON D-CLS2 {
		# charclass == ASBR (on the fly, all)
		CC-ASBR [marpa unicode 2asbr [ccranges $data]]
		# Alternate rule (CLS4, TODO?): split of named classes via
		#                 alternation, remainder on the fly.
	    }
	    ON D-CLS1 {
		# charclass = alternation of elements (1-element sequences)
		RULES {
		    foreach element $data {
			switch -exact -- [eltype $element] {
			    character   { DEF [L character   $element] }
			    range       { DEF [L range    {*}$element] }
			    named-class { DEF [L named-class $element] }
			}
		    }
		}
	    }
	    ON K-CLS KEEP
	}
	^charclass {
	    ON D-^CLS1 {
		# charclass - expand to ranges, negate, save as charclass
		IS-A charclass {*}[marpa unicode negate-class [ccranges $data]]
	    }
	    ON D-^CLS2 {
		# charclass - Tcl support vs non
		##
		# convert the named classes not directly supported by
		# Tcl to numeric ranges and merge into the codes
		# section of the class (if any). That is a final
		# form. (Because it is usable by Tcl)

		IS-A/ ^charclass {*}[CC-TCL $data]
	    }
	    ON K-^CLS KEEP
	}
	named-class {
	    ON D-NCC3 {
		if {[marpa unicode data cc have-tcl $data]} {
		    # Supported by Tcl.
		    KEEP
		} else {
		    # Not directly supported by Tcl. Expand into
		    # ranges. See -> D-NCC1
		    IS-A charclass {*}[marpa unicode data cc ranges $data]
		}
	    }
	    ON D-NCC2 {
		# named-class == ASBR (on the fly)
		CC-ASBR [marpa unicode 2asbr \
			     [marpa unicode data cc ranges $data]]
	    }
	    ON D-NCC1 {
		# named-class == charclass (take predefined)
		IS-A charclass {*}[marpa unicode data cc ranges $data]
	    }
	    ON K-NCC KEEP
	}
	%named-class {
	    # TODO: %NCC3 as-grammar
	    ON D-%NCC2 {
		# named-class == ASBR (codes, unfold, on-the-fly)
		CC-ASBR [marpa unicode 2asbr \
			     [marpa unicode unfold \
				  [marpa unicode data cc ranges $data]]]
	    }
	    ON D-%NCC1 {
		# named-class == charclass (codes, unfold, re-compress)
		IS-A charclass {*}[marpa unicode unfold \
					  [marpa unicode data cc ranges $data]]
	    }
	    ON K-%NCC KEEP
	}
	^named-class {
	    ON D-^NCC1 {
		# named-class == charclass (codes, negate)
		IS-A charclass {*}[marpa unicode negate-class \
					  [marpa unicode data cc ranges $data]]
	    }
	    ON D-^NCC2 {
		# named-class == Tcl vs non (supported - keep, else -
		# expand to ranges & negate -- See D-^NCC1)

		if {[marpa unicode data cc have-tcl $data]} {
		    # Supported by Tcl.
		    KEEP
		} else {
		    # Not directly supported by Tcl. Expand into
		    # ranges. See -> D-NCC1
		    IS-A charclass {*}[marpa unicode negate-class \
					   [marpa unicode data cc ranges $data]]
		}
	    }
	    ON K-^NCC KEEP
	}
	^%named-class {
	    ON D-^%NCC2 {
		# ^%named-class == ASBR (on the fly, from codes unfolded, negated)
		CC-ASBR [marpa unicode 2asbr \
			     [marpa unicode negate-class \
				  [marpa unicode unfold \
				       [marpa unicode data cc ranges $data]]]]
	    }
	    ON D-^%NCC1 {
		# ^%named-class == charclass (codes, unfold, re-compress, negate)
		IS-A charclass {*}[marpa unicode negate-class \
					  [marpa unicode unfold \
					       [marpa unicode data cc ranges $data]]]
	    }
	    ON K-^%NCC KEEP
	}
	range {
	    lassign $data start end
	    # An empty range is forbidden
	    if {$end <= $start} FAILE

	    ON D-RAN2 {
		# range == ASBR (compute here)
		CC-ASBR [marpa unicode 2asbr [list $data]]
	    }
	    ON D-RAN1 {
		# range == alternation(character)
		RULES {
		    for {} {$start <= $end} {incr start} {
			DEF [L character $start]
		    }
		}
	    }
	    ON K-RAN KEEP
	}
	%range {
	    lassign $data start end
	    # An empty range is forbidden
	    if {$end <= $start} FAILE

	    ON D-%RAN {
		# %range == case-expand, re-compress /charclass
		IS-A charclass {*}[marpa unicode unfold [list $data]]
	    }
	    ON K-%RAN KEEP
	}
	^range {
	    set max [marpa unicode max]
	    lassign $data start end
	    # An empty range is forbidden
	    if {($start <= 0) && ($end >= $max)} FAILE

	    ON D-^RAN2 {
		# ^range == ASBR (compute here)
		CC-ASBR [marpa unicode 2asbr \
			     [marpa unicode negate-class [list $data]]]
	    }
	    ON D-^RAN1 {
		# Note, empty range already excluded, can omit here
		set complement [marpa unicode negate-class [list $data]]
		if {[llength $complement] == 1} {
		    IS-A range {*}[lindex $complement 0]
		} else {
		    IS-A charclass {*}$complement
		}
	    }
	    ON K-^RAN KEEP
	}
	character {
	    ON D-CHR {
		# character == sequence (byte) [utf-8 encoding]
		set bytes [marpa unicode 2utf $data]
		if {[llength $bytes] == 1} {
		    # Rewrite directly to byte.
		    IS-A/ byte {*}$bytes
		} else {
		    # Sequence of several bytes
		    RULES {
			DEF* [lmap byte $bytes { L byte $byte }]
		    }
		}
	    }
	    ON K-CHR KEEP
	}
	^character {
	    ON D-^CHR {
		# ^character == charclass (range/before, range/after)
		set pre  $data ; incr pre -1
		set post $data ; incr post
		IS-A charclass [L 0 $pre] [L $post [marpa unicode max]]
	    }
	    ON K-^CHR KEEP
	}
    }
    FAILR
    return
}

proc ::marpa::slif::literal::L {args} {
    # The 'list' command is implicit in the handling of an args
    # argument
    return $args
}

proc ::marpa::slif::literal::DEF {args} {
    upvar 1 alternatives alternatives
    lappend alternatives $args
    return
}

proc ::marpa::slif::literal::DEF* {words} {
    upvar 1 alternatives alternatives
    lappend alternatives $words
    return
}

proc ::marpa::slif::literal::RULES {script {symqueue work}} {
    upvar 1 state state litsymbol litsymbol alternatives alternatives
    set alternatives {}
    uplevel 1 $script
    $state place done $symqueue $litsymbol [L composite {*}$alternatives]
    return
}

proc ::marpa::slif::literal::KEEP {} {
    upvar 1 state state litsymbol litsymbol literal literal
    $state queue done $litsymbol $literal
    return
}

proc ::marpa::slif::literal::IS-A/ {args} {
    upvar 1 state state litsymbol litsymbol
    $state queue done $litsymbol $args
    return
}

proc ::marpa::slif::literal::IS-A {args} {
    upvar 1 state state litsymbol litsymbol
    $state queue work $litsymbol $args
    return
}

proc ::marpa::slif::literal::CC-ASBR {asbr} {
    upvar 1 state state litsymbol litsymbol
    # asbr      :: list (alternate)
    # alternate :: list (range)
    # range     :: pair (from to)

    if {([llength $asbr] == 1) && ([llength [lindex $asbr 0]] == 1)} {
	# asbr has one alternate, having only one element in the
	# sequence. No need to inject a priority rule. We can rewrite
	# the main symbol.
	IS-A/ brange {*}[lindex $asbr 0 0]
	return
    }

    RULES {
	foreach rhs $asbr {
	    DEF* [lmap range $rhs { MK-RANGE $range }]
	}
    }
    return
}

proc ::marpa::slif::literal::MK-RANGE {range} {
    lassign $range s e
    if {$s == $e} {
	return [L byte $s]
    } else {
	return [L brange $s $e]
    }
}

proc ::marpa::slif::literal::ON {rule script} {
    upvar 1 rules rules
    if {$rule ni $rules} return
    uplevel 1 $script
    return -code return
}

proc ::marpa::slif::literal::FAILR {} {
    upvar 1 type type data data
    X "Unable to reduce type ($type ($data))" \
	SLIF LITERAL INTERNAL
}

proc ::marpa::slif::literal::FAILE {} {
    upvar 1 type type data data
    X "Unable to reduce empty literal ($type ($data))" \
	SLIF LITERAL EMPTY
}

proc ::marpa::slif::literal::FAILI {} {
    upvar 1 type type data data
    X "Unable to reduce incomplete literal ($type ($data))" \
	SLIF LITERAL INCOMPLETE
}

proc ::marpa::slif::literal::CC-TCL {charclass} {
    debug.marpa/slif/literal/reducer {}
    # Take a character class which may contain constructions Tcl
    # cannot handle and return an equivalent class which can be
    # handled by Tcl.

    lassign [ccsplit $charclass] codes named
    set named [lmap name $named {
	if {[marpa unicode data cc have-tcl $name]} {
	    # supported, pass to result
	    set name
	} else {
	    # not supported, get code ranges and merge. Any %XXX are
	    # handled by looking for the base name and case-expanding
	    # that. Note, this could be moved into the unicode
	    # database accessor code.
	    if {[regexp {^%(.*)$} $name -> base]} {
		set ccodes [marpa unicode data cc ranges $base]
		set ccodes [marpa unicode unfold $ccodes]
	    } else {
		set ccodes [marpa unicode data cc ranges $name]
	    }
	    lappend codes {*}$ccodes
	    # filter out of result
	    continue
	}
    }]

    return [list {*}[marpa unicode norm-class $codes] {*}$named]
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::reducer 0
return
