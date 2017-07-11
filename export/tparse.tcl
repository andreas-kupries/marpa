# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator)
##
# - Output format: Tcl code
#   Subclass of "marpa::engine::tcl::lex" with embedded deconstructed (*) grammar
#   (*) The various pieces used to configure the lexer base class.
#
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

# Implied:
# - marpa::export::tparse::template
# - marpa::slif::container
# - marpa:: ... :: reduce

debug define marpa/export/tparse
debug prefix marpa/export/tparse {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::tparse {
    namespace export serial container
    namespace ensemble create

    namespace import ::marpa::export::config

    variable self [info script]
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::tparse::container {gc} {
    debug.marpa/export/tparse {}
    return [Generate [$gc serialize]]
}

proc ::marpa::export::tparse::Generate {serial} {
    debug.marpa/export/tparse {}

    # Create a local copy of the grammar for the upcoming
    # rewrites. This also gives us the opportunity to validate the
    # input.
    
    set gc [marpa::slif::container new]
    $gc deserialize $serial
    $gc validate

    # First rewrite is replacement of higher-precedenced rules with
    # groups encoding the precedence directly in their structure. (**)

    marpa::slif::precedence 2container \
	[marpa::slif::precedence rewrite $gc] \
	$gc

    # Second rewrite is of the literals to forms supported by the
    # engine.
    
    marpa::slif::literal r2container \
	[marpa::slif::literal reduce [concat {*}[lmap {sym rhs} [dict get [$gc l0 serialize] literal] {
	    list $sym [lindex $rhs 0]
	}]] {
	    D-STR1 D-%STR  D-CLS3  D-^CLS2
	    D-NCC3 D-%NCC1 D-^NCC2 D-^%NCC1
	    K-RAN  D-%RAN  K-^RAN  K-CHR
	    K-^CHR
	}] $gc
    # Types we can get out of the reduction:
    # - character,   ^character
    # - charclass,   ^charclass
    # - named-class, ^named-class
    # - range,       ^range

    # TODO: Putting the names and other meta information to the engines.
    # TODO: Handling actual user semantics.
    
    # Next, pull the various required parts out of the container ...

    set sem  [$gc lexeme-semantics? action]
    set latm [$gc l0 latm]
    set have [$gc l0 classes]
    foreach {class var} {
	literal lit
	{}      l0symbols
	discard discards
	lexeme  lex
    } {
	if {$class ni $have} {
	    set $var {}
	} else {
	    set $var [$gc l0 symbols-of $class]
	}
    }

    set g1symbols [$gc g1 symbols-of {}]
    # Ignoring class 'terminal'. That is the same as the l0 lexemes,
    # and the semantics made sure, as did the container validation.

    # sem       :: map ('array -> list(semantic-code))
    # latm      :: map (sym -> bool) (sym == lexemes)
    # lit       :: list (sym)
    # l0symbols :: list (sym) - as is
    # discard   :: list (sym) - as is
    # lex       :: list (sym)

    # ... And transform them into the form required by the template

    # sem - Check for array, and unpack...
    if {[dict exists $sem array]} {
	set semantics [dict get $sem array]
    } else {
	# TODO: Test case required -- Check what the semantics and syntax say
	error XXX
    }

    set start [$gc start?]

    lassign [ConvertLiterals $gc $lit] characters classes
    set l0rules {}
    ExtendRules l0rules $gc l0 $l0symbols
    ExtendRules l0rules $gc l0 $discards
    ExtendRules l0rules $gc l0 $lex
    lappend l0symbols {*}$discards

    set g1rules {}
    ExtendRules g1rules $gc g1 $g1symbols

    set characters [FormatDict $characters 0] ; # literal: map sym -> char
    set classes    [FormatDict $classes]    ; # literal: map sym -> spec
    set discards   [FormatList $discards]   ; # list (sym)
    set lexemes    [FormatDict $latm 0]       ; # map (sym -> latm)
    set l0symbols  [FormatList $l0symbols]  ; # list (sym)
    set l0rules    [FormatList $l0rules]    ; # list (rule)
    #   semantics  -                            list (semantic-code)
    set g1symbols  [FormatList $g1symbols]  ; # list (sym)
    set g1rules    [FormatList $g1rules]    ; # list (rule)

    $gc destroy

    lappend map {*}[config]
    lappend map @characters@    $characters
    lappend map @classes@       $classes
    lappend map @discards@      $discards
    lappend map @lexemes@       $lexemes
    lappend map @l0-symbols@    $l0symbols
    lappend map @l0-rules@      $l0rules
    lappend map @l0-semantics@  $semantics
    lappend map @g1-symbols@    $g1symbols
    lappend map @g1-rules@      $g1rules
    lappend map @start@         $start

    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

proc ::marpa::export::tparse::ExtendRules {rv gc area symbols} {
    debug.marpa/export/tparse {}
    upvar 1 $rv rules

    # Remember last declared action, to avoid superfluous
    # redefinition. Implied, if all rules have the same action it is
    # defined only once.
    set lastaction {}
    
    foreach sym $symbols {
	foreach def [$gc $area get $sym] {
	    Process $def $area $sym
	}
    }
    return
}

proc ::marpa::export::tparse::Process {def area sym} {
    debug.marpa/export/tparse {}
    upvar 1 rules rules lastaction lastaction
    switch -exact -- [lindex $def 0] {
	priority {
	    set attr [lassign $def _ rhs _]
	    dict with attr {}
	    Action
	    Name
	    set op {}
	    if {($area eq "g1") && [info exists mask] && ("1" in $mask)} {
		lappend op :M [Remask $mask]
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

proc ::marpa::export::tparse::Name {} {
    debug.marpa/export/tparse {}
    upvar 1 name name area area rules rules
    # Ignore for L0, and no name, or empty.
    if {$area ne "g1"} return
    if {![info exists action]} return
    if {$action eq {}} return

    # Declare name for the next rule
    lappend rules [list __ :N $name]
    return
}

proc ::marpa::export::tparse::Action {} {
    debug.marpa/export/tparse {}
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
	    error XXX ;# non-array not supported yet.
	}
    }

    set lastaction $action
    return
}

proc ::marpa::export::tparse::Remask {mask} {
    debug.marpa/export/tparse {}
    # Convert mask from the semantics: list (bool), true => hide, 0 => visible
    # The engine takes a list of indices to remove instead.
    set i -1
    set filter {}
    foreach flag $mask {
	incr i
	if {!$flag} continue
	lappend filter $i
    }
    return $filter
}

proc ::marpa::export::tparse::ConvertLiterals {gc symbols} {
    debug.marpa/export/tparse {}
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

proc ::marpa::export::tparse::+CH {spec} {
    upvar 1 characters characters sym sym
    lappend characters $sym $spec
    return
}

proc ::marpa::export::tparse::+CL {spec} {
    upvar 1 classes classes sym sym
    lappend classes $sym $spec
    return
}

proc ::marpa::export::tparse::CC {ccelts} {
    join [lmap elt $ccelts {
	switch -exact -- [::marpa::slif::literal::eltype $elt] {
	    character   { CX $elt    }
	    range       { RA {*}$elt }
	    named-class { NC $elt    }
	}
    }] ""
}

proc ::marpa::export::tparse::RA {s e} {
    debug.marpa/export/tparse {}
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

proc ::marpa::export::tparse::NC {name} {
    debug.marpa/export/tparse {}
    return "\[:${name}:\]"
}

proc ::marpa::export::tparse::Class {spec} {
    debug.marpa/export/tparse {}
    return "\[${spec}\]"
}

proc ::marpa::export::tparse::NegC {spec} {
    debug.marpa/export/tparse {}
    return "\[^${spec}\]"
}

proc ::marpa::export::tparse::CX {code} {
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

proc ::marpa::export::tparse::Char {code} {
    debug.marpa/export/tparse {}
    return [char quote tcl [format %c $code]]
}

proc ::marpa::export::tparse::FormatList {words {listify 1}} {
    debug.marpa/export/tparse {}
    # The context of the list in the template is
    # <TAB>return {@@}
    # where @@ is the laceholder for the list.
    # For proper formatting we have to indent, plus additional leading
    # and trailing newlines.
    set prefix "\n\t    "
    set words [lsort -dict $words]
    if {$listify} {
	set words [lmap w $words { list $w }]
    }
    return "$prefix[join $words $prefix]\n\t"
}

proc ::marpa::export::tparse::FormatDict {dict {listify 1}} {
    debug.marpa/export/tparse {}
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

    return [FormatList $lines 0]
}

# # ## ### ##### ######## #############
return
##
## Template following (`source` will not process it)
# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
##
##	Tparse (*) Engine for SLIF Grammar "@slif-name@"
##	Generated On @generation-time@
##		  By @tool-operator@
##		 Via @tool@
##
##	(*) Tcl-based Parser

package provide @slif-name@ @slif-version@

# # ## ### ##### ######## #############
## Requisites

package require marpa	      ;# marpa::slif::container
package require Tcl 8.5       ;# -- Foundation
package require TclOO         ;# -- Implies Tcl 8.5 requirement.
package require debug         ;# Tracing
package require debug::caller ;#

# # ## ### ##### ######## #############

debug define marpa/grammar/@slif-name@
debug prefix marpa/grammar/@slif-name@ {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create @slif-name@ {
    superclass marpa::engine::tcl::parse

    # Lifecycle: No constructor needed. No state.
    # All data is embedded as literals into methods

    # Declare the various things needed by the engine for its
    # operation.  To get the information the base class will call on
    # these methods in the proper order. The methods simply return the
    # requested information. Their base-class implementations simply
    # throw errors, thus preventing the construction of an incomplete
    # parser.
    
    method Characters {} {
	debug.marpa/grammar/@slif-name@
	# Literals: The directly referenced (allowed) characters.
	return {@characters@}
    }
    
    method Classes {} {
	debug.marpa/grammar/@slif-name@
	# Literals: The character classes in use
	return {@classes@}
    }
    
    method Lexemes {} {
	debug.marpa/grammar/@slif-name@
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {@lexemes@}
    }
    
    method Discards {} {
	debug.marpa/grammar/@slif-name@
	# Discarded symbols (whitespace)
	return {@discards@}
    }
    
    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.marpa/grammar/@slif-name@
	return {@l0-symbols@}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.marpa/grammar/@slif-name@
	return {@l0-rules@}
    }

    method L0.Semantics {} {
	debug.marpa/grammar/@slif-name@
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {@l0-semantics@}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.marpa/grammar/@slif-name@
	return {@g1-symbols@}
    }

    method G1.Rules {} {
	# Structural rules
	debug.marpa/grammar/@slif-name@
	return {@g1-rules@}
    }

    method Start {} {
	debug.marpa/grammar/@slif-name@
	# G1 start symbol
	return {@start@}
    }
}

# # ## ### ##### ######## #############
return
