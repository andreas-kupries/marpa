#!/usr/bin/env tclsh
# -*- tcl -*-
# Process UnicodeData.txt and Scripts.txt
# to get categories, scripts, and basic case-folding information.
#
# The information is collected in memory first, and then written as a
# series of Tcl dictionary assignments for easy use by other scripts.
# One other script making use of this information is the compiler from
# the unicode ranges for a class into an utf-8 asbr which matches the
# elements of the class.  The result of that is then used in generator
# backends to provide unicode support.
#
# Copyright 2017 Andreas Kupries

package require Tcl 8.5
package require fileutil
package require lambda
#package require marpa

# Get the generic reader
set     selfdir [file dirname [file normalize [info script]]]
source $selfdir/unicode_reader.tcl

# direct use of the marpa unicode commands, without installed
source $selfdir/../p_unicode.tcl

set pongchan stderr
#set pongchan stdout

# Tcl character classes I. They are created from the base unicode
# categories. See generic/tclUtf.c ("TclUnicharIsXXX").

set derived {
    alpha   {Lu Ll Lt Lm Lo}
    control {Cc Cf Co}
    digit   {Nd}
    space   {Zs Zl Zp}
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
    global asbr    ; set asbr    {} ;# ditto as alternatives of sequences of ranges.
    global gr      ; set gr      {} ;# ditto as actual grammar (left-factored ASBR)
    global foldid  ; set foldid  0  ;# fold class id counter
    global foldmap ; set foldmap {} ;# map codepoint -> fold class
    global foldset ; set foldset {} ;# fold class id -> list(codepoint...)
    global rid     ; set rid     0  ;# range id counter - num unique
    global rnum    ; set rnum    0  ;# counter for all ranges out of ASBR compilation
    global rdef    ; set rdef    {} ;# range -> id
    global rname   ; set rname   {} ;# id -> range

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

    compile-to-asbrs
    compile-to-grammars
    ## compile-folds -- not sensible
    ## - Folds are small classes, just 1-4 elements
    ##   Easier written as direct alternatives of characters.

    write-header
    write-limits
    write-ranges
    write-classes
    write-folding
    write-sep {unidata done}

    pong-done
    return
}

proc cmdline {} {
    # Syntax ==> See usage
    global argv out pong unimax mode
    if {[llength $argv] ni {2 3}} usage
    lassign $argv out mode pong
    if {$mode ni {bmp full}} usage
    if {$pong eq {}} { set pong 1 }
    set out [open $out w]
    set unimax [expr {$mode eq "bmp" ? 0xFFFF : 0x10FFFF }]
    return
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv0 output bmp|full ?pong?"
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
	    add-to-class $key {*}[get-class $cc]
	}
	def-label $key "= [join $spec { + }]"
    }
    return
}

proc get-class {cclass} {
    global cc
    return [dict get $cc $cclass]
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
	set-class $cc [marpa unicode norm [get-class $cc]]
    }
    return
}

proc compile-to-asbrs {} {
    foreach cc [lsort -dict [classes]] {
	pong "Compiling ASBR $cc"
	set asbr [marpa unicode 2asbr [get-class $cc]]
	set pretty [marpa unicode asbr-format $asbr 1]
	set asbr [encode-ranges $asbr]
	set-asbr $cc [list $asbr $pretty]
    }
    return
}

proc encode-ranges {asbr} {
    global rnum
    set newasbr {}
    foreach alternate $asbr {
	# unique ranges
	set newranges {}
	foreach range $alternate {
	    incr rnum
	    lappend newranges [set-range $range]
	}
	lappend newasbr $newranges
    }
    return $newasbr
}

proc set-range {range} {
    global rid rdef rname
    if {[dict exists $rdef $range]} {
	return [dict get $rdef $range]
    }
    set id R[incr rid]
    dict set rdef $range $id
    dict set rname $id $range
    return $id
}

proc compile-to-grammars {} {
    # Note: Ranges are already unique
    # (See compile-to-asbr, must be called beforehand)

    foreach cc [lsort -dict [classes]] {
	pong "Compiling grammar $cc"
	set-grammar $cc [asbr-to-grammar [lindex [get-asbr $cc] 0]]
    }
    return
}


proc asbr-to-grammar {asbr} {
    # Note: Ranges are already unique
    # (See encode-ranges, must be called beforehand)

    # Phase I. Put the ASBR into tree/trie form, links stored in a dict.

    set nid  0  ;# node id counter
    set node {} ;# node -> node-id
    set nval {} ;# node-id -> range
    set tree {} ;# node-id -> list (node-id)
    #           ;# node = (parent-id + range)

    foreach alternate $asbr {
	# Global root for all alternates
	set parent N0

	foreach range $alternate {
	    set key [list $parent $range]

	    if {[dict exists $node $key]} {
		set current [dict get $node $key]
	    } else {
		set current N[incr nid]
		dict set node $key $current
		dict set nval $current $range
	    }

	    # Add, remove duplicates
	    dict lappend tree $parent $current
	    dict set tree $parent [lsort -dict [lsort -unique [dict get $tree $parent]]]

	    set parent $current
	}
    }
    # Each element in tree now points to its possible sucessors,
    # i.e. alternates.

    # Phase II. Scan the tree/trie and generate priority rules
    #           (sequences, alternatives) which embody it.

    set id 0
    set series {}
    set gr     {}

    # Recursively traces the tree and builds the rules in the dict "gr".
    # Upvars the required context: tree nval id gr
    set root [tree-trace series N0]
    set top  [incr id]

    # Flip the enumeration of the rule symbols around. Thye were
    # generated from the back/deep to front/top. Flipped they
    # should be ordered top to bottom.
    dict for {id spec} $gr {
	dict set gr A[expr {$top - $id}] [tree-flip $top $spec]
	dict unset gr $id
    }

    # Normalize the root, must be a single symbol, for one or more
    # alternatives. We can check for "A1", because the last A
    # generated is the one at the top, and after flipping its id
    # is constant "1". If there is no such we have a sequence at
    # the top and have to put a start symbol over it.
    set root [tree-flip $top $root]
    if {$root ne "A1"} {
	dict set gr A0 [list $root]
	set root A0
    }
    dict set gr {} $root

    # Phase III. Linearize the grammar into priority rules, and
    # store the result.

    set rules {}
    foreach sym [lsort -dict [dict keys $gr]] {
	foreach alter [dict get $gr $sym] {
	    lappend rules [list $sym := {*}$alter]
	}
    }

    return $rules
}

proc tree-flip {top spec} {
    global rname
    upvar 1 gr gr
    foreach alter $spec {
	set new {}
	foreach e $alter {
	    if {[dict exists $rname $e]} {
		lappend new $e
	    } else {
		lappend new A[expr {$top - $e}]
	    }
	}
	lappend res $new
    }
    return $res
}

proc tree-trace {sv node} {
    upvar 1 tree tree nval nval id id gr gr
    upvar 1 $sv series

    # Extend the current trace with the range symbol at the tree node,
    # if any.
    if {[dict exists $nval $node]} {
	lappend series [dict get $nval $node]
    }

    # Handle the tree node as per its sucessors.

    if {![dict exist $tree $node]} {
	# Node has no sucessors.  Return the current trace and stop.
	return $series
    }

    set post [dict get $tree $node]
    if {[llength $post] == 1} {
	# Node has a single sucessor.  Recursively extend the trace
	# and stop.
	return [tree-trace series [lindex $post 0]]
    }

    # Node has multiple sucessors.
    # 1. Build sub-trace for each sucessor.
    # 2. Add A(lt)-symbol which refers to all the sub-traces as to the grammar
    # 3. Extend current trace with the new symbol, then return it and stop.

    foreach nx $post { set subseries {} ; lappend alt [tree-trace subseries $nx] }
    set new [incr id]
    dict set gr $new $alt
    lappend series $new
    return $series
}

proc set-asbr {cc x} {
    global asbr
    dict set asbr $cc $x
    return
}

proc get-asbr {cc} {
    global asbr
    return [dict get $asbr $cc]
}

proc set-grammar {cc x} {
    global gr
    dict set gr $cc $x
    return
}

proc get-grammar {cc} {
    global gr
    return [dict get $gr $cc]
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

proc compile-folds {} {
    global foldset
    # foldsets are character classes, of a different kind.
    # As such they can be compiled into ASBR and grammars,
    # and stored as such.

    dict for {fid spec} $foldset {
	pong "Compiling fold class $fid"

	set asbr [marpa unicode 2asbr $spec]
	set asbr [encode-ranges $asbr]
	set gr   [asbr-to-grammar $asbr]

	dict set foldset $fid [list $asbr $gr]
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
    global out
    puts $out $text
    return
}

proc wr* {text} {
    global out
    puts -nonewline $out $text
    return
}

proc write-comment {text} {
    wr "# [join [split $text \n] "\n# "]"
    return
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
    wr {namespace eval marpa::unicode {
    variable cc      ;# character classes as a set of unicode points and ranges
    variable asbr    ;# ditto as alternatives of sequences of byte ranges (utf-8)
    variable gr      ;# ditto as list of priority rules (left-factored ASBR)
    variable range   ;# Adjunct to asbr, and gr, their set of unique byte-ranges
    variable foldmap ;# character mapped to equivalence class under folding
    variable foldset ;# id -> equivalence class under folding
    variable mode    ;# Name of supported unicode range
    variable max     ;# Maximal codepoint in that range
}}
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

proc write-classes {} {
    write-sep {character classes -- named, represented as ranges, asbr, grammar)}
    foreach cc [lsort -dict [classes]] {
	pong "Writing $cc"
	set lcc    [string tolower $cc]
	set gr     [get-grammar $cc]
	lassign    [get-asbr    $cc] asbr pretty
	set ranges [get-class   $cc]
	set sz     [class-size $ranges]
	set label "$cc ($sz)[get-label $cc]"

	set bl [string repeat { } [string length $cc]]

	write-sep $label
	write-comment "I Class $cc: Unicode ranges:  [llength $ranges]"
	write-comment "I       $bl: ASBR alternates: [llength $asbr]"
	write-comment "I       $bl: Grammar rules:   [llength $gr]"
	wr "#"
	write-comment $pretty
	wr ""
	wr "dict set marpa::unicode::cc $lcc \{"
	write-items 5 \t $ranges
	wr "\}"
	wr ""
	wr "dict set marpa::unicode::asbr $lcc \{"
	set max [expr {([llength $asbr] > 9) ? 9 : 1}]
	write-items $max \t $asbr
	wr "\}"
	wr ""
	wr "dict set marpa::unicode::gr $lcc \{"
	write-items 1 \t $gr
	wr "\}"
	wr ""
    }
    return
}

proc write-ranges {} {
    write-sep {character classes -- unique byte ranges in ASBRs/grammars}
    global rname rid rnum
    write-comment "$rid unique ranges out of $rnum"
    wr "set marpa::unicode::range \{"
    write-items 16 \t $rname
    wr "\}"
    wr ""
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
