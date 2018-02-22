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
# Package marpa::slif::literal 0
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
# Meta require     marpa::slif::literal::parser
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
package require marpa::slif::literal::parser
package require marpa::slif::literal::util
package require marpa::slif::literal::norm

debug define marpa/slif/literal

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export parse reduce reduce1 rstate r2container
    namespace ensemble create
    namespace import ::marpa::X
    namespace import ::marpa::slif::literal::util::*
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::parse {litstring} {
    debug.marpa/slif/literal {}
    parser create LD
    try {
	set lit [norm [semantics::Decode [LD process $litstring]]]
    } finally {
	LD destroy
    }
    return $lit
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::r2container {reductions container} {
    debug.marpa/slif/literal {}
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
    debug.marpa/slif/literal {}
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
    debug.marpa/slif/literal {}
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
    debug.marpa/slif/literal {}
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
## Semantics for the literal parser

namespace eval ::marpa::slif::literal::semantics {
    variable nocase  0
    variable type    {}
    variable details {}
    variable names   {}
}

proc ::marpa::slif::literal::semantics::Init {} {
    debug.marpa/slif/literal {}
    variable nocase  0
    variable type    {}
    variable details {}
    variable names   {}
    return
}

proc ::marpa::slif::literal::semantics::Result {} {
    debug.marpa/slif/literal {}
    variable type
    variable details
    variable nocase
    if {$nocase} {
	lappend map %^ ^%
	set type [string map $map %$type]
    }
    return [linsert $details 0 $type]
}

proc ::marpa::slif::literal::semantics::CC {codes named} {
    debug.marpa/slif/literal {}
    set     codes [marpa unicode norm-class $codes]
    lappend codes {*}[lsort -dict -unique $named]
    return $codes
}

proc ::marpa::slif::literal::semantics::Decode {ast} {
    debug.marpa/slif/literal {}
    Init
    {*}$ast
    Result
}

proc ::marpa::slif::literal::semantics::literal {values} {
    debug.marpa/slif/literal {}
    #   <single quoted string> <modifiers>
    # | <character class>      <modifiers>
    # | <negated class>        <modifiers>
    # Modifiers first, informs initial normalization
    foreach v [lreverse $values] { {*}$v }
    return
}

proc {::marpa::slif::literal::semantics::single quoted string} {values} {
    variable type string
    variable nocase
    # <string elements>
    {*}[lindex $values 0]
    if {$nocase} {
	variable details
	set details [marpa unicode fold/c $details]
    }
    return
}

proc {::marpa::slif::literal::semantics::string elements} {values} {
    # <string element> *
    foreach v $values { {*}$v }
    return
}

proc {::marpa::slif::literal::semantics::string element} {values} {
    #   <plain string char>
    # | <escaped char>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::semantics::plain string char} {values} {
    variable details
    lappend details [lindex [scan [lindex $values 0 2] %c] 0]
    return
}

proc {::marpa::slif::literal::semantics::escaped char} {values} {
    #   unioct
    # | unixhex
    # | control
    {*}[lindex $values 0]
    return
}

proc ::marpa::slif::literal::semantics::unioct {values} {
    variable details
    lappend  details [expr 0o[lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::semantics::unihex {values} {
    variable details
    lappend details [expr 0x[lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::semantics::control {values} {
    variable details
    lappend  details [dict get {
	a  7	b  8	f  12	n  10
	r  13	t  9	v  11	\\ 92
    } [lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::semantics::modifiers {values} {
    # modifier *
    foreach v $values { {*}$v }
    return
}

proc ::marpa::slif::literal::semantics::modifier {values} {
    # nocase
    {*}[lindex $values 0]
    return
}

proc ::marpa::slif::literal::semantics::nocase {values} {
    # --
    variable nocase 1
    return
}

proc {::marpa::slif::literal::semantics::character class} {values} {
    variable type charclass
    variable details
    variable names
    # <cc elements>
    {*}[lindex $values 0]
    set details [CC $details $names]
    return
}

proc {::marpa::slif::literal::semantics::negated class} {values} {
    variable type ^charclass
    variable details
    variable names
    # <cc elements>
    {*}[lindex $values 0]
    set details [CC $details $names]
    return
}

proc {::marpa::slif::literal::semantics::cc elements} {values} {
    # <cc element> *
    foreach v $values { {*}$v }
    return
}

proc {::marpa::slif::literal::semantics::cc element} {values} {
    #   <cc character>
    #   <posix char class>
    # | <cc range>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::semantics::cc character} {values} {
    #   <plain cc char>
    # | <escaped char>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::semantics::plain cc char} {values} {
    variable details
    # Note: We have to unpack the codepoint from the list it came in.
    # Without doing that the `norm-class` call in CC will mis-interpret
    # it as range element, with only a single element, an error.
    lappend details [lindex [scan [lindex $values 0 2] %c] 0]
    return
}

proc {::marpa::slif::literal::semantics::posix char class} {values} {
    # add lexeme (class name)
    variable names
    lappend  names [lindex $values 0 2]
    return
}

proc {::marpa::slif::literal::semantics::cc range} {values} {
    # <cc character> <cc character>
    foreach v $values { {*}$v }
    # last two elements of details are the range
    # rewrite
    variable details
    set details [linsert [lrange $details 0 end-2] end [lrange $details end-1 end]]
    return
}

# # ## ### ##### ######## #############

oo::class create marpa::slif::literal::rstate {
    marpa::E marpa/slif/literal SLIF LITERAL

    variable mywork    ; # list (symbol) - stack of symbols to reduce
    variable myresults ; # list (symbol) - queue of completed symbols
    variable mydef     ; # dict (symbol -> literal) - definition database

    # # ## ### ##### ######## #############

    constructor {worklist} {
	debug.marpa/slif/literal {}
	set mywork    {}
	set myresults {}
	set mydef     {}
	#my XB
	foreach {litsymbol literal} $worklist {
	    set data [lassign $literal type]
	    if {![llength $data]} {
		my E "Unable to reduce incomplete literal ($type ($data))" \
		    SLIF LITERAL INCOMPLETE
	    }
	    dict set mydef $litsymbol $literal
	    lappend mywork $litsymbol
	}
	#my XC
	return
    }

    method work? {} {
	debug.marpa/slif/literal {}
	llength $mywork
    }

    method take {} {
	#my XB
	debug.marpa/slif/literal {}
	if {![llength $mywork]} {
	    my E "No work available" EMPTY
	}
	# Treating the pending work as a stack.
	set litsymbol [lindex   $mywork end]
	set mywork    [lreplace $mywork end end]
	set literal   [dict get $mydef $litsymbol]
	dict unset mydef $litsymbol
	#my XC
	list $litsymbol $literal
    }

    method place {queue symqueue litsymbol literal} {
	#my XB
	debug.marpa/slif/literal {}
	set res [my queue $queue $litsymbol \
		     [my symbolize $symqueue $literal]]
	#my XC
	return $res
    }

    method queue {queue litsymbol literal} {
	#my XB
	debug.marpa/slif/literal {}
	# queue in {work, done}
	# assert: The elements of a composite literal are symbols, not
	# literal specs to convert into.

	# Note, the incoming non-composite pieces are
	# normalized to simplify them further.
	if {[lindex $literal 0] ne "composite"} {
	    set literal [my NORM $literal]
	}
	dict set mydef $litsymbol $literal
	switch -exact -- $queue {
	    continue - work { lappend mywork    $litsymbol }
	    return   - done { lappend myresults $litsymbol }
	    default {
		my E "Bad queue \"$queue\", expected one of done, or work" \
		    BAD QUEUE
	    }
	}
	#my XC
	return $litsymbol
    }

    method symbolize {queue literal} {
	debug.marpa/slif/literal {}
	# queue in {work, done}
	set data [lassign $literal type]
	if {$type eq "composite"} {
	    # The literal is a set of alternates, each a sequence of
	    # elements.  This method assumes that each element is a
	    # literal itself. It generates and queues symbols for
	    # them, constructing a new literal referencing these
	    # symbols.
	    set literal [list $type {*}[lmap alternate $data {
		lmap child $alternate {
		    set cdata [lassign $child ctype]
		    if {$ctype eq "symbol"} {
			# Direct symbol reference.
			set cdata
		    } else {
			set childsym [my SYM $child]
			if {![dict exists $mydef $childsym]} {
			    my queue $queue $childsym $child
			}
			set childsym
		    }
		}
	    }]]
	}
	return $literal
    }

    forward SYM  marpa::slif::literal::util::symbol
    forward NORM marpa::slif::literal::norm

    method results {} {
	debug.marpa/slif/literal {}

	# Look for literals which exist as multiple symbols, which
	# we can and should merge.
	##
	# I. Invert, key by definition.
	# II. Choose one symbol for the multi-def literals, remember
	#     the aliases.
	# III. During result assembly suppress the secondaries, and
	#      rewrite other definitions to use the primary.

	set syms {}
	dict for {sym def} $mydef {
	    dict lappend syms $def $sym
	}

	# syms :: dict (def -> list(sym))
	#array set _XXX_syms $syms ; parray _XXX_syms ; unset _XXX_syms

	set ralias {}
	set alias  {}
	set keep   {}
	dict for {def symlist} $syms {
	    # For simplicity we map everything, even the unique
	    # definitions I.e. we can avoid conditionals. We still
	    # have to check to get proper supression.
	    if {[llength $symlist] == 1} {
		lassign $symlist primary
	    } else {
		foreach secondary [lassign [lsort -dict $symlist] primary] {
		    dict set ralias $secondary $primary ;# Needed mappings, for result
		    dict set alias  $secondary $primary ;# (1) Mapping for unconditional use
		    dict set keep   $secondary no
		}
	    }
	    dict set alias $primary $primary ;# See (1)
	    dict set keep  $primary yes
	}

	# alias :: dict (sym -> sym)  - Rewrite A to primary B
	# keep  :: dict (sym -> bool) - Flag if we keep a symbol or not.
	#array set _XXX_alias $alias ; parray _XXX_alias ; unset _XXX_alias
	#array set _XXX_keep  $keep  ; parray _XXX_keep  ; unset _XXX_keep
	set result {}
	foreach litsymbol [lreverse $myresults] {
	    # Reverse order, bottom up from atoms to composites
	    # Skip duplicate definitions.
	    if {[dict get $keep $litsymbol]} {
		set literal [dict get $mydef $litsymbol]
		set data    [lassign $literal type]

		if {$type eq "composite"} {
		    # Symbols on the RHS, map them over to chosen definitions.
		    set literal [list $type {*}[lmap alternate $data {
			lmap el $alternate { dict get $alias $el }
		    }]]
		}
	    } else {
		# Signal that this symbol should be destroyed.
		set literal {}
	    }

	    lappend result $litsymbol $literal
	}
	return [list $result $ralias]
    }

    # # ## ### ##### ######## #############

    method XB {} {
	puts __________________________________BEGIN\t[info level -1]
	puts XX_W\t[join $mywork    \nXX_W\t]\n
	puts XX_R\t[join $myresults \nXX_R\t]\n
	puts XX_D\t[join [lsort -dict [dict keys $mydef]] \nXX_D\t]
	puts __________________________________
    }

    method XC {} {
	puts __________________________________
	puts XX_W\t[join $mywork    \nXX_W\t]\n
	puts XX_R\t[join $myresults \nXX_R\t]\n
	puts XX_D\t[join [lsort -dict [dict keys $mydef]] \nXX_D\t]
	puts __________________________________COMPLETE/\t[info level -1]
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal 0
return
