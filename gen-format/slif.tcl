# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator)
##
# - Output format: SLIF
#
#   Use case: Reprint a SLIF grammar after application of
#   transformations.

# TODO: Limit attributes to non-default values
# TODO: Set singular|majority latm information as default
# TODO: Set singular|majority G1 action as default
# TODO: Lift literals into G1 via single-definition lexemes/terminals.
#       (@LEX:...)

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::format::slif 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Generator for SLIF from grammar containers.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     char
# Meta require     marpa::util
# Meta require     marpa::unicode
# Meta require     marpa::gen
# Meta require     marpa::slif::literal::util
# Meta subject     marpa {slif generator}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require char
package require marpa::unicode
package require marpa::gen
package require marpa::util
package require marpa::slif::literal::util

debug define marpa/gen/format/slif
debug prefix marpa/gen/format/slif {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::gen::format::slif {
    namespace export container
    namespace ensemble create

    namespace import ::marpa::gen::config

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::format::slif::container {gc} {
    debug.marpa/gen/format/slif {}
    marpa::fqn gc
    return [Generate [$gc serialize]]
}

# # ## ### ##### ######## #############
## Helpers - Format for readability.
## Snarfed from tests/support/gcontainer_state.tcl

proc ::marpa::gen::format::slif::Generate {serial} {
    debug.marpa/gen/format/slif {}

    lappend map {*}[config]
    lappend map @slif-serial@ [DumpSLIF $serial]

    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

proc ::marpa::gen::format::slif::DumpSLIF {serial} {
    debug.marpa/gen/format/slif {}

    set gc [Ingest $serial]
    # gc = GC serialization = nested dict

    # We can rewrite this dict as we see fit to simplify the generator
    # stages.

    # We cannot do this on the GC object. For example LATM is not
    # stored as rule attribute, making it imposible to move there
    # (missing method, and rejection by object validation).

    # Key structure:
    # global
    #   start -- SYM
    #   inacessible -- ok|warn|error
    # g1
    #   {}
    #     SYM    -- list RULE
    #   terminal
    #     SYM    -- list RULE
    # l0
    #   events
    #     SYM
    #       WHEN
    #         E-NAME -- on|off
    #   latm
    #     SYM -- bool
    #   discard
    #     SYM    -- list RULE
    #   lexeme
    #     SYM    -- list RULE
    #   {}
    #     SYM    -- list RULE
    #   literal
    #     SYM    -- list RULE
    # lexeme -- lexeme semantic action
    #

    RewriteLATM          gc
    RewriteDiscardEvents gc
    RewriteLexemeEvents  gc
    RewriteLiterals      gc
    RewriteRHS           gc

    WInit
    DumpGeneral $gc
    DumpG1      $gc
    DumpL0      $gc
    Close
    return [WGet]
}

proc ::marpa::gen::format::slif::Ingest {serial} {
    debug.marpa/gen/format/slif {}

    # Create a local copy of the grammar for the upcoming
    # rewrites. Validate the input as well, now.

    set gc [marpa::slif::container new]
    $gc deserialize $serial
    $gc validate
    return [$gc serialize]
}

proc ::marpa::gen::format::slif::RewriteLATM {gcv} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc

    if {![dict exists $gc l0 latm]} return
    # The LATM information is stored separate from the lexemes.  Here
    # we pull the information and put into the attributes of the
    # lexeme rules.

    dict for {sym latm} [dict get $gc l0 latm] {
	dict set gc l0 lexeme $sym [lmap rule [dict get $gc l0 lexeme $sym] {
	    lappend rule latm $latm
	}]
    }
    dict unset gc l0 latm
    return
}

proc ::marpa::gen::format::slif::DumpG1Events {gc} {
    debug.marpa/gen/format/slif {}

    # G1 has completed|nulled|predicted events

    if {![dict exists $gc g1 events]} return

    Section "Structural events"
    dict for {sym events} [dict get $gc g1 events] {
	dict for {when spec} $events {
	    lassign $spec name state
	    W "event [AV/name $name] = $state = $when [Sym2Name $sym]"
	}

	dict unset gc g1 events $sym
    }
    W {}
    return
}

proc ::marpa::gen::format::slif::RewriteDiscardEvents {gcv} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc

    if {![dict exists $gc l0 discard]} return
    # The event information for discards is stored separately. Here we
    # move the information into a separate block for pickup by DumpDiscard.

    dict for {sym rules} [dict get $gc l0 discard] {
	if {![dict exists $gc l0 events $sym discard]} continue

	set event [dict get $gc l0 events $sym discard]
	dict unset gc l0 events $sym discard
	dict set gc dis $sym $event
    }
    return
}

proc ::marpa::gen::format::slif::RewriteLexemeEvents {gcv} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc

    if {![dict exists $gc l0 lexeme]} return
    # The event information for lexemes is stored separately. Here we
    # move the information into a separate block for pickup by DumpLexeme.

    dict for {sym rules} [dict get $gc l0 lexeme] {
	if {[dict exists $gc l0 events $sym before]} {
	    set event [dict get $gc l0 events $sym before]
	    dict unset gc l0 events $sym before
	    dict set gc lex $sym [list before $event]

	} elseif {[dict exists $gc l0 events $sym after]} {
	    set event [dict get $gc l0 events $sym after]
	    dict unset gc l0 events $sym after
	    dict set gc lex $sym [list after $event]
	}
    }
    return
}

proc ::marpa::gen::format::slif::RewriteRHS {gcv} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc

    foreach class {{} lexeme discard} {
	RewriteRHS' gc l0 $class
	RewriteRHS' gc g1 $class
    }
    return
}

proc ::marpa::gen::format::slif::RewriteRHS' {gcv area class} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc
    if {![dict exists $gc $area $class]} return
    dict for {sym rules} [dict get $gc $area $class] {
	dict set gc $area $class $sym [lmap rule $rules {
	    set details [lassign $rule type]
	    set details [lreplace $details 0 0 \
			     [RewriteRHS'$type gc $area [lindex $details 0]]]
	    set _ [linsert $details 0 $type]
	}]
    }
    return
}

proc ::marpa::gen::format::slif::RewriteRHS'priority {gcv area rhs} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc
    return [lmap sym $rhs { RewriteRHS'quantified gc $area $sym }]
}

proc ::marpa::gen::format::slif::RewriteRHS'quantified {gcv area rhs} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc
    if {[dict exists $gc $area lit $rhs]} {
	return [dict get $gc $area lit $rhs]
    }
    return [Sym2Name $rhs]
}

proc ::marpa::gen::format::slif::RewriteLiterals {gcv} {
    debug.marpa/gen/format/slif {}
    upvar 1 $gcv gc

    # The literals are recoded from tagged data structures to readable
    # SLIF input. The result is stored in the top level of the GC.

    # Further rewrites then push this information into the l0 rule
    # definitions, replacing the lit symbols with their values

    dict set gc g1 lit {}
    dict set gc l0 lit {}

    if {![dict exists $gc l0 literal]} return

    dict for {sym lit} [dict get $gc l0 literal] {
	dict set gc l0 lit $sym [SlifLit {*}[lindex $lit 0]]
    }
    dict unset gc l0 literal
    return
}

proc ::marpa::gen::format::slif::SlifLit {type args} {
    SlifLit/$type {*}$args
}

proc ::marpa::gen::format::slif::SlifLit/character {uni} {
    return '[C $uni]'
}

proc ::marpa::gen::format::slif::SlifLit/^character {uni} {
    return \[^[C $uni]\]
}

proc ::marpa::gen::format::slif::SlifLit/string {args} {
    return '[join [lmap c $args { C $c }] {}]'
}

proc ::marpa::gen::format::slif::SlifLit/%string {args} {
    return '[join [lmap c $args { C $c }] {}]':i
}

proc ::marpa::gen::format::slif::SlifLit/range {s e} {
    return "\[[C $s]-[C $e]\]"
}

proc ::marpa::gen::format::slif::SlifLit/^range {s e} {
    return "\[^[C $s]-[C $e]\]"
}

proc ::marpa::gen::format::slif::SlifLit/charclass {args} {
    return \[[CC $args imod]\]$imod
}

proc ::marpa::gen::format::slif::SlifLit/^charclass {args} {
    return \[^[CC $args imod]\]$imod
}

proc ::marpa::gen::format::slif::CC {pieces iv} {
    upvar 1 $iv imodifier
    set imodifier ""
    return [join [lmap element $pieces {
	switch -exact -- [marpa::slif::literal::util::eltype $element] {
	    character   { set _ [C $element] }
	    range       { lassign $element s e ; set _ "[C $s]-[C $e]" }
	    named-class {
		if {[string match %* $element]} {
		    set imodifier :i
		    set element [string range $element 1 end]
		}
		set _ "\[:${element}:\]"
	    }
	}
    }] {}]
}


proc ::marpa::gen::format::slif::SlifLit/named-class {name} {
    return "\[\[:${name}:\]\]"
}

proc ::marpa::gen::format::slif::SlifLit/^named-class {name} {
    return "\[^\[:${name}:\]\]"
}

proc ::marpa::gen::format::slif::SlifLit/%named-class {name} {
    return "\[\[:${name}:\]\]:i"
}

proc ::marpa::gen::format::slif::SlifLit/^%named-class {name} {
    return "\[^\[:${name}:\]\]:i"
}

proc ::marpa::gen::format::slif::Section {label} {
    debug.marpa/gen/format/slif {}
    W "# ## #### ####### ############ ####################"
    W "## $label"
    W {}
    return
}

proc ::marpa::gen::format::slif::Close {} {
    debug.marpa/gen/format/slif {}
    W "# ## #### ####### ############ ####################"
    return
}

proc ::marpa::gen::format::slif::DumpGeneral {gc} {
    debug.marpa/gen/format/slif {}
    set start   [dict get $gc global start]
    set inacc   [dict get $gc global inaccessible]
    set laction [dict get $gc lexeme action]

    Section "General configuration"
    W ":start ::= [Sym2Name $start]"
    W "inaccessible is $inacc by default"
    W "lexeme default = action => [AV/action $laction]"
    # Note: LATM flags are listed with each lexeme rule

    W {}
    return
}

proc ::marpa::gen::format::slif::DumpG1 {gc} {
    debug.marpa/gen/format/slif {}

    DumpClass $gc g1 {} "Structure"
    # Ignore terminals

    DumpG1Events $gc
    return
}

proc ::marpa::gen::format::slif::DumpL0 {gc} {
    debug.marpa/gen/format/slif {}

    DumpDiscard $gc l0 discard "Discards"
    DumpLexeme  $gc l0 lexeme  "Lexemes aka Terminals"
    DumpClass   $gc l0 {}      "Lexical"
    return
}

proc ::marpa::gen::format::slif::DumpDiscard {gc area class label} {
    if {![dict exists $gc $area $class]} return

    set map [Symbols [dict get $gc $area $class]]

    Section $label
    foreach {sym sname} $map {
	W ":discard ~ $sname"
	if {[dict exists $gc dis $sym]} {
	    lassign [dict get $gc dis $sym] name state
	    W "           event => [AV/name $name] = $state"
	}
	FormatSymbol $sym $sname $area [dict get $gc $area $class $sym]
    }
    W {}
    return
}

proc ::marpa::gen::format::slif::DumpLexeme {gc area class label} {
    if {![dict exists $gc $area $class]} return

    set map [Symbols [dict get $gc $area $class]]

    Section $label
    foreach {sym sname} $map {
	if {[dict exists $gc lex $sym] ||
	    [dict exists $gc l0 priority $sym]} {
	    W ":lexeme ~ $sname"
	    if {[dict exists $gc lex $sym]} {
		lassign [dict get $gc lex $sym] when spec
		lassign $spec name state
		if {$name ne {}} {
		    W "          event => [AV/name $name] = $state"
		}
		W "          pause => $when"
	    }
	    if {[dict exists $gc l0 priority $sym]} {
		W "          priority => [dict get $gc l0 priority $sym]"
	    }
	}
	FormatSymbol $sym $sname $area [dict get $gc $area $class $sym]
    }
    W {}
    return
}

proc ::marpa::gen::format::slif::DumpClass {gc area class label} {
    if {![dict exists $gc $area $class]} return

    set map [Symbols [dict get $gc $area $class]]

    Section $label
    foreach {sym sname} $map {
	FormatSymbol $sym $sname $area [dict get $gc $area $class $sym]
    }
    W {}
    return
}

proc ::marpa::gen::format::slif::AV/latm {v} {
    # v = bool (0|1)
    return $v
}

proc ::marpa::gen::format::slif::AV/pause {v} {
    # v = on|off
    return $v
}

proc ::marpa::gen::format::slif::AV/event {v} {
    # v = tuple (name state)
    lassign $v name state
    return "[AV/name $name] = $state"
}

proc ::marpa::gen::format::slif::AV/separator {v} {
    # Separator is symbol.
    return [Sym2Name $v]
}

proc ::marpa::gen::format::slif::AV/proper {v} {
    # Proper is boolean, print as-is
    return $v
}

proc ::marpa::gen::format::slif::AV/action {v} {
    # Encode action spec
    lassign $v type details
    switch -exact -- $type {
	array   { return \[[join $details ,]\]	}
	cmd     { return [AV/name $details] }
	special { return ::$details }
	default {
	    return -code error "Unknown action type $type"
	}
    }

    return $v
}

proc ::marpa::gen::format::slif::AV/assoc {v} {
    # Encode assoc spec. Nothing to do, value as-is
    return $v
}

proc ::marpa::gen::format::slif::AV/name {v} {
    # Encode name spec (string, quotes only when required)
    if {[string match {* *} $v]} {
	set v '${v}'
    }
    return $v
}

proc ::marpa::gen::format::slif::Mask {mask rhs} {
    set last 0
    set res {}
    foreach hide $mask sym $rhs {
	if {$hide != $last} {
	    if {$hide} {
		# Start hidden group
		lappend res "(" $sym
	    } else {
		# End hidden group at previous (last) symbol
		lappend res ")" $sym
	    }
	} else {
	    lappend res $sym
	}
	set last $hide
    }
    return $res
}

proc ::marpa::gen::format::slif::Symbols {cmap} {
    debug.marpa/gen/format/slif {}
    # cmap = dict (symbol --> list(rule))

    # Returns a dict keyed by symbols, mapped to the symbol padded for
    # left-justified tabular (aligned) output.

    set syms [lsort -dict [dict keys $cmap]]
    if {![llength $syms]} {
	return {}
    }

    # Generate map from symbols to formatted names (padding to the
    # right for max length, and <>-wrapping (where needed).

    set maxl [lindex [lsort -dict [lmap s $syms {
	string length [Sym2Name $s]
    }]] end]
    set format %-${maxl}s
    foreach s $syms {
	lappend map $s [format $format [Sym2Name $s]]
    }
    return $map
}

proc ::marpa::gen::format::slif::Sym2Name {symbol} {
    if {[string match {* *} $symbol]} {
	return "<${symbol}>"
    }
    return $symbol
}

proc ::marpa::gen::format::slif::FormatSymbol {symbol sname area defs} {
    debug.marpa/gen/format/slif {}

    lassign [Op $area] aop cop bop
    set blank  [string repeat { } [string length $sname]]
    set prefix "$sname $aop"
    set cont   "$blank $cop"
    set attrin "$blank $bop"
    set lastprec 0

    foreach definition $defs {
	set details [lassign $definition type]
	switch -exact -- $type {
	    priority {
		set attr [lassign $details rhs prec]
		# rhs = list (rhs-text)
		if {[dict exists $attr mask]} {
		    set rhs [Mask [dict get $attr mask] $rhs]
		    dict unset attr mask
		}
		if {$lastprec != $prec} {
		    # Precedence change, tweak the operator
		    set prefix [string map {{|  } {|| }} $prefix]
		}
		W "$prefix [join $rhs]"
		DumpAttr $attrin $attr

		set prefix $cont
		set lastprec $prec

	    }
	    quantified {
		set attr [lassign $details rhs pos]
		# rhs = rhs-text
		W "$prefix $rhs [Q $pos]"

		if {[dict exists $attr separator]} {
		    # Split unified attribute into the two it came from
		    lassign [dict get $attr separator] sep proper
		    dict set attr separator $sep
		    dict set attr proper    $proper
		}
		DumpAttr $attrin $attr
		break
	    }
	    default {
		error "Not handling |$definition|"
	    }
	}
    }
    # TODO: RHS. Attributes. (Limit to non-default?)
    return
}

proc ::marpa::gen::format::slif::DumpAttr {prefix attr} {
    debug.marpa/gen/format/slif {}
    foreach a [lsort -dict [dict keys $attr]] {
	set v [dict get $attr $a]
	W "$prefix $a => [AV/$a $v]"
    }
    return
}

proc ::marpa::gen::format::slif::C {uni} {
    # See also ::marpa::slif::literal::util::symchar
    switch -exact -- $uni {
	45 { return "\\55" }
	93 { return "\\135" }
    }
    if {$uni > [marpa unicode bmp]} {
	# Beyond the BMP, \u notation
	return \\u[format %x $uni]
    }
    char quote tcl [format %c $uni]
}

proc ::marpa::gen::format::slif::Q {pos} {
    dict get {
	0 *
	1 +
    } $pos
}

proc ::marpa::gen::format::slif::Op {area} {
    dict get {
	g1 {::= {|  } {   }}
	l0 {~   {|}   { }}
    } $area
}

# # ## ### ##### ######## #############
## Low-level templating commands, buffer management

proc ::marpa::gen::format::slif::WInit {} {
    variable lines {}
    return
}

proc ::marpa::gen::format::slif::WGet {} {
    variable lines
    return $lines
}

proc ::marpa::gen::format::slif::W {text} {
    variable lines
    append lines $text \n
    return
}

proc ::marpa::gen::format::slif::W* {text} {
    variable lines
    append lines $text
    return
}

# # ## ### ##### ######## #############
package provide marpa::gen::format::slif 0
return
##
## Template following (`source` will not process it)
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	Container for SLIF Grammar "@slif-name@"
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##

@slif-serial@
