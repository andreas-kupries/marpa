# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

debug define marpa/slif/literal

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export symbol parse norm eltype ccunfold ccsplit \
	decode decode-string decode-class type unescape tags \
	reduce reduce1 rstate r2container ccranges
    namespace ensemble create
    namespace import ::marpa::X

    variable typecode  {
	%character    %CHR
	%charclass    %CLS
	%named-class  %NCC
	%range        %RAN
	%string       %STR
	^%character   ^%CHR
	^%charclass   ^%CLS
	^%named-class ^%NCC
	^%range       ^%RAN
	^character    ^CHR
	^charclass    ^CLS
	^named-class  ^NCC
	^range        ^RAN
	byte          BYTE
	brange        BRAN
	character     CHR
	charclass     CLS
	named-class   NCC
	range         RAN
	string        STR
    }
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::parse {litstring} {
    debug.marpa/slif/literal {}
    return [norm [decode {*}[type {*}[tags $litstring]]]]
}

proc ::marpa::slif::literal::symbol {literal} {
    debug.marpa/slif/literal {}
    variable typecode
    set data [lassign $literal type]

    append symbol @ [dict get $typecode $type] :<
    foreach element $data {
	switch -exact -- [eltype $element] {
	    character {
		# Single character
		append symbol [char quote tcl [format %c $element]]
	    }
	    range {
		# Character range
		lassign $element s e
		append symbol [char quote tcl [format %c $s]] -
		append symbol [char quote tcl [format %c $e]]
	    }
	    named-class {
		# Named CC
		append symbol \[: $element :\]
	    }
	}
    }
    append symbol >
    return $symbol
}

# # ## ### ##### ######## #############
## Internal helpers

proc ::marpa::slif::literal::norm {literal} {
    debug.marpa/slif/literal {}
    set data [lassign $literal type]
    while {1} {
	switch -exact -- $type {
	    string {
		if {[llength $data] == 1} {
		    TO character ;# N01
		} else STOP ;# N02
	    }
	    %string {
		if {[llength $data] == 1} {
		    TO %character ;# N03
		} else STOP ;# N04
	    }
	    charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO [eltype $data] ;# N05, N06, N07
		} else STOP ;# N08
	    }
	    %charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO %[eltype $data] ;# N09, N10, N11
		} else {
		    set data [ccunfold $data]
		    TO charclass ;# N12
		}
	    }
	    ^charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO ^[eltype $data] ;# N13, N14, N15
		} else STOP ;# N16
	    }
	    ^%charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO ^%[eltype $data] ;# N17, N18, N19
		} else {
		    set data [ccunfold $data]
		    TO ^charclass ;# N20
		}
	    }
	    character {
		STOP ;# N21
	    }
	    %character {
		set data [marpa unicode data fold $data]
		TO charclass ;# N22
	    }
	    ^character {
		STOP ;# N23
	    }
	    ^%character {
		set data [marpa unicode data fold $data]
		TO ^charclass ;# N24
	    }
	    range {
		lassign $data s e
		if {$s == $e} {
		    set data $s
		    TO character ;# N25
		} else STOP ;# N26
	    }
	    %range {
		set data [marpa unicode unfold [list $data]]
		TO charclass ;# N28
	    }
	    ^range {
		STOP ;# N29
	    }
	    ^%range {
		set data [marpa unicode unfold [list $data]]
		TO ^charclass ;# N30
	    }
	    named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO %named-class ;# N32
		    }
		    *   STOP
		}
	    }
	    %named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO %named-class ;# N36
		    }
		    *   STOP
		}
	    }
	    ^named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO ^%named-class ;# N40
		    }
		    *   STOP
		}
	    }
	    ^%named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO ^%named-class ;# N44
		    }
		    *   STOP
		}
	    }
	    byte {
		STOP ;# N47
	    }
	    brange {
		STOP ;# N48
	    }
	    default FAIL
	}
	# Recurse (tailcall -> loop)
    }
}

proc ::marpa::slif::literal::FAIL {} {
    upvar 1 type type data data
    X "Unable to normalize type ($type ($data))" \
	SLIF LITERAL INTERNAL
}

proc ::marpa::slif::literal::TO {new args} {
    debug.marpa/slif/literal {}
    upvar 1 type type
    set type $new
    return -code continue
}

proc ::marpa::slif::literal::STOP {} {
    debug.marpa/slif/literal {}
    upvar 1 type type data data
    return -code return [linsert $data 0 $type]
}

proc ::marpa::slif::literal::eltype {ccelement} {
    debug.marpa/slif/literal {}
    if {[string is int -strict $ccelement]} {
	return character
    } elseif {[string is list -strict $ccelement] && ([llength $ccelement] == 2)} {
	return range
    } else {
	return named-class
    }
}

proc ::marpa::slif::literal::ccunfold {data} {
    debug.marpa/slif/literal {}
    # Goes beyond `marpa unicode unfold` to handle named classes in
    # the data as well.

    lassign [ccsplit $data] codes named
    # inlined cc, dropped superfluous norm-class
    set     codes [marpa unicode unfold $codes]
    lappend codes {*}[lsort -dict -unique [lmap n $named { set _ %$n }]]
    return $codes
}

proc ::marpa::slif::literal::ccranges {data} {
    debug.marpa/slif/literal {}
    lassign [ccsplit $data] codes names
    foreach name $names {
	if {[regexp {^%(.*)$} $name -> base]} {
	    set ccodes [marpa unicode data cc ranges $base]
	    set ccodes [marpa unicode unfold $ccodes]
	} else {
	    set ccodes [marpa unicode data cc ranges $name]
	}
	lappend codes {*}$ccodes
    }
    return [marpa unicode norm-class $codes]
}

proc ::marpa::slif::literal::ccsplit {data} {
    debug.marpa/slif/literal {}
    set named {}
    set codes {}
    foreach value $data {
	switch -exact -- [eltype $value] {
	    character - range {
		lappend codes $value
	    }
	    named-class {
		lappend named $value
	    }
	}
    }
    list $codes $named
}

proc ::marpa::slif::literal::decode {type litstring} {
    debug.marpa/slif/literal {}
    list $type {*}[switch -glob -- $type {
	*string    { decode-string $litstring }
	*charclass { decode-class  $litstring }
	default {
	    X "Unable to decode bogus type \"$type\"" \
		SLIF LITERAL INTERNAL
	}
    }]
}

proc ::marpa::slif::literal::decode-string {litstring} {
    debug.marpa/slif/literal {}
    upvar 1 type type
    set codes [lmap ch [split $litstring {}] { marpa unicode point $ch }]
    if {$type eq {%string}} {
	set codes [marpa unicode fold/c $codes]
    }
    return $codes
}

proc ::marpa::slif::literal::decode-class {litstring} {
    debug.marpa/slif/literal {}
    # literal = element* (escapes aready handled, ditto negation),
    # where
    #   element = [:\w+:]       - named posix character class
    #           | char '-' char - range of characters
    #           | char          - single character
    ##

    set codes {}
    set named {}
    while {$litstring ne {}} {
	switch -matchvar match -regexp -- $litstring {
	    "^\\\[:(\\w+):\\\](.*)$" {
		lassign $match _ name litstring
		lappend named $name
	    }
	    {^(.)-(.)(.*)$} {
		lassign $match _ start end litstring
		lappend codes [list [marpa unicode point $start] \
				   [marpa unicode point $end]]
	    }
	    {^(.)(.*)$} {
		lassign $match _ character litstring
		lappend codes [marpa unicode point $character]
	    }
	    default {
		# Should not be reachable, the last pattern above
		# should always match, taking a simple character off
		# from the front of the literal.
		X "Unable to decode remainder of char-class: \"$litstring\"" \
		    SLIF LITERAL INTERNAL ;# internal error - semantic/syntax mismatch
	    }
	}
    }
    return [cc $codes $named]
}

proc ::marpa::slif::literal::cc {codes named} {
    debug.marpa/slif/literal {}
    set     codes [marpa unicode norm-class $codes]
    lappend codes {*}[lsort -dict -unique $named]
    return $codes
}

proc ::marpa::slif::literal::type {litstring nocase} {
    debug.marpa/slif/literal {}
    # litstring = ['].*[']  - string
    #           | '['.*']'  - charclass
    #           | '[^'.*']' - negated (^) charclass

    set nocase [expr {$nocase ? "%" : "" }]
    switch -glob -- $litstring {
	'*' {
	    set type ${nocase}string
	    set litstring [string range $litstring 1 end-1]
	}
	{\[^*\]} {
	    set type ^${nocase}charclass
	    set litstring [string range $litstring 2 end-1]
	}
	{\[*\]} {
	    set type ${nocase}charclass
	    set litstring [string range $litstring 1 end-1]
	}
	default {
	    X "Unable to determine type of literal \"$litstring\"" \
		SLIF LITERAL UNKNOWN TYPE $litstring
	}
    }

    return [list $type [unescape $litstring]]
}

proc ::marpa::slif::literal::unescape {litstring} {
    debug.marpa/slif/literal {}
    return [subst -nocommands -novariables $litstring]
}

proc ::marpa::slif::literal::tags {litstring} {
    debug.marpa/slif/literal {}
    # litstring = .*(:i|:ic)*
    # Decode and strip literal modifiers

    set nocase 0
    while {1} {
	switch -glob -- $litstring {
	    *:i {
		set litstring [string range $litstring 0 end-2]
		set nocase 1
		continue
	    }
	    *:ic {
		set litstring [string range $litstring 0 end-3]
		set nocase 1
		continue
	    }
	}
	break
    }
    return [list $litstring $nocase]
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

    forward SYM  marpa::slif::literal::symbol
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
