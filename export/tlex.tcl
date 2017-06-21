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
# - marpa::export::tlex::template
# - marpa::slif::container
# - marpa:: ... :: reduce

debug define marpa/export/tlex
debug prefix marpa/export/tlex {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::tlex {
    namespace export serial container
    namespace ensemble create

    namespace import ::marpa::export::config
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::tlex::container {gc} {
    debug.marpa/export/tlex {}
    return [Generate [$gc serialize]]
}

proc ::marpa::export::tlex::Generate {serial} {
    debug.marpa/export/tlex {}

    # First, reduce the literals in the input to what is supported by
    # the Tcl-engine. We pull the literals to reduce directly out of
    # the serial we have, with some post-processing (strip the rhs to
    # the expected single literal).
    set gc [marpa::slif::container new]
    $gc deserialize $serial
    $gc validate
    
    marpa::slif::literal r2container \
	[marpa::slif::literal reduce [concat {*}[lmap {sym rhs} [dict get $serial l0 literal] {
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

    # Next, pull the various required parts out of the container ...
    
    set sem  [$gc lexeme-semantics? action]
    set latm [$gc l0 latm]
    set have [$gc l0 classes]
    foreach {class var} {
	literal lit
	{}      symbols
	discard discards
	lexeme  lex
    } {
	if {$class ni $have} {
	    set $var {}
	} else {
	    set $var [$gc l0 symbols-of $class]
	}
    }

    # sem     :: map ('array -> list(semantic-code))
    # latm    :: map (sym -> bool) (sym == lexemes)
    # lit     :: list (sym)
    # symbols :: list (sym) - as is
    # discard :: list (sym) - as is
    # lex   :: list (sym)

    # ... And transform them into the form required by the template
    
    # sem - Check for array, and unpack...
    if {[dict exists $sem array]} {
	set semantics [dict get $sem array]
    } else {
	# TODO: Test case required -- Check what the semantics and syntax say
	error XXX
    }
    
    lassign [ConvertLiterals $gc $lit] characters classes
    
    ExtendRules rules $gc $symbols
    ExtendRules rules $gc $discards
    ExtendRules rules $gc $lex
    set characters [FormatDict $characters] ; # literal: map sym -> char
    set classes    [FormatDict $classes]    ; # literal: map sym -> spec
    set discards   [FormatList $discards]   ; # list (sym)		     
    set lexemes    [FormatDict $latm]       ; # map (sym -> latm)
    set symbols    [FormatList $symbols]    ; # list (sym)		     
    set rules      [FormatList $rules]      ; # list (rule)	     
    #   semantics  -                            list (semantic-code)
    
    $gc destroy
    
    lappend map {*}[config]
    lappend map @characters@ $characters
    lappend map @classes@    $classes
    lappend map @discards@   $discards
    lappend map @lexemes@    $lexemes
    lappend map @symbols@    $symbols
    lappend map @rules@      $rules
    lappend map @semantics@  $semantics

    return [string map $map [template get]]
}

proc ::marpa::export::tlex::ExtendRules {rv gc symbols} {
    debug.marpa/export/tlex {}
    upvar 1 $rv rules
    foreach sym $symbols {
	foreach def [$gc l0 get $sym] {
	    switch -exact -- [lindex $def 0] {
		priority {
		    set attr [lassign $def _ rhs _]
		    # L0: name - TODO - currently ignored
		    lappend rules [list $sym := {*}$rhs]
		}
		quantified {
		    set attr [lassign $def _ rhs pos]
		    # L0: name? - TODO - currently ignored
		    set pos  [expr {$pos ? "+" : "*"}]
		    set rule [list $sym $pos $rhs]
		    if {[dict exists $attr separator]} {
			# value = (symbol bool)
			# matches the order of arguments taken by the engine
			lappend rule {*}[dict get $attr separator]
		    }
		    lappend rules $rule
		}
		default {
		    error XXX
		}
	    }
	}
    }
    return
}

proc ::marpa::export::tlex::ConvertLiterals {gc symbols} {
    debug.marpa/export/tlex {}
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

proc ::marpa::export::tlex::+CH {spec} {
    upvar 1 characters characters sym sym
    lappend characters $sym $spec
    return
}

proc ::marpa::export::tlex::+CL {spec} {
    upvar 1 classes classes sym sym
    lappend classes $sym $spec
    return
}

proc ::marpa::export::tlex::CC {ccelts} {
    join [lmap elt $ccelts {
	switch -exact -- [::marpa::slif::literal::eltype $elt] {
	    character   { CX $elt    }
	    range       { RA {*}$elt }
	    named-class { NC $elt    }
	}
    }] ""
}

proc ::marpa::export::tlex::RA {s e} {
    debug.marpa/export/tlex {}
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

proc ::marpa::export::tlex::NC {name} {
    debug.marpa/export/tlex {}
    return "\[:${name}:\]"
}

proc ::marpa::export::tlex::Class {spec} {
    debug.marpa/export/tlex {}
    return "\[${spec}\]"
}

proc ::marpa::export::tlex::NegC {spec} {
    debug.marpa/export/tlex {}
    return "\[^${spec}\]"
}

proc ::marpa::export::tlex::CX {code} {
    switch -exact -- $code {
	45 { return "\\055" }
	93 { return "\\135" }
    }
    return [Char $code]
}

proc ::marpa::export::tlex::Char {code} {
    debug.marpa/export/tlex {}
    return [char quote tcl [format %c $code]]
}

proc ::marpa::export::tlex::FormatList {words {listify 1}} {
    debug.marpa/export/tlex {}
    # The context of the list in the template is
    # <TAB>return {@@}
    # where @@ is the laceholder for the list.
    # For proper formatting we have to indent, plus additional leading
    # and trailing newlines.
    set prefix "\n\t    "
    if {$listify} {
	set words [lmap w $words { list $w }]
    }
    return "$prefix[join $words $prefix]\n\t"
}

proc ::marpa::export::tlex::FormatDict {dict} {
    debug.marpa/export/tlex {}
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
	lappend lines [format "%-*s %s" \
			   $maxl $dname \
			   [list [dict get $dict $name]]]
    }

    return [FormatList $lines 0]
}

# # ## ### ##### ######## #############
return
