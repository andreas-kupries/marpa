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
# Package marpa::slif::literal::util 0
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
# Meta subject     marpa literal transform reduction case-folding
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

# Unicode tables, classes, operations.
package require marpa::unicode

debug define marpa/slif/literal/util

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal::util {
    namespace export   eltype ccunfold ccnorm ccsplit ccranges symbol
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::util::eltype {ccelement} {
    debug.marpa/slif/literal/util {}
    if {[string is int -strict $ccelement]} {
	return character
    } elseif {[string is list -strict $ccelement] && ([llength $ccelement] == 2)} {
	return range
    } else {
	return named-class
    }
}

proc ::marpa::slif::literal::util::ccunfold {data} {
    debug.marpa/slif/literal/util {}
    # Goes beyond `marpa unicode unfold` to handle named classes in
    # the data as well.

    lassign [ccsplit $data] codes named
    # inlined cc, dropped superfluous norm-class
    set     codes [marpa unicode unfold $codes]
    lappend codes {*}[lsort -dict -unique [lmap n $named { set _ %$n }]]
    return $codes
}

proc ::marpa::slif::literal::util::ccranges {data} {
    debug.marpa/slif/literal/util {}
    lassign [ccsplit $data] codes names
    foreach name $names {
	# Note: %foo is handled by data cc ranges
	lappend codes {*}[marpa unicode data cc ranges $name]
    }
    return [marpa unicode norm-class $codes]
}

proc ::marpa::slif::literal::util::ccnorm {data} {
    debug.marpa/slif/literal/util {}
    lassign [ccsplit $data] codes names
    lappend r {*}[marpa unicode norm-class $codes]
    lappend r {*}[lsort -dict -unique $names]
    return $r    
}

proc ::marpa::slif::literal::util::ccsplit {data} {
    debug.marpa/slif/literal/util {}
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

proc ::marpa::slif::literal::util::symbol {literal} {
    debug.marpa/slif/literal/util {}
    variable typecode
    set data [lassign $literal type]

    append symbol @ [symtype $type] :<
    foreach element $data {
	switch -exact -- [eltype $element] {
	    character {
		# Single character
		append symbol [symchar $element]
	    }
	    range {
		# Character range
		lassign $element s e
		append symbol [symchar $s] - [symchar $e]
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

proc ::marpa::slif::literal::util::symtype {type} {
    debug.marpa/slif/literal/util {}
    return [dict get {
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
    } $type]
}

proc ::marpa::slif::literal::util::symchar {codepoint} {
    debug.marpa/slif/literal/util {}

    if {$codepoint > [marpa unicode bmp]} {
	# Beyond the BMP, \u notation
	return \\u[format %x $codepoint]
    }
    # TODO XXX: handle control > 127 as \u, not octal
    # TODO XXX: Divorce from `char quote tcl` ? Do our own ?
    return [char quote tcl [format %c $codepoint]]
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::util 0
return
