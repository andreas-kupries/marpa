# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter -- Common core for related generators (tparse, tlex)
##
# - Output format: Tcl code
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::runtime::tcl 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Functionality shared between
# Meta description the tlex and tparse generators
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::slif::container
# Meta require     marpa::slif::literal::util
# Meta require     marpa::slif::literal::redux
# Meta require     marpa::slif::literal::reduce::2tcl
# Meta require     marpa::slif::precedence
# Meta require     marpa::gen
# Meta require     marpa::gen::remask
# Meta require     marpa::unicode
# Meta subject     marpa {generator tcl}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::slif::container
package require marpa::slif::literal::util
package require marpa::slif::literal::redux
package require marpa::slif::literal::reduce::2tcl
package require marpa::slif::precedence
package require marpa::gen
package require marpa::gen::remask
package require marpa::unicode

debug define marpa/gen/runtime/tcl
debug prefix marpa/gen/runtime/tcl {[debug caller] | }

# # ## ### ##### ######## #############
## Configuration coming out of this supporting module.
#
## General placeholders
#
## @slif-version@    -- Grammar information: Version
## @slif-writer@     -- Grammar information: Author
## @slif-year@       -- Grammar information: Year of authorship
## @slif-name@       -- Grammar information: Name
## @slif-name-tag@   -- Grammar information: Derived from name, tag for Tcl `debug` commands.
## @tool-operator@   -- Name of user invoking the tool
## @tool@            -- Name of the pool generating the output
## @generation-time@ -- Date/Time of when tool was invoked
#
## Engine-specific placeholders
#
## @characters@    -- (lit) dict (symbol name --> character)
## @classes@       -- (lit) dict (symbol name --> class specification [Tcl cc regexp])
## @discards@      -- (l0)  list (symbol name)
## @lexemes@       -- (l0)  dict (symbol name --> boolean [latm flag])
## @l0-symbols@    -- (l0)  list (symbol name)
## @l0-rules@      -- (l0)  list (rule-specification)
## @l0-semantics@  -- (l0)  list (array-descriptor-code)
## @l0-events@     -- (l0)  dict (symbol name -> (type -> (event name -> boolean)))
## @g1-symbols@    -- (g1)  list (symbol name)
## @g1-rules@      -- (g1)  list (rule-specification) [%%]
## @g1-events@     -- (g1)  dict (symbol name -> (type -> (event name -> boolean)))
## @start@         -- (g1)  symbol name
##
## [Ad %%] special forms declare the g1 rule semantics and names

namespace eval ::marpa::gen::runtime {}
namespace eval ::marpa::gen::runtime::tcl {
    namespace import ::marpa::gen::config ::marpa::unicode::bmp
    rename config core-config
    namespace export config gc
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::runtime::tcl::gc {serial} {
    debug.marpa/gen/runtime/tcl {}

    set gc [Ingest $serial]
    EncodePrecedences $gc
    LowerLiterals     $gc

    RefactorRanges $gc
    return $gc
}

proc ::marpa::gen::runtime::tcl::RefactorRanges {gc} {
    debug.marpa/gen/runtime/tcl {}
    # Global refactoring of codepoint ranges.  This is the local
    # equivalent of ::marpa::gen::runtime::c::RefactorRanges (**) for
    # byte ranges.  This here operates on the ranges coming out of the
    # grammar and due to ASSR generation for SMP charclasses.
    #
    # For the big explanation of benefits see (**).

    # NOTE: The puts statements with AAA and ZZZ prefixes can be used
    # print the set of ranges as pseudo bitmaps, showing the
    # distribution before and after the refactoring. Extract them with
    # grep, then sort by start and end bytes.
    #
    # - Lets see, a bit difficult, the overall range is so much larger
    # - for the codepoints (65536...1114111 vs 0...255).

    set ranges {}   ; # ranges :: (start -> (stop -> symbol))
    set cover  {}   ; # cover  :: ((start,stop) -> sym)

    foreach sym [$gc l0 symbols-of literal] {
	set details [lassign [lindex [$gc l0 get $sym] 0] type]
	if {$type eq "range"} {
	    lassign $details start stop
	    debug.marpa/gen/runtime/tcl {Range: $sym ($start - $stop)}
	    # Print range as bitmap.
	    #puts AAA_[format %3d $start]-[format %3d $stop]|[string repeat { } [expr {$start-1}]][string repeat * [expr {$stop-$start+1}]]

	    # Collect ranges with the same start together.
	    dict set ranges $start $stop $sym

	    # Collect range to symbol mapping for re-use of existing
	    # definition where possible.
	    dict set cover [list $start $stop] $sym
	} elseif {$type eq "character"} {
	    # type is a "character". We put this into the symbol
	    # mapping for reuse, but not in the table for refactoring.
	    lassign $details byte
	    debug.marpa/gen/runtime/tcl {Byte: $sym ($byte)}
	    dict set cover [list $byte $byte] $sym
	}
    }

    #debug.marpa/gen/runtime/tcl {[debug::pdict $cover]}

    while {[dict size $ranges]} {
	# ranges is the table/queue of things to refactor.
	set start [lindex [lsort -integer [dict keys $ranges]] 0]
	# We iterate over the collected ranges by ascending start.
	# This way any new ranges we may create below for suffixes is
	# added in places we will look at and process later. There is
	# no need to go backward for reprocessing of added things.

	# Take definition, drop it from queue, we will be done with it.
	set defs [dict get $ranges $start]
	dict unset ranges $start

	debug.marpa/gen/runtime/tcl {Processing [format %3d $start] :: [dictsort $defs]}

	# For each set of ranges starting at the same point, sort them
	# by ascending endpoint. The first definition stands as is. If
	# it is the sole definition we drop the entire set from
	# processing.

	if {[llength [dict keys $defs]] == 1} {
	    debug.marpa/gen/runtime/tcl {...Single range, skip}
	    continue
	}

	# All definitions after the first become an alternation of
	# prefix and suffix range, the latter is the subtraction of
	# the prefix from the full range, making it smaller. That part
	# may re-use an existing range definition. Note that the
	# suffix may be refactored too. As the start of any suffix
	# range is greater than the current start they are processed
	# in upcoming iterations.

	set remainder [lassign [lsort -integer [dict keys $defs]] prefixstop]
	set prefixsym [dict get $defs $prefixstop]

	debug.marpa/gen/runtime/tcl {...Multiple ranges, refactor 2+}

	foreach stop $remainder {
	    debug.marpa/gen/runtime/tcl {...Prefix  ([format %3d $start]-[format %3d $prefixstop]) $prefixsym}

	    set currentsym [dict get $defs $stop]
	    debug.marpa/gen/runtime/tcl {...Current ([format %3d $start]-[format %3d $stop]) $currentsym}

	    # suffix = prefixstop+1 ... stop
	    set suffixstart $prefixstop
	    incr suffixstart

	    set key [list $suffixstart $stop]
	    if {![dict exists $cover $key]} {
		# The suffix range has no symbol yet. Create it as
		# either a character or a range literal, depending on
		# the size of the covered range. Always add it to the
		# coverage map for future reuse.  Add it to the queue
		# for refactoring only if it is a range.  We use names
		# which avoid conflict with the standard symbols
		# coming out of the reducer.

		if {$suffixstart == $stop} {
		    set suffixsym CHR<d$suffixstart>
		    dict set cover [list $suffixstart $suffixstart] $suffixsym
		    $gc l0 literal $suffixsym character $suffixstart

		    debug.marpa/gen/runtime/tcl {...Suffix  ([format %3d $suffixstart]) $suffixsym (CHAR)}
		} else {
		    set suffixsym RAN<d${suffixstart}-d${stop}>
		    dict set cover $key $suffixsym
		    dict set ranges $suffixstart $stop $suffixsym
		    $gc l0 literal $suffixsym range $suffixstart $stop
		    debug.marpa/gen/runtime/tcl {...Suffix  ([format %3d $suffixstart]-[format %3d $stop]) $suffixsym (NEW)}
		}
	    } else {
		# We have a symbol for the suffix. Reuse it. No new
		# entries are needed.
		set suffixsym [dict get $cover $key]
		debug.marpa/gen/runtime/tcl {...Suffix  ([format %3d $suffixstart]-[format %3d $stop]) $suffixsym (reused)}
	    }

	    # create priority alternation of prefix and suffix ranges
	    $gc l0 remove        $currentsym
	    $gc l0 priority-rule $currentsym [list $prefixsym] 0
	    $gc l0 priority-rule $currentsym [list $suffixsym] 0

	    debug.marpa/gen/runtime/tcl {...Replace $currentsym ::= $prefixsym | $suffixsym}

	    # The processed definition becomes the prefix for the next.
	    set prefixstop $stop
	    set prefixsym  $currentsym
	}
    }

    if 0 {
	# post refactoring, print new ranges as bitmaps
	foreach sym [$gc l0 symbols-of literal] {
	    set details [lassign [lindex [$gc l0 get $sym] 0] type]
	    if {$type eq "range"} {
		lassign $details start stop
		# Print range as bitmap.
		puts ZZZ_[format %3d $start]-[format %3d $stop]|[string repeat { } [expr {$start-1}]][string repeat {*} [expr {$stop-$start+1}]]
	    }
	}
    }

    #exit 1
    return
}

proc ::marpa::gen::runtime::tcl::config {serial} {
    debug.marpa/gen/runtime/tcl {}

    set gc [gc $serial]
    # Types we can get out of the reduction:
    # - character,   ^character
    # - charclass,   ^charclass
    # - named-class, ^named-class
    # - range,       ^range
    # This is important for `ConvertLiterals` below.
    # Another important result: All literals with these types are
    # limited to codepoints within the BMP. Codepoints in the SMP have
    # been deconstructed into pairs of surrogate (ranges), each within
    # the BMP.

    set semantics [L0Semantics $gc]      ; # map ('array -> list(semantic-code))
    set latm      [$gc l0 latm]          ; # map (sym -> bool) (sym == lexemes)
    set l0events  [$gc l0 events]        ; # map (sym -> (type -> (event -> bool)))
    set lit	  [GetL0 $gc literal]    ; # list (sym)
    set l0symbols [GetL0 $gc {}]         ; # list (sym) - as is
    set discards  [GetL0 $gc discard]    ; # list (sym) - as is
    set lex       [GetL0 $gc lexeme]     ; # list (sym)
    set g1symbols [$gc g1 symbols-of {}] ; # list (sym)
    set g1events  [$gc g1 events]        ; # map (sym -> (type -> (event -> bool)))
    set start     [$gc start?]

    # We ignore g1 class 'terminal'. That is the same as the l0
    # lexemes, and the semantics made sure of that, as did the
    # container validation.

    # Transform into the form required by the template

    lassign [ConvertLiterals $gc $lit] characters classes

    set l0rules {}
    ExtendRules l0rules $gc l0 $l0symbols
    ExtendRules l0rules $gc l0 $discards
    ExtendRules l0rules $gc l0 $lex
    lappend l0symbols {*}$discards

    set g1rules {}
    ExtendRules g1rules $gc g1 $g1symbols

    $gc destroy

    # Generate the configuration for the templating engine.

    set     map [core-config]
    lappend map @characters@    [FormatDict   $characters 0] ; # literal: map sym -> char
    lappend map @classes@       [FormatDict   $classes]      ; # literal: map sym -> spec
    lappend map @discards@      [FormatList   $discards]     ; # list (sym)
    lappend map @lexemes@       [FormatDict   $latm 0]       ; # map (sym -> latm)
    lappend map @l0-symbols@    [FormatList   $l0symbols]    ; # list (sym)
    lappend map @l0-rules@      [FormatList   $l0rules]      ; # list (rule)
    lappend map @l0-semantics@  $semantics                   ; # list (array-descriptor-code)
    lappend map @l0-events@     [FormatEvents $l0events 0]
    lappend map @g1-symbols@    [FormatList   $g1symbols]    ; # list (sym)
    lappend map @g1-rules@      [FormatList   $g1rules 1 0]  ; # list (rule) [%%]
    lappend map @g1-events@     [FormatEvents $g1events 1]
    lappend map @start@         $start                       ; # sym

    return $map
}

# # ## ### ##### ######## #############
## Internals

proc ::marpa::gen::runtime::tcl::Ingest {serial} {
    debug.marpa/gen/runtime/tcl {}

    # Create a local copy of the grammar for the upcoming
    # rewrites. Validate the input as well, now.

    set gc [marpa::slif::container new]
    $gc deserialize $serial
    $gc validate
    return $gc
}

proc ::marpa::gen::runtime::tcl::EncodePrecedences {gc} {
    debug.marpa/gen/runtime/tcl {}

    # Replace higher-precedenced rules with groups of rules encoding
    # the precedences directly into their structure. (**)

    marpa::slif::precedence 2container \
	[marpa::slif::precedence rewrite $gc] \
	$gc
    return
}

proc ::marpa::gen::runtime::tcl::LowerLiterals {gc} {
    debug.marpa/gen/runtime/tcl {}

    # Rewrite the literals into forms supported by the runtime (Tcl engine).

    marpa::slif::literal::redux $gc \
	marpa::slif::literal::reduce::2tcl
    return
}

proc ::marpa::gen::runtime::tcl::GetL0 {gc class} {
        debug.marpa/gen/runtime/tcl {}
    if {$class ni [$gc l0 classes]} {
	return {}
    }
    return [lsort -dict [$gc l0 symbols-of $class]]
}

proc ::marpa::gen::runtime::tcl::L0Semantics {gc} {
    debug.marpa/gen/runtime/tcl {}
    set keys [$gc lexeme-semantics? action]
    # sem - Check for array, and unpack...
    if {![dict exists $keys array]} {
	# TODO: Test case required -- Check what the semantics and syntax say
	error XXX|$keys|
    }
    return [dict get $keys array]
}

proc ::marpa::gen::runtime::tcl::ExtendRules {rv gc area symbols} {
    debug.marpa/gen/runtime/tcl {}
    upvar 1 $rv rules

    # Remember last declared action, to avoid superfluous
    # redefinition. Implied, if all rules have the same action it is
    # defined only once.
    set lastaction {}

    foreach sym [lsort -dict $symbols] {
	foreach def [lsort -dict [$gc $area get $sym]] {
	    Process $def $area $sym
	}
    }
    return
}

proc ::marpa::gen::runtime::tcl::Process {def area sym} {
    debug.marpa/gen/runtime/tcl {}
    upvar 1 rules rules lastaction lastaction
    switch -exact -- [lindex $def 0] {
	priority {
	    set attr [lassign $def _ rhs _]
	    dict with attr {}
	    Action
	    Name
	    set op {}
	    if {($area eq "g1") && [info exists mask] && ("1" in $mask)} {
		lappend op :M [::marpa::gen remask $mask]
	    } else {
		lappend op :=
	    }
	    lappend op {*}$rhs
	    lappend rules [list $sym {*}$op]
	}
	quantified {
	    set attr [lassign $def _ rhs pos]
	    dict with attr {}
	    Action
	    Name
	    set op {}
	    lappend op [expr {$pos ? "+" : "*"}] $rhs
	    if {[info exists separator]} {
		# value = (symbol bool)
		# matches the order of arguments taken by the engine
		lappend op {*}$separator
	    }
	    lappend rules [list $sym {*}$op]
	}
	default {
	    error XXX
	}
    }
    return
}

proc ::marpa::gen::runtime::tcl::Name {} {
    debug.marpa/gen/runtime/tcl {}
    upvar 1 name name area area rules rules
    # Ignore for L0, and no name, or empty.
    if {$area ne "g1"} return
    if {![info exists name]} return
    if {$name eq {}} return

    # Declare name for the next rule
    lappend rules [list __ :N $name]
    return
}

proc ::marpa::gen::runtime::tcl::Action {} {
    debug.marpa/gen/runtime/tcl {}
    upvar 1 lastaction lastaction action action area area rules rules
    # Ignore for L0, and no action, or empty.
    if {$area ne "g1"} return
    if {![info exists action]} return
    if {$action eq {}} return

    # Ignore when not changed since last definition
    if {$action eq $lastaction} return

    # Declare action for all following rules, until a new one is
    # declared.
    lassign $action atype adetails
    switch -exact -- $atype {
	special {
	    switch -exact -- $adetails {
		first {
		    lappend rules [list __ :A Afirst]
		}
		default {
		    error BAD-SPECIAL:$adetails
		}
	    }
	}
	array {
	    lappend rules [list __ :A $adetails]
	}
	default {
	    error BAD-SEMANTICS:$action| ;# non-array not supported yet.
	}
    }

    set lastaction $action
    return
}

proc ::marpa::gen::runtime::tcl::ConvertLiterals {gc symbols} {
    debug.marpa/gen/runtime/tcl {}
    set characters {}
    set classes {}
    foreach sym $symbols {
	foreach def [$gc l0 get $sym] {
	    set data [lassign $def type]
	    switch -exact -- $type {
		character    { +CH [Char $data]			}
		^character   { +CL [NegC  [RA $data $data]]	}
		named-class  { +CL [Class [NC $data]]		}
		^named-class { +CL [NegC  [NC $data]]		}
		range        { +CL [Class [RA {*}$data]]	}
		^range       { +CL [NegC  [RA {*}$data]]	}
		charclass    { +CL [Class [CC $data]]		}
		^charclass   { +CL [NegC  [CC $data]]		}
		default {
		    error XXX
		}
	    }
	}
    }
    return [list $characters $classes]
}

proc ::marpa::gen::runtime::tcl::+CH {spec} {
    upvar 1 characters characters sym sym
    lappend characters $sym $spec
    return
}

proc ::marpa::gen::runtime::tcl::+CL {spec} {
    upvar 1 classes classes sym sym
    lappend classes $sym $spec
    return
}

proc ::marpa::gen::runtime::tcl::CC {ccelts} {
    join [lmap elt $ccelts {
	switch -exact -- [::marpa::slif::literal::util::eltype $elt] {
	    character   { CX $elt    }
	    range       { RA {*}$elt }
	    named-class { NC $elt    }
	}
    }] ""
}

proc ::marpa::gen::runtime::tcl::RA {s e} {
    debug.marpa/gen/runtime/tcl {}
    if {$s == $e} {
	# Equal. Not truly a range
	return [CX $s]
    }
    if {($s == 0) && ($e == [bmp])} {
	# Range covers the entire BMP.
	# This is special to Tcl: dot.
	return "dot"
    }
    set sx [CX $s]
    set ex [CX $e]
    if {$s == ($e - 1)} {
	# Adjacent. Leave the dash out, it is superfluous
	return "${sx}${ex}"
    }
    return "${sx}-${ex}"
}

proc ::marpa::gen::runtime::tcl::NC {name} {
    debug.marpa/gen/runtime/tcl {}
    return "\[:${name}:\]"
}

proc ::marpa::gen::runtime::tcl::Class {spec} {
    debug.marpa/gen/runtime/tcl {}
    if {$spec eq "dot"} { return "." }
    return "\[${spec}\]"
}

proc ::marpa::gen::runtime::tcl::NegC {spec} {
    debug.marpa/gen/runtime/tcl {}
    return "\[^${spec}\]"
}

proc ::marpa::gen::runtime::tcl::CX {code} {
    debug.marpa/gen/runtime/tcl {}
    switch -exact -- $code {
	1  { return "\\001" }
	2  { return "\\002" }
	3  { return "\\003" }
	4  { return "\\004" }
	5  { return "\\005" }
	6  { return "\\006" }
	7  { return "\\007" }
	45 { return "\\055" }
	93 { return "\\135" }
    }
    return [Char $code]
}

proc ::marpa::gen::runtime::tcl::Char {code} {
    debug.marpa/gen/runtime/tcl {}
    
    # Note: Older versions of `char` (v1.0.1 or earlier) convert all
    #       control characters they encounter to octal before checking
    #       for `beyond ASCII`. This causes them to convert non-ASCII
    #       control characters (Ex: \u06dd) into a representation
    #       longer than three octal digits, the max Tcl can handle.
    #       This causes here the generation of bogus character
    #       references and ranges. Forcing \u representation for
    #       non-ASCII in the BMP, and \U above BMP solves the issue.
    #
    # The test grammar `l0-rules/issue-cc-000` demonstrates the bogus
    # output when the next 2 lines are disabled.
    if {$code >   127} { return \\u[format %04x $code] } ;# >ASCII, <=BMP
    if {$code > 65535} { return \\U[format %08x $code] } ;# >BMP
    return [char quote tcl [format %c $code]]
}

proc ::marpa::gen::runtime::tcl::FormatList {words {listify 1} {sort 1}} {
    debug.marpa/gen/runtime/tcl {}
    # The context of the list in the template is
    # <TAB>return {@@}
    # where @@ is the laceholder for the list.
    # For proper formatting we have to indent, plus additional leading
    # and trailing newlines.
    set prefix "\n\t    "
    if {$sort} {
	set words [lsort -dict $words]
    }
    if {$listify} {
	set words [lmap w $words { list $w }]
    }
    return "$prefix[join $words $prefix]\n\t"
}

proc ::marpa::gen::runtime::tcl::FormatDict {dict {listify 1} {sort 1}} {
    debug.marpa/gen/runtime/tcl {}
    # The context of the dict in the template is
    # <TAB>return {@@}
    # where @@ is the laceholder for the list.
    # For proper formatting we have to indent (*), plus additional
    # leading and trailing newlines.
    #
    # (*) <TAB> and 4 <SPACE>

    set maxl 0
    set names [lsort -dict [dict keys $dict]]
    foreach name $names {
	set name [list $name]
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    set maxl [expr {$maxl + 2}]
    set lines {}
    foreach name $names {
	set dname [list $name]
	set value [dict get $dict $name]
	if {$listify} { set value [list $value] }
	lappend lines [format "%-*s %s" \
			   $maxl $dname $value]
    }

    return [FormatList $lines 0 $sort]
}

proc ::marpa::gen::runtime::tcl::FormatEvents {dict multi} {
    # dict = (symbol -> (type -> (event -> bool)))
    if {![dict size $dict]} {
	return $dict
    }
    foreach sym [lsort -dict [dict keys $dict]] {
	set spec [dict get $dict $sym]
	lappend lines "[list $sym] \{"
	foreach type [lsort -dict [dict keys $spec]] {
	    set events [dict get $spec $type]
	    if {$multi} {
		# multiple events per type, show each event on its own line
		lappend lines "    [list $type] \{"
		foreach e [lsort -dict [dict keys $events]] {
		    set state [dict get $events $e]
		    lappend lines "        [list $e] $state"
		}
		lappend lines "    \}"
	    } else {
		# more compact, useful when we have only one event per type
		lappend lines "    [list $type] \{[lrange $events 0 end]\}"
	    }
	}
	lappend lines "\}"
    }
    return "\n\t    [join $lines "\n\t    "]\n\t"
}

# # ## ### ##### ######## #############
package provide marpa::gen::runtime::tcl 1
return
