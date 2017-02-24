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
	    # XXX Multi-method link fails, links oly the first XXX
	    link {AT     AT}
	    link {DEDENT DEDENT}
	    link {INDENT INDENT}
	    link {UNDENT UNDENT}
	}]}
	marpa::import $container Container

	# Semantic state, start symbol.
	marpa::slif::semantics::Start create Start $container

	# Semantic state, symbol context
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
	link {ADVP    ADVP}    ;# Process the collected adverbs
	link {ADVQ    ADVQ}    ;# Quantified rule adverb special handling
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

    method enter {ast} {
	debug.marpa/slif/semantics {[debug caller 1] |}

	# Execute the AST, and in doing so fill the slif grammar
	# container. This needs the methods as immediately accessible
	# commands, with the AST type elements used as the methods
	# called.
	my {*}$ast

	# Done. Auto-destroy
	debug.marpa/slif/semantics {[debug caller 1] | /ok}
	my destroy
	return
    }

    method eof {} {
	puts /eof
	# Nothing to do.
    }

    method fail {} {
	puts /fail
	# Report incoming error.
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
    #method statement/9  {children} { EVAL } ; # FAIL NODOC <discard default statement>
    method statement/10 {children} { EVAL } ; # OK <lexeme rule>
    method statement/11 {children} { EVAL } ; # OK <completion event declaration>
    method statement/12 {children} { EVAL } ; # OK <nulled event declaration>
    method statement/13 {children} { EVAL } ; # OK <predicted event declaration>
    #method statement/14 {children} { EVAL } ; # FAIL NODOC <current lexer statement>
    method statement/15 {children} { EVAL } ; # OK <inaccessible statement>

    # Executing the statements in order updates the grammar ...
    # # -- --- ----- -------- -------------
    ## Start symbol declaration

    method {start rule/0} {children} { SymCo g1 use ; Start with: [FIRST] } ; # OK <symbol>
    method {start rule/1} {children} { SymCo g1 use ; Start with: [FIRST] } ; # OK <symbol>

    # TODO: @ end assert (Start ok?)

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
	SymCo def ; set lhs [FIRST]
	SymCo use ; set rhs [UNMASK [SINGLE 1]]

	Start maybe: $lhs

	set positive [SINGLE 2]
	set adverbs  [SINGLE 3]

	Container g1 add-quantified $lhs $rhs $positive

	ADVQ adverbs
	ADVP g1 last-rule $adverbs
	return
    }

    method {quantified rule/1} {children} {
	#    0             1     2            3
	# OK <lhs>         <rhs> <quantifier> <adverbs>
	#     |              \      */+          /
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

	SymCo l0
	SymCo def ; set lhs [FIRST]
	SymCo use ; set rhs [UNMASK [SINGLE 1]]

	set positive [SINGLE 2]
	set adverbs  [SINGLE 3]

	Container l0 add-quantified $lhs $rhs $positive

	ADVQ adverbs
	ADVP l0 last-rule $adverbs
	return
    }

    # # -- --- ----- -------- -------------
    ## Empty rules. Like prioritized rules below, except with a more
    ## limited set of adverbs.

    method {empty rule/0} {children} { # OK <lhs> <op declare> <adverb list>
	# <lhs> <adverb list bnf empty>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - action    -- <action>
	# - bless     -- <blessing>

	SymCo g1
	SymCo def

	set lhs     [FIRST]
	set adverbs [SINGLE 1]

	Start maybe: $lhs

	Container g1 add-bnf $lhs {} 0
	ADVP g1 last-rule $adverbs 
	return
    }

    method {empty rule/1} {children} { # OK <lhs> <op declare> <adverb list>
	# <lhs> <adverb list match empty>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - action    -- <action>
	# - bless     -- <blessing>

	SymCo l0
	SymCo def

	set lhs     [FIRST]
	set adverbs [SINGLE 1]

	Container l0 add-bnf $lhs {} 0
	ADVP l0 last-rule $adverbs
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
	SymCo def

	set lhs [FIRST]
        Start maybe: $lhs

	SymCo lhs $lhs
	SymCo use
	SymCo precedence/reset

	EVALR 1 end
    }

    method {priority rule/1} {children} {
	# 0     1
	# <lhs> <priorities match>
	#  \- symbol name       \- alternatives each with adverb information
	#
	# Push information (lhs, decl) down to the <alternative>, do
	# adverb and precedence processing there, not here.

	SymCo l0
	SymCo def
	SymCo lhs [FIRST]
	SymCo use
	SymCo precedence/reset

	EVALR 1 end
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
	set adverbs [SINGLE 1]

	lassign $rhs rhsmask rhssymbols
	Container g1 add-bnf $lhs $rhssymbols $prec
	Container g1 last-rule set-mask $rhsmask
	ADVP      g1 last-rule $adverbs
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
	Container l0 add-bnf $lhs $rhssymbols $prec
	ADVP      l0 last-rule $adverbs
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
    # # -- --- ----- -------- -------------
    # # -- --- ----- -------- -------------
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
    method {adverb item default/1} {children} { FIRST } ;# blessing
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
    method {adverb item lexeme default/1} {children} { FIRST } ;# blessing
    method {adverb item lexeme default/2} {children} { FIRST } ;# latm
    method {adverb item lexeme default/3} {children} { FIRST } ;# null

    method {adverb item bnf alternative/0} {children} { FIRST } ;# action
    method {adverb item bnf alternative/1} {children} { FIRST } ;# blessing
    method {adverb item bnf alternative/2} {children} { FIRST } ;# left
    method {adverb item bnf alternative/3} {children} { FIRST } ;# right
    method {adverb item bnf alternative/4} {children} { FIRST } ;# group
    method {adverb item bnf alternative/5} {children} { FIRST } ;# naming
    method {adverb item bnf alternative/6} {children} { FIRST } ;# null

    method {adverb item bnf empty/0} {children} { FIRST } ;# action
    method {adverb item bnf empty/1} {children} { FIRST } ;# blessing
    method {adverb item bnf empty/2} {children} { FIRST } ;# left
    method {adverb item bnf empty/3} {children} { FIRST } ;# right
    method {adverb item bnf empty/4} {children} { FIRST } ;# group
    method {adverb item bnf empty/5} {children} { FIRST } ;# naming
    method {adverb item bnf empty/6} {children} { FIRST } ;# null

    method {adverb item bnf quantified/0} {children} { FIRST } ;# action
    method {adverb item bnf quantified/1} {children} { FIRST } ;# blessing
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
    method {separator specification/0} {children} { ADVS separator [UNMASK [FIRST]] }

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

	SymCo assert use
	# Expect RHS

	Container new-charclass $literal $start $length
	Container charclass-use $literal $start $length

	if {[SymCo l0?]} {
	    # L0 rule - The value is a string atom, (auto)marked leaf,
	    # possibly defined here, used here. Nothing else
	} else {
	    # This L0 symbol is a lexeme, needs a G1 symbol
	    Container charclass-to-g1 $literal ; # TODO
	    # Generate the associated G1 symbol - Leaf
	    # TODO: Set def if this is a new symbol
	    #set name [$symbol name?]
	    #set symbol [Container g1-symbol $name]
	    #$symbol is-leaf!
	    #$symbol use $start $length
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $literal}
	return $literal
    }

    method CSTRING {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	lassign [lindex $children 0] start length literal

	SymCo assert use
	# Expect RHS

	Container new-string $literal $start $length
	Container string-use $literal $start $length

	if {[SymCo l0?]} {
	    # L0 rule - The value is a string symbol, (auto)marked leaf,
	    # possibly defined here, used here. Nothing else
	} else {
	    # This L0 symbol is lexeme, needs a G1 symbol
	    Container string-to-g1 $literal ; # TODO
	    # Generate the associated G1 symbol - Leaf
	    # TODO: Set def if this is a new symbol
	    #set name [$symbol name?]
	    #set symbol [Container g1-symbol $name]
	    #$symbol is-leaf!
	    #$symbol use $start $length
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
	# <==> SINGLE 0
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
	set type  [SymCo type?]  ;# def/use

	lassign [lindex $children $index] start length literal
	# child structure = (start-offset length literal)
	debug.marpa/slif/semantics {[debug caller] | [AT]: $layer $type @${start}(${length})="$literal"}

	# TODO XXX symbol name from literal - normalization !!

	if {$bracketed} {
	    # Normalize the string - Remove brackets, leading/trailing
	    # whitespace, convert all inner whitespace to single
	    # spaces.
	    regsub -all {\s+} [string trim [string range $literal 1 end-1]] { } literal
	}

	Container ${layer} symbol         $literal
	Container ${layer} symbol-${type} $literal $start $length

	# TODO: @end assert (All L0 symbols have a def (rule, atomic))
	# TODO: @end assert (All G1 symbols, but start have a use)
	# TODO: @end assert (L0 without use == G1 without a def == lexeme == terminal)

	debug.marpa/slif/semantics {[debug caller] | [AT] ==> $literal}
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
	# TODO XXX separator/proper - Merge into a single adverb/attribute.

	upvar 1 $avar adverbs

	if {[dict exists $adverbs separator]} {
	    # Ensure the existence of a default for adverb 'proper'
	    # when a 'separator' was specified. XXX: Error instead ?
	    if {![dict exists $adverbs proper]} {
		dict set adverbs proper 0
	    }
	    return
	}

	# Remove 'proper' if 'separator' is not specified. XXX: Warning ?
	if {[dict exists $adverbs proper]} {
	    dict unset adverbs proper
	}
	return
    }

    method ADVP {layer reference adverbs} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}

	set layer [SymCo layer?] 
	dict for {adverb value} $adverbs {
	    debug.marpa/slif/semantics {[AT] $adverb = ($value)}
	    Container $layer $reference set-$adverb $value
	}

	debug.marpa/slif/semantics {[debug caller] | [AT] /ok}
	return
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
## Semantic state - Symbol context
## - Layer: g1/l0
## - Type:  def/use

oo::class create marpa::slif::semantics::SymContext {
    variable mytype       ;# def/use
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

    method def {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype def
	# Process additional attributes
	if {![llength $args]} return
	my {*}$args
	return
    }

    method use {args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set mytype use
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

    method l0? {} {
	set ok [expr {$mylayer eq "l0"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    if 0 {method g1? {} {
	set ok [expr {$mylayer eq "g1"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }}

    method def? {} {
	set ok [expr {$mytype eq "def"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

    method use? {} {
	set ok [expr {$mytype eq "use"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }
}

# # ## ### ##### ######## #############
## Semantic state - Start symbol

oo::class create marpa::slif::semantics::Start {
    variable mystate

    # Start symbol handling
    # Method State --> New State Action
    # ------ -----     --------- ------
    # with:  undef     yes       set
    #        maybe     yes       set
    #        yes       yes       set
    # ------ -----     --------- ------
    # maybe: undef     maybe     set
    #        maybe     maybe     -
    #        yes       yes       -
    # ------ -----     --------- ------
    ##
    # Order by state
    # State Method --> New State Action
    # ----- ------     --------- ------
    # undef with:      yes       set
    #       maybe:     maybe     set
    # ----- ------     --------- ------
    # maybe with:      yes       set
    #       maybe:     maybe     -
    # ----- ------     --------- ------
    # yes   with:      yes       set
    #       maybe:     yes       -
    # ----- ------     --------- ------

    # "maybe:" is used by the LHS of rules. It will pass its value
    # only on the 1st call, and even then only if no explicit setting
    # was made via "with:". "with:" always passes its value.

    constructor {container} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mystate undef
	return
    }

    # # -- --- ----- -------- -------------

    method maybe: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	if {$mystate ne "undef"} return

	debug.marpa/slif/semantics {[debug caller] | pass}
	set mystate maybe
	Container start! $symbol
	return
    }

    method with: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	set mystate yes

	debug.marpa/slif/semantics {[debug caller] | pass always}
	Container start! $symbol
	return
    }

    method ok? {} {
	set ok [expr {$mystate ne "undef"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
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
