# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# See doc/atoms.md

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

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
	lappend codes {*}[marpa unicode data cc ranges $name]
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

proc ::marpa::slif::literal::r2container {worklist container} {
    debug.marpa/slif/literal {}
    foreach {litsymbol literal} $worklist {
	set data [lassign $literal type]
	$container l0 remove $litsymbol
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
    # CC-GRAMMAR - Save a GRAMMAR
    
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
		lassign [ccsplit $data] codes named
		set named [lmap name $named {
		    if {[marpa unicode data cc have-tcl $name]} {
			# supported, pass to result
			set name
		    } else {
			# not supported, get codes, merge
			lappend codes {*}[marpa unicode data cc ranges $name]
			# filter out of result
			continue
		    }
		}]
		IS-A/ charclass {*}[marpa unicode norm-class $codes] {*}$named
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
		lassign [ccsplit $data] codes named
		set named [lmap name $named {
		    if {[marpa unicode data cc have-tcl $name]} {
			# supported, pass to result
			set name
		    } else {
			# not supported, get codes, merge
			lappend codes {*}[marpa unicode data cc ranges $name]
			# filter out of result
			continue
		    }
		}]
		IS-A/ ^charclass {*}[marpa unicode norm-class $codes] {*}$named
	    }
	    ON K-^CLS KEEP
	}
	named-class {
	    ON D-NCC4 {
		# named-class == GRAMMAR (take predefined)
		CC-GRAMMAR [marpa unicode data cc grammar $data $litsymbol]
	    }
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
		# named-class == ASBR (take predefined)
		CC-ASBR [marpa unicode data cc asbr $data]
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
	    # TODO CC-GRAMMAR on the fly
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
		RULES {
		    DEF* [lmap byte [marpa unicode 2utf $data] { L byte $byte }]
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
    RULES {
	foreach rhs $asbr {
	    DEF* [lmap range $rhs { MK-RANGE $range }]
	}
    }
    return
}

proc ::marpa::slif::literal::CC-GRAMMAR {grammar} {
    upvar 1 state state litsymbol litsymbol
    # grammar :: list (rule)
    # rule    :: tuple (sym ":=" rhs...)
    # rhs     :: tuple ("symbol" string) -- symbol ref
    #          | tuple ("range" from to) -- byte range

    # Note how the RHS are mix of symbols and literals.  Note, the
    # data is already rewritten to have unique symbols within the
    # current context. Still to do: Rewrite ranges into proper
    # literals, and aggregate the rules per symbol.

    set rules {}
    foreach rule $grammar {
	set rhs [lmap el [lassign $rule sym __] {
	    set data [lassign $el type]
	    switch -exact -- $type {
		symbol { set el }
		range  { MK-RANGE $data }
	    }
	}]
	dict lappend rules $sym $rhs
    }
    dict for {sym alts} $rules {
	$state place done done $sym [list composite {*}$alts]
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

# # ## ### ##### ######## #############

oo::class create marpa::slif::literal::rstate {
    marpa::E marpa/slif/literal SLIF LITERAL

    variable mywork
    variable myresults
    variable mydef

    # # ## ### ##### ######## #############

    constructor {worklist} {
	debug.marpa/slif/literal {}
	set mywork {}
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
	# literal specs to convert into

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
	set result {}
	foreach litsymbol [lreverse $myresults] {
	    # Reverse order, bottom up from atoms to composites
	    set literal [dict get $mydef $litsymbol]
	    set data    [lassign $literal type]

	    lappend result $litsymbol $literal
	}
	return $result
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
return