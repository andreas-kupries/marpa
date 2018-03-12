# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# Conversion of literals to the internal representation.
# See doc/atoms.md
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::parse 0
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
# Meta require     marpa::slif::literal::parser
# Meta require     marpa::slif::literal::norm
# Meta subject     marpa literal transform parsing
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

# Unicode tables, classes, operations.
package require marpa::unicode
package require marpa::slif::literal::parser
package require marpa::slif::literal::norm

debug define marpa/slif/literal/parse

if {![llength [info commands try]]} {
    # Builtin "try" exists from Tcl 8.6 forward. Before that use the
    # 8.5+ compatibility implementation found in Tcllib
    package require try
}

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export parse
    namespace ensemble create
}

namespace eval ::marpa::slif::literal::parse {
    namespace import ::marpa::slif::literal::norm
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::parse {litstring} {
    parse::DO $litstring
}

# # ## ### ##### ######## #############
## Internals

proc ::marpa::slif::literal::parse::DO {litstring} {
    debug.marpa/slif/literal/parse {}
    ::marpa::slif::literal::parser create LD
    try {
	set lit [norm [Decode [LD process $litstring]]]
    } finally {
	LD destroy
    }
    return $lit
}

proc ::marpa::slif::literal::parse::Decode {ast} {
    debug.marpa/slif/literal/parse {}
    Init
    {*}$ast
    Result
}

namespace eval ::marpa::slif::literal::parse {
    variable nocase  0
    variable type    {}
    variable details {}
    variable names   {}
}

proc ::marpa::slif::literal::parse::Init {} {
    debug.marpa/slif/literal/parse {}
    variable nocase  0
    variable type    {}
    variable details {}
    variable names   {}
    return
}

proc ::marpa::slif::literal::parse::Result {} {
    debug.marpa/slif/literal/parse {}
    variable type
    variable details
    variable nocase
    if {$nocase} {
	lappend map %^ ^%
	set type [string map $map %$type]
    }
    return [linsert $details 0 $type]
}

proc ::marpa::slif::literal::parse::literal {values} {
    debug.marpa/slif/literal/parse {}
    #   <single quoted string> <modifiers>
    # | <character class>      <modifiers>
    # | <negated class>        <modifiers>
    # Modifiers first, informs initial normalization
    foreach v [lreverse $values] { {*}$v }
    return
}

proc {::marpa::slif::literal::parse::single quoted string} {values} {
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

proc {::marpa::slif::literal::parse::string elements} {values} {
    # <string element> *
    foreach v $values { {*}$v }
    return
}

proc {::marpa::slif::literal::parse::string element} {values} {
    #   <plain string char>
    # | <escaped char>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::parse::plain string char} {values} {
    variable details
    lappend details [lindex [scan [lindex $values 0 2] %c] 0]
    return
}

proc {::marpa::slif::literal::parse::escaped char} {values} {
    #   unioct
    # | unixhex
    # | control
    {*}[lindex $values 0]
    return
}

proc ::marpa::slif::literal::parse::unioct {values} {
    variable details
    lappend  details [expr 0o[lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::parse::unihex {values} {
    variable details
    lappend details [expr 0x[lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::parse::control {values} {
    variable details
    lappend  details [dict get {
	a  7	b  8	f  12	n  10
	r  13	t  9	v  11	\\ 92
    } [lindex $values 0 2]]
    return
}

proc ::marpa::slif::literal::parse::modifiers {values} {
    # modifier *
    foreach v $values { {*}$v }
    return
}

proc ::marpa::slif::literal::parse::modifier {values} {
    # nocase
    {*}[lindex $values 0]
    return
}

proc ::marpa::slif::literal::parse::nocase {values} {
    # --
    variable nocase 1
    return
}

proc {::marpa::slif::literal::parse::character class} {values} {
    variable type charclass
    variable details
    variable names
    # <cc elements>
    {*}[lindex $values 0]
    set details [CC $details $names]
    return
}

proc {::marpa::slif::literal::parse::negated class} {values} {
    variable type ^charclass
    variable details
    variable names
    # <cc elements>
    {*}[lindex $values 0]
    set details [CC $details $names]
    return
}

proc {::marpa::slif::literal::parse::cc elements} {values} {
    # <cc element> *
    foreach v $values { {*}$v }
    return
}

proc {::marpa::slif::literal::parse::cc element} {values} {
    #   <cc character>
    #   <posix char class>
    # | <cc range>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::parse::cc character} {values} {
    #   <plain cc char>
    # | <escaped char>
    {*}[lindex $values 0]
    return
}

proc {::marpa::slif::literal::parse::plain cc char} {values} {
    variable details
    # Note: We have to unpack the codepoint from the list it came in.
    # Without doing that the `norm-class` call in CC will mis-interpret
    # it as range element, with only a single element, an error.
    lappend details [lindex [scan [lindex $values 0 2] %c] 0]
    return
}

proc {::marpa::slif::literal::parse::posix char class} {values} {
    # add lexeme (class name)
    variable names
    lappend  names [lindex $values 0 2]
    return
}

proc {::marpa::slif::literal::parse::cc range} {values} {
    # <cc character> <cc character>
    foreach v $values { {*}$v }
    # last two elements of details are the range
    # rewrite
    variable details
    set details [linsert [lrange $details 0 end-2] end [lrange $details end-1 end]]
    return
}

# # ## ### ##### ######## #############

proc ::marpa::slif::literal::parse::CC {codes named} {
    debug.marpa/slif/literal/parse {}
    set     codes [marpa unicode norm-class $codes]
    lappend codes {*}[lsort -dict -unique $named]
    return $codes
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::parse 0
return
