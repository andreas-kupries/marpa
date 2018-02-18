#!/usr/bin/env tclsh
# -*- tcl -*-
#
# Process
#     UnicodeData.txt
# and Scripts.txt
# to get categories, scripts, and basic case-folding information.
#
# The information is collected in memory first, and then written as a
# series of Tcl dictionary assignments for easy use by other scripts.
# One other script making use of this information is the compiler from
# the unicode ranges for a class into an utf-8 asbr which matches the
# elements of the class.  The result of that is then used in generator
# backends to provide unicode support.
#
# Copyright 2017-2018 Andreas Kupries

package require Tcl 8.5
package require fileutil
package require lambda

# Get the generic reader
set     selfdir [file dirname [file normalize [info script]]]
source $selfdir/unicode_reader.tcl

# Get pure-Tcl implementations of norm-class, negate-class.

# While these are slower, well, we cannot rely on having an installed
# marpa. And we cannot use the uninstalled marpa code because these
# operations are in C and thus only available after building, and as
# this tool generates a piece needed for building, well.
source $selfdir/unicode_ops.tcl

set pongchan stderr
#set pongchan stdout

# Tcl character classes I. They are created from the base unicode
# categories. See generic/tclUtf.c ("TclUnicharIsXXX"), and tclParse.c
# ("TclIsSpaceProc").

set derived {
    alpha   {Lu Ll Lt Lm Lo}
    control {Cc Cf Co}
    digit   {Nd}
    space   {Zs Zl Zp 0x0009 0x000A 0x000B 0x000C 0x000D 0x180E}
    word    {alpha digit Pc}
    punct   {Pc Pd Ps Pe Pi Pf Po}
    graph   {word punct Mn Me Mc Nl No Sm Sc Sk So}
    alnum   {alpha digit}
    lower   {Ll}
    upper   {Lu}
    print   {graph space}
}

# Tcl character classes II. directly specified ranges and codepoints.
# See generic/regc_locale.c ("UnicharIsXXXX").

set special {
    ascii  {{0 0x7f}}
    blank  {{0x20 0x20} {0x09 0x09}}
    xdigit {{0x41 0x46} {0x61 0x66} {0x30 0x39}}
}

# Nicer labels for the core unicode categories.

set catlabel {
    Cn Unassigned
    Lu Uppercase_Letter
    Ll Lowercase_Letter
    Lt Titlecase_Letter
    Lm Modifier_Letter
    Lo Other_Letter
    Mn Non_spacing_mark
    Me Enclosing_Mark
    Mc Combining_spacing_mark
    Nd Decimal_digit_number
    Nl Letter_number
    No Other_number
    Zs Space_separator
    Zl Line_separator
    Zp Paragraph_separator
    Cc Control
    Cf Format
    Co Private_use
    Cs Surrogate
    Pc Connector_punctuation
    Pd Dash_punctuation
    Ps Open_punctuation
    Pe Close_punctuation
    Pi Initial_quote_punctuation
    Pf Final_quote_punctuation
    Po Other_punctuation
    Sm Math_symbol
    Sc Currency_symbol
    Sk Modifier_symbol
    So Other_symbol
}

proc main {selfdir} {
    global cc      ; set cc      {} ;# char classes as ranges of unicode points
    global foldid  ; set foldid  0  ;# fold class id counter
    global foldmap ; set foldmap {} ;# map codepoint -> fold class
    global foldset ; set foldset {} ;# fold class id -> list(codepoint...)

    cmdline

    process-unidata [file join [file dirname $selfdir] unidata/UnicodeData.txt]
    process-scripts [file join [file dirname $selfdir] unidata/Scripts.txt]

    undef-class Cs ;# No interest in the surrogate block

    make-derived-tcl-classes
    make-direct-tcl-classes

    # Derive negated, case-insensitive classes ?
    # (All combinations: 2^2 = 4 forms, 3 to derive)

    normalize-classes
    clean-folds

    ## compile-folds -- not sensible
    ## - Folds are small classes, just 1-4 elements
    ##   Easier written as direct alternatives of
    ##   characters.

    write-header
    write-limits
    write-classes
    write-folding
    write-sep {unidata done}

    write-c-header
    write-c-limits
    write-c-sep {unidata done}
    
    pong-done
    return
}

proc cmdline {} {
    # Syntax ==> See usage
    global argv outtcl outc pong unimax mode
    if {[llength $argv] ni {3 4}} usage
    lassign $argv mode outtcl outc pong
    if {$mode ni {bmp full}} usage
    if {$pong eq {}} { set pong 1 }
    set outtcl [open $outtcl w]
    set outc   [open $outc w]
    set unimax [expr {$mode eq "bmp" ? 0xFFFF : 0x10FFFF }]
    return
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv0 bmp|full output-for-tcl output-for-c ?pong?"
    exit 1
}

proc process-unidata {file} {
    pong "Processing $file"
    unireader::process [fileutil::cat $file] 15 do-unidata
    return
}

proc do-unidata {first last name category __ __ __ __ __ __ __ __ __ up low __} {
    # Skip above chosen max
    global unimax
    if {$last > $unimax} return

    #                       1    2        3  4  5  6  7  8  9  10 11 12 13  14
    #pong "Unidata $first .. $last = $category"
    add-to-class   $category [list $first $last]
    add-to-folding $first $up $low
    return
}

proc add-to-class {class args} {
    global cc
    dict lappend cc $class {*}$args
    return
}

proc set-class {class ranges} {
    global cc
    dict set cc $class $ranges
    return
}

proc undef-class {class} {
    global cc
    dict unset cc $class
    return
}

proc add-to-folding {codepoint upcase downcase} {
    if {$upcase ne {}} {
	fold $codepoint 0x$upcase
    }
    if {$downcase ne {}} {
	fold $codepoint 0x$downcase
    }
    return
}

proc fold {code fold} {
    global foldmap foldid foldset

    incr code 0 ;# normalize code points to decimal integer, no leading zeros.
    incr fold 0 ;# more portable than 4/6 character hex, and less conversion
    #           ;# later

    # Extend existing sets
    if {[dict exists $foldmap $code]} {
	set fid [dict get $foldmap $code]
	dict lappend foldset $fid $fold
	#puts FA|$code|$fold|$fid|[dict get $foldset $fid|
	return
    }

    if {[dict exists $foldmap $fold]} {
	set fid [dict get $foldmap $fold]
	dict lappend foldset $fid $code
	#puts FB|$code|$fold|$fid|[dict get $foldset $fid|
	return
    }

    # Create new fold set (**)
    set fid @[incr foldid]

    dict set foldmap $code $fid
    dict set foldmap $fold $fid

    dict lappend foldset $fid $code
    dict lappend foldset $fid $fold

    #puts FC|$code|$fold|$fid|[dict get $foldset $fid|
    return
}

proc process-scripts {file} {
    pong "Processing $file"
    unireader::process [fileutil::cat $file] 2 do-script
    return
}

proc do-script {first last script} {
    # Skip above chosen max
    global unimax
    if {$last > $unimax} return

    #pong "Script $first .. $last = $script"
    add-to-class $script [list $first $last]
    return
}

proc make-derived-tcl-classes {} {
    global derived
    foreach {key spec} $derived {
	pong "Making $key"
	set ranges {}
	foreach cc $spec {
	    if {[is-class $cc]} {
		add-to-class $key {*}[get-class $cc]
	    } else {
		add-to-class $key $cc
	    }
	}
	def-label $key "= [join $spec { + }]"
    }
    return
}

proc get-class {cclass} {
    global cc
    return [dict get $cc $cclass]
}

proc is-class {cclass} {
    global cc
    return [dict exists $cc $cclass]
}

proc classes {} {
    global cc
    return [dict keys $cc]
}

proc make-direct-tcl-classes {} {
    global special
    foreach {key spec} $special {
	pong "Making $key"
	# spec = ranges
	add-to-class $key {*}$spec
	def-label    $key special
    }
    return
}

proc def-label {key label} {
    global catlabel
    dict set catlabel $key $label
    return
}

proc get-label {key} {
    global catlabel
    if {[dict exists $catlabel $key]} {
	return " :[dict get $catlabel $key]"
    } else {
	return {}
    }
}

proc normalize-classes {} {
    foreach cc [classes] {
	pong "Normalizing $cc"
	set-class $cc [norm-class [get-class $cc]]
    }
    return
}

proc clean-folds {} {
    global foldmap foldset

    # Check that all characters mapping to a fold set (class) are in
    # that class.
    dict for {ch fid} $foldmap {
	pong "Validating fold $ch"
	set fset [dict get $foldset $fid]
	if {$ch in $fset} continue
	puts "Char $ch mapped to fold $fid ni ($fset)"
	exit 1
    }

    # Look for and purge foldsets which contain only the character
    # itself. These need not be stored. Normally such do not exist.
    # If they do it might have been a trouble with the generating
    # code. Hence also the validation above to find incomplete maps.

    dict for {ch fid} $foldmap {
	pong "Checking fold $ch"
	set fset [dict get $foldset $fid]
	if {[llength $fset] > 1} continue
	lassign $fset backref
	if {$backref != $ch} {
	    error "fold mismatch $ch --> $backref, but not revers"
	}
	dict unset foldmap $ch
	dict unset foldset $fid
    }
    return
}


proc pong {line} {
    global pong pongchan
    if {!$pong} return
    puts -nonewline $pongchan "\r\033\[0K\r$line ..."
    flush $pongchan
    return
}

proc pong-done {} {
    global pong pongchan
    if {!$pong} return
    puts $pongchan "\n... done"
    return
}

proc wr {text} {
    global outtcl
    puts $outtcl $text
    return
}

proc wr* {text} {
    global outtcl
    puts -nonewline $outtcl $text
    return
}

proc write-comment {text} {
    wr "# [join [split $text \n] "\n# "]"
    return
}

proc wrc {text} {
    global outc
    puts $outc $text
    return
}

proc wrc* {text} {
    global outc
    puts -nonewline $outc $text
    return
}

proc write-c-comment {text} {
    wrc "/* [join [split $text \n] "\n# "] */"
    return
}

proc write-c-header {} {
    global mode unimax
    set m $unimax ; incr m 0
    wrc "/* -*- c -*-"
    wrc "** Generator       tools/unidata.tcl"
    wrc "** Data sources    unidata/{UnicodeData,Scripts}.txt"
    wrc "** Build-Time      [clock format [clock seconds]]"
    wrc "** Supported range $mode ($m codepoints)"
    wrc "*/"
    wrc ""
}

proc write-header {} {
    global mode unimax
    set m $unimax ; incr m 0
    wr "# -*- tcl -*-"
    wr "## Generator       tools/unidata.tcl"
    wr "## Data sources    unidata/{UnicodeData,Scripts}.txt"
    wr "## Build-Time      [clock format [clock seconds]]"
    wr "## Supported range $mode ($m codepoints)"
    wr ""
    write-sep {unicode information}
    lappend map {    } {} \t {    }
    wr [string map $map {namespace eval marpa::unicode {
	variable cc      ;# character classes as a set of unicode points and ranges
	variable foldmap ;# character mapped to equivalence class under folding
	variable foldset ;# id -> equivalence class under folding
	variable mode    ;# Name of supported unicode range
	variable max     ;# Maximal codepoint in that range
    }}]
    wr ""
    return
}

proc write-limits {} {
    global mode unimax
    write-sep "unicode limits: $mode = $unimax"
    wr "set marpa::unicode::mode $mode"
    wr "set marpa::unicode::max  $unimax ;# $mode range"
    wr ""
    return
}

proc write-c-limits {} {
    global mode unimax
    write-c-sep "unicode limits: $mode = $unimax"
    lappend map <<unimax>>  $unimax
    lappend map <<unimode>> $mode
    lappend map \t {} {    } {}
    wrc [string map $map {
	#define UNI_MODE "<<unimode>>" /* <<unimax>> codepoints */
	#define UNI_MAX  <<unimax>>
    }]
    return
}

proc write-classes {} {
    write-sep {character classes -- named, represented as ranges)}
    foreach cc [lsort -dict [classes]] {
	pong "Writing $cc"
	set lcc    [string tolower $cc]
	set ranges [get-class   $cc]
	set sz     [class-size $ranges]
	set label "$cc ($sz)[get-label $cc]"

	set bl [string repeat { } [string length $cc]]

	write-sep $label
	write-comment "I Class $cc: Unicode ranges:  [llength $ranges]"
	wr ""
	wr "dict set marpa::unicode::cc $lcc \{"
	write-items 5 \t $ranges
	wr "\}"
	wr ""
    }
    return
}

proc write-items {max pfx items} {
    set col 0
    set prefix $pfx
    foreach item $items {
	wr* $prefix[list $item]
	set prefix { }
	incr col
	if {$col == $max} {
	    set prefix \n$pfx
	    set col 0
	}
    }
    return
}

proc write-sep {label} {
    wr "# _ __ ___ _____ ________ _____________ _____________________ $label"
    wr "##"
    wr ""
    return
}

proc write-c-sep {label} {
    wrc "/* _ __ ___ _____ ________ _____________ _____________________ $label"
    wrc "*/"
    wrc ""
    return
}

proc class-size {ranges} {
    set sz 0
    foreach r $ranges {
	lassign $r s e
	if {$e eq {}} {
	    incr sz 1
	} else {
	    incr sz [expr {$e - $s + 1}]
	}
    }
    return $sz
}

proc write-folding {} {
    global foldmap foldset

    pong "Writing folding"

    set map {}
    foreach ch [lsort -integer [dict keys $foldmap]] {
	# NOTE: ch is normalized to decimal integer without leading zeros.
	incr ch 0
	lappend map $ch [dict get $foldmap $ch]
    }
    write-sep {case folding, map to class}
    wr "set marpa::unicode::foldmap \{"
    write-items 16 \t $map
    wr "\}"
    wr ""

    set map {}
    foreach id [lsort -dict [dict keys $foldset]] {
	lappend map $id [lsort -integer [lsort -unique [dict get $foldset $id]]]
    }
    write-sep {case folding, classes}
    wr "set marpa::unicode::foldset \{"
    write-items 12 \t $map
    wr "\}"
    wr ""

    if 0 {write-sep {character classes - case folding, equivalences}
	foreach fid [lsort -dict [dict keys $foldset]] {
	    # fids match @* -- See [fold](**) for the creation.
	    lassign [dict get $foldset $fid] asbr gr

	    wr "set marpa::unicode::asbr $fid \{"
	    set max [expr {([llength $asbr] > 9) ? 9 : 1}]
	    write-items $max \t $asbr
	    wr "\}"
	    wr ""
	    wr "dict set marpa::unicode::gr $fid \{"
	    write-items 1 \t $gr
	    wr "\}"
	    wr ""
	}}
    return
}

main $selfdir
exit
