# -*- tcl -*-
## Data structures and accessors for the management of fold classes.
#
# Copyright 2017-2018 Andreas Kupries
#
# - fold-add-code codepoint up down
# - fold-verify-and-cleanup
# - fold-write-c

# # ## ### ##### ########

proc fold-write-c {} {
    global foldmap foldset foldmax unimax
    # foldmax --> write-h-limits

    pong "Writing folding (C)"

    # simple data structures
    # - foldmap int[]
    # - foldset int[] (size,...)
    #
    # FUTURE: compress into similar pages (with delta coding)

    set k 0
    set sets {}
    set maxn 0
    foreach id [lsort -dict [dict keys $foldset]] {
	dict set idmap $id $k
	set fold [lsort -integer [lsort -unique [dict get $foldset $id]]]
	set nfold [llength $fold]
	if {$nfold > $maxn} { set maxn $nfold }
	lappend sets $nfold {*}$fold
	incr nfold
	incr k $nfold
    }

    set map {}
    set last -1
    foreach ch [lsort -integer [dict keys $foldmap]] {
	incr ch 0
	FOLD-fill map $ch
	set id [dict get $foldmap $ch]
	set k [dict get $idmap $id]
	lappend map $k
    }

    set foldmax $maxn

    write-c-sep {case folding, equivalence sets}
    
    wrc "static int fold_set\[[llength $sets]] = \{"
    write-c-items 24 \t $sets
    wrc "\};"
    wrc ""

    write-c-sep {case folding, map codepoints to set of equivalents}
    wrc "#define FM_SIZE ([llength $map])"
    wrc ""
    wrc "static int fold_map\[FM_SIZE] = \{"
    write-c-items 24 \t $map
    wrc "\};"
    wrc ""

    write-c-sep {case folding, api}

    lappend map "\t\t" \t "\t" {}
    wrc [string map $map {
	void
	marpatcl_unfold (int codepoint, int* n, int** set)
	{
	    int id;
	    if (codepoint >= FM_SIZE) {
		*n = 0;
		return;
	    }
	    id = fold_map [codepoint];
	    if (id < 0) {
		*n = 0;
		return;
	    }
	    *n   = fold_set [id];
	    *set = &fold_set [id+1];
	}
    }]
}

proc fold-verify-and-cleanup {} {
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

proc fold-add-code {codepoint upcase downcase} {
    if {$upcase ne {}} {
	FOLD-def $codepoint 0x$upcase
    }
    if {$downcase ne {}} {
	FOLD-def $codepoint 0x$downcase
    }
    return
}

proc FOLD-def {code fold} {
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

proc FOLD-fill {lv top} {
    upvar 1 $lv l
    while {[llength $l] < $top} { lappend l -1 }
    return
}

# # ## ### ##### ########
## init

global foldid  ; set foldid  0  ;# fold class id counter
global foldmap ; set foldmap {} ;# map codepoint -> fold class
global foldset ; set foldset {} ;# fold class id -> list(codepoint...)
return
