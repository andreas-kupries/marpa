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
package require oo::util      ;# mymethod

debug define marpa/slif/semantics
#debug prefix marpa/slif/semantics {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::semantics {
    marpa::E marpa/slif/semantics SLIF SEMANTICS

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

	# Track G1 action/bless defaults
	marpa::slif::semantics::Defaults create G1 \
	    $container {
		action {array values}
		bless  {special undef}
	    }

	# Track LATM flag handling for lexemes
	marpa::slif::semantics::Fixup create LATM \
	    $container [mymethod FixLATM]

	# Track event handling for discards
	marpa::slif::semantics::Fixup create DDE \
	    $container [mymethod FixDiscard]

	# Track knowledge of which L0 symbols are lexemes or not.
	marpa::slif::semantics::Flag create Lexeme \
	    $container "Lexeme" LEXEME

	# Track knowledge of which G1 symbols are terminals or not.
	set terminal [marpa::slif::semantics::Flag create Terminal \
			  $container "Terminal" TERMINAL]

	# Track knowledge of defined L0 symbols, lexeme or not (i.e. defs)
	marpa::slif::semantics::Flag create L0Def \
	    $container "L0 symbol" L0SYMBOL

	# Track knowledge of defined G1 symbols, terminals or not
	marpa::slif::semantics::Flag create G1Def \
	    $container "G1 symbol" G1SYMBOL

	# Track lexeme default singleton
	marpa::slif::semantics::Singleton create LD \
	    "Illegal second use of 'lexeme default'" LEXEME-DEFAULT

	# Track discard default singleton
	marpa::slif::semantics::Singleton create DD \
	    "Illegal second use of 'discard default'" LEXEME-DEFAULT

	# Semantic state, start symbol.
	marpa::slif::semantics::Start create \
	    Start $container $terminal

	# Semantic state, symbol context
	marpa::slif::semantics::SymContext create \
	    SymCo

	# The lexeme and terminal data is complementary.
	# G1 terminals are L0 lexemes and vice versa.
	# At the end both sets have to agree.

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
	link {CCLASS  CCLASS}  ;# Character class to translate
	link {CSTRING CSTRING} ;# Character string to translate
	link {E       ERR}
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

	# Check that we have a start symbol. This also checks that the
	# start symbol is known as non-Terminal symbol, i.e. had a G1
	# rule with it as the LHS.
	Start complete

	# Known flags are for non-lexemes (RHS => unset!, LHS - maybe)
	# And some lexemes (via :lexeme statements).
	# The left-over maybes must be lexemes.
	# As they had no :lexeme these are without latm configuration,
	# fix that now.
	Lexeme complete 1 sym {
	    Container comment LATM fixup $sym
	    LATM fixup $sym
	}

	# Known flags are for non-terminals (LHS => unset!, RHS - maybe)
	# The left-over maybes must be terminals
	Terminal complete 1 _ {
	    # TODO: Finalize terminals in G1.
	    # Defer actual operation until after checks.
	    # Only collect the symbols to process.
	}

	# Show the final Lexeme/Terminal flagging.
	if 0 {
	    Lexeme foreach sym {
		Container comment Lk[Lexeme known? $sym],s[Lexeme set? $sym],u[Lexeme unset? $sym]:$sym
	    }
	    Terminal foreach sym {
		Container comment Tk[Terminal known? $sym],s[Terminal set? $sym],u[Terminal unset? $sym]:$sym
	    }
	}

	# Validate that terminal and lexeme are the same set.
	# Report any differences.

	# Definition: Lexeme and non-Terminal
	Lexeme foreach sym {
	    if {[Lexeme set? $sym] && [Terminal unset? $sym]} {
		my E "Lexeme '$sym' also defined as G1 non-terminal" \
		    MISMATCH L0/G1 BOTH $sym
		# # ##
		## A ~   'a' -- A lexeme definition
		## A ::= 'x' -- A non-terminal definition
		# # ##
	    }
	}

	# Use: Terminal and non-Lexeme
	Terminal foreach sym {
	    if {[Terminal set? $sym] && [Lexeme unset? $sym]} {
		my E "Terminal '$sym' also used as L0 non-lexeme" \
		    MISMATCH G1/L0 BOTH $sym
		# # ##
		## A ::= B -- B terminal use
		## C ~   B -- B non-lexeme use
		# # ##
	    }
	}

	# Lexeme not used in G1
	Lexeme foreach sym {
	    if {[Lexeme set? $sym] && ![Terminal set? $sym]} {
		# Lexeme and not used in G1
		my E "Lexeme '$sym' not used as terminal" \
		    MISMATCH L0/G1 LEXEME $sym
		# # ##
		## A ~   'a' -- A lexeme definition
		##           -- A not used in a ::= RHS
		# # ##
	    }
	}

	# Terminal not defined in L0
	Terminal foreach sym {
	    if {[Terminal set? $sym] && ![Lexeme set? $sym]} {
		my E "Terminal '$sym' not defined as lexeme" \
		    MISMATCH G1/L0 TERMINAL $sym
		# # ##
		## A ::= B -- Terminal B usage
		##         -- Terminal B is not a ~ LHS
		# # ##
	    }
	}

	# 
	L0Def foreach sym {
	    if {[L0Def set? $sym]} continue
	    my E "L0 symbol '$sym' used, not defined" \
		L0 MISSING $sym
	}

	G1Def foreach sym {
	    if {[G1Def set? $sym] || [Terminal set? $sym]} continue
	    my E "G1 symbol '$sym' used, not defined" \
		G1 MISSING $sym
	}

	# TODO: @end assert (All L0 symbols have a def location (rule, atomic))
	# TODO: @end assert (All G1 symbols, but start have a use location)
	# TODO: @end assert (L0 without use == G1 without a def == lexeme == terminal)

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
	#    0             1     2            3
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

	SymCo g1
	SymCo definition ; set lhs [FIRST]
	SymCo usage      ; set rhs [lindex [UNMASK [SINGLE 1]] 0]

	set positive [SINGLE 2]
	set adverbs  [G1 defaults [SINGLE 3]] ;# still /usage
	ADVQ adverbs

	# lhs - definitely not a terminal - unset!
	# rhs - possibly terminals, not known, don't do anything
	Terminal unset! $lhs ; G1Def set! $lhs
	Terminal def    $rhs ; G1Def def  {*}$rhs

	if {[dict exists $adverbs separator]} {
	    # The separator symbol is a possible terminal too.
	    set sep [lindex [dict get $adverbs separator] 0]
	    Terminal def $sep
	    G1Def def    $sep
	}

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

	SymCo l0
	SymCo definition ; set lhs [FIRST]
	SymCo usage      ; set rhs [lindex [UNMASK [SINGLE 1]] 0]

	set positive [SINGLE 2]
	set adverbs  [SINGLE 3] ;# still /usage
	ADVQ adverbs

	# lhs - maybe toplevel - cannot set!
	# rhs - definitely not toplevel - unset!
	Lexeme def    $lhs ; L0Def set! $lhs
	Lexeme unset! $rhs ; L0Def def  $rhs

	if {[dict exists $adverbs separator]} {
	    # The separator symbol is definitely not a lexeme
	    set sep [lindex [dict get $adverbs separator] 0]
	    Lexeme unset! $sep
	    L0Def def     $sep
	}

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

	SymCo g1
	SymCo definition

	set lhs     [FIRST]
	set adverbs [G1 defaults [SINGLE 1]]

	# lhs - definitely not a terminal - unset!
	# rhs - possibly terminals, not known, don't do anything
	Terminal unset! $lhs
	G1Def    set!   $lhs
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

	SymCo l0
	SymCo definition

	set lhs     [FIRST]
	set adverbs [SINGLE 1]

	# lhs - maybe toplevel - cannot set!
	# rhssymbols - none available
	Lexeme def  $lhs
	L0Def  set! $lhs
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

	SymCo g1
	SymCo definition

	set lhs [FIRST]

	SymCo lhs $lhs
	SymCo usage
	SymCo precedence/reset

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

	SymCo l0
	SymCo definition
	SymCo lhs [FIRST]
	SymCo usage
	SymCo precedence/reset

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

	set prec    [SymCo precedence?]
	set lhs     [SymCo lhs?]
	set rhs     [FIRST]
	set adverbs [G1 defaults [SINGLE 1]]

	lassign $rhs rhsmask rhssymbols
	dict set adverbs mask $rhsmask

	# lhs - definitely not a terminal - unset!
	# rhs - possibly terminals, not known, don't do anything
	Terminal unset! $lhs           ; G1Def set! $lhs
	Terminal def    {*}$rhssymbols ; G1Def def  {*}$rhssymbols
	Container g1 priority-rule $lhs $rhssymbols $prec {*}$adverbs
	return
    }

    method {alternative match/0} {children} {
	# <rhs> <adverb list match alternative>
	# L0 implied

	set prec    [SymCo precedence?]
	set lhs     [SymCo lhs?]
	set rhs     [FIRST]
	set adverbs [SINGLE 1]

	lassign $rhs __ rhssymbols
	# Ignore masking, irrelevant at L0 level.

	# lhs - maybe toplevel - cannot set!
	# rhssymbols - definitely not toplevel - unset!
	Lexeme def    $lhs           ; L0Def set! $lhs
	Lexeme unset! {*}$rhssymbols ; L0Def def  {*}$rhssymbols
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
	Container comment LATM global! [dict get $adverbs latm]
	LATM global! [dict get $adverbs latm]
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

	SymCo l0
	SymCo use

	set symbol  [FIRST]
	set adverbs [SINGLE 1]
	#Container comment :lexeme adverbs = $adverbs ;#debug

	Lexeme set! $symbol
	ADVE adverbs

	if {[dict size $adverbs]} {
	    Container l0 configure $symbol {*}$adverbs
	}

	if {![dict exists $adverbs latm]} {
	    Container comment LATM fixup $symbol
	    LATM fixup $symbol
	}
	return
    }

    method FixLATM {symbol latm immediate} {
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
	Container comment DDE global! [dict get $adverbs event]
	DDE global! $adverbs
	return
    }

    method {discard rule/0} {children} {
	# <single symbol> <adverb list discard>
	# 0        1
	# Adverbs
	# - event

	SymCo l0
	SymCo use

	set symbol  [lindex [UNMASK [FIRST]] 0]
	set adverbs [SINGLE 1]
	#Container comment :discard adverbs = $adverbs ;#debug

	# Discards are not lexemes. But must be defined
	Lexeme unset!        $symbol
	L0Def def            $symbol
	Container l0 discard $symbol

	if {![dict exists $adverbs event]} {
	    Container comment DDE fixup $symbol
	    DDE fixup $symbol
	} else {
	    Container l0 configure $symbol {*}[ADVE1 $adverbs $symbol]
	}
	return
    }

    method FixDiscard {symbol adverbs immediate} {
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
	set adverbs [FIRST]
	Container comment g1 defaults = $adverbs
	G1 defaults: $adverbs
	return
    }

    # # -- --- ----- -------- -------------
    ## G1 parse event declarations

    method {completion event declaration/0} {children} {
	# <event initialization> <symbol name>
	SymCo g1 ; SymCo usage

	set spec [FIRST]
	set sym  [SINGLE 1]

	G1Def def $sym ;# Must be defined, check at end.

	# Run through common event post-processing. This needs boxing
	# it up as adverb, and unboxing the result
	# TODO - Rewrite to work on unboxed value instead of adverb.
	set spec [dict get [ADVE1 [dict create event $spec] $sym] event]

	# Fix event type, and record
	lset spec 2 completed
	Container g1 event $sym $spec
	return
    }

    method {nulled event declaration/0} {children} {
	# <event initialization> <symbol name>
	SymCo g1 ; SymCo usage

	set spec [FIRST]
	set sym  [SINGLE 1]

	G1Def def $sym ;# Must be defined, check at end.

	# Run through common event post-processing. This needs boxing
	# it up as adverb, and unboxing the result
	# TODO - Rewrite to work on unboxed value instead of adverb.
	set spec [dict get [ADVE1 [dict create event $spec] $sym] event]

	# Fix event type, and record
	lset spec 2 nulled
	Container g1 event $sym $spec
	return
    }

    method {prediction event declaration/0} {children} {
	# <event initialization> <symbol name>
	SymCo g1 ; SymCo usage

	set spec [FIRST]
	set sym  [SINGLE 1]

	G1Def def $sym ;# Must be defined, check at end.

	# Run through common event post-processing. This needs boxing
	# it up as adverb, and unboxing the result
	# TODO - Rewrite to work on unboxed value instead of adverb.
	set spec [dict get [ADVE1 [dict create event $spec] $sym] event]

	# Fix event type, and record
	lset spec 2 predicted
	Container g1 event $sym $spec
	return
    }

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
	Container $layer charclass $literal
	Container $layer usage     $literal $start $length

	L0Def set! $literal ;# self-defined L0 symbol
	# Yes, we set for L0 and G1

	if {$layer eq "g1"} {
	    # Mark the literal as a terminal (for G1), and a lexeme (for L0).
	    # Further include it into LATM tracking
	    Terminal set!  $literal ; G1Def set! $literal
	    Lexeme   set!  $literal
	    LATM     fixup $literal
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $literal}
	return $literal
    }

    method CSTRING {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	lassign [lindex $children 0] start length literal

	SymCo assert usage
	# Expect RHS

	set layer [SymCo layer?]
	Container $layer string $literal
	Container $layer usage  $literal $start $length

	L0Def set! $literal ;# self-defined L0 symbol
	# Yes, we set for L0 and G1

	if {$layer eq "g1"} {
	    # Mark the literal as a terminal (for G1), and a lexeme (for L0).
	    # Further include it into LATM tracking
	    Terminal set!  $literal ; G1Def set! $literal
	    Lexeme   set!  $literal
	    LATM     fixup $literal
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $literal}
	return $literal
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

	Container $layer $type $literal $start $length

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
		my E "Required 'pause' is missing." ADVERB PAUSE
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
		    my E "Unknown reserved name ::$name" \
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
    ## Semantic state

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
## Semantic state - Generic management of defaults

oo::class create marpa::slif::semantics::Defaults {
    marpa::E marpa/slif/semantics SLIF SEMANTICS DEFAULTS

    variable mybase     ;# dictionary of the last defaults
    variable mydefaults ;# dictionary of current defaults

    constructor {container base} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mybase     $base
	set mydefaults $base
	return
    }

    method defaults: {defaults} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Set new defaults. Missing parts are filled from the base.
	set mydefaults [dict merge $mybase $defaults]
	return
    }

    method defaults {dict} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Fill missing pieces in the incoming dict with the current defaults.
	return [dict merge $mydefaults $dict]
    }
}

# # ## ### ##### ######## #############
## Semantic state - Generic management of fixups

oo::class create marpa::slif::semantics::Fixup {
    marpa::E marpa/slif/semantics SLIF SEMANTICS DE

    variable mycmd     ;# command invoked to perform actual fixup.
    variable myglobal  ;# global setting, if any.
    variable mypending ;# symbols waiting for fixup by global setting

    constructor {container cmd} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mycmd     $cmd
	set myglobal  {}
	set mypending {}
	return
    }

    method global! {x} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Set global state, handle all pending fixup
	# Note! Caller makes sure to call this only once.
	set myglobal $x
	foreach symbol $mypending { my fixup $symbol 0 }
	set mypending {}
	return
    }

    method fixup {sym {immediate 1}} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Run fixup immediate if we have state, else defer
	if {$myglobal ne {}} {
	    {*}$mycmd $sym $myglobal $immediate
	    return
	}
	lappend mypending $sym
	return
    }
}

# # ## ### ##### ######## #############
## Semantic state - Symbol context
## - Layer: g1/l0
## - Type:  def/use

oo::class create marpa::slif::semantics::SymContext {
    variable mytype       ;# definition/usage
    variable mylayer      ;# L0/G1
    variable mylhs        ;# Symbol for upcoming alternatives
    variable myprecedence ;# Precedence level for alternatives

    marpa::E marpa/slif/semantics SLIF SEMANTICS SYMBOLCONTEXT

    constructor {} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype       {}
	set mylayer      {}
	set mylhs        {}
	set myprecedence {}
	return
    }

    # # -- --- ----- -------- -------------

    method precedence/reset {} {
	debug.marpa/slif/semantics {[debug caller] | }
	set myprecedence 0
	return
    }

    method precedence/loosen {} {
	debug.marpa/slif/semantics {[debug caller] | }
	incr myprecedence -1
	return
    }

    # # -- --- ----- -------- -------------

    method lhs {symbol} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylhs $symbol
	return
    }

    # # -- --- ----- -------- -------------

    method g1 {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylayer g1
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    method l0 {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mylayer l0
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    # # -- --- ----- -------- -------------

    forward def my definition
    method definition {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype definition
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    forward use my usage
    method usage {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype usage
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    # # -- --- ----- -------- -------------

    method assert {args} {
	foreach property $args {
	    if {[my ${property}?]} continue
	    my E "Unexpected non-$property context" $property
	}
    }

    # # -- --- ----- -------- -------------

    method layer? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mylayer}
	return $mylayer
    }

    method type? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mytype}
	return $mytype
    }

    method lhs? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $mylhs}
	return $mylhs
    }

    method precedence? {} {
	debug.marpa/slif/semantics {[debug caller] | ==> $myprecedence}
	return $myprecedence
    }

    # # -- --- ----- -------- -------------

    method definition? {} {
	set ok [expr {$mytype eq "definition"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    method usage? {} {
	set ok [expr {$mytype eq "usage"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }
}

# # ## ### ##### ######## #############
## Semantic state - Singletons

oo::class create marpa::slif::semantics::Singleton {
    marpa::EP marpa/slif/semantics \
	{Grammar error.} \
	SLIF SEMANTICS SINGLETON

    variable mymsg  ;# error message
    variable mycode ;# error code
    variable myok   ;# flag tracking calls

    constructor {msg args} {
	debug.marpa/slif/semantics {}
	set mymsg  $msg
	set mycode $args
	set myok   1
	return
    }

    method pass {} {
	debug.marpa/slif/semantics {}
	if {!$myok} {
	    my E $mymsg {*}$mycode
	}
	set myok 0
	return
    }
}

# # ## ### ##### ######## #############
## Semantic state - Flag management
## Flags are per symbol or similar.
## A flag can be set, or unset, but not both.
## A flags state may be unknown however.
## This means
## - Setting a flag already known as unset fails
## - Unsetting a flag already known as set fails
## - Both set? and unset? may return false
## - If either set? or unset? returns true the
##   other predicate will return false.
##
## The semantics use instances of this class to track toplevel, use,
## and other state for grammar symbols.
##

oo::class create marpa::slif::semantics::Flag {
    marpa::EP marpa/slif/semantics \
	{Grammar error.} \
	SLIF SEMANTICS FLAG

    variable mymsg  ;# error message prefix
    variable mycode ;# error code prefix
    variable myflag ;# flag dictionary (known information)
    variable mysym  ;# symbol dictionary (superset of myflag, (*))
    #               ;# (*) I.e. includes the maybes

    constructor {container msg args} {
	marpa::import $container Container

	debug.marpa/slif/semantics {}
	if {$msg ne {}} { append msg { } }
	set mymsg  $msg
	set mycode $args
	set myflag {}
	set mysym  {}
	return
    }

    method def {args} {
	debug.marpa/slif/semantics {}
	foreach key $args { dict set mysym $key . }
	return
    }

    method complete {x v script} {
	debug.marpa/slif/semantics {}
	upvar 1 $v sym

	#Container comment [self] complete _S_($mysym)__
	#Container comment [self] complete _F_($myflag)__

	# all maybes become 'x'
	dict for {sym _} $mysym {
	    if {[my known? $sym]} continue
	    dict set myflag $sym $x
	    # Run the script on the completed symbol
	    uplevel 1 $script
	}
	return
    }

    method foreach {vs script} {
	debug.marpa/slif/semantics {}
	upvar 1 $vs sym

	#Container comment [self] complete _S_($mysym)__
	#Container comment [self] complete _F_($myflag)__

	dict for {sym _} $mysym {
	    uplevel 1 $script
	}
	return
    }

    method set! {args} {
	debug.marpa/slif/semantics {}
	foreach key $args {
	    if {![my unset? $key]} continue
	    my E "Not a ${mymsg}already, cannot be made one" \
		{*}$mycode ALREADY UNSET
	}
	foreach key $args {
	    dict set mysym  $key .
	    dict set myflag $key 1
	}
	return
    }

    method unset! {args} {
	debug.marpa/slif/semantics {}
	foreach key $args {
	    if {![my set? $key]} continue
	    my E "Already a [string trimright ${mymsg}], cannot be undone" \
		{*}$mycode ALREADY SET
	}
	foreach key $args {
	    dict set mysym  $key .
	    dict set myflag $key 0
	}
	return
    }

    method known? {key} {
	debug.marpa/slif/semantics {}
	return [dict exists $myflag $key]
    }

    method set? {key} {
	debug.marpa/slif/semantics {}
	return [expr {[dict exists $myflag $key] && [dict get $myflag $key]}]
    }

    method unset? {key} {
	debug.marpa/slif/semantics {}
	return [expr {[dict exists $myflag $key] && ![dict get $myflag $key]}]
    }
}

# # ## ### ##### ######## #############
## Semantic state - Start symbol

oo::class create marpa::slif::semantics::Start {
    marpa::EP marpa/slif/semantics \
	{Grammar error. Start symbol} \
	SLIF SEMANTICS START

    # Start symbol handling
    # Method   State --> New State Action
    # ------   -----     --------- ------
    # with:    undef     done      set
    #          maybe     done      set
    #          done      -          FAIL
    # ------   -----     --------- ------
    # maybe:   undef     maybe     save
    #          maybe     -         ignore
    #          done      done      ignore
    # ------   -----     --------- ------
    # complete undef     -          FAIL (INTERNAL?)
    #          maybe     -         set
    #          done      -         ignore
    # ------   -----     --------- ------
    ##
    # Order by state
    # State Method --> New State Action
    # ----- ------     --------- ------
    # undef with:      done      set
    #       maybe:     maybe     saved
    #       complete   -          FAIL
    # ----- ------     --------- ------
    # maybe with:      done      set
    #       maybe:     -         ignore
    #       complete   -         set
    # ----- ------     --------- ------
    # done  with:      -          FAIL
    #       maybe:     done      ignore
    #       complete   -         ignore
    # ----- ------     --------- ------

    # "maybe:" is used by the LHS of rules. It will pass its value
    # only on the 1st call, and even then only if no explicit setting
    # was made via "with:". "with:" always passes its value.

    variable mystate
    variable mysym

    constructor {container terminal} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	marpa::import $terminal  Terminal
	set mystate undef
	set mysym   {}
	return
    }

    # # -- --- ----- -------- -------------

    method maybe: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		set mysym   $symbol
		set mystate maybe
	    }
	    maybe -
	    done {}
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method with: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef -
	    maybe {
		set mystate done
		set mysym   $symbol
		# We defer passing even and explicitly defined start
		# symbol to the completion phase. Because then we can
		# check if it has a definition or not (Terminal flags).
	    }
	    done {
		# TODO: Get location information from somewhere.
		my E "illegally declared for a second time" \
		    WITH TWICE
	    }
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method complete {} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		my E "not known" UNKNOWN
	    }
	    done -
	    maybe {
		# While the start symbol cannot be a terminal
		# << Why not? >>
		# there is
		# still the possibility that there is no rule defining
		# it either.
		# IOW instead of simply trying unset! we explictly check
		# that it is a non-terminal and bail if not.
		if {![Terminal unset? $mysym]} {
		    my E "has no G1 rule" UNDEFINED
		}
		Container start! $mysym
	    }
	    done {}
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }
}

# # ## ### ##### ######## #############
## Debugging helper class for the semantics.
## Only mixed into the class when needed.
## Provides supporting methods, and a filter adding debug narrative.

oo::class create marpa::slif::semantics::Debug {

    method AT {} {
	return [my DEDENT]<[lindex [info level -2] 1]>
    }

    method DEDENT {} {
	my variable __indent
	if {[info exist __indent]} {
	    return $__indent
	} else {
	    return {}
	}
    }

    method INDENT {} {
	my variable __indent
	upvar 1 __predent save
	if {[info exist __indent]} {
	    set save $__indent
	} else {
	    set save {}
	}
	append __indent {  }
	return
    }

    method UNDENT {} {
	my variable __indent
	upvar 1 __predent save
	set __indent $save
	return
    }
}

# # ## ### ##### ######## #############
return
