# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Semantics. Manually written, as a backend to the
# marpa::slif::parser class, processing the AST it generated. Boot
# strapping will replace this later with generated code. Note that the
# semantics are not the container for a SLIF grammar. That is handled
# by a separate class, marpa::slif::container. It is the intermediate
# between parser and container, converting the AST into calls on the
# container, filling it with the grammar encoding the AST.

# Note: While the container has lots of internal objects the semantics
# will not see these. There will be no indirect access by asking the
# container for some internal object and then directly talking to that
# object. All operations go through container methods. All internals
# are hidden from the semantics.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require char          ;# quoting cstring - debugging narrative
package require oo::util      ;# mymethod

debug define marpa/slif/semantics
#debug prefix marpa/slif/semantics {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::semantics {
    marpa::E marpa/slif/semantics SLIF SEMANTICS

    variable mycc ;# map from char class literal symbols to their
		   # original literal. Always the last.

    constructor {container} {
	debug.marpa/slif/semantics {[marpa::D {
	    # Mix helpers, pre- and post- filters on all AST
	    # processing methods into the instance, to generate the
	    # complex debugging output (indenting, etc.)
	    oo::objdefine [self] mixin marpa::slif::semantics::Debug
	    # XXX Multi-method link fails, links only the first XXX
	    link {AT     AT}
	    link {DEDENT DEDENT}
	    link {INDENT INDENT}
	    link {UNDENT UNDENT}
	}]}
	marpa::import $container Container
	set mycc {}

	# Track the def and use locations for all pieces of rules
	set def [marpa::slif::semantics::Locations create definition $container]
	set use [marpa::slif::semantics::Locations create usage      $container]
	# TODO: Make use of this information in other places, in
	#       particular in error messages.

	# Track symbol classifications
	set st [marpa::slif::semantics::Symbol create \
		    Symbol $container $def $use [self]]

	# Track G1 action/bless defaults
	marpa::slif::semantics::Defaults create G1 \
	    $container {
		action {array values}
		bless  {special undef}
	    }

	# Track LATM flag handling for lexemes
	marpa::slif::semantics::Fixup create LATM $container 1

	# Track event handling for discards
	marpa::slif::semantics::Fixup create DDE $container {}

	# Track inacessible singleton
	marpa::slif::semantics::Singleton create IA \
	    "Illegal second use of 'inacessible'" INACCESSIBLE

	# Track lexeme default singleton
	marpa::slif::semantics::Singleton create LD \
	    "Illegal second use of 'lexeme default'" LEXEME-DEFAULT

	# Track discard default singleton
	marpa::slif::semantics::Singleton create DD \
	    "Illegal second use of 'discard default'" DISCARD-DEFAULT

	# Semantic state, start symbol.
	marpa::slif::semantics::Start create \
	    Start $container $st $def $use [self]

	# Semantic state per symbol and the history of contexts each
	# was found in.
	marpa::slif::semantics::SymContext create SymCo

	# Shortcut access to all AST processing methods (implicit "my")
	# Format: <name>/<number>
	if 0 {foreach m [info class methods [self class] -private] {
	    if {![string match */* $m]} continue
	    link [list $m $m]
	}}

	# Shortcut access to AST helper methods (from with the processing methods)
	link {EVAL    EVAL}    ;# Recursive AST evaluation without sem value
	link {EVALR   EVALR}   ;# Ditto, limited to a range of children
	link {EVALS   EVALS}   ;# Ditto, with interposed script
	link {VALUES  VALUES}  ;# As EVAL, but returns list of child results
	link {FLATTEN FLATTEN} ;# As above, and flattens the list
	link {DESEQ   DESEQ}   ;# Strip odd/even elements from the children
	link {FIRST   FIRST}   ;# Get sem value of 1st child, recursively eval'd
	link {SINGLE  SINGLE}  ;# Get sem value of chosen child, recursively eval'd
	link {LITERAL LITERAL} ;# Get literal string for chosen AST node
	link {LITLOC  LITLOC}  ;# Get literal location for chosen AST node
	link {ADVL    ADVL}    ;# Generate singular adverb sem value, for literal
	link {ADVS    ADVS}    ;# Generate singular adverb sem value, for symbol
	link {ADVQ    ADVQ}    ;# Quantified rule adverb special handling
	link {ADVE    ADVE}    ;# :lexeme adverb special handling
	link {ADVE1   ADVE1}   ;# :discard adverb special handling
	link {SYMBOL  SYMBOL}  ;# Get symbol instance for chosen AST node
	link {CONST   CONST}   ;# Sem value is fixed.
	link {LEAF    LEAF}    ;# Leaf rhs sem value from symbol
	link {UNMASK  UNMASK}  ;# Extract symbol part from an rhs sem value
	link {MERGE   MERGE}   ;# Merge multiple rhs sem values
	link {MERGE2  MERGE2}  ;# Merge 2 rhs sem values
	link {HIDE    HIDE}    ;# Set mask in rhs sem value to "all hidden"
	link {CCLASS  CCLASS}  ;# Character class translation
	link {CSTRING CSTRING} ;# Character string translation
	link {CHAR    CHAR}    ;# Character normalization. Determine codepoint, wrap.
	link {CCODE   CCODE}   ;# Char codepoint, raw.
	link {CWRAP   CWRAP}   ;# Char boxing
	link {UNESC   UNESC}   ;# Char normalization. Handle escape sequences.
	link {RANGES  RANGES}  ;# Recompression of adjacent chars into ranges.
	link {G1Event G1Event} ;# Adverb processing for g1 parse events
	link {E       ERR}
	link {LOCFMT  LOCFMT}
    }

    method process {ast} {
	debug.marpa/slif/semantics {[debug caller 1] |}

	# Execute the AST, and in doing so fill the slif grammar
	# container. This needs the methods as immediately accessible
	# commands, with the AST type elements used as the methods
	# called.
	my {*}$ast

	# Complete anything still waiting (fixups and the like)
	Container comment Semantics completion processing

	# Validate the final states of all symbols, report the
	# concluding issues.
	Symbol finalize

	# Check that we have a start symbol, if needed pass it on.
	Start complete

	# Finalize LATM and DDE
	LATM fix [Symbol filter lexeme]  [mymethod FixLATM]
	DDE  fix [Symbol filter discard] [mymethod FixDDE]

	# TODO: @end assert (All L0 symbols have a def location (rule, atomic))
	# TODO: @end assert (All G1 symbols, but start have a use location)

	# Done. Auto-destroy
	debug.marpa/slif/semantics {[debug caller 1] | /ok}
	my destroy
	return
    }

    # # ## ### ##### ######## #############
    ## AST processing methods

    # Toplevel. Execute all declarations.
    method statements/0 {children} { EVAL }

    # # -- --- ----- -------- -------------

    method statement/0  {children} { EVAL } ; # OK <start rule>
    method statement/1  {children} { EVAL } ; # OK <empty rule>
    method statement/2  {children} {      } ; # IGNORED <null statement>
    method statement/3  {children} { EVAL } ; # OK <statement group>
    method statement/4  {children} { EVAL } ; # OK <priority rule>
    method statement/5  {children} { EVAL } ; # OK <quantified rule>
    method statement/6  {children} { EVAL } ; # OK <discard rule>
    method statement/7  {children} { EVAL } ; # OK <default rule>
    method statement/8  {children} { EVAL } ; # OK <lexeme default statement>
    method statement/9  {children} { EVAL } ; # OK <discard default statement>
    method statement/10 {children} { EVAL } ; # OK <lexeme rule>
    method statement/11 {children} { EVAL } ; # OK <completion event declaration>
    method statement/12 {children} { EVAL } ; # OK <nulled event declaration>
    method statement/13 {children} { EVAL } ; # OK <prediction event declaration>
    #method statement/14 {children} { EVAL } ; # FAIL NODOC <current lexer statement>
    method statement/15 {children} { EVAL } ; # OK <inaccessible statement>

    # Executing the statements in order updates the grammar ...
    # # -- --- ----- -------- -------------
    ## Start symbol declaration

    method {start rule/0} {children} { SymCo g1 use ; Start with: [FIRST] } ; # OK <symbol>
    method {start rule/1} {children} { SymCo g1 use ; Start with: [FIRST] } ; # OK <symbol>

    # # -- --- ----- -------- -------------
    ## Null statement - Not reachable, see statement/2

    method {null statement/0} {children} { ERR "unreachable" UNREACHABLE } ; # OK ()

    # # -- --- ----- -------- -------------
    ## Statement grouping, simply recurse. No nested scopes

    method {statement group/0} {children} { EVAL } ; # OK <statement>...

    # # -- --- ----- -------- -------------
    ## Quantified rules (repetitions, lists, sequences)

    method {quantified rule/0} {children} {
	# :  0             1     2            3
	# OK <lhs>         <rhs> <quantifier> <adverbs>
	#     |              \   */+             /
	#     \- symbol name  \- single symbol  /
	#                                      /
	# Accepted adverbs (see statement/5) -/
	# - action    -- <action>
	# - bless     -- <blessing>                   | IGNORED. WARN
	# - proper    -- <proper specification>
	# - separator -- <separator specification>
	# - name      -- <naming>
	# - rank      -- <rank specification>         | IGNORED. WARN
	# - null rank -- <null ranking specification> |

	SymCo g1 definition
	set lhs [FIRST]
	Symbol context1 g1-definition $lhs

	SymCo usage
	set rhs [lindex [UNMASK [SINGLE 1]] 0]
	Symbol context1 g1-usage      $rhs

	# SymCo usage, still
	set adverbs [G1 defaults [SINGLE 3]] ;
	ADVQ adverbs

	if {[dict exists $adverbs separator]} {
	    # The separator symbol is used as well.
	    set sep [lindex [dict get $adverbs separator] 0]
	    Symbol context1 g1-usage $sep
	}

	set positive [SINGLE 2]

	Container g1 quantified-rule $lhs $rhs $positive {*}$adverbs
	Start maybe: $lhs
	return
    }

    method {quantified rule/1} {children} {
	#    0             1     2            3
	# OK <lhs>         <rhs> <quantifier> <adverbs>
	#     |              \      */+          /
	#     \- symbol name  \- single symbol  /
	#                                      /
	# Accepted adverbs (see statement/5) -/
	# - proper    -- <proper specification>
	# - separator -- <separator specification>

	SymCo l0 definition
	set lhs [FIRST]
	Symbol context1 l0-definition $lhs

	SymCo usage
	set rhs [lindex [UNMASK [SINGLE 1]] 0]
	Symbol context1 l0-usage $rhs

	set adverbs  [SINGLE 3] ;# still /usage
	ADVQ adverbs

	if {[dict exists $adverbs separator]} {
	    # The separator symbol is used as well.
	    set sep [lindex [dict get $adverbs separator] 0]
	    Symbol context1 l0-usage $sep
	}

	set positive [SINGLE 2]

	Container l0 quantified-rule $lhs $rhs $positive {*}$adverbs
	return
    }

    # # -- --- ----- -------- -------------
    ## Empty rules. Like prioritized rules below, except with a more
    ## limited set of adverbs.

    method {empty rule/0} {children} { # OK <lhs> <op declare bnf> <adverb list>
	# <lhs> <adverb list bnf empty>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - action    -- <action>
	# - bless     -- <blessing>

	SymCo g1 definition
	set lhs [FIRST]
	Symbol context1 g1-definition $lhs

	set adverbs [G1 defaults [SINGLE 1]]

	Container g1 priority-rule $lhs {} 0 {*}$adverbs
	Start maybe: $lhs
	return
    }

    method {empty rule/1} {children} { # OK <lhs> <op declare match> <adverb list>
	# <lhs> <adverb list match empty>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - name
	# - null

	SymCo l0 definition
	set lhs [FIRST]
	Symbol context1 l0-definition $lhs

	set adverbs [SINGLE 1]

	Container l0 priority-rule $lhs {} 0 {*}$adverbs
	return
    }

    # # -- --- ----- -------- -------------
    ## Priority rules. BNF rules, alternatives, prioritized

    method {priority rule/0} {children} {
	# 0     1
	# <lhs> <priorities bnf>
	#  \- symbol name     \- alternatives each with adverb information
	#
	# Push information (lhs, decl) down to the <alternative>, do
	# adverb and precedence processing there, not here.

	SymCo g1 definition
	SymCo lhs [set lhs [FIRST]]

	SymCo usage precedence/reset
	EVALR 1 end

        Start maybe: $lhs
	return
    }

    method {priority rule/1} {children} {
	# 0     1
	# <lhs> <priorities match>
	#  \- symbol name       \- alternatives each with adverb information
	#
	# Push information (lhs, decl) down to the <alternative>, do
	# adverb and precedence processing there, not here.

	SymCo l0 definition
	SymCo lhs [FIRST]

	SymCo usage precedence/reset
	EVALR 1 end
	return
    }

    method {priorities bnf/0} {children} {
	DESEQ ; EVALS { SymCo precedence/loosen }
    } ; # OK <alternatives bnf> <op loosen> ...

    method {priorities match/0} {children} {
	DESEQ ; EVALS { SymCo precedence/loosen }
    } ; # OK <alternatives match> <op loosen> ...

    method {alternatives bnf/0} {children} {
	DESEQ ; EVAL
    } ; # OK <alternative bnf> <op equal priority> ...

    method {alternatives match/0} {children} {
	DESEQ ; EVAL
    } ; # OK <alternative match> <op equal priority> ...

    method {alternative bnf/0}  {children} {
	# <rhs> <adverb list bnf alternative>
	# G1 implied

	SymCo assert g1
	set lhs [SymCo lhs?]
	Symbol context1 g1-definition $lhs

	lassign [FIRST] rhsmask rhssymbols
	Symbol context  g1-usage {*}$rhssymbols

	set adverbs [G1 defaults [SINGLE 1]]
	dict set adverbs mask $rhsmask

	set prec [SymCo precedence?]

	Container g1 priority-rule $lhs $rhssymbols $prec {*}$adverbs
	return
    }

    method {alternative match/0} {children} {
	# <rhs> <adverb list match alternative>
	# L0 implied

	SymCo assert l0
	set lhs     [SymCo lhs?]
	Symbol context1 l0-definition $lhs

	# Ignore masking, irrelevant at L0 level.
	lassign [FIRST] __ rhssymbols
	Symbol context  l0-usage      {*}$rhssymbols

	set adverbs [SINGLE 1]
	set prec    [SymCo precedence?]

	Container l0 priority-rule $lhs $rhssymbols $prec {*}$adverbs
	return
    }

    method rhs/0                {children} { MERGE {*}[VALUES] } ; # OK <rhs>+
    method {rhs primary list/0} {children} { MERGE {*}[VALUES] } ; # OK <rhs>+

    method {rhs primary/0} {children} { FIRST }          ; # OK <single symbol>
    method {rhs primary/1} {children} { LEAF [CSTRING] } ; # OK <single quoted string>
    method {rhs primary/2} {children} { FIRST }          ; # OK <parenthesized rhs primary list>

    method {parenthesized rhs primary list/0} {children} { HIDE [FIRST] } ; # OK <rhs primary list>

    # # -- --- ----- -------- -------------
    ## Quantifiers

    method quantifier/0 {children} { CONST 0 }
    method quantifier/1 {children} { CONST 1 }

    # # -- --- ----- -------- -------------
    ## Handle lexeme default and :lexeme

    method {lexeme default statement/0} {children} {
	# <adverb list lexeme default>
	# 0
	##
	# Note: May only be used ONCE
	# Adverbs
	# - action \ These go into the grammar (container)
	# - bless  /
	# - latm   | This goes into LATM handling with the :lexeme's
	LD pass

	set adverbs [SINGLE 0]

	# TODO: Should possibly register warning if there are no adverbs.
	if {![dict size $adverbs]} return

	set action $adverbs
	dict unset action latm
	if {[dict size $action]} {
	    # Have at least one of action, bless
	    Container lexeme-semantics {*}$action
	}

	dict unset adverbs action
	dict unset adverbs bless
	# latm only at this point, at most.

	if {![dict size $adverbs]} return
	# latm definitely present.
	LATM default: [dict get $adverbs latm]
	return
    }

    method {lexeme rule/0} {children} {
	# <symbol> <adverb list lexeme>
	# 0        1
	# Adverbs
	# - event    \ Check before
	# - pause    /
	# - priority
	# - latm     | This goes into LATM handling with the :lexeme's

	SymCo l0 use
	set symbol  [FIRST]
	Symbol context1 :lexeme $symbol ;# Issues container ops

	set adverbs [SINGLE 1]
	#Container comment :lexeme adverbs = $adverbs ;#debug
	ADVE adverbs

	if {![dict size $adverbs]} return

	Container l0 configure $symbol {*}$adverbs
	LATM exclude $symbol
	return
    }

    method FixLATM {symbol latm} {
	Container l0 configure $symbol latm $latm
	return
    }

    # # -- --- ----- -------- -------------
    ## Handle discard default and :discard

    method {discard default statement/0} {children} {
	# <adverb list discard default>
	# 0
	##
	# Note: May only be used ONCE
	# Adverbs
	# - event
	DD pass

	set adverbs [SINGLE 0]
	if {![dict size $adverbs]} return

	# event definitely present.
	# force check (fail bad specials early)
	ADVE1 $adverbs dummy
	DDE default: $adverbs
	return
    }

    method {discard rule/0} {children} {
	# symbol <adverb list discard>
	# 0      1
	# Adverbs
	# - event

	SymCo l0 use
	set symbol [FIRST]
	Symbol context1 :discard $symbol ;# Issues container ops

	set adverbs [SINGLE 1]
	#Container comment :discard adverbs = $adverbs ;#debug
	if {![dict exists $adverbs event]} return

	Container l0 configure $symbol {*}[ADVE1 $adverbs $symbol]
	DDE exclude $symbol
	return
    }

    method {discard rule/1} {children} {
	# <character class> <adverb list discard>
	# 0                 1
	# Adverbs
	# - event

	SymCo l0 use
	set litsymbol [CCLASS] ;# implied index 0

	# Create a proper discard symbol on top of the char class
	# literal, plus associated priority rule. See also CCLASS and
	# CSTRING for similar constructions to embed a literal into G1
	# with a helper lexeme symbol.

	set discard @DIS:$litsymbol
	definition add {*}[definition last $litsymbol] $discard
	Symbol context1 l0-definition $discard ;# Issues container ops
	Symbol context1 :discard      $discard ;# Issues container ops
	Container l0 priority-rule    $discard $litsymbol 0

	set adverbs [SINGLE 1]
	#Container comment :discard adverbs = $adverbs ;#debug
	if {![dict exists $adverbs event]} return

	# Event name is actual literal, if special.
	set literal [dict get $mycc $litsymbol]
	Container l0 configure $discard {*}[ADVE1 $adverbs $literal]
	DDE exclude $discard
	return
    }

    method FixDDE {symbol adverbs} {
	if {$adverbs eq {}} return
	Container l0 configure $symbol {*}[ADVE1 $adverbs $symbol]
	return
    }

    # # -- --- ----- -------- -------------
    ## G1 action/bless defaults

    method {default rule/0} {children} {
	# <adverb list default>
	# 0
	# Adverbs
	# - action
	# - bless
	G1 defaults: [FIRST]
	return
    }

    # # -- --- ----- -------- -------------
    ## G1 parse event declarations

    method {completion event declaration/0} {children} {
	# <event initialization> <symbol name>

	SymCo g1 usage
	set symbol [SINGLE 1]
	Symbol context1 g1-usage $symbol

	Container g1 event $symbol [G1Event completed $symbol]
	return
    }

    method {nulled event declaration/0} {children} {
	# <event initialization> <symbol name>

	SymCo g1 usage
	set symbol [SINGLE 1]
	Symbol context1 g1-usage $symbol

	Container g1 event $symbol [G1Event nulled $symbol]
	return
    }

    method {prediction event declaration/0} {children} {
	# <event initialization> <symbol name>
	SymCo g1 usage
	set symbol [SINGLE 1]
	Symbol context1 g1-usage $symbol

	Container g1 event $symbol [G1Event predicted $symbol]
	return
    }

    method G1Event {e symbol} {
	upvar 1 children children
	# Run through common event post-processing. This needs boxing
	# it up as adverb, and unboxing the result
	# TODO - Rewrite to work on unboxed value instead of adverb.
	set spec [dict get [ADVE1 [dict create event [FIRST]] $symbol] event]
	# Fix event type, and record
	lset spec 2 $e
	return $spec
    }

    # # -- --- ----- -------- -------------
    ##

    method {inaccessible statement/0} {children} {
	# <inaccessible treatment>
	IA pass
	Container inaccessible [FIRST]
	return
    }

    method {inaccessible treatment/0} {children} { CONST warn  }
    method {inaccessible treatment/1} {children} { CONST ok    }
    method {inaccessible treatment/2} {children} { CONST fatal }

    # # -- --- ----- -------- ------------- BOTTOM
    # # -- --- ----- -------- -------------
    # # -- --- ----- -------- -------------
    # # -- --- ----- -------- -------------
    # # -- --- ----- -------- -------------

    # # -- --- ----- -------- -------------
    ## Adverb processing. The semantic value coming out of the top of
    ## that sub tree is a dictionary mapping from adverb names to values.
    ## Note: Location information is currently not available.

    method {adverb list default/0}           {children} { FIRST }
    method {adverb list discard/0}           {children} { FIRST }
    method {adverb list lexeme/0}            {children} { FIRST }
    method {adverb list discard default/0}   {children} { FIRST }
    method {adverb list lexeme default/0}    {children} { FIRST }
    method {adverb list bnf alternative/0}   {children} { FIRST }
    method {adverb list bnf empty/0}         {children} { FIRST }
    method {adverb list bnf quantified/0}    {children} { FIRST }
    method {adverb list match alternative/0} {children} { FIRST }
    method {adverb list match empty/0}       {children} { FIRST }
    method {adverb list match quantified/0}  {children} { FIRST }

    # Squash the list of separate parts (each a single-key dict) into
    # a single (multi-key) dict
    method {adverb list items default/0}           {children} { FLATTEN }
    method {adverb list items discard/0}           {children} { FLATTEN }
    method {adverb list items lexeme/0}            {children} { FLATTEN }
    method {adverb list items discard default/0}   {children} { FLATTEN }
    method {adverb list items lexeme default/0}    {children} { FLATTEN }
    method {adverb list items bnf alternative/0}   {children} { FLATTEN }
    method {adverb list items bnf empty/0}         {children} { FLATTEN }
    method {adverb list items bnf quantified/0}    {children} { FLATTEN }
    method {adverb list items match alternative/0} {children} { FLATTEN }
    method {adverb list items match empty/0}       {children} { FLATTEN }
    method {adverb list items match quantified/0}  {children} { FLATTEN }

    method {adverb item default/0} {children} { FIRST } ;# action
    method {adverb item default/1} {children} { FIRST } ;# bless
    method {adverb item default/2} {children} { FIRST } ;# null

    method {adverb item discard/0} {children} { FIRST } ;# event
    method {adverb item discard/1} {children} { FIRST } ;# null

    method {adverb item lexeme/0} {children} { FIRST } ;# event
    method {adverb item lexeme/1} {children} { FIRST } ;# latm
    method {adverb item lexeme/2} {children} { FIRST } ;# priority
    method {adverb item lexeme/3} {children} { FIRST } ;# pause
    method {adverb item lexeme/4} {children} { FIRST } ;# null

    method {adverb item discard default/0} {children} { FIRST } ;# event
    method {adverb item discard default/1} {children} { FIRST } ;# null

    method {adverb item lexeme default/0} {children} { FIRST } ;# action
    method {adverb item lexeme default/1} {children} { FIRST } ;# bless
    method {adverb item lexeme default/2} {children} { FIRST } ;# latm
    method {adverb item lexeme default/3} {children} { FIRST } ;# null

    method {adverb item bnf alternative/0} {children} { FIRST } ;# action
    method {adverb item bnf alternative/1} {children} { FIRST } ;# bless
    method {adverb item bnf alternative/2} {children} { FIRST } ;# left
    method {adverb item bnf alternative/3} {children} { FIRST } ;# right
    method {adverb item bnf alternative/4} {children} { FIRST } ;# group
    method {adverb item bnf alternative/5} {children} { FIRST } ;# naming
    method {adverb item bnf alternative/6} {children} { FIRST } ;# null

    method {adverb item bnf empty/0} {children} { FIRST } ;# action
    method {adverb item bnf empty/1} {children} { FIRST } ;# bless
    method {adverb item bnf empty/2} {children} { FIRST } ;# left
    method {adverb item bnf empty/3} {children} { FIRST } ;# right
    method {adverb item bnf empty/4} {children} { FIRST } ;# group
    method {adverb item bnf empty/5} {children} { FIRST } ;# naming
    method {adverb item bnf empty/6} {children} { FIRST } ;# null

    method {adverb item bnf quantified/0} {children} { FIRST } ;# action
    method {adverb item bnf quantified/1} {children} { FIRST } ;# bless
    method {adverb item bnf quantified/2} {children} { FIRST } ;# separator
    method {adverb item bnf quantified/3} {children} { FIRST } ;# proper
    method {adverb item bnf quantified/4} {children} { FIRST } ;# null

    method {adverb item match alternative/0} {children} { FIRST } ;# naming
    method {adverb item match alternative/1} {children} { FIRST } ;# null

    method {adverb item match empty/0} {children} { FIRST } ;# naming
    method {adverb item match empty/1} {children} { FIRST } ;# null

    method {adverb item match quantified/0} {children} { FIRST } ;# separator
    method {adverb item match quantified/1} {children} { FIRST } ;# proper
    method {adverb item match quantified/2} {children} { FIRST } ;# null

    #             Defaults
    # action      l0 [values] g1 undef
    # left  assoc \* left
    # right assoc |
    # group assoc /
    # separator   undef
    # proper      no
    # rank        ?
    # null rank   ?
    # priority    0
    # pause       undef
    # event       undef
    # latm        no
    # bless       undef
    # name        undef
    # null        N/A

    # # -- --- ----- -------- -------------

    method {proper specification/0}    {children} { ADVL proper    [LITERAL]        }
    method {separator specification/0} {children} { ADVS separator [lindex [UNMASK [FIRST]] 0] }

    # # -- --- ----- -------- -------------
    ## TODO XXX null ranking - check sem value propriety

    method {null ranking specification/0} {children} { ADVS 0rank [FIRST]  } ; # OK
    method {null ranking specification/1} {children} { ADVS 0rank [FIRST]  } ; # OK

    method {null ranking constant/0} {children} { CONST low  } ; # OK
    method {null ranking constant/1} {children} { CONST high } ; # OK

    # # -- --- ----- -------- -------------

    method {left association/0}  {children} { ADVL assoc left  }
    method {right association/0} {children} { ADVL assoc right }
    method {group association/0} {children} { ADVL assoc group }

    # # -- --- ----- -------- -------------

    method {latm specification/0} {children} { ADVL latm [LITERAL] }
    method {latm specification/1} {children} { ADVL latm [LITERAL] }

    # # -- --- ----- -------- -------------

    method {priority specification/0} {children} { ADVL priority [LITERAL] }

    # # -- --- ----- -------- -------------

    method {pause specification/0}  {children} { ADVL pause [LITERAL] }
    method {event specification/0}  {children} { ADVS event [FIRST] }

    method {event initialization/0} {children} { list [FIRST] [SINGLE 1] }

    method {event name/0} {children} {
	# standard name - identifier
	list standard [LITERAL]
    }
    method {event name/1} {children} {
	# single quoted
	list standard [my NORM [LITERAL]]
    }
    method {event name/2} {children} {
	# reserved name ::...
	list special [string range [LITERAL] 2 end]
    }

    method {event initializer/0} {children} { FIRST }

    method {on or off/0} {children} { CONST on  }
    method {on or off/1} {children} { CONST off }

    # # -- --- ----- -------- -------------
    ## Symbol processing

    method lhs/0           {children} { FIRST    } ; # OK

    method symbol/0        {children} { FIRST    } ; # OK
    method {symbol name/0} {children} { SYMBOL 0 0 } ; # OK bare
    method {symbol name/1} {children} { SYMBOL 0 1 } ; # OK bracketed

    # users: quantified rule, discard rule, separator spec, rhs primary/0
    method {single symbol/0} {children} { LEAF [FIRST]  } ; # OK <symbol>
    method {single symbol/1} {children} { LEAF [CCLASS] } ; # OK <character class>

    # # -- --- ----- -------- -------------
    ## Action forms

    method action/0 {children} { ADVL action [FIRST] }

    method {action name/0} {children} {
	# perl name (id ('::' id)+)
	list cmd [LITERAL]
    }
    method {action name/1} {children} {
	# reserved name ::....
	list special [string range [LITERAL] 2 end]
    }
    method {action name/2} {children} {
	# array descriptor [xxx, ...]
	list array [split [string range [LITERAL] 1 end-1] ,]
    }

    # # -- --- ----- -------- -------------
    ## Blessings

    method blessing/0 {children} { ADVL bless [FIRST] }

    method {blessing name/0} {children} {
	# standard name - identifier
	list standard [LITERAL]
    }
    method {blessing name/1} {children} {
	# reserved name ::...
	list special [string range [LITERAL] 2 end]
    }

    # # -- --- ----- -------- -------------
    ## Rule naming

    method naming/0 {children} { ADVL name [FIRST] }

    method {alternative name/0} {children} {
	# standard name - identifier
	LITERAL
    }
    method {alternative name/1} {children} {
	# single quoted name
	string range [LITERAL] 1 end-1
    }

    # # ## ### ##### ######## #############
    ## AST helpers

    method LEAF {symbol} {
	# Generate a sem value suitable for a BNF rule rhs, being a
	# pair consisting of mask and symbol vectors. Here each vector
	# contains a sngle element.
	return [list 0 [list $symbol]]
    }

    # Reduce an rhs sem value to the symbol vector alone
    method UNMASK {rhs} { lindex $rhs 1 }

    # Merge multiple rhs sem values into a single value
    method MERGE {args} {
	foreach b [lassign $args a] { set a [MERGE2 $a $b] }
	return $a
    }

    # Merge 2 rhs sem values into a single value
    method MERGE2 {a b} {
	lassign $a amask asymbols
	lassign $b bmask bsymbols
	lappend amask    {*}$bmask
	lappend asymbols {*}$bsymbols
	return [list $amask $asymbols]
    }

    # Replace the mask in an rhs sem value with a mask hiding all the symbols
    method HIDE {sv} {
	# sv :: list (mask, symbols) :: |mask| == |symbols|
	# Replace mask with hide-mask for all elements.
	lassign $sv mask symbols
	set mask [lrepeat [llength $mask] 1]
	return [list $mask $symbols]
    }

    method CCLASS {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	lassign [lindex $children 0] start length literal

	SymCo assert usage
	# Expect RHS

	set layer [SymCo layer?]

	lassign [my NORMCLASS $literal] spec nocase litsymbol
	usage      add $start $length  $literal $litsymbol
	definition add $start $length  $literal $litsymbol

	dict set mycc $litsymbol $literal
	# Remember actual literal for use in (discard rule/1)

	# The literal is (always) a terminal in the L0 grammar.
	Symbol context1 <literal> $litsymbol
	Container l0 charclass    $litsymbol $spec $nocase

	if {$layer eq "l0"} {
	    set result $litsymbol
	} else {
	    # We are in the G1 layer.
	    # The literal cannot be used directly.
	    # We need a lexeme around it, and an associated match rule.

	    set lexeme @LEX:$litsymbol
	    definition add $start $length $lexeme
	    Symbol context1 l0-definition $lexeme ; # Issue container ops
	    Symbol context1 :lexeme       $lexeme ; # Issue container ops
	    Container l0 priority-rule $lexeme $litsymbol 0

	    set result $lexeme
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $result}
	return $result
    }

    method NORMCLASS {literal} {
	# literal = [...](:ic|:i)* where
	# where ... = list (char|range|collation-element)
	#    or ... = [:classname:]
	#       range = X-Y
	#       collation-element = [.X.]

	lassign [my NOCASE $literal] literal nocase

	# Handle escapes (Tcl syntax), afterward we have a simple
	# sequence of characters and ranges.
	set literal [UNESC $literal]

	# Process class elements.
	set spec {}
	while {[string length $literal]} {
	    #puts NCC|$literal|

	    # negated posix char class
	    if {[regexp -- "^\\\[:^(\[alnum\]+):\\\](.*)$" $literal -> name remainder]} {
		lappend spec [list CC- $name]
		set literal $remainder
		continue
	    }
	    # posix char class
	    if {[regexp -- "^\\\[:(\[alnum\]+):\\\](.*)$" $literal -> name remainder]} {
		lappend spec [list CC $name]
		set literal $remainder
		continue
	    }

	    if {[regexp -- {^(.)-(.)(.*)$} $literal -> start end remainder]} {
		# Expand the range into the individual characters
		# (We cannot assume that folding preverses continuity, or order)
		set start [CCODE $start]
		set end   [CCODE $end]
		for {set codepoint $start} {$codepoint <= $end} {incr codepoint} {
		    lappend spec [CWRAP $codepoint $nocase]
		}
		set literal $remainder
		continue
	    }

	    if {[regexp -- {^(.)(.*)$} $literal -> char remainder]} {
		# Remember characters as codepoints, possibly up/downcased
		lappend spec [CHAR $char $nocase]
		set literal $remainder
		continue
	    }

	    my E "" ... ;# internal error semantic/syntax mismatch
	    break
	}

	# Canonical sort order, removal of obvious duplicates, and
	# compression to ranges where possible.

	set spec [RANGES [lsort -unique $spec]]

	# Generate a symbol from the normalized spec.  This symbol
	# represents the char class itself.  There may come more
	# symbols derived from it which represent things built from
	# the literal. For example a lexeme.

	set symbol [my SYM @LCC:<> $nocase $spec]

	return [list $spec $nocase $symbol]
    }

    method CSTRING {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	lassign [lindex $children 0] start length literal

	SymCo assert usage
	# Expect RHS

	set layer [SymCo layer?]

	lassign [my NORMSTR $literal] spec nocase litsymbol
	usage      add $start $length  $literal $litsymbol
	definition add $start $length  $literal $litsymbol

	# The literal is (always) a terminal in the L0 grammar.
	Container l0 string $litsymbol $spec $nocase
	Symbol context1 <literal> $litsymbol

	if {$layer eq "l0"} {
	    set result $litsymbol
	} else {
	    # We are in the G1 layer.
	    # The literal cannot be used directly.
	    # We need a lexeme around it, and a match rule.

	    set lexeme @LEX:$litsymbol
	    definition add $start $length $lexeme
	    Symbol context1 l0-definition $lexeme ; # Issue container ops
	    Symbol context1 :lexeme       $lexeme ; # Issue container ops
	    Container l0 priority-rule $lexeme $litsymbol 0

	  set result $lexeme
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $result}
	return $result
    }

    method NORMSTR {literal} {
	lassign [my NOCASE $literal] literal nocase

	# Handle escapes (Tcl syntax), afterward we have a simple
	# sequence of characters.
	set literal [UNESC $literal]

	# Process the string elements.
	set spec {}
	foreach char [split $literal {}] {
	    # Remember characters as code points, possibly downcased for nocase.
	    lappend spec [CHAR $char $nocase]
	}

	# Generate a symbol from the normalized spec.  This symbol
	# represents the char class itself.  There may come more
	# symbols derived from it which represent things built from
	# the literal. For example a lexeme.

	set symbol [my SYM @LIT:<> $nocase $spec]

	return [list $spec $nocase $symbol]

    }

    method RANGES {spec} {
	set result {}
	set buf {}
	foreach el $spec {
	    lassign $el type value
	    switch -exact -- $type {
		CC - CC- { lappend result $el }
		CH {
		    if {![llength $buf]} {
			lappend buf $value
			continue
		    }
		    if {([lindex $buf end] + 1) == $value} {
			lappend buf $value
			continue
		    }
		    # gap, flush buffer
		    if {[llength $buf] > 1} {
			set s [lindex $buf 0]
			set e [lindex $buf end]
			lappend result [list RN [list $s $e]]
		    } else {
			lappend result [list CH [lindex $buf 0]]
		    }
		    # restart accumulation
		    set buf [list $value]
		}
	    }
	}
	if {[llength $buf]} {
	    if {[llength $buf] > 1} {
		set s [lindex $buf 0]
		set e [lindex $buf end]
		lappend result [list RN [list $s $e]]
	    } else {
		lappend result [list CH [lindex $buf 0]]
	    }
	}
	return $result
    }

    method CHAR {char nocase} {
	return [CWRAP [CCODE $char] $nocase]
    }

    method CWRAP {codepoint nocase} {
	if {$nocase} {
	    set codepoint [marpa unicode data fold/c $codepoint]
	}
	return [list CH $codepoint]
    }

    method UNESC {x} {
	return [subst -nocommands -novariables $x]
    }

    method CCODE {char} {
	# Input is unescaped tcl character.
	# Determine the decimal codepoint.
	scan $char %c char
	return $char
    }

    method NOCASE {literal} {
	# Strip and normalize modifiers
	set nocase 0
	while {1} {
	    if {[string match *:i $literal]} {
		set literal [string range $literal 0 end-2]
		set nocase 1
		continue
	    }
	    if {[string match *:ic $literal]} {
		set literal [string range $literal 0 end-3]
		set nocase 1
		continue
	    }
	    break
	}

	# Strip bracketing
	set literal [string range $literal 1 end-1]

	return [list $literal $nocase]
    }

    method SYM {base nocase spec} {
	set symbol [string range $base 0 end-1]
	foreach el $spec {
	    lassign $el type value
	    switch -exact -- $type {
		CC  { append symbol \[:${value}:\]  }
		CC- { append symbol \[:^${value}:\] }
		CH  { append symbol [char quote tcl [format %c $value]] }
		RN  {
		    lassign $value s e
		    append symbol \
			[char quote tcl [format %c $s]] - \
			[char quote tcl [format %c $e]]
		}
	    }
	}
	append symbol [string index $base end]
	if {$nocase} { append symbol :i }
	return $symbol
    }

    # # ## ### ##### ######## #############
    ## Processing helpers

    method EVAL {} {
	# Process the node's children, but do not generate a sem val
	# of our own. The side-effects are important, not the result.
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	foreach child $children {
	    my {*}$child
	}
	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] /ok}
	return
    }

    method EVALR {from to} {
	# As EVAL above, except only a range of children is handled this way.
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	foreach child [lrange $children $from $to] {
	    my {*}$child
	}
	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] /ok}
	return
    }

    method EVALS {script} {
	# As EVAL above, with an additional script run between the children.
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	foreach child $children {
	    my {*}$child
	    uplevel 1 $script
	}
	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] /ok}
	return
    }

    method DESEQ {{initial yes}} {
	# Strip the separator elements from a list of semantic values.
	# initial == yes (default): result contains the even elements (0, 2, ...)
	# initial == no: result contains the odd elements (1, 3, ...)
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	upvar 1 children children
	set tmp {}
	set add $initial
	foreach child $children {
	    #debug.marpa/slif/semantics {[debug caller] | [AT]: $c}
	    if {$add} { lappend tmp $child }
	    set add [expr {!$add}]
	}
	set children $tmp
	debug.marpa/slif/semantics {[debug caller] | [AT] /done}
	return
    }

    method FIRST {} {
	# nearly-<==> SINGLE 0 (SINGLE ignores missing/empty child)
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	#debug.marpa/slif/semantics {[debug caller] | [AT]: ([join $children )\n(])}

	set first [lindex $children 0]
	#debug.marpa/slif/semantics {[debug caller] | [AT]: $first}

	set value [my {*}$first]

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> ($value)}
	return $value
    }

    method SINGLE {index} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	#debug.marpa/slif/semantics {[debug caller] | [AT]: ([join $children )\n(])}

	set child [lindex $children $index]
	#debug.marpa/slif/semantics {[debug caller] | [AT]: $child}

	if {$child ne {}} {
	    set value [my {*}$child]
	} else {
	    set value {}
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> ($value)}
	return $value
    }

    method VALUES {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children

	set value {}
	foreach child $children {
	    #debug.marpa/slif/semantics {[debug caller] | [AT]: $child}
	    lappend value [my {*}$child]
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> ($value)}
	return $value
    }

    method FLATTEN {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children

	set value {}
	foreach child $children {
	    #debug.marpa/slif/semantics {[debug caller] | [AT]: $child}
	    lappend value {*}[my {*}$child]
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> ($value)}
	return $value
    }

    method LITERAL {{index 0}} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	upvar 1 children children

	debug.marpa/slif/semantics {[debug caller] | [AT]: ([lindex $children $index])}
	# child structure = (start-offset length literal)

	set literal [lindex $children $index 2]

	debug.marpa/slif/semantics {[debug caller] | [AT] ==> "$literal"}
	return $literal
    }

    method LITLOC {{index 0}} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	upvar 1 children children

	debug.marpa/slif/semantics {[debug caller] | [AT]: ([lindex $children $index])}
	# child structure = (start-offset length literal)

	set location [lrange [lindex $children $index] 0 1]

	debug.marpa/slif/semantics {[debug caller] | [AT] ==> @($location)}
	return $location
    }

    method SYMBOL {index bracketed} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	upvar 1 children children

	# Context:
	set layer [SymCo layer?] ;# g1/l0
	set type  [SymCo type?]  ;# definition/usage

	lassign [lindex $children $index] start length literal
	# child structure = (start-offset length literal)
	debug.marpa/slif/semantics {[debug caller] | [AT]: $layer $type @${start}(${length})="$literal"}

	if {$bracketed} {
	    # Normalize the string - Remove brackets, leading/trailing
	    # whitespace, convert all inner whitespace to single
	    # spaces.
	    set literal [my NORM $literal]
	}

	$type add $start $length   $literal

	debug.marpa/slif/semantics {[debug caller] | [AT] ==> $literal}
	return $literal
    }

    method NORM {literal} {
	regsub -all {\s+} [string trim [string range $literal 1 end-1]] { } literal
	return $literal
    }

    method CONST {args} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($args)}
	return $args
    }

    method ADVL {key value} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	# location is done automatically by
	#set value [list $key [list [uplevel 1 LITLOC] $value]]
	set value [list $key $value]
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($value)}
	return $value
    }

    method ADVS {key symbol} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	# location is done automatically by
	#set value [list $key [list [$symbol last-use] $symbol]]
	#TODO last-use -- Container (layer) last-use $symbol
	set value [list $key $symbol]
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($value)}
	return $value
    }

    method ADVQ {avar} {
	# Custom check for related attributes 'separator' and 'proper'

	upvar 1 $avar adverbs

	if {[dict exists $adverbs separator]} {
	    # Ensure the existence of a default for adverb 'proper'
	    # when a 'separator' was specified. XXX: Error instead ?

	    # Normalize (defaults, aggregation)
	    # => pair (symbol proper)

	    if {![dict exists $adverbs proper]} {
		set proper 0
	    } else {
		set proper [dict get $adverbs proper]
		dict unset adverbs proper
	    }

	    dict lappend adverbs separator $proper
	    return
	}

	# Remove 'proper' if 'separator' is not specified. XXX: Warning ?
	if {[dict exists $adverbs proper]} {
	    dict unset adverbs proper
	}
	return
    }

    method ADVE {avar} {
	# Custom check for related attributes 'event' and 'pause'.
	# Note that after checking both are merged into a single
	# 'event' adverb with a structured value capturing all the
	# info.
	upvar 1 $avar adverbs

	if {[dict exists $adverbs event]} {
	    # When an event is specified, we also need 'pause'.
	    # Not having it is a fatal error

	    if {![dict exists $adverbs pause]} {
		my E "Required adverb 'pause' is missing." ADVERB PAUSE
	    }

	    # Normalize the value for event (flatten, defaults, specials)
	    # => 3-tuple (name state when)
	    lassign [dict get $adverbs event] tn state
	    lassign $tn type name

	    if {$type eq "special"} {
		if {$name eq "symbol"} {
		    my E "Reserved event name ::$name illegal for :lexeme" \
			ADVERB EVENT NAME SPECIAL ILLEGAL
		} else {
		    my E "Unknown reserved name ::$name for :lexeme" \
			ADVERB EVENT NAME SPECIAL UNKNOWN $name
		}
	    }
	    # assert (type eq "standard")

	    set when [dict get $adverbs pause]
	    if {$state eq {}} { set state on }
	    dict set adverbs event [list $name $state $when]
	    dict unset adverbs pause
	    return
	} elseif {[dict exists $adverbs pause]} {
	    # We have 'pause', but not 'event'. This is ok, it "just"
	    # causes the engine to use an _unnamed_ event. Note
	    # however that such are strongly disrecommended.
	    #
	    # TODO: Register a warning.

	    set when [dict get $adverbs pause]
	    dict set adverbs event [list {} on $when]
	    dict unset adverbs pause
	}
	return
    }

    method ADVE1 {adverbs symbol} {
	# Custom check of attribute 'event'. Resolves specials.
	# 'pause' not required. Implied as 'discard'.

	if {![dict exists $adverbs event]} { return $adverbs }

	# Normalize the value for event (flatten, defaults, specials)
	# => 3-tuple (name state when)
	lassign [dict get $adverbs event] tn state
	lassign $tn type name

	if {$type eq "special"} {
	    if {$name ne "symbol"} {
		my E "Unknown reserved name ::$name" \
		    ADVERB EVENT NAME SPECIAL UNKNOWN $name
	    } else {
		# Resolve ::symbol
		set name $symbol
	    }
	}
	# assert (type eq "standard")
	if {$state eq {}} { set state on }
	dict set adverbs event [list $name $state discard]

	return $adverbs
    }

    # # ## ### ##### ######## #############
    ##

    method LOCFMT {locations} {
	if {![llength $locations]} {
	    return ""
	}
	set result {}
	foreach loc $locations {
	    lassign $loc location span
	    lappend result @${location}..[expr {$location + $span - 1}]
	}
	return "- [join $result "\n- "]"
    }
    export LOCFMT ;# Used in s_sem_start, s_sem_symbols

    # # ## ### ##### ######## #############
    ## Helper - XXX - Remove when class is complete

    method unknown {m args} {
	debug.marpa/slif/semantics {[AT] IGNORING ($m)}
	error "Unknown rule: $m"
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
