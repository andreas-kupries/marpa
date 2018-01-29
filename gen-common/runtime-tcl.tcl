# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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
# Meta require     marpa::slif::literal
# Meta require     marpa::slif::precedence
# Meta require     marpa::gen
# Meta require     marpa::gen::remask
# Meta subject     marpa {generator tcl}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::slif::container
package require marpa::slif::literal
package require marpa::slif::precedence
package require marpa::gen
package require marpa::gen::remask

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
## @g1-symbols@    -- (g1)  list (symbol name)
## @g1-rules@      -- (g1)  list (rule-specification) [%%]
## @start@         -- (g1)  symbol name
##
## [Ad %%] special forms declare the g1 rule semantics and names

namespace eval ::marpa::gen::runtime {}
namespace eval ::marpa::gen::runtime::tcl {
    namespace import ::marpa::gen::config
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

    return $gc
}

proc ::marpa::gen::runtime::tcl::config {serial} {
    debug.marpa/gen/runtime/tcl {}

    set gc [gc $serial]
    # Types we can get out of the reduction:
    # - character,   ^character
    # - charclass,   ^charclass
    # - named-class, ^named-class
    # - range,       ^range
    # This is important for `ConvertLiterals` below

    set semantics [L0Semantics $gc]      ; # map ('array -> list(semantic-code))
    set latm      [$gc l0 latm]          ; # map (sym -> bool) (sym == lexemes)
    set lit	  [GetL0 $gc literal]    ; # list (sym)
    set l0symbols [GetL0 $gc {}]         ; # list (sym) - as is
    set discards  [GetL0 $gc discard]    ; # list (sym) - as is
    set lex       [GetL0 $gc lexeme]     ; # list (sym)
    set g1symbols [$gc g1 symbols-of {}] ; # list (sym)
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
    lappend map @characters@    [FormatDict $characters 0] ; # literal: map sym -> char
    lappend map @classes@       [FormatDict $classes]      ; # literal: map sym -> spec
    lappend map @discards@      [FormatList $discards]     ; # list (sym)
    lappend map @lexemes@       [FormatDict $latm 0]       ; # map (sym -> latm)
    lappend map @l0-symbols@    [FormatList $l0symbols]    ; # list (sym)
    lappend map @l0-rules@      [FormatList $l0rules]      ; # list (rule)
    lappend map @l0-semantics@  $semantics                 ; # list (array-descriptor-code)
    lappend map @g1-symbols@    [FormatList $g1symbols]    ; # list (sym)
    lappend map @g1-rules@      [FormatList $g1rules 1 0]  ; # list (rule) [%%]
    lappend map @start@         $start                     ; # sym

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

    marpa::slif::literal r2container \
	[marpa::slif::literal reduce [concat {*}[lmap {sym rhs} [dict get [$gc l0 serialize] literal] {
	    list $sym [lindex $rhs 0]
	}]] {
	    D-STR1 D-%STR  D-CLS3  D-^CLS2
	    D-NCC3 D-%NCC1 D-^NCC2 D-^%NCC1
	    K-RAN  D-%RAN  K-^RAN  K-CHR
	    K-^CHR
	}] $gc
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
	array {
	    lappend rules [list __ :A $adetails]
	}
	default {
	    error XXX|$action| ;# non-array not supported yet.
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
	switch -exact -- [::marpa::slif::literal::eltype $elt] {
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

# # ## ### ##### ######## #############
package provide marpa::gen::runtime::tcl 1
return
