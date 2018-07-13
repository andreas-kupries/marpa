# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Exporter -- Common core for related generators (rtc-raw, rtc-critcl)
##
# - Output format: C code, structures for RTC.
#   Code is formatted with newlines and indentation.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen::runtime::c 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Functionality shared between
# Meta description the clex and cparse generators
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::slif::container
# Meta require     marpa::slif::literal::util
# Meta require     marpa::slif::literal::redux
# Meta require     marpa::slif::literal::reduce::2c4tcl
# Meta require     marpa::slif::precedence
# Meta require     marpa::gen
# Meta require     marpa::gen::remask
# Meta subject     marpa {generator c}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug
package require debug::caller
package require marpa::slif::container
package require marpa::slif::literal::util
package require marpa::slif::literal::redux
package require marpa::slif::literal::reduce::2c4tcl
package require marpa::slif::precedence
package require marpa::gen
package require marpa::gen::remask

debug define marpa/gen/runtime/c
debug prefix marpa/gen/runtime/c {[debug caller] | }

# # ## ### ##### ######## #############
## Configuration coming out of this supporting module.
#
## General placeholders
#
## @slif-version@    -- Grammar information: Version
## @slif-writer@     -- Grammar information: Author
## @slif-year@       -- Grammar information: Year of authorship
## @slif-name@       -- Grammar information: Name
## @slif-name-tag@   -- Grammar information: Derived from name.
##                      Tag for Tcl `debug` commands.
## @tool-operator@   -- Name of user invoking the tool
## @tool@            -- Name of the pool generating the output
## @generation-time@ -- Date/Time of when tool was invoked
#
## Engine-specific placeholders
#
## @always-c@            -- #always active L0 symbols (discards + LTM-mode lexemes)
## @always-sz@           -- Informational: #bytes for always active L0 symbols
## @always-v@            -- ACS symbol ids of the always active L0 symbols
## @cname@               -- C identifier, derived from @name@
## @discards-c@          -- #discarded symbols in the L0 level (i.e. whitespace)
## @event-names@         -- Literal pool for user-declared event names, or empty line
## @event-table@         -- Array of all declared user events, L0 first, then G1, shared by the higher structures
## @g1-code-c@           -- #entries to encode the structural (G1) rules
## @g1-code-sz@          -- Informational: #bytes for
## @g1-code@             -- VM instructions encoding the structural (G1) rules
## @g1-event-struct-ref@ -- Address of the g1 event declaration structure, or 0.
## @g1-event-struct@     -- G1 event declaration structure, or nothing
## @g1-insn-c@           -- #instructions encoding the structural (G1) rules
## @g1-lhs-v@            -- Per G1 rule indices into the symbol map = lhs of rule
## @g1-masking-c@        -- #entries encoding the G1 masks (See spec.h for details)
## @g1-masking-sz@       -- Informational: #bytes for encoding the G1 masks
## @g1-masking-v@        -- Data encoding the G1 masks
## @g1-rules-c@          -- #structural (G1) rules
## @g1-rules-sz@         -- Informational: #bytes for
## @g1-rules-v@          -- Per G1 rule indices into the string pool = rule name
## @g1-semantics-c@      -- #entries encoding the G1 semantics
## @g1-semantics-sz@     -- Informational: #bytes for encoding of the G1 semantics
## @g1-semantics-v@      -- Data encoding the G1 semantics (See spec.h for details)
## @g1-symbols-c@        -- #symbols in the structural (G1) level of the engine
## @g1-symbols-indices@  -- Per G1 symbol indices into the string pool = symbol name
## @g1-symbols-sz@       -- Informational: #bytes for
## @have-events@         -- number of user-declared events (L0 and G1 together)
## @l0-code-c@           -- #entries to encode the lexical (L0) rules
## @l0-code-sz@          -- Informational: #bytes for
## @l0-code@             -- VM instructions encoding the lexical (L0) rules
## @l0-event-struct-ref@ -- Address of the l0 event declaration structure, or 0.
## @l0-event-struct@     -- L0 event declaration structure, or nothing
## @l0-insn-c@           -- #instructions encoding the lexical (L0) rules
## @l0-semantics-c@      -- #array descriptor codes of the L0 semantics
## @l0-semantics-sz@     -- Informational: #bytes for the lexical semantics
## @l0-semantics-v@      -- The array descriptor codes of the L0 semantics
## @l0-symbols-c@        -- #symbols in the lexical (L0) level of the engine
## @l0-symbols-indices@  -- Per L0 symbol indices into the string pool = symbol name
## @l0-symbols-sz@       -- Informational: #bytes for the symbol name map
## @lexemes-c@           -- #lexemes = #terminals in the grammar
## @space@               -- Informational: #bytes taken by all structures
## @string-c@            -- #strings in the pool
## @string-data-sz@      -- Informational: #bytes for the string data of the pool
## @string-data-v@       -- The string data of the string pool
## @string-length-sz@    -- Informational: #bytes for the length data of the pool
## @string-length-v@     -- Length data for the strings in the pool
## @string-offset-sz@    -- Informational: #bytes for the offset data of the pool
## @string-offset-v@     -- Offset data for the strings in the pool

namespace eval ::marpa::gen::runtime {}
namespace eval ::marpa::gen::runtime::c {
    namespace import ::marpa::gen::config  ; rename config  core-config
    namespace import ::marpa::gen::config? ; rename config? core-config?
    namespace export config gc
    namespace ensemble create

    # Map from SLIF array-codes to the runtime's equivalent C defines
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

	first    MARPATCL_SV_A_FIRST
    }
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::runtime::c::gc {serial} {
    debug.marpa/gen/runtime/c {}
    
    set gc [Ingest $serial]
    EncodePrecedences $gc
    LowerLiterals     $gc

    return $gc
}

proc ::marpa::gen::runtime::c::config {serial {config {}}} {
    debug.marpa/gen/runtime/c {}
    set defaults {
	prefix {    }
	events both
    }
    set config [dict merge $defaults $config]
    # Carry the prefix into all *Array commands, i.e. Flow, Tabular, and Chunked.
    # Remove unexposed internal CVs to prevent override.
    dict unset config separator
    dict unset config from
    dict unset config to
    dict unset config n
    # Pull chosen event generation mode
    set emode [dict get $config events]
    dict unset config events

    set gc [gc $serial]
    # Types we can get out of the reduction:
    # - byte, brange

    # Pull various required parts out of the container ...

    set lit       [GetL0 $gc literal]
    set l0symbols [GetL0 $gc {}]
    set l0events  [$gc l0 events]
    set discards  [GetL0 $gc discard]
    set lex       [GetL0 $gc lexeme]
    set g1symbols [$gc g1 symbols-of {}]
    set g1events  [$gc g1 events]
    
    # Ignoring class 'terminal'. That is the same as the l0 lexemes,
    # and the semantics made sure, as did the container validation.

    # sem       :: map ('array -> list(semantic-code))
    # latm      :: map (sym -> bool) (sym == lexemes)
    # lit       :: list (sym)
    # l0symbols :: list (sym) - as is
    # discards  :: list (sym) - as is
    # lex       :: list (sym)

    # Data processing.

    catch {B destroy} ;# Remove possible left overs from a previous failed run.
    catch {P destroy}
    catch {L destroy}
    catch {G destroy}
    catch {LR destroy}
    catch {GR destroy}
    catch {A destroy}
    catch {M destroy}

    Bytes create B
    Pool  create P
    Sym   create L  P
    Sym   create G  P
    Rules create LR L P
    Rules create GR G P 1
    SemaG create A
    Mask  create M

    set acs_discards [lmap w $discards { set _ @ACS:$w }]
    set acs_lex      [lmap w $lex      { set _ @ACS:$w }]
    set l0start      @L0:START

    set l0rules [RulesOf $gc l0 [concat $lex $discards $l0symbols]]
    set g1rules [RulesOf $gc g1 $g1symbols]

    P add  1 [concat $l0symbols $discards $lex $acs_discards $acs_lex $lit]
    P add  0 [concat [Names $g1rules] $g1symbols]
    P add* 0 $l0start

    A add $g1rules
    M add $g1rules

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
	    set bsym [::marpa::slif::literal::util::symbol [list byte $codepoint]]
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

    set sem    [SemaCodeL [$gc lexeme-semantics? action]]
    set always [lmap w [concat $acs_discards [LTM $lex $gc]] {
	# Convert ACS down to terminal symbols and pseudo-terminals
	# (latter are for the discards)
	# NOTE: See (%%accept/always%%) in rtc/lexer.c
	expr {[L 2id $w] - 256}
    }]

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

    lappend map {*}[core-config]
    # C code placeholders ...

    # General name
    lappend map @cname@	[CName]

    # String pool
    lappend map @string-c@      [P size]
    incr dsz [* 2 [P size]]
    lappend map @string-length-sz@ [* 2 [P size]]
    lappend map @string-length-v@  [TabularArray [P lengths] $config]
    incr dsz [* 2 [P size]]
    lappend map @string-offset-sz@ [* 2 [P size]]
    lappend map @string-offset-v@  [TabularArray [P offsets] $config]
    incr dsz [P str-size]
    lappend map @string-data-sz@ [P str-size]
    lappend map @string-data-v@  [FlowArray [P strings] \
				      [dict merge $config {separator { } n -1}]]

    incr dsz 24 ;# sizeof(marpatcl_rtc_string)

    # L0 grammar: symbols, rules, semantics, events
    Limit12 "\#l0 symbols" [L size]

    incr dsz [* 2 [L size]]       ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-symbols-sz@		[* 2 [L size]]
    lappend map @l0-symbols-c@		[L size]
    lappend map @l0-symbols-indices@	[ChunkedArray [L refs] \
					     [L0C $lex $discards] $config]

    incr dsz [* 2 [LR elements]]  ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-code-sz@            [* 2 [LR elements]]
    lappend map @l0-insn-c@             [LR size]
    lappend map @l0-rule-c@             [LR numrules]
    lappend map @l0-code-c@             [LR elements]
    lappend map @l0-code@		[LR content [dict get $config prefix]]

    Limit16 "\#l0 semantics" [llength $sem]
    incr dsz [* 2 [llength $sem]] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @l0-semantics-sz@       [* 2 [llength $sem]]
    lappend map @l0-semantics-c@        [llength $sem]
    lappend map @l0-semantics-v@        [TabularArray $sem $config]
    
    incr dsz 52                   ; # sizeof(marpatcl_rtc_rules) = 52

    # G1 grammar: symbols, rules
    Limit12 "\#g1 symbols" [L size]

    incr dsz [* 2 [G size]]      ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-symbols-sz@		[* 2 [G size]]
    lappend map @g1-symbols-c@	   	[G size]
    lappend map @g1-symbols-indices@	[ChunkedArray [G refs] \
					     [G1C $lex] $config]

    incr dsz [* 2 [GR elements]] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-code-sz@            [* 2 [GR elements]]
    lappend map @g1-insn-c@             [GR size]
    lappend map @g1-rule-c@             [GR numrules]
    lappend map @g1-code-c@             [GR elements]
    lappend map @g1-code@	   	[GR content [dict get $config prefix]]

    Limit16 "\#g1 rules" [GR size]
    incr dsz [* 2 [GR size]]     ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-rules-sz@		[* 2 [GR size]]
    lappend map @g1-rules-c@		[GR size]
    lappend map @g1-rules-v@		[TabularArray [GR refs] $config]

    incr dsz [* 2 [GR size]]     ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-lhs-v@		[TabularArray [GR lhs] $config]

    incr dsz 48                  ; # sizeof(marpatcl_rtc_rules) = 48

    # G1 grammar: semantics
    set acode [FormatRD asz Semantics $config [A tag] [A content] [GR size]]
    Limit16 "\#g1 semantics" $asz
    incr dsz [* 2 $asz] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-semantics-sz@       [* 2 $asz]
    lappend map @g1-semantics-c@        $asz
    lappend map @g1-semantics-v@        $acode

    # G1 grammar: masking
    set mcode [FormatRD msz Mask $config [M tag] [M content] [GR size]]
    Limit16 "\#g1 masking" $msz
    incr dsz [* 2 $msz] ; # sizeof(marpatcl_rtc_sym) = 2
    lappend map @g1-masking-sz@       [* 2 $msz]
    lappend map @g1-masking-c@        $msz
    lappend map @g1-masking-v@        $mcode

    # Overarching spec info (various counts, always-on symbols)
    lappend map @lexemes-c@		[llength $lex]
    lappend map @discards-c@		[llength $discards]

    incr dsz [* 2 [llength $always]]
    lappend map @always-sz@		[* 2 [llength $always]]
    lappend map @always-c@		[llength $always]
    lappend map @always-v@              [TabularArray $always $config]
    # ^ always - how to code if none is always?

    incr dsz 72 ; # sizeof(marpatcl_rtc_spec) = 72

    # Event handling. 2 possible modes:
    # (l0) L0 events only
    # (both) L0 and G1 events combined (main table)

    switch -exact -- $emode {
	l0 {
	    set l0events [Events2Table $l0events L]
	    set name     [CName]_events
	    set l0name   [CName]_l0events

	    lappend map @have-events@         [llength $l0events]
	    lappend map @event-table@         [EventTable  $name $l0events]
	    lappend map @event-names@         [EventNames  $l0events]
	    lappend map @l0-event-struct-ref@ [EventRef    $l0name $l0events]
	    lappend map @l0-event-struct@     [EventStruct $l0name $l0events $name]

	    incr dsz 0 ;# TODO XXX size of the event structures
	}
	both {
	    set l0events [Events2Table $l0events L]
	    set g1events [Events2Table $g1events G]
	    set events   [concat $l0events $g1events]
	    set nl       [llength $l0events]

	    set name     [CName]_events
	    set l0name   [CName]_l0events
	    set g1name   [CName]_g1events

	    lappend map @have-events@         [llength $events]
	    lappend map @event-table@         [EventTable  $name $events]
	    lappend map @event-names@         [EventNames  $events]
	    lappend map @l0-event-struct-ref@ [EventRef    $l0name $l0events]
	    lappend map @l0-event-struct@     [EventStruct $l0name $l0events $name]
	    lappend map @g1-event-struct-ref@ [EventRef    $g1name $g1events]
	    lappend map @g1-event-struct@     [EventStruct $g1name $g1events $name $nl]

	    incr dsz 0 ;# TODO XXX size of the event structures
	}
	default {
	    return -code error \
		"Bad event mode $emode, expected one of l0, or both."
	}
    }
   
    lappend map @space@ $dsz

    # todo - actions, masking

    P destroy
    L destroy
    G destroy
    LR destroy
    GR destroy
    A destroy
    M destroy

    return $map
}

# # ## ### ##### ######## #############
## Internals

proc ::marpa::gen::runtime::c::Ingest {serial} {
    debug.marpa/gen/runtime/c {}

    # Create a local copy of the grammar for the upcoming
    # rewrites. Validate the input as well, now.

    set gc [marpa::slif::container new]
    $gc deserialize $serial
    $gc validate
    return $gc
}

proc ::marpa::gen::runtime::c::EncodePrecedences {gc} {
    debug.marpa/gen/runtime/c {}

    # Replace higher-precedenced rules with groups of rules encoding
    # the precedences directly into their structure. (**)

    marpa::slif::precedence 2container \
	[marpa::slif::precedence rewrite $gc] \
	$gc
    return
}

proc ::marpa::gen::runtime::c::LowerLiterals {gc} {
    debug.marpa/gen/runtime/c {}

    # Rewrite the literals into forms supported by the runtime (C
    # engine, with Tcl associated). These are bytes and byte
    # ranges. The latter are expanded during setup at runtime, into
    # alternations of bytes, with a subsequent explosion of rules.

    marpa::slif::literal::redux $gc \
	marpa::slif::literal::reduce::2c4tcl

    RefactorRanges $gc
    return
}

proc ::marpa::gen::runtime::c::RefactorRanges {gc} {
    debug.marpa/gen/runtime/c {}
    # Global refactoring of byte ranges.
    #
    # The byte ranges in the ASBR for the used unicode classes often
    # overlap significantly. One of the patterns seen are many byte
    # ranges starting at the same byte and just having different end
    # bytes.

    # Without refactorization each range is coded on its own, as
    # alternation of all the bytes in the range. This generates
    # (end-start+1) rules for a range, one per byte/alternate. Due to
    # the strong overlap between ranges many of the generated
    # alternates are identical across all the ranges.
    ##
    # In concrete numbers, using the L0 sub-grammar of the SLIF meta
    # grammar as our example:
    ##
    #   2191 setup instructions are used to decribe 6639 rules.  About
    #   73% (1591 exactly) are instructions for byte ranges, expanding
    #   into 6039 rules (91%) for the range alternates. The remaining
    #   600 instructions (27%) account for the remaining 600 rules
    #   (9%).

    # The refactoring algorithm currently only looks for the pattern
    # mentioned before, i.e. sets of ranges starting at the same
    # byte. This is easy to do, compared to comparing all ranges
    # against all others for overlap and then trying to find
    # advantageous splits.
    ##
    # After ordering by end byte the first range is left as is,
    # becoming the initial prefix, while all the following ranges are
    # refactored into an alternation of the current prefix and the
    # left-over suffix, becoming in turn the current prefix to the
    # next range. By properly ordering the overall refactoring itself,
    # i.e. processing sets in ascending order of their start byte the
    # generated range suffixes may in turn be refactored further.
    ##
    # For our example this results in
    ##
    #   2584 setup instructions (+18%) are used to describe 2942 rules
    #   (-56%). About only 4% (91 exactly) are instructions for byte
    #   ranges, expanding into 449 rules (15%) for the range
    #   alternates. The remaining 2493 instructions (96%) account for
    #   the remaining 2493 rules (85%). As the 600 other rules from
    #   before the refactoring are the basic lexical structure we can
    #   infer that 1893 of these instructions and rules are newly-made
    #   alternations aggregating the atomic small ranges into the
    #   larger ranges used by the grammar.
    ##
    # As end result we can expect that the number of instructions
    # needed to encode an L0 sub-grammar goes moderately up while the
    # number of actual rules they generate should fall dramatically.
    # Instead of many large (wide) byte ranges expanding into a large
    # set of virtually identical alternates the grammar will contain a
    # small set of near-atomic ranges instead, from which all the
    # larger ranges are constructed, via (binary) trees of
    # alternations.

    # NOTE: The puts statements with AAA and ZZZ prefixes can be used
    # print the set of byte ranges as pseudo bitmaps, showing the
    # distribution before and after the refactoring. Extract them with
    # grep, then sort by start and end bytes.

    set ranges {}   ; # ranges :: (start -> (stop -> symbol))
    set cover  {}   ; # cover  :: ((start,stop) -> sym)

    foreach sym [$gc l0 symbols-of literal] {
	set details [lassign [lindex [$gc l0 get $sym] 0] type]
	if {$type eq "brange"} {
	    lassign $details start stop
	    debug.marpa/gen/runtime/c {Range: $sym ($start - $stop)}
	    # Print range as bitmap.
	    #puts AAA_[format %3d $start]-[format %3d $stop]|[string repeat { } [expr {$start-1}]][string repeat * [expr {$stop-$start+1}]]

	    # Collect ranges with the same start together.
	    dict set ranges $start $stop $sym

	    # Collect range to symbol mapping for re-use of existing
	    # definition where possible.
	    dict set cover [list $start $stop] $sym
	} else {
	    # type is a "byte". We put this into the symbol mapping
	    # for reuse, but not in the table for refactoring.
	    lassign $details byte
	    debug.marpa/gen/runtime/c {Byte: $sym ($byte)}
	    dict set cover [list $byte $byte] $sym
	}
    }

    #debug.marpa/gen/runtime/c {[debug::pdict $cover]}

    while {[dict size $ranges]} {
	# ranges is the table/queue of things to refactor.
	set start [lindex [lsort -integer [dict keys $ranges]] 0]
	# We iterate over the collected ranges by ascending start.
	# This way any new ranges we may create below for suffixes is
	# added in places we will look at and process later. There is
	# no need to go backward for reprocessing of added things.

	# Take definition, drop it from queue, we will be done with it.
	set defs [dict get $ranges $start]
	dict unset ranges $start

	debug.marpa/gen/runtime/c {Processing [format %3d $start] :: [dictsort $defs]}

	# For each set of ranges starting the same point, sort them by
	# ascending endpoint. The first definition stands as is. If it
	# is the sole definition we drop the entire set from processing.

	if {[llength [dict keys $defs]] == 1} {
	    debug.marpa/gen/runtime/c {...Single range, skip}
	    continue
	}

	# All definitions after the first become an alternation of
	# prefix and suffix range, the latter the subtraction of
	# prefix from full range, making it smaller. That part may
	# re-use an existing range definition. Note that the suffix
	# may be refactored too. As the start of any suffix range is
	# greater than the current start they are processed in
	# upcoming iterations.

	set remainder [lassign [lsort -integer [dict keys $defs]] prefixstop]
	set prefixsym [dict get $defs $prefixstop]

	debug.marpa/gen/runtime/c {...Multiple ranges, refactor 2+}

	foreach stop $remainder {
	    debug.marpa/gen/runtime/c {...Prefix  ([format %3d $start]-[format %3d $prefixstop]) $prefixsym}

	    set currentsym [dict get $defs $stop]
	    debug.marpa/gen/runtime/c {...Current ([format %3d $start]-[format %3d $stop]) $currentsym}

	    # suffix = prefixstop+1 ... stop
	    set suffixstart $prefixstop
	    incr suffixstart

	    set key [list $suffixstart $stop]
	    if {![dict exists $cover $key]} {
		# The suffix range has no symbol yet. Create it as
		# either a byte or a brange literal, depending on the
		# size of the covered range. Always add it to the
		# coverage map for future reuse.  Add it to the queue
		# for refactoring only if it is a range.

		if {$suffixstart == $stop} {
		    set suffixsym BYTE<d$suffixstart>
		    dict set cover [list $suffixstart $suffixstart] $suffixsym
		    $gc l0 literal $suffixsym byte $suffixstart

		    debug.marpa/gen/runtime/c {...Suffix  ([format %3d $suffixstart]) $suffixsym (BYTE)}
		} else {
		    set suffixsym BRAN<d${suffixstart}-d${stop}>
		    dict set cover $key $suffixsym
		    dict set ranges $suffixstart $stop $suffixsym
		    $gc l0 literal $suffixsym brange $suffixstart $stop
		    debug.marpa/gen/runtime/c {...Suffix  ([format %3d $suffixstart]-[format %3d $stop]) $suffixsym (NEW)}
		}
	    } else {
		# We have a symbol for the suffix. Reuse it. No new
		# entries are needed.
		set suffixsym [dict get $cover $key]
		debug.marpa/gen/runtime/c {...Suffix  ([format %3d $suffixstart]-[format %3d $stop]) $suffixsym (reused)}
	    }

	    # create priority alternation of prefix and suffix ranges
	    $gc l0 remove        $currentsym
	    $gc l0 priority-rule $currentsym [list $prefixsym] 0
	    $gc l0 priority-rule $currentsym [list $suffixsym] 0

	    debug.marpa/gen/runtime/c {...Replace $currentsym ::= $prefixsym | $suffixsym}

	    # The processed definition becomes the prefix for the next.
	    set prefixstop $stop
	    set prefixsym  $currentsym
	}
    }

    if 0 {
	# post refactoring, print new ranges as bitmaps
	foreach sym [$gc l0 symbols-of literal] {
	    set details [lassign [lindex [$gc l0 get $sym] 0] type]
	    if {$type eq "brange"} {
		lassign $details start stop
		# Print range as bitmap.
		puts ZZZ_[format %3d $start]-[format %3d $stop]|[string repeat { } [expr {$start-1}]][string repeat {*} [expr {$stop-$start+1}]]
	    }
	}
    }

    #exit 1
    return
}

proc ::marpa::gen::runtime::c::L0C {lex discards} {
    set l [llength $lex]
    set d [llength $discards]

    if {!$d} {
	# No discards, do not provide segments for them in the
	# ChunkedArray
	return [list \
		    Characters       256 \
		    {{ACS: Lexeme}}  $l \
		    Lexeme           $l \
		    Internal]
    }
    
    return [list \
		Characters       256 \
		{{ACS: Lexeme}}  $l \
		{{ACS: Discard}} $d \
		Lexeme           $l \
		Discard          $d \
		Internal]
}

proc ::marpa::gen::runtime::c::G1C {terminals} {
    set t [llength $terminals]
    return [list \
		Terminals $t \
		Structure]
}

proc ::marpa::gen::runtime::c::* {sz n} {
    expr {$n * $sz}
}

proc ::marpa::gen::runtime::c::GetL0 {gc class} {
    if {$class ni [$gc l0 classes]} {
	return {}
    }
    return [lsort -dict [$gc l0 symbols-of $class]]
}

proc ::marpa::gen::runtime::c::SemaCodeL {keys} {
    variable ak
    # sem - Check for array, and unpack...
    if {![dict exists $keys array]} {
	# TODO: Test case required -- Check what the semantics and syntax say
	error XXX
    }
    return [lmap w [dict get $keys array] { dict get $ak $w }]
}

proc ::marpa::gen::runtime::c::SemaCodeG {keys} {
    variable ak
    # sem - Check for array, and unpack...
    if {[dict exists $keys special]} {
	set special [dict get $keys special]
	if {[dict exists $ak $special]} {
	    return [list [dict get $ak $special]]
	}
	# TODO: Test case required
	error BAD-SPECIAL:$special
    }
    if {[dict exists $keys array]} {
	return [lmap w [dict get $keys array] { dict get $ak $w }]
    }
    # TODO: Test case required -- Check what the semantics and syntax say
    error BAD-SEMANTICS:$keys
}

proc ::marpa::gen::runtime::c::CName {} {
    debug.marpa/gen/runtime/c {}
    string map {:: _ - _} [core-config? name]
}

proc ::marpa::gen::runtime::c::Names {rules} {
    return [lmap rule $rules { RName $rule }]
}

proc ::marpa::gen::runtime::c::RName {rule} {
    lassign $rule lhs def
    set attr [lassign $def type _ _]
    dict with attr {}
    if {![info exists name]} { return $lhs }
    if {$name eq {}} { return $lhs }
    return $name
}

proc ::marpa::gen::runtime::c::RulesOf {gc area syms} {
    set r {}
    foreach s $syms {
	foreach def [$gc $area get $s] {
	    lappend r [list $s $def]
	}
    }
    return $r
}

proc ::marpa::gen::runtime::c::LTM {lex gc} {
    set latm [$gc l0 latm]
    return [lmap w $lex {
	if {[dict get $latm $w]} continue
	set w
    }]
}

proc ::marpa::gen::runtime::c::ChunkedArray {words chunking {config {}}} {
    # Sectioned array ...
    set indent [dict get $config prefix]
    set result ""
    set chunking [lassign $chunking label]
    set     lconfig $config
    lappend lconfig {*}[lassign $label label]
    set pfx $indent
    while {[llength $chunking] && [llength $words]} {
	set chunking  [lassign $chunking chunk]
	set remainder [lrange $words $chunk end]
	if {!$chunk} {
	    return -code error \
		"Cannot chunk zero-length segment \"$label\""
	}
	append result [Hdr $chunk $label]
	incr chunk -1
	set header [lrange $words 0 $chunk]
	append result [TabularArray $header $lconfig]
	set words    $remainder
	set chunking [lassign $chunking label]
	set     lconfig $config
	lappend lconfig {*}[lassign $label label]
	set pfx ,\n\n$indent
    }
    if {[llength $words]} {
	append result [Hdr [llength $words] $label]
	append result [TabularArray $words $lconfig]
    }
    return $result
}

proc ::marpa::gen::runtime::c::Hdr {n label} {
    upvar 1 pfx pfx indent indent
    if {$label eq {}} {
	# custom prefix
	return ",\n"
    }
    return "$pfx/* --- ($n) --- --- --- $label\n$indent */\n"
}

proc ::marpa::gen::runtime::c::TabularArray {words {config {}}} {
    # Generate an array with `n` aligned columns, regardless of extend
    # in columns of characters.

    set defaults {
	prefix    {    }
	separator {, }
	n         16
	from      0
	to        end
    }
    dict with defaults {} ; # import defaults into scope
    dict with config   {} ; # and overide with caller's settings.

    set words [lmap w [lreverse [lassign [lreverse $words] last]] {
	set _ $w$separator
    }]
    lappend words $last[regsub -all -- {[^\t]} $separator { }]
    # Note how the last word gets a separator as well, as spaces, to
    # match the alignment within the field of all the others. Without
    # it would indent badly in a tabular format. These spaces are
    # removed at the end, with a trimright.

    # Determine field width and derive the formatting pattern for
    # proper alignment from that. Note, alignment is right-justified,
    # space padding to the left of each word.

    set max [Width [lrange $words $from $to]]
    set sf %${max}s

    append result $prefix

    set k $n
    foreach w $words {
	if {$k == 0} {
	    set k $n
	    set result [string trimright $result]
	    append result \n $prefix
	}
	append result [format $sf $w]
	incr k -1
    }

    return [string trimright $result]
}

proc ::marpa::gen::runtime::c::FlowArray {words {config {}}} {
    # Generate an array with as many elements packed into each line
    # while staying under the configured maximal column `n` (default:
    # 79). Note however that to have progress each line will contain
    # at least one element, even if it overshoots the chosen maximum.

    # Note, this can be used force a line break after each element,
    # simply set maxcol to 0, or 1.

    set defaults {
	prefix    {    }
	separator {, }
	n         79
    }
    dict with defaults {} ; # import defaults into scope
    dict with config   {} ; # and overide with caller's settings.

    append result $prefix
    set n   [expr {$n - [string length $prefix]}]
    set col 0 ;# This does not count the prefix.
    #          # n was adjusted instead to account for it.

    set words [lmap w [lreverse [lassign [lreverse $words] last]] {
	set _ $w$separator
    }]
    lappend words $last

    foreach w $words {
	set k [string length $w]
	if {$col == 0} {
	    append result $w
	    incr col $k
	    continue
	}
	if {($col + $k) > $n} {
	    set result [string trimright $result]
	    append result \n $prefix
	    set col 0
	}
	append result $w
	incr col $k
    }

    return [string trimright $result]

}

proc ::marpa::gen::runtime::c::FormatRD {cv label config tag data nr} {
    upvar 1 $cv size
    set  size [llength $data]
    incr size
    set all [linsert $data 0 $tag]
    switch -exact -- $tag {
	MARPATCL_S_SINGLE { set chunks [list Tag 1 [list "Common $label" to 0]]	}
	MARPATCL_S_PER    { set chunks [RuleC $label $data $nr]	}
	default { error ZZZ:$tag }
    }
    return [ChunkedArray $all $chunks $config]
}

proc ::marpa::gen::runtime::c::RuleC {label data nr} {
    lappend chunks Tag 1
    lappend chunks [list "$label Offsets"] $nr

    set label "$label Data"

    while {[set n [lindex $data $nr]] ne {}} {
	# strip comments coded before the length
	regexp { (\d+)$} $n -> n
	incr n 1 ;# adjust for length entry
	# NOTE: At this point n >= 1.
	#       No chunk is zero-length
	lappend chunks [list $label from 1] $n
	incr nr $n
	set label {}
    }
    lappend chunks {}
    return $chunks
}

proc ::marpa::gen::runtime::c::Limit16 {label n} {
    if {$n < 65536} return
    return -code error "ZZZ:$label $n > 64K"
}

proc ::marpa::gen::runtime::c::Limit12 {label n} {
    if {$n < 4096} return
    return -code error "ZZZ:$label $n > 4K"
}

proc ::marpa::gen::runtime::c::Width {words} {
    return [tcl::mathfunc::max {*}[lmap w $words { string length $w }]]
}


proc ::marpa::gen::runtime::c::dictsort {dict} {
    foreach k [lsort -dict [dict keys $dict]] {
	lappend r $k [dict get $dict $k]
    }
    return $r
}

proc ::marpa::gen::runtime::c::Events2Table {dict sym} {
    if {![dict size $dict]} { return {} }
    # Flatten
    dict for {symbol spec} $dict {
	dict for {type decl} $spec {
	    dict for {event active} $decl {
		# Attention: Type converter has to match
		# marpa_runtime_c.h:marpatcl_rtc_event_code
		set type [dict get {
		    after     marpatcl_rtc_event_after
		    before    marpatcl_rtc_event_before
		    completed marpatcl_rtc_event_completed
		    discard   marpatcl_rtc_event_discard
		    nulled    marpatcl_rtc_event_nulled
		    predicted marpatcl_rtc_event_predicted
		} $type]
		set active [dict get {
		    on  1  true  1  1 1
		    off 0  false 0  0 0
		} $active]
		# Note: The lex engine sees ACS symbols for lexemes
		# and discards. Use them in the table.
		switch -exact -- $sym {
		    L {	set sid [$sym 2id @ACS:$symbol] }
		    G {	set sid [$sym 2id $symbol] }
		}
		lappend table [list $event $symbol $sid $type $active]
	    }
	}
    }
    # Sort (Event names, then symbol names)
    return [lsort -dict -index 0 [lsort -dict -index 1 $table]]
}

proc ::marpa::gen::runtime::c::EventRef {name table} {
    if {[llength $table]} {
	return &${name}
    }
    return 0
}

proc ::marpa::gen::runtime::c::EventNames {table} {
    if {![llength $table]} { return "" }

    lappend names "\ncritcl::literals::def [core-config? name]_event \{"
    set k 0
    foreach item $table {
	lassign $item event _ _ _ _
	lappend names "    u$k \"$event\""
	incr k
    }
    lappend names "\} +list\n"
    
    return [join $names \n]
}

proc ::marpa::gen::runtime::c::EventTable {name table} {
    set n [llength $table]
    if {!$n} { return "" }

    lappend decl "\n    static marpatcl_rtc_event_spec $name \[$n\] = \{"
    foreach item $table {
	lassign $item event sym sid type active
	# TODO: left-pad / right-align the columns
	lappend decl "\t\{ $sid, $type, $active \}, // ${sym}: $event"
    }
    lappend decl "    \};\n"
    # dsz + len(table)*(4+4+4)

    return [join $decl \n]
}

proc ::marpa::gen::runtime::c::EventStruct {name table dname {offset 0}} {
    set n [llength $table]
    if {!$n} { return "" }

    lappend decl "\n    static marpatcl_rtc_events $name = \{"
    if {$offset} {
	lappend decl "\t$n, ${dname} + $offset"
    } else {
	lappend decl "\t$n, ${dname}"
    }
    lappend decl "    \};\n"
    # dsz + 8 (2+4+pad:2)

    return [join $decl \n]
}

# # ## ### ##### ######## #############
## Various helper classes to hold generator state

oo::class create marpa::gen::runtime::c::Mask {
    variable mymask ; # dict (mask -> list(rule id))
    variable mycount
    variable myfinal
    variable mytag
    variable mycode

    constructor {} {
	set mycount 0
	set mymask  {}
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
	# masks
	if {$type eq "priority" && [llength $rhs]} {
	    if {![info exists mask]} { error MASK-MISSING:($rule) }
	    if {$mask eq {}} { error MASK-EMPTY:($rule) }
	    # mask is bit vector (true -> hidden, convert to filter)
	    set filter [::marpa::gen remask $mask]
	    set filter [linsert $filter 0 [llength $filter]]
	} else {
	    # quantified, or empty rule - No mask, no filter
	    set filter 0
	}
	# filter = (length, i'0 ... i'length-1)

	dict lappend mymask $filter $mycount
	return
    }

    method Finalize {} {
	if {$myfinal} return
	set myfinal 1

	if {[dict size $mymask] == 1} {
	    # Code global
	    set mytag  MARPATCL_S_SINGLE
	    set mycode [lindex [dict keys $mymask] 0]
	    return
	}
	# Code variadic
	set ref    $mycount
	set mytag  MARPATCL_S_PER
	set mycode [lrepeat $mycount -1]

	set max $mycount
	foreach s [dict keys $mymask] {
	    if {[lindex $s 0] == 0} continue
	    incr max [llength $s]
	}
	set df %[string length $max]d

	foreach s [lsort -dict [dict keys $mymask]] {
	    if {[lindex $s 0] == 0} {
		# Do not store empty mask definitions.
		# Indicate them via offset zero.
		foreach r [dict get $mymask $s] {
		    lset mycode $r 0
		}
		continue
	    }
	    lappend mycode {*}[lreplace $s 0 0 "/* [format $df $ref] */ [lindex $s 0]"]
	    foreach r [dict get $mymask $s] {
		lset mycode $r $ref
	    }
	    incr ref [llength $s]
	}
	return
    }
}

# # ## ### ##### ######## #############

oo::class create marpa::gen::runtime::c::SemaG {
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

	set action [::marpa::gen::runtime::c::SemaCodeG $action]
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
	set mycode [lrepeat $mycount -1]
	set max $mycount

	foreach s [dict keys $mysema] {
	    if {[lindex $s 0] == 0} continue
	    incr max [llength $s]
	}
	set df %[string length $max]d

	foreach s [lsort -dict [dict keys $mysema]] {
	    lappend mycode {*}[lreplace $s 0 0 "/* [format $df $ref] */ [lindex $s 0]"]
	    foreach r [dict get $mysema $s] {
		lset mycode $r $ref
	    }
	    incr ref [llength $s]
	}
	return
    }
}

# # ## ### ##### ######## #############

oo::class create marpa::gen::runtime::c::Rules {
    variable myrules    ; # list (string) : rule instructions
    variable mydisplay1 ; # list (string) : rule lhs (parallels myrules)
    variable mydisplay2 ; # list (string) : rule rhs (parallels myrules)
    variable mysize     ; # int           : #rule instructions (llength myrules)
    variable myrnum     ; # int           : #rules (>= mysize (branges!))
    variable myelements ; # int           : #entries in the instruction array
    variable mynames    ; # list (int)    : rule name ref (parallels myrules)
    variable mylhsids   ; # list (int)    : rule lhs name ref (parallels myrules)
    variable myusenames ; # bool          : true -> `mynames`, `mylhsids` are valid
    variable mymaxpad   ; # int           : max length of a rule right hand side
    variable mylastlhs  ; # string        : last lhs id specified by a CMD_PRIO
    variable myblank    ; # string        : whitespace covering `mylastlhs`.

    constructor {sym pool {usenames 0}} {
	marpa::import $sym  S
	marpa::import $pool P
	set myrules    {}
	set mydisplay1 {}
	set mydisplay2 {}
	set mysize     0
	set myrnum     0
	set myelements 0
	set mynames    {}
	set mylhsids   {}
	set myusenames $usenames
	set mymaxpad   0
	set mylastlhs  {}
	set myblank    {}
	return
    }

    method content {{prefix {    }}} {
	set maxr [marpa::gen::runtime::c::Width $myrules]
	set maxd [marpa::gen::runtime::c::Width $mydisplay1]
	set fmta "${prefix}%-${maxr}s /* %-${maxd}s %s */"
	set fmtb "${prefix}%s"

	return [join [lmap ins $myrules lhs $mydisplay1 rhs $mydisplay2 {
	    if {$lhs ne {}} {
		format $fmta $ins $lhs $rhs
	    } else {
		format $fmtb $ins $lhs $rhs
	    }
	}] \n]
    }

    method refs {} {
	return $mynames
    }

    method lhs {} {
	return $mylhsids
    }

    method add {words} {
	foreach rule $words {
	    lassign $rule lhs def
	    set details [lassign $def type]
	    my P_$type $lhs {*}$details
	    if {!$myusenames} continue
	    lappend mynames  [P id [marpa::gen::runtime::c::RName $rule]]
	    lappend mylhsids [S 2id $lhs]
	}
	return
    }

    method start {sym} {
	# wrap the rule instructions into declarations of scratch area
	# size and start symbol.
	set     myrules [linsert $myrules 0 [my C start $mymaxpad],]
	lappend myrules [my C stop [S 2id $sym]]
	set     mydisplay1 [linsert $mydisplay1 0 {}]
	lappend mydisplay1 {}
	set     mydisplay2 [linsert $mydisplay2 0 {}]
	lappend mydisplay2 {}
	incr myelements 2
	return
    }

    method P_brange {lhs start stop} {
	lappend cmd [my C brange [S 2id $lhs]]
	lappend cmd "MARPATCL_RCMD_BOXR ([format %3d $start],[format %3d $stop])"
	my P $cmd <$lhs> "brange ($start - $stop)"
	incr myelements 2
	incr myrnum [expr {$stop - $start + 1}]
	return
    }

    method P_priority {lhs rhs prio args} {
	# g1: name, action, mask; ignore assoc
	# l0: ignore all
	set lhid [S 2id $lhs]

	set rl [llength $rhs]
	::marpa::gen::runtime::c::Limit12 {priority rhs length} $rl
	if {$rl > $mymaxpad} { set mymaxpad $rl }
	incr myelements $rl
	incr myrnum

	if {$lhid eq $mylastlhs} {
	    # Short coding of rule for same LHS
	    lappend cmd [my C prio-short $rl]$myblank
	    incr myelements 1
	    set lhs " [string repeat { } [string length $lhs]] "
	    set op "|   "
	} else {
	    # New lhs, full coding, and save for reuse
	    lappend cmd [my C prio $rl]
	    lappend cmd $lhid
	    incr myelements 2
	    set mylastlhs $lhid
	    set    myblank {  }
	    append myblank [string repeat { } [string length $lhid]]
	    set lhs <${lhs}>
	    set op "::= "
	}
	lappend cmd {*}[lmap s $rhs { S 2id $s }]
	my P $cmd $lhs $op[join [lmap w $rhs { set _ <${w}> }] { }]
	return
    }

    method P_quantified {lhs rhs pos args} {
	set lhsid [S 2id $lhs]
	set op [dict get {
	    0 *
	    1 +
	} $pos]
	dict with args {}
	set suffix {}
	if {[info exists separator]} {
	    lassign $separator separator proper
	    set separatorid [S 2id $separator]
	    set suffix " (<$separator>[dict get {
		0 {}
		1 { P}
	    } $proper])"
	}
	incr myrnum
	switch -exact -- ${pos}[info exists separator] {
	    00 {
		lappend cmd [my C quant* $lhsid]
		lappend cmd [S 2id $rhs]
		incr myelements 2
	    }
	    01 {
		lappend cmd [my C quant*S $lhsid]
		lappend cmd [S 2id $rhs]
		lappend cmd [my C [my S $proper] $separatorid]
		incr myelements 3
	    }
	    10 {
		lappend cmd [my C quant+ $lhsid]
		lappend cmd [S 2id $rhs]
		incr myelements 2
	    }
	    11 {
		lappend cmd [my C quant+S $lhsid]
		lappend cmd [S 2id $rhs]
		lappend cmd [my C [my S $proper] $separatorid]
		incr myelements 3
	    }
	}
	my P $cmd <$lhs> "::= <$rhs> $op$suffix"
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
	lappend myrules    "[join $cmd ", "],"
	lappend mydisplay1 $lhs
	lappend mydisplay2 $display
	incr mysize
	return
    }

    method size {} {
	return $mysize
    }

    method numrules {} {
	return $myrnum
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

oo::class create marpa::gen::runtime::c::Sym {
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

oo::class create marpa::gen::runtime::c::Bytes {
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

oo::class create marpa::gen::runtime::c::Pool {
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
	    ::marpa::gen::runtime::c::Limit16 {string pool offset} $offset
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
package provide marpa::gen::runtime::c 1
return
