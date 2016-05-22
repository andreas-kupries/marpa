# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Semantics. Manually written, as backend to the
# marpa::slif::parser class, processing its AST. Boot strapping will
# replace this with generated code, later. Note that the semantics are
# not the container for a SLIF grammar. That is handled by a separate
# class, marpa::slif::container

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
	link {ADV     ADV}     ;# Generate singular adverb sem value, for literal
	link {ADVS    ADVS}    ;# Generate singular adverb sem value, for symbol
	link {ADVP    ADVP}    ;# Process adverbs for a context
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

    # TODO: G1 rules LHS = Start maybe ...
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
	#    0     1         2     3            4
	# OK <lhs> <op decl> <rhs> <quantifier> <adverbs>
	#     |     g1/l0     |     */+          /
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

	SymCo [SINGLE 1] ;# match operator specifies grammar layer
	SymCo def ; set lhs [FIRST]
	SymCo use ; set rhs [UNMASK [SINGLE 2]]

	if {[SymCo g1?]} { Start maybe: $lhs }

	set positive [SINGLE 3]
	set adverbs  [SINGLE 4]
	set rule     [$lhs add-quantified $rhs $positive]

	set accepted {separator proper action bless name rank}
	if {[SymCo g1?]} { lappend accepted 0rank }

	# Custom check for related attributes 'separator' and 'proper'
	# TODO XXX separator/proper - Merge into a single adverb/attribute.
	if {[dict exists $adverbs separator]} {
	    # Ensure existence of a default for 'proper' when a
	    # 'separator' is specified.
	    if {![dict exists $adverbs proper]} {
		dict set adverbs proper 0
	    }
	} else {
	    # Ignore 'proper' if there is no 'separator'. XXX: Warning ?
	    if {[dict exists $adverbs proper]} {
		dict unset adverbs proper
	    }
	}

	ADVP {quantified rule} $adverbs $accepted $rule
	return
    }

    # # -- --- ----- -------- -------------
    ## Empty rules. Like prioritized rules below, except with a more
    ## limited set of adverbs.

    method {empty rule/0} {children} { # OK <lhs> <op declare> <adverb list>
	# <lhs> <op declare> <adverb list>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - action    -- <action>
	# - bless     -- <blessing>

	SymCo [SINGLE 1] ;# match operator specifies grammar layer
	SymCo def ; set lhs [FIRST]

	if {[SymCo g1?]} { Start maybe: $lhs }

	set rule [$lhs add-bnf {} 0]

	# TODO XXX empty rule - adverb checking if ok for l0, or g1 only
	set adverbs  [SINGLE 2] ;# dict. Optional, possibly empty.
	set accepted {action bless}
	ADVP {empty rule} $adverbs $accepted $rule
	return
    }

    # # -- --- ----- -------- -------------
    ## Priority rules. BNF rules, alternatives, prioritized

    method {priority rule/0} {children} {
	# 0     1            2...
	# <lhs> <op declare> <priorities>
	#  \- symbol name    \- alternatives each with adverb information
	#
	# Push information (lhs, decl) down to the <alternative>, do
	# adverb and precedence processing there, not here.

	SymCo [SINGLE 1] ;# match operator specifies grammar layer
	SymCo def ; set lhs [FIRST]

	if {[SymCo g1?]} { Start maybe: $lhs }

	SymCo lhs $lhs
	SymCo use
	SymCo precedence/reset

	EVALR 2 end
    }

    method priorities/0 {children} {
	DESEQ ; EVALS { SymCo precedence/loosen }
    } ; # OK <alternatives> <op loosen> ...

    method alternatives/0 {children} {
	DESEQ ; EVAL
    } ; # OK <alternative> <op equal priority> ...

    method alternative/0  {children} {
	# <rhs> <adverb list>

	set lhs  [SymCo lhs?]
	set rhs  [FIRST]
	set prec [SymCo precedence?]
	# UNBOX, symbol and mask vectors

	set rule [$lhs add-bnf $rhs $prec]
	# TODO: Add mask/visibility vectors XXX L0: masking irrelevant.

	# TODO XXX bnf rule - adverb checking if ok for l0, or g1 only
	set adverbs  [SINGLE 1] ;# dict. Optional, possibly empty.
	set accepted {action bless name rank assoc}
	if {[SymCo g1?]} { lappend accepted 0rank }

	ADVP {bnf rule} $adverbs $accepted $rule
	return
    }

    method rhs/0                {children} { MERGE {*}[VALUES] } ; # OK <rhs>+
    method {rhs primary list/0} {children} { MERGE {*}[VALUES] } ; # OK <rhs>+

    method {rhs primary/0} {children} { FIRST }          ; # OK <single symbol>
    method {rhs primary/1} {children} { LEAF [CSTRING] } ; # OK <single quoted string>
    method {rhs primary/2} {children} { FIRST }          ; # OK <parenthesized rhs primary list>

    method {parenthesized rhs primary list/0} {children} { HIDE [FIRST] } ; # OK <rhs primary list>

    # # -- --- ----- -------- -------------
    ## Match operators (:=, ~)

    method {op declare/0} {children} { CONST g1 }
    method {op declare/1} {children} { CONST l0 }

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
    ## that sub tree is a dict mapping from adverb names to pairs,
    ## with each pair the adverb's value and location in the input.

    method {adverb list/0}       {children} { FIRST }
    method {adverb list items/0} {children} { FLATTEN } ;# Squash parts into single dict

    #                                                           Defaults
    method {adverb item/0}  {children} { FIRST } ;# action      l0 [values] g1 undef
    method {adverb item/1}  {children} { FIRST } ;# left  assoc \* left
    method {adverb item/2}  {children} { FIRST } ;# right assoc |
    method {adverb item/3}  {children} { FIRST } ;# group assoc /
    method {adverb item/4}  {children} { FIRST } ;# separator   undef
    method {adverb item/5}  {children} { FIRST } ;# proper      no
    method {adverb item/6}  {children} { FIRST } ;# rank        ?
    method {adverb item/7}  {children} { FIRST } ;# null rank   ?
    method {adverb item/8}  {children} { FIRST } ;# priority    0
    method {adverb item/9}  {children} { FIRST } ;# pause       undef
    method {adverb item/10} {children} { FIRST } ;# event       undef
    method {adverb item/11} {children} { FIRST } ;# latm        no
    method {adverb item/12} {children} { FIRST } ;# bless       undef
    method {adverb item/13} {children} { FIRST } ;# name        undef
    method {adverb item/14} {children} { FIRST } ;# null        N/A

    # # -- --- ----- -------- -------------

    method {proper specification/0}    {children} { ADV  proper    [LITERAL]        }
    method {separator specification/0} {children} { ADVS separator [UNMASK [FIRST]] }

    # # -- --- ----- -------- -------------
    ## TODO XXX null ranking - check sem value propriety

    method {null ranking specification/0} {children} { ADVS 0rank [FIRST]  } ; # OK
    method {null ranking specification/1} {children} { ADVS 0rank [FIRST]  } ; # OK

    method {null ranking constant/0} {children} { CONST low  } ; # OK
    method {null ranking constant/1} {children} { CONST high } ; # OK

    # # -- --- ----- -------- -------------

    method {left association/0}  {children} { ADV assoc [LITERAL] }
    method {right association/0} {children} { ADV assoc [LITERAL] }
    method {group association/0} {children} { ADV assoc [LITERAL] }

    # # -- --- ----- -------- -------------

    # # -- --- ----- -------- -------------
    ## Symbol processing

    method lhs/0           {children} { FIRST    } ; # OK

    method symbol/0        {children} { FIRST    } ; # OK
    method {symbol name/0} {children} { SYMBOL 0 } ; # OK
    method {symbol name/1} {children} { SYMBOL 0 } ; # OK

    # users: quantified rule, discard rule, separator spec, rhs primary/0
    method {single symbol/0} {children} { LEAF [FIRST]  } ; # OK <symbol>
    method {single symbol/1} {children} { LEAF [CCLASS] } ; # OK <character class>

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

	set symbol [Container new-charclass $literal $start $length]
	$symbol use $start $length

	if {[SymCo l0?]} {
	    # L0 rule - Value is string atom, (auto)marked leaf,
	    # possibly defined here, used here. Nothing else
	} else {
	    # This L0 symbol is toplevel/lexeme
	    $symbol is-toplevel!

	    # Generate the associated G1 symbol - Leaf
	    # TODO: Set def if this is a new symbol
	    set name [$symbol name?]
	    set symbol [Container g1-symbol $name]
	    $symbol is-leaf!
	    $symbol use $start $length
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $symbol}
	return $symbol
    }

    method CSTRING {} {
	debug.marpa/slif/semantics {[debug caller] | [AT][INDENT]}
	upvar 1 children children
	lassign [lindex $children 0] start length literal

	SymCo assert use
	# Expect RHS

	set symbol [Container new-string $literal $start $length]
	$symbol use $start $length

	if {[SymCo l0?]} {
	    # L0 rule - Value is string symbol, (auto)marked leaf,
	    # possibly defined here, used here. Nothing else
	} else {
	    # This L0 symbol is toplevel/lexeme
	    $symbol is-toplevel!

	    # Generate the associated G1 symbol - Leaf
	    # TODO: Set def if this is a new symbol
	    set name [$symbol name?]
	    set symbol [Container g1-symbol $name]
	    $symbol is-leaf!
	    $symbol use $start $length
	}

	debug.marpa/slif/semantics {[UNDENT][debug caller] | [AT] ==> $symbol}
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

    method SYMBOL {index} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	upvar 1 children children

	# Context:
	set layer [SymCo layer?] ;# g1/l0
	set type  [SymCo type?]  ;# def/use

	lassign [lindex $children $index] start length literal
	# child structure = (start-offset length literal)
	debug.marpa/slif/semantics {[debug caller] | [AT]: $layer $type @${start}(${length})="$literal"}

	# TODO XXX symbol name from literal - normalization !!

	# Get symbol instance ...
	set symbol [Container ${layer}-symbol $literal]

	# ... and save location by type.
	$symbol $type $start $length

	# TODO: @end assert (All L0 symbols have a def (rule, atomic))
	# TODO: @end assert (All G1 symbols, but start have a use)
	# TODO: @end assert (L0 without use == G1 without a def == lexeme == terminal)

	debug.marpa/slif/semantics {[debug caller] | [AT] ==> $symbol}
	return $symbol
    }

    method CONST {args} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($args)}
	return $args
    }

    method ADV {key value} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	# location is done automatically by
	set value [list $key [list [uplevel 1 LITLOC] $value]]
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($value)}
	return $value
    }

    method ADVS {key symbol} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	# location is done automatically by
	set value [list $key [list [$symbol last-use] $symbol]]
	debug.marpa/slif/semantics {[debug caller] | [AT] ==> ($value)}
	return $value
    }

    method ADVP {context adverbs accepted destination} {
	debug.marpa/slif/semantics {[debug caller] | [AT]}
	foreach key $accepted {
	    if {![dict exists $adverbs $key]} {
		debug.marpa/slif/semantics {[debug caller] | [AT] $key SKIP}
		continue
	    }
	    set value [dict get $adverbs $key]
	    dict unset adverbs $key

	    debug.marpa/slif/semantics {[AT] $key = ($value)}
	    $destination set-$key $value
	}
	if {[dict size $adverbs]} {
	    E "Invalid adverbs [dict keys $adverbs] in $context" \
		INVALID ADVERB $context
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

    method g1? {} {
	set ok [expr {$mylayer eq "g1"}]
	debug.marpa/slif/semantics {[debug caller] | ==> $ok}
	return $ok
    }

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

    constructor {container} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mystate undef
	return
    }

    # # -- --- ----- -------- -------------

    method maybe: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	if {$mystate eq "yes"} return

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
