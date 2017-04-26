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
	decode decode-string decode-class type unescape tags
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
		set data [ccunfold [list $data]]
		TO charclass ;# N28
	    }
	    ^range {
		STOP ;# N29
	    }
	    ^%range {
		set data [ccunfold [list $data]]
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

proc ::marpa::slif::literal::TO {new} {
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
    lassign [ccsplit $data] codes named
    cc \
	[marpa unicode unfold $codes] \
	[lmap n $named { set _ %$n }]
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
    set     codes [marpa unicode norm $codes]
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

proc ::marpa::slif::literal::box {type args} {
    debug.marpa/slif/literal {}
    return [linsert $args 0 $type]
}


proc ::marpa::slif::literal:: {literaltext} {


}


# # ## ### ##### ######## #############
return
