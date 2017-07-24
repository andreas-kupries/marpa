# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter (Generator)
##
# - Output format: C code, structures for RTC.
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

# Implied:
# - marpa::slif::container
# - marpa:: ... :: reduce

debug define marpa/export/rtc
debug prefix marpa/export/rtc {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval ::marpa::export::rtc {
    namespace export serial container
    namespace ensemble create

    namespace import ::marpa::export::config
    namespace import ::marpa::export::config?

    variable self [info script]
    variable indent {    }
    variable ak {
	start    MARPATCL_SV_START
	length	 MARPATCL_SV_LENGTH  
	g1start	 MARPATCL_SV_G1START 
	g1length MARPATCL_SV_G1LENGTH
	symbol	 MARPATCL_SV_LHS_NAME
	lhs	 MARPATCL_SV_LHS_ID  
	name	 MARPATCL_SV_RULE_NAME
	rule	 MARPATCL_SV_RULE_ID 
	value	 MARPATCL_SV_VALUE   
	values   MARPATCL_SV_VALUE   
    }
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::rtc::container {gc} {
    debug.marpa/export/rtc {}
    return [Generate [$gc serialize]]
}

proc ::marpa::export::rtc::Generate {serial} {
    debug.marpa/export/rtc {}

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
    # engine -- bytes only.

    marpa::slif::literal r2container \
	[marpa::slif::literal reduce [concat {*}[lmap {sym rhs} [dict get [$gc l0 serialize] literal] {
	    list $sym [lindex $rhs 0]
	}]] {
	    D-STR2 D-%STR  D-CLS2  D-^CLS1
	    D-NCC2 D-%NCC2 D-^NCC1 D-^%NCC2
	    D-RAN2 D-%RAN  D-^RAN2 D-CHR
	    D-^CHR
	}] $gc
    # Types we can get out of the reduction:
    # - byte
    
    # Pull various required parts out of the container ...

    set lit       [Get $gc literal]
    set l0symbols [Get $gc {}]
    set discards  [Get $gc discard]
    set lex       [Get $gc lexeme]
    set g1symbols [$gc g1 symbols-of {}]

    # Ignoring class 'terminal'. That is the same as the l0 lexemes,
    # and the semantics made sure, as did the container validation.
    
    # sem       :: map ('array -> list(semantic-code))
    # latm      :: map (sym -> bool) (sym == lexemes)
    # lit       :: list (sym)
    # l0symbols :: list (sym) - as is
    # discards  :: list (sym) - as is
    # lex       :: list (sym)

    # Data processing.

    Bytes create B
    Pool  create P
    Sym   create L  P
    Sym   create G  P
    Rules create LR L P
    Rules create GR G P 1
    SemaG create A
    
    set acs_discards [lmap w $discards { set _ @ACS:$w }]
    set acs_lex      [lmap w $lex      { set _ @ACS:$w }]
    set l0start      @L0:START

    set l0rules [RulesOf $gc l0 [concat $lex $discards $l0symbols]]
    set g1rules [RulesOf $gc g1 $g1symbols]

    P add  1 [concat $l0symbols $discards $lex $acs_discards $acs_lex $lit]
    P add  0 [concat [Names $g1rules] $g1symbols]
    P add* 0 $l0start

    A add $g1rules
    
    # Symbol allocations in L0. See also rtc/spec.h -- Keep In Sync
    #
    # characters  :   0         ... 255
    # ACS lexeme  : 256         ... 256+L-1
    # ACS discard : 256+L       ... 256+L+D-1
    # lexeme      : 256+L+D     ... 256+L+D+L-1   \ spec calls them all `other`
    # discard     : 256+L+D+L   ... 256+L+D+L+D-1 |
    # other       : 256+L+D+L+D ... 256+X-1       /
    #
    # @ terminal   + 256 --> ACS lexeme
    # @ ACS lexeme - 256 --> terminal
    #
    # @ ACS     + (L+D) --> regular
    # @ regular - (L+D) --> ACS

    B add $gc $lit
    L bulk-is [B gaps]
    B destroy

    # Symbols for the covered bytes.
    foreach sym $lit {
	set details [lassign [lindex [$gc l0 get $sym] 0] type]
	# assert: type in (byte brange)
	if {$type ne "byte"} continue
	lassign $details codepoint
	L force $sym $codepoint
    }
    # Symbols for the bytes covered through ranges and nothing else.
    foreach sym $lit {
	set details [lassign [lindex [$gc l0 get $sym] 0] type]
	# assert: type in (byte brange)
	if {$type ne "brange"} continue
	lassign $details start stop
	for {
	    set codepoint $start
	} {$codepoint <= $stop} {
	    incr codepoint
	} {
	    if {[L has-id $codepoint]} continue
	    set bsym [::marpa::slif::literal::symbol [list byte $codepoint]]
	    P add* 1 $bsym
	    L force  $bsym $codepoint
	}
    }
    L skip
    L add [concat $acs_lex $acs_discards $lex $discards $l0symbols]
    # Now make symbols for the brange literals, these are the lhs of
    # the alternations-to-be.
    L add [lmap sym $lit {
	set details [lassign [lindex [$gc l0 get $sym] 0] type]
	# assert: type in (byte brange)
	if {$type ne "brange"} continue
	set sym
    }]
    L add* $l0start
    P fix

    # G1: Terminals first, same order as lexemes, then other.
    G add [concat $lex $g1symbols]

    LR add $l0rules
    # Special: At runtime all brange literals will be handled as
    # alternations of bytes, i.e. as a series of priority rules with
    # the same LHS.  This means these literals have to be handled as
    # rules. To keep the size of the data tables down they are stored
    # directly as branges. The RTC expands them during engine setup
    # into a proper set of rules.
    LR add [lmap sym $lit {
	set def [lindex [$gc l0 get $sym] 0]
	set details [lassign $def type]
	# assert: type in (byte brange)
	if {$type ne "brange"} continue
	set _ [list $sym $def]
    }]
    foreach s [concat $lex $discards] { LR prio $l0start @ACS:$s $s }
    LR start $l0start

    GR add $g1rules
    GR start [$gc start?]

    set sem    [SemaCode [$gc lexeme-semantics? action]]
    set always [lmap w [concat $acs_discards [LTM $lex $gc]] { L 2id $w }]
    
    $gc destroy

    set map {}
    set dsz 0
    # type		sizeof/64
    # ----------------- ------------
    # marpatcl_rtc_sym		2
    # char*		8
    # marpatcl_rtc_string	24 = 3*8
    # marpatcl_rtc_symvec	16 = (2+(6)+8)
    # marpatcl_rtc_rules	48 = (8+16+16+8)
    # marpatcl_rtc_spec	72 = (2+2+2+2+16+8+8+16+16)
    # ----------------- ------------
    # Note: Inner (..) values are padding
    
    lappend map {*}[config]
    # C code placeholders ...

    # General name
    lappend map @cname@	[CName]

    # String pool
    lappend map @string-c@      [P size]
    incr dsz [* 2 [P size]]
    lappend map @string-length-sz@ [* 2 [P size]]
    lappend map @string-length-v@  [CArray [P lengths] 16]
    incr dsz [* 2 [P size]]
    lappend map @string-offset-sz@ [* 2 [P size]]
    lappend map @string-offset-v@  [CArray [P offsets] 16]
    incr dsz [P str-size]
    lappend map @string-data-sz@ [P str-size]
    lappend map @string-data-v@  [Array "    " " " [P strings] -1]

    incr dsz 24 ;# sizeof(marpatcl_rtc_string)

    # L0 grammar: symbols, rules, semantics
    incr dsz [* 2 [L size]]       ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-symbols-sz@		[* 2 [L size]]
    lappend map @l0-symbols-c@		[L size]
    lappend map @l0-symbols-indices@	[Chunked [L refs] \
					     Characters  256 \
					     "ACS: Lexeme"  [llength $lex] \
					     "ACS: Discard" [llength $discards] \
					     Lexeme         [llength $lex] \
					     Discard        [llength $discards] \
					     Internal]

    incr dsz [* 2 [LR elements]]  ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-code-sz@            [* 2 [LR elements]]
    lappend map @l0-code-c@             [LR elements]
    lappend map @l0-code@		[LR content]

    incr dsz [* 2 [llength $sem]] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-semantics-sz@       [* 2 [llength $sem]]
    lappend map @l0-semantics-c@        [llength $sem]
    lappend map @l0-semantics-v@        [CArray $sem 16]

    incr dsz 48                   ; # sizeof(marpatcl_rtc_rules) = 48
    
    # G1 grammar: symbols, rules
    incr dsz [* 2 [G size]]      ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-symbols-sz@		[* 2 [G size]]
    lappend map @g1-symbols-c@	   	[G size]
    lappend map @g1-symbols-indices@	[Chunked [G refs] \
					     Terminals [llength $lex] \
					     Structure]

    incr dsz [* 2 [GR elements]] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-code-sz@            [* 2 [GR elements]]
    lappend map @g1-code-c@             [GR elements]
    lappend map @g1-code@	   	[GR content]

    incr dsz [* 2 [GR size]]     ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-rules-sz@		[* 2 [GR size]]
    lappend map @g1-rules-c@		[GR size]
    lappend map @g1-rules-v@		[CArray [GR refs] 16]

    incr dsz 48                  ; # sizeof(marpatcl_rtc_rules) = 48

    # G1 grammar: semantics
    set acode [EncodeGS asz [A tag] [A content] [GR size]]
    incr dsz [* 2 $asz] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-semantics-sz@       [* 2 $asz]
    lappend map @g1-semantics-c@        $asz
    lappend map @g1-semantics-v@        $acode
    
    # Overarching spec info (various counts, always-on symbols)
    lappend map @lexemes-c@		[llength $lex]
    lappend map @discards-c@		[llength $discards]

    incr dsz [* 2 [llength $always]]
    lappend map @always-sz@		[* 2 [llength $always]]
    lappend map @always-c@		[llength $always]
    lappend map @always-v@              [CArray $always 16]
    # ^ always - how to code if none is always?

    incr dsz 72 ; # sizeof(marpatcl_rtc_spec) = 72

    lappend map @space@ $dsz
    
    # todo - actions, masking

    P destroy
    L destroy
    G destroy
    LR destroy
    GR destroy
    
    variable self
    return [string map $map [string trim [marpa asset $self]]]
}

proc ::marpa::export::rtc::* {sz n} {
    expr {$n * $sz}
}

proc ::marpa::export::rtc::Get {gc class} {
    if {$class ni [$gc l0 classes]} {
	return {}
    }
    return [lsort -dict [$gc l0 symbols-of $class]]
}

proc ::marpa::export::rtc::SemaCode {keys} {
    variable ak
    # sem - Check for array, and unpack...
    if {![dict exists $keys array]} {
	# TODO: Test case required -- Check what the semantics and syntax say
	error XXX
    }
    return [lmap w [dict get $keys array] { dict get $ak $w }]
}

proc ::marpa::export::rtc::CName {} {
    debug.marpa/export/rtc {}
    string map {:: _ - _} [config? name] 
}

proc ::marpa::export::rtc::Names {rules} {
    return [lmap rule $rules { RName $rule }]
}

proc ::marpa::export::rtc::Sema {rules} {
    foreach rule $rules {
	Sem $rule
    }
}

proc ::marpa::export::rtc::RName {rule} {
    lassign $rule lhs def
    set attr [lassign $def type _ _]
    dict with attr {}
    if {![info exists name]} { return $lhs }
    if {$name eq {}} { return $lhs }
    return $name
}

proc ::marpa::export::rtc::RulesOf {gc area syms} {
    set r {}
    foreach s $syms {
	foreach def [$gc $area get $s] {
	    lappend r [list $s $def]
	}
    }
    return $r
}

proc ::marpa::export::rtc::LTM {lex gc} {
    set latm [$gc l0 latm]
    return [lmap w $lex {
	if {[dict get $latm $w]} continue
	set w
    }]
}

proc ::marpa::export::rtc::Chunked {words args} {
    variable indent
    if {![llength $args]} {
	return [CArray $words 16]
    }

    # Sectioned array ...
    set result ""
    set args [lassign $args label]
    set pfx $indent
    while {[llength $args] && [llength $words]} {
	set args [lassign $args chunk]
	set remainder [lrange $words $chunk end]
	append result [Hdr $chunk $label]
	incr chunk -1
	set header [lrange $words 0 $chunk]
	append result [CArray $header 16]
	set words $remainder
	set args [lassign $args label]
	set pfx ,\n\n$indent
    }
    if {[llength $words]} {
	append result [Hdr [llength $words] $label]
	append result [CArray $words 16]
    }
    return $result
}

proc ::marpa::export::rtc::Hdr {n label} {
    if {$label eq {}} return
    upvar 1 pfx pfx indent indent
    return "$pfx/* --- ($n) --- --- --- $label\n$indent */\n"
}

proc ::marpa::export::rtc::CArray {words n} {
    variable indent
    return [Array $indent ", " $words $n]
}

proc ::marpa::export::rtc::Array {prefix sep words n} {
    # Add the separator to all but the last word.
    set     words [lmap w [lreverse [lassign [lreverse $words] last]] { set _ $w$sep }]
    lappend words $last

    append result $prefix

    if {$n < 0} {
	# dynamically chunk to stay under n columns
	set n [expr {(- $n) - [string length $prefix]}]
	set col 0 ;# This does not count the prefix. n was adjusted.
	foreach w $words {
	    set k [string length $w]
	    if {$col == 0} {
		append result $w
		incr col $k
		continue
	    }
	    if {($col + $k) > $n} {
		append result \n $prefix
		set col 0
	    }
	    append result $w
	    incr col $k
	}
    } else {
	# chunk every n words
        set k $n
	foreach w $words {
	    if {$k == 0} { set k $n ; append result \n $prefix }
	    append result $w
	    incr k -1
	}
    }
    return $result
}

proc ::marpa::export::rtc::EncodeGS {cv tag data nr} {
    upvar 1 $cv size
    set size [llength $data]
    incr size
    switch -exact -- $tag {
	MARPATCL_S_SINGLE {
	    return [CArray [linsert $data 0 $tag] 80]
	}
	MARPATCL_S_PER {
	    set chunks {}
	    lappend chunks Tag 1
	    lappend chunks References $nr
	    while {[set n [lindex $data $nr]] ne {}} {
		lappend chunks {} $n
		incr nr $n
	    }
	    lappend chunks {}
	    return [Chunked [linsert $data 0 $tag] {*}$chunks]
	}
	default { error ZZZ:$tag }
    }
}

# # ## ### ##### ######## #############
## Various helper classes to hold generator state

oo::class create marpa::export::rtc::SemaG {
    variable mysema ; # dict (semantics -> list(rule id))
    variable mycount
    variable myfinal
    variable mytag
    variable mycode
    
    constructor {} {
	set mycount 0
	set mysema  {}
	set myfinal 0
	set mytag  {}
	set mycode {}
	return
    }

    method size {} {
	my Finalize
	set n [llength $mycode]
	incr n 1
	return $n
    }

    method tag {} {
	my Finalize
	return $mytag
    }
    
    method content {} {
	my Finalize
	return $mycode
    }
    
    method add {rules} {
	foreach rule $rules {
	    my Process $rule
	    incr mycount
	}
	return
    }

    method Process {rule} {
	lassign $rule lhs def
	set attr [lassign $def type rhs _]
	dict with attr {}
	# action.
	if {![info exists action]} { error ACTION-MISSING }
	if {$action eq {}} { error ACTION-EMPTY }

	set action [::marpa::export::rtc::SemaCode $action]
	set action [linsert $action 0 [llength $action]]
	dict lappend mysema $action $mycount
	return
    }

    method Finalize {} {
	if {$myfinal} return
	set myfinal 1
	if {[dict size $mysema] == 1} {
	    # Code global
	    set mytag  MARPATCL_S_SINGLE
	    set mycode [lindex [dict keys $mysema] 0]
	    return
	}
	# Code variadic
	set ref    $mycount
	set mytag  MARPATCL_S_PER
	set mycode [lrepeat -1 $mycount]
	foreach s [lsort -dict [dict keys $mysema]] {
	    lappend mycode {*}$s
	    foreach r [dict get $mysema $sema] {
		lset mycode $r $ref
	    }
	    incr ref [llength $sema]
	}
	return
    }
}

oo::class create marpa::export::rtc::Rules {
    variable myrules
    variable mysize
    variable myelements
    variable mynames
    variable myusenames
    variable mymaxpad
    variable mylastlhs
    variable myblank

    constructor {sym pool {usenames 0}} {
	marpa::import $sym  S
	marpa::import $pool P
	set myrules    {}
	set mysize     0
	set myelements 0
	set mynames    {}
	set myusenames $usenames
	set mymaxpad   0
	set mylastlhs  {}
	set myblank    {}
	return
    }

    method content {} {
	return "    [join $myrules "\n    "]"
    }

    method refs {} {
	return $mynames
    }

    method add {words} {
	foreach rule $words {
	    lassign $rule lhs def
	    set details [lassign $def type]
	    my P_$type $lhs {*}$details
	    if {!$myusenames} continue
	    lappend mynames [P id [marpa::export::rtc::RName $rule]]
	}
	return
    }

    method start {sym} {
	set myrules [linsert $myrules 0 [my C start $mymaxpad],]
	lappend myrules [my C stop [S 2id $sym]]
	incr myelements 2
	return
    }

    method P_brange {lhs start stop} {
	lappend cmd [my C brange [S 2id $lhs]]
	lappend cmd "MARPATCL_RCMD_BOXR ([format %3d $start],[format %3d $stop])"
	my P $cmd $lhs {}
	incr myelements 2
	return
    }

    method P_priority {lhs rhs prio args} {
	# g1: name, action, mask; ignore assoc
	# l0: ignore all
	set lhid [S 2id $lhs]

	set rl [llength $rhs]
	if {$rl > $mymaxpad} { set mymaxpad $rl }
	incr myelements $rl

	if {$lhid eq $mylastlhs} {
	    # Short coding of rule for same LHS
	    lappend cmd [my C prio-short $rl]$myblank
	    incr myelements 1
	} else {
	    # New lhs, full coding, and save for reuse
	    lappend cmd [my C prio $rl]
	    lappend cmd $lhid
	    incr myelements 2
	    set mylastlhs $lhid
	    set    myblank {  }
	    append myblank [string repeat { } [string length $lhid]]
	}
	lappend cmd {*}[lmap s $rhs { S 2id $s }]
	my P $cmd $lhs $rhs
	return
    }

    method P_quantified {lhs rhs pos args} {
	set lhs [S 2id $lhs]
	dict with args {}
	if {[info exists separator]} {
	    lassign $separator separator proper
	    set separator [S 2id $separator]
	}
	switch -exact -- ${pos}[info exists separator] {
	    00 {
		lappend cmd [my C quant* $lhs]
		lappend cmd [S 2id $rhs]
		incr myelements 2
	    }
	    01 {
		lappend cmd [my C quant*S $lhs]
		lappend cmd [S 2id $rhs]
		lappend cmd [my C [my S $proper] $separator]
		incr myelements 3
	    }
	    10 {
		lappend cmd [my C quant+ $lhs]
		lappend cmd [S 2id $rhs]
		incr myelements 2
	    }
	    11 {
		lappend cmd [my C quant+S $lhs]
		lappend cmd [S 2id $rhs]
		lappend cmd [my C [my S $proper] $separator]
		incr myelements 3
	    }
	}
	my P $cmd $lhs [linsert $args 0 $pos]
	return
    }

    method S {v} {
	dict get {
	    0 sep
	    1 proper
	} $v
    }

    method C {cmd v} {
	return "MARPATCL_RCMD_[dict get {
	    brange     {BRAN }
	    sep        {SEP}
	    proper     {SEPP}
	    start      {SETUP}
	    stop       {DONE }
	    prio       {PRIO }
	    prio-short {PRIS }
	    quant*     {QUN  }
	    quant+     {QUP  }
	    quant*S    {QUNS }
	    quant+S    {QUPS }
        } $cmd] ($v)"
    }

    method P {cmd lhs display} {
	lappend myrules "[join $cmd ", "]," ; #" /* -- $lhs ::= $display -- */"
	incr mysize
	return
    }

    method size {} {
	return $mysize
    }

    method elements {} {
	return $myelements
    }

    method add* {args} {
	my add $args
    }

    method prio {lhs args} {
	my add* [list $lhs [list priority $args 0]] 
    }
}

# # ## ### ##### ######## #############

oo::class create marpa::export::rtc::Sym {
    variable mycounter
    variable myid
    variable mysym

    constructor {pool} {
	marpa::import $pool P
	set mycounter -1
	return
    }

    method refs {} {
	return [lmap id [lsort -integer [dict keys $mysym]] {
	    P id [dict get $mysym $id]
	}]
    }

    method size {} { dict size $myid }

    method 2id {sym} { dict get $myid $sym }
    export 2id

    method has-id {id} { dict exists $mysym $id }

    method skip {} {
	set  mycounter [dict size $myid]
	incr mycounter -1
	return
    }

    method add* {args} {
	my add $args
    }

    method add {strings} {
	foreach str $strings {
	    set id [incr mycounter]
	    my force $str $id
	}
	return
    }

    method force {str id} {
	# TODO: prevent multi assignment of either
	dict set myid  $str $id
	dict set mysym $id $str
	return
    }

    method bulk-is {map} {
	# Assumed: Only used for L => strip-able
	foreach {id str} $map {
	    P add* 1 $str
	    my force $str $id
	}
	return
    }
}

# # ## ### ##### ######## #############

oo::class create marpa::export::rtc::Bytes {
    # Literals are bytes - The complexity in the code below comes from
    # the possibility that the bytes and byte-ranges from the grammar
    # do not cover the entire set. Thus we
    # - Fill a coverage map
    # - Pool the literal, and retract them from the map
    # - Pool the bytes which were not retracted, i.e. are not covered

    variable mycover

    constructor {} {
	for {set k 0} {$k < 256} {incr k} {
	    dict set mycover $k @L0:ILLEGAL_BYTE_$k
	}
	return
    }

    method add {gc literals} {
	foreach s $literals {
	    set def [lindex [$gc l0 get $s] 0]
	    set details [lassign $def type]
	    switch -exact -- $type {
		byte {
		    lassign $details codepoint
		    dict unset mycover $codepoint
		}
		brange {
		    lassign $details start stop
		    for {
			set codepoint $start
		    } {$codepoint <= $stop} {
			incr codepoint
		    } {
			dict unset mycover $codepoint
		    }
		}
		default {
		    error XXX:${s}:$def
		}
	    }
	}
	return
    }

    method gaps {} {
	return $mycover
    }
}

# # ## ### ##### ######## #############

oo::class create marpa::export::rtc::Pool {
    variable mystr     ; # dict (string -> string) : external -> transformed
    variable mypool    ; # dict (string -> length),
    #       post-finalize: dict (string -> id)
    variable myfinal   ; # bool
    variable mystrings ; # list (string)
    variable mylengths ; # list (length)
    variable myoffsets ; # list (offset)
    variable mymax     ; # length, maximum
    variable mystrsize ; # total length
    variable bmap      ;# byte mapping
    
    constructor {} {
	set mystr     {}
	set mypool    {}
	set myfinal   0
	set mystrings {}
	set mylengths {}
	set mymax     0
	set mystrsize 0
	for {set c 0} {$c < 256} {incr c} {
	    lappend bmap \\u[format %04x $c] \\[format %o $c]
	}
	return
    }

    method Strip {s} {
	set is $s
	# remove @-prefixes
	while {1} {
	    set n [regsub {@[^:]*:} $is {}]
	    if {$n eq $is} break
	    set is $n
	}
	# strip <>-bracketing
	if {[regexp {^<(.*)>$} $is -> n]} { set is $n }

	# Normalize range strings (insertion of -)
	if {[string match *@RAN:* $s]||
	    [string match *@BRAN:* $s]} {
	    set is \[[my FixRange $is]\]
	}
	if {[string match *CLS:* $s]} {
	    set is \[$is\]
	}

	# normalize \u00xx to octals.
	set is [string map $bmap $is]
	
	return $is
    }

    method FixRange {s} {
	if {[string length $s] == 2} {
	    return [join [linsert [split $s {}] 1 -] {}]
	}
	if {[string match "?\\\\*" $s]} {
	    return [string index $s 0]-[string range $s 1 end]
	}
	if {[regexp {^(\B[^\B]*)([^\B])$} $s -> pfx sfx]} {
	    return ${pfx}-$sfx
	}
	if {[regexp {^(.*)(\B[^\B]*)$} $s -> pfx sfx]} {
	    return ${pfx}-$sfx
	}
	error XXX:($s)
    }
    
    method add {strip strings} {
	if {$myfinal} {
	    return -code error "Cannot add strings to finalized pool"
	}
	foreach s $strings {
	    set is $s
	    if {$strip} {
		set is [my Strip $s]
	    }
	    dict set mystr $s $is
	    set len [string length $is]
	    dict set mypool $is $len
	    set n [string length $len]
	    if {$n > $mymax} { set mymax $n }
	}
	return
    }

    method add* {strip args} {
	my add $strip $args
    }

    method strings {} {
	my Finalize
	return $mystrings
    }

    method lengths {} {
	my Finalize
	return $mylengths
    }

    method offsets {} {
	my Finalize
	return $myoffsets
    }

    method id {str} {
	my Finalize
	# double-ref, external -> internal -> id
	return [dict get $mypool [dict get $mystr $str]]
    }

    method size {} {
	my Finalize
	return [llength $mystrings]
    }

    method str-size {} {
	my Finalize
	return $mystrsize
    }

    method fix {} { my Finalize }

    method Finalize {} {
	if {$myfinal} return
	set myfinal 1

	set lf %${mymax}d
	set if %[string length [dict size $mypool]]d
	
	set index 0
	set offset 0
	foreach str [lsort -dict [dict keys $mypool]] {
	    set len [dict get $mypool $str]
	    incr mystrsize $len
	    incr mystrsize ;# \0
	    dict set mypool $str $index
	    lappend mylengths $len
	    lappend myoffsets $offset
	    lappend mystrings "/* [format $if $index] */ \"[char quote cstring $str]\\0\""
	    incr index
	    incr offset $len
	    incr offset ;# \0
	}
	return
    }
}

# # ## ### ##### ######## #############
return
##
## Template following (`source` will not process it)
/* -*- c -*-
**
* This template is BSD-licensed.
* (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
*                                     http://core.tcl.tk/akupries/
**
* (c) @slif-year@ Grammar @slif-name@ By @slif-writer@
**
**	rtc-derived Engine for grammar "@slif-name@". Lexing + Parsing.
**	Generated On @generation-time@
**		  By @tool-operator@
**		 Via @tool@
**
** Space taken: @space@ bytes
*/

#include <spec.h>
#include <rtc.h>

/*
 * Shared string pool (@string-length-sz@ len bytes over @string-c@ entries)
 *                    (@string-offset-sz@ off bytes -----^)
 *                    (@string-data-sz@ content bytes)
 */

static marpatcl_rtc_size @cname@_pool_length [@string-c@] = { /* @string-length-sz@ */
@string-length-v@
};

static marpatcl_rtc_size @cname@_pool_offset [@string-c@] = { /* @string-offset-sz@ */
@string-offset-v@
};

static marpatcl_rtc_string @cname@_pool = { /* 24 + @string-data-sz@ */
    @cname@_pool_length,
    @cname@_pool_offset,
@string-data-v@
};

/*
 * L0 structures
 */

static marpatcl_rtc_sym @cname@_l0_sym_name [@l0-symbols-c@] = { /* @l0-symbols-sz@ */
@l0-symbols-indices@
};

static marpatcl_rtc_sym @cname@_l0_rule_definitions [@l0-code-c@] = { /* @l0-code-sz@ */
@l0-code@
};

static marpatcl_rtc_rules @cname@_l0 = { /* 48 */
    /* .sname   */  &@cname@_pool,
    /* .symbols */  { @l0-symbols-c@, @cname@_l0_sym_name },
    /* .rules   */  { 0, NULL },
    /* .rcode   */  @cname@_l0_rule_definitions
};

static marpatcl_rtc_sym @cname@_l0semantics [@l0-semantics-c@] = { /* @l0-semantics-sz@ */
@l0-semantics-v@
};

/*
 * G1 structures
 */

static marpatcl_rtc_sym @cname@_g1_sym_name [@g1-symbols-c@] = { /* @g1-symbols-sz@ */
@g1-symbols-indices@
};

static marpatcl_rtc_sym @cname@_g1_rule_name [@g1-rules-c@] = { /* @g1-rules-sz@ */
@g1-rules-v@
};

static marpatcl_rtc_sym @cname@_g1_rule_definitions [@g1-code-c@] = { /* @g1-code-sz@ */
@g1-code@
};

static marpatcl_rtc_rules @cname@_g1 = { /* 48 */
    /* .sname   */  &@cname@_pool,
    /* .symbols */  { @g1-symbols-c@, @cname@_g1_sym_name },
    /* .rules   */  { @g1-rules-c@, @cname@_g1_rule_name },
    /* .rcode   */  @cname@_g1_rule_definitions
};

static marpatcl_rtc_sym @cname@_g1semantics [@g1-semantics-c@] = { /* @g1-semantics-sz@ */
@g1-semantics-v@
};

/*
 * Parser definition
 */

static marpatcl_rtc_sym @cname@_always [@always-c@] = { /* @always-sz@ */
@always-v@
};

static marpatcl_rtc_spec @cname@_spec = { /* 72 */
    /* .lexemes    */  @lexemes-c@,
    /* .discards   */  @discards-c@,
    /* .l_symbols  */  @l0-symbols-c@,
    /* .g_symbols  */  @g1-symbols-c@,
    /* .always     */  { @always-c@, @cname@_always },
    /* .l0         */  &@cname@_l0,
    /* .g1         */  &@cname@_g1,
    /* .l0semantic */  { @l0-semantics-c@, @cname@_l0semantics },
    /* .g1semantic */  { @g1-semantics-c@, @cname@_g1semantics }
};

/*
 * Constructor
 */

marpatcl_rtc_p
@cname@_constructor (marpatcl_rtc_sv_cmd a)
{
    return marpatcl_rtc_cons (&@cname@_spec, a);
}

// open things
// -- capture failure
// -- fill in lexer, parser operation
// -- write critcl wrapper around generated code
// -- tracing
