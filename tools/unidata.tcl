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
# Copyright 2017-present Andreas Kupries

package require Tcl 8.5
package require fileutil
package require lambda

# Get the generic reader
set     selfdir [file dirname [file normalize [info script]]]
source $selfdir/unicode_reader.tcl
# And the various managers
source $selfdir/uni_fold.tcl
source $selfdir/uni_cclass.tcl
source $selfdir/uni_alias.tcl
source $selfdir/uni_writers.tcl

# Get pure-Tcl implementations of norm-class, negate-class.

# While these are slower, well, we cannot rely on having an installed
# marpa. And we cannot use the uninstalled marpa code because these
# operations are in C and thus only available after building, and as
# this tool generates a piece needed for building, well.
source $selfdir/unicode_ops.tcl

set pongchan stderr
#set pongchan stdout

proc main {selfdir} {
    cmdline

    process-unidata [file join [file dirname $selfdir] unidata/UnicodeData.txt]
    process-scripts [file join [file dirname $selfdir] unidata/Scripts.txt]

    make-derived-tcl-classes
    make-direct-tcl-classes

    # Derive negated, case-insensitive classes ?
    # (All combinations: 2^2 = 4 forms, 3 to derive)

    cc-normalize
    cc-parts
    categories
    fold-verify-and-cleanup

    ## compile-folds -- not sensible
    ## - Folds are small classes, just 1-4 elements
    ##   Easier written as direct alternatives of
    ##   characters.

    write-tcl-header
    write-limits
    alias-write-tcl
    cc-write-tcl
    write-sep {unidata done}

    write-c-header
    fold-write-c

    write-h-header
    write-h-limits
    write-h-sep {unidata done}

    pong-done
    return
}

proc cmdline {} {
    # Syntax ==> See usage
    global argv pong unimax bmpmax
    if {[llength $argv] ni {3 4}} usage
    lassign $argv outtcl outh outc pong
    if {$pong eq {}} { set pong 1 }
    write-destinations $outtcl $outh $outc
    set unimax 0x10FFFF
    set bmpmax 0xFFFF
    return
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv0 output-for-tcl output-for-c-hdr output-for-c ?pong?"
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
    cc-extend $category [list $first $last]

    fold-add-code $first $up $low
    return
}

proc process-scripts {file} {
    pong "Processing $file"
    unireader::process [fileutil::cat $file] 2 do-script
    return
}

proc do-script {first last script} {
    # Skip above chosen max
    global unimax sc
    if {$last > $unimax} return

    #pong "Script $first .. $last = $script"
    cc-extend $script [list $first $last]
    return
}

proc categories {} {
    foreach {cat label} {
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
    } {
	if {![cc-exists $cat]} continue
	cc-label $cat $label

	# Control has custom Tcl definition.
	if {$cat eq "Cc"} continue

	set label [string tolower $label]
	set cat   [string tolower $cat]
	alias-def $label $cat

	foreach suffix { :bmp :smp } {
	    if {![cc-exists $cat$suffix] &&
		![alias-exists $cat$suffix]
	    } continue
	    alias-def $label$suffix $cat$suffix
	}
    }
}

proc make-derived-tcl-classes {} {
    # Tcl character classes I. They are created from the base unicode
    # categories. See generic/tclUtf.c ("TclUnicharIsXXX"), and
    # tclParse.c ("TclIsSpaceProc").
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
    foreach {name spec} $derived {
	pong "Making $name"
	set ranges {}
	foreach cc $spec {
	    if {[cc-exists $cc]} {
		cc-extend $name {*}[cc-get $cc]
	    } else {
		cc-extend $name $cc
	    }
	}
	cc-label $name "= [join $spec { + }]"
    }
    return
}

proc make-direct-tcl-classes {} {
    # Tcl character classes II. directly specified ranges and
    # codepoints.  See generic/regc_locale.c ("UnicharIsXXXX").
    set special {
	ascii  {{0 0x7f}}
	blank  {{0x20 0x20} {0x09 0x09}}
	xdigit {{0x41 0x46} {0x61 0x66} {0x30 0x39}}
    }
    foreach {name spec} $special {
	pong "Making $name"
	# spec = ranges
	cc-extend $name {*}$spec
	cc-label  $name special
    }
    return
}

proc write-h-header {} {
    global unimax bmpmax
    set m $unimax ; incr m 0
    set b $bmpmax ; incr b 0
    wrh "/* -*- c -*-"
    wrh "** Generator:           tools/unidata.tcl"
    wrh "** Data sources:        unidata/{UnicodeData,Scripts}.txt"
    wrh "** Build-Time:          [clock format [clock seconds]]"
    wrh "** Supported range:     $m codepoints"
    wrh "** Basic multi-lingual: $b codepoints"
    wrh "*/"
    wrh ""
}

proc write-c-header {} {
    global unimax bmpmax
    set m $unimax ; incr m 0
    set b $bmpmax ; incr b 0
    wrc "/* -*- c -*-"
    wrc "** Generator:           tools/unidata.tcl"
    wrc "** Data sources:        unidata/{UnicodeData,Scripts}.txt"
    wrc "** Build-Time:          [clock format [clock seconds]]"
    wrc "** Supported range:     $m codepoints"
    wrc "** Basic multi-lingual: $b codepoints"
    wrc "*/"
    wrc ""
    wrc "#include <unidata.h>"
    wrc ""
}

proc write-tcl-header {} {
    global unimax bmpmax
    set m $unimax ; incr m 0
    set b $bmpmax ; incr b 0
    wr "# -*- tcl -*-"
    wr "## Generator:           tools/unidata.tcl"
    wr "## Data sources:        unidata/{UnicodeData,Scripts}.txt"
    wr "## Build-Time:          [clock format [clock seconds]]"
    wr "## Supported range:     $m codepoints"
    wr "## Basic multi-lingual: $b codepoints"
    wr ""
    write-sep {unicode information}
    lappend map {    } {} \t {    }
    wr [string map $map {namespace eval marpa::unicode {
	variable ccalias ;# Map cc alias names to the base cc
	variable cc      ;# character classes as a set of unicode points and ranges
	variable max     ;# Maximal supported codepoint
	variable bmp     ;# Maximal supported codepoint, BMP
    }}]
    wr ""
    return
}

proc write-limits {} {
    global unimax bmpmax
    write-sep "unicode limits"
    wr "set marpa::unicode::max $unimax"
    wr "set marpa::unicode::bmp $bmpmax"
    wr ""
    return
}

proc write-h-limits {} {
    global unimax bmpmax foldmax
    write-h-sep "unicode limits"
    lappend map <<unimax>>  $unimax
    lappend map <<bmpmax>>  $bmpmax
    lappend map <<foldmax>> $foldmax
    lappend map \t {} {    } {}
    wrh [string map $map {
	#define UNI_MAX  <<unimax>>
	#define UNI_BMP  <<bmpmax>>
	#define UNI_FMAX <<foldmax>>

	extern void marpatcl_unfold (int codepoint, int* n, int** set);
    }]
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

main $selfdir
exit
