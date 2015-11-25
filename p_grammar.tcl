# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container for SLIF. Able to directly ingest a SLIF AST.
# Accessor methods to all stored data allow a generator to get all the
# information they need for their operation.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/grammar
#debug prefix marpa/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::grammar {
    # Data structures.

    constructor {ast} {
	debug.marpa/grammar {[debug caller 2] | }
	# Shortcut access to all methods (implicit "my")
	# TODO: limit to AST symbol methods

	foreach m [info class methods [self class] -private] {
	    link [list $m $m]
	}

	# This needs the methods as immediately accessible commands.
	eval $ast

	debug.marpa/grammar {[debug caller 2] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## AST processing methods

    method statements/0        {children} { EVAL }
    method statement/0         {children} { EVAL }
    method statement/1         {children} { EVAL }
    method statement/2         {children} { EVAL }
    method statement/3         {children} { EVAL }
    method statement/4         {children} { EVAL }
    method statement/5         {children} { EVAL }
    method statement/6         {children} { EVAL }
    method statement/7         {children} { EVAL }
    method statement/8         {children} { EVAL }
    method statement/9         {children} { EVAL }
    method statement/10        {children} { EVAL }
    method statement/11        {children} { EVAL }
    method statement/12        {children} { EVAL }
    method statement/13        {children} { EVAL }
    method statement/14        {children} { EVAL }
    method statement/15        {children} { EVAL }
    method {statement group/0} {children} { EVAL }

    # Executing the statements in order updates the grammar ... TODO gr updates
    method {null statement/0}             {children} { ISX }

    method {start rule/0}                   {children} { ISX }
    method {start rule/1}                   {children} { ISX }

    method {default rule/0}                 {children} { ISX PASS1 }
    method {lexeme default statement/0}     {children} { ISX PASS1 }
    method {discard default statement/0}    {children} { ISX PASS1 }
    method {priority rule/0}                {children} { ISX PASS }
    method {empty rule/0}                   {children} { ISX }
    method {quantified rule/0}              {children} { ISX PASS }
    method {discard rule/0}                 {children} { ISX PASS }
    method {lexeme rule/0}                  {children} { ISX PASS }
    method {completion event declaration/0} {children} { ISX PASS }
    method {nulled event declaration/0}     {children} { ISX PASS }
    method {prediction event declaration/0} {children} { ISX PASS }
    method {current lexer statement/0}      {children} { ISX PASS }
    method {inaccessible statement/0}       {children} { ISX PASS }

    # Adverb processing, generates a dict of the adverbs
    method {adverb list/0}       {children} { PASS }
    method {adverb list items/0} {children} { FLAT } ;# Squash parts into single dict
    method {adverb item/0}       {children} { PASS1 }
    method {adverb item/1}       {children} { PASS1 }
    method {adverb item/2}       {children} { PASS1 }
    method {adverb item/3}       {children} { PASS1 }
    method {adverb item/4}       {children} { PASS1 }
    method {adverb item/5}       {children} { PASS1 }
    method {adverb item/6}       {children} { PASS1 }
    method {adverb item/7}       {children} { PASS1 }
    method {adverb item/8}       {children} { PASS1 }
    method {adverb item/9}       {children} { PASS1 }
    method {adverb item/10}      {children} { PASS1 }
    method {adverb item/11}      {children} { PASS1 }
    method {adverb item/12}      {children} { PASS1 }
    method {adverb item/13}      {children} { PASS1 }
    method {adverb item/14}      {children} { PASS1 }
    # Adverb parts ...
    method {null adverb/0}       {children} { CONST }

    method action/0              {children} { CONST action [PASS1] }
    method {action name/0}       {children} { CONST cmd   [STRING] }
    method {action name/1}       {children} { CONST cmd   [STRING] }
    method {action name/2}       {children} { CONST array [STRING] }

    method {left association/0}  {children} { CONST assoc left  }
    method {right association/0} {children} { CONST assoc right }
    method {group association/0} {children} { CONST assoc group }

    method {separator specification/0}    {children} { CONST sep   [PASS1]  }
    method {proper specification/0}       {children} { CONST latm  [STRING] }
    method {rank specification/0}         {children} { CONST rank  [STRING] }
    method {priority specification/0}     {children} { CONST prio  [PASS1]  }
    method {pause specification/0}        {children} { CONST pause [STRING] }

    method {null ranking specification/0} {children} { CONST 0rank [PASS1]  }
    method {null ranking specification/1} {children} { CONST 0rank [PASS1]  }
    method {null ranking constant/0}      {children} { CONST low  }
    method {null ranking constant/1}      {children} { CONST high }

    method {event specification/0}        {children} { CONST event [PASS1]  }
    method {event initialization/0}       {children} { PASS }
    method {event initializer/0}          {children} { PASS1 }
    method {on or off/0}                  {children} { CONST on  }
    method {on or off/1}                  {children} { CONST off }

    method {event name/0}                 {children} { STRING }
    method {event name/1}                 {children} { STRING }
    method {event name/2}                 {children} { STRING }
    method {latm specification/0}         {children} { CONST latm [STRING] }
    method {latm specification/0}         {children} { CONST latm [STRING] }
    method {blessing/0}                   {children} { PASS1 }
    method {blessing name/0}              {children} { CONST bless [STRING] }
    method {blessing name/1}              {children} { CONST bless [STRING] }
    method {naming/0}                     {children} { CONST name  [PASS1]  }

    method {inaccessible treatment/0} {children} { CONST warn  }
    method {inaccessible treatment/1} {children} { CONST ok    }
    method {inaccessible treatment/2} {children} { CONST fatal }

    method quantifier/0 {children} { CONST * }
    method quantifier/1 {children} { CONST + }

    method {op declare/0} {children} { CONST G1 }
    method {op declare/1} {children} { CONST L0 }

    method priorities/0   {children} {
	IS {
	    set r {}
	    set add yes
	    foreach c $children {
		if {$add} { lappend r [eval $c] }
		set add [expr {!$add}]
	    }
	    return $r
	}
    }
    method alternatives/0 {children} {
	IS {
	    set r {}
	    set add yes
	    foreach c $children {
		if {$add} { lappend r [eval $c] }
		set add [expr {!$add}]
	    }
	    return $r
	}
    }
    method alternative/0  {children} { PASS }

    method {alternative name/0} {children} { PASS1 }
    method {alternative name/1} {children} { PASS1 }

    method {lexer name/0} {children} { PASS1 }
    method {lexer name/1} {children} { PASS1 }
    method lhs/0          {children} { PASS1 }

    # TODO: The SV here has to be a list of rhs elements + mask vector
    # TODO: This flows up until into the 'alternative'.
    method rhs/0           {children} { PASS } ;# remove separators ?
    method {rhs primary/0} {children} { PASS } ;# mask calculations
    method {rhs primary/1} {children} {
	# <single quoted string> : lexeme
	# TODO: Allocate internal lexer symbol for the string.
	# TODO: Do interning, allocate only one symbol per unique string.
	# TODO: Record characters of the string.
	# TODO: Consider char modifiers!
	# TODO: generate internal lex rule for the exploded string
	# TODO: Adverb settings for such internal symbol ?
	STRING
	# Pass the created symbol
    } ;# ditto
    method {rhs primary/2} {children} { PASS } ;# ditto

    method {parenthesized rhs primary list/0} {children} { PASS }
    method {rhs primary list/0} {children} { PASS }

    method {single symbol/0} {children} { PASS1 }
    method {single symbol/1} {children} {
	# <character class>
	# TODO: Allocate internal lexer symbol for the class
	# TODO: Do interning, allocate only one symbol per unique class
	# TODO: Record characters of the class?
	# TODO: Consider char modifiers!
	# TODO: generate internal lex rule for the class
	# TODO: Adverb settings for such internal symbol ?
	CONST cc  [STRING]
	# Pass the created symbol
    }

    method symbol/0        {children} { PASS1 }
    method {symbol name/0} {children} { STRING }
    method {symbol name/1} {children} { STRING }

    # # ## ### ##### ######## #############

    method EVAL {} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	foreach c $children {
	    # The side-effects are important, not the result.
	    eval $c
	}
	debug.marpa/grammar {[debug caller] | [AT] /ok}
	return
    }

    method PASS1 {{index 0}} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children

	#debug.marpa/grammar {[debug caller] | [AT]: ([join $children )\n(])}

	set child [lindex $children $index]
	#debug.marpa/grammar {[debug caller] | [AT]: $child}

	set r [eval $child]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method LEX {args} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r [lindex $children {*}$args]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method STRING {{index 0}} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r [lindex $children $index 2]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method CONST {args} {
	debug.marpa/grammar {[debug caller] | [AT]}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($args)}
	return $args
    }

    method PASS {} {
	debug.marpa/grammar {[uplevel 1 {debug caller}]}
	upvar 1 children children
	set r {}
	foreach c $children {
	    #debug.marpa/grammar {[debug caller] | [AT]: $c}
	    lappend r [eval $c]
	}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method FLAT {} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r {}
	foreach c $children {
	    #debug.marpa/grammar {[debug caller] | [AT]: $c}
	    lappend r {*}[eval $c]
	}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method IS {{script {}}} {
	debug.marpa/grammar {[debug caller 1] | [AT]}
	upvar 1 children children
	set r [uplevel 1 $script]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method ISX {{script {}}} {
	debug.marpa/grammar {[debug caller 1] | [AT]}
	upvar 1 children children
	set r [uplevel 1 $script]
	debug.marpa/grammar {[debug caller 1] | [AT] DEF ($r)}
	return $r
    }

    # # ## ### ##### ######## #############

    method AT {} {
	return <[lindex [info level -2] 1]>
    }

    # # ## ### ##### ######## #############
    ## Accessor methods for data retrieval

    # # ## ### ##### ######## #############
    ## Methods for direct/bulk loading of grammar information

    # # ## ### ##### ######## #############
    ## Activate for processing of an input per the loaded grammar.

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
