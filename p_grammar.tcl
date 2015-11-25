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

    method statements {children} { EVAL }
    method statement  {children} { EVAL }

    # Executing the statements in order updates the grammar
    method {null statement}               {children} { ISX }
    method {statement group}              {children} { ISX }
    method {start rule}                   {children} { ISX }
    method {default rule}                 {children} { ISX {PASS1 2} } ;# TODO: Update grammar state with adverbs
    method {lexeme default statement}     {children} { ISX PASS1 }
    method {discard default statement}    {children} { ISX PASS1 }
    method {priority rule}                {children} { ISX PASS }
    method {empty rule}                   {children} { ISX }
    method {quantified rule}              {children} { ISX PASS }
    method {discard rule}                 {children} { ISX PASS }
    method {lexeme rule}                  {children} { ISX PASS }
    method {completion event declaration} {children} { ISX PASS }
    method {nulled event declaration}     {children} { ISX PASS }
    method {prediction event declaration} {children} { ISX PASS }
    method {current lexer statement}      {children} { ISX PASS }
    method {inaccessible statement}       {children} { ISX PASS }

    # Adverb processing, generates a dict of the adverbs
    method {adverb list}       {children} { PASS }
    method {adverb list items} {children} { FLAT } ;# Squash parts into single dict
    method {adverb item}       {children} { PASS1 }
    # Adverb parts ...
    method {null adverb}       {children} { IS {return {}} }
    method action              {children} { PASS1 }
    method {action name}       {children} {
	IS {
	    lassign $children lex
	    lassign $lex s l str
	    if {[string match "\\\[*" $str]} {
		return [list action [list array $str]]
	    } else {
		return [list action [list cmd $str]]
	    }
	}
    }
    method {left association}           {children} { IS {return {assoc left}} }
    method {right association}          {children} { IS {return {assoc right}} }
    method {group association}          {children} { IS {return {assoc group}} }
    method {separator specification}    {children} { IS {return [list sep [PASS1]] }}
    method {proper specification}       {children} { IS {return [list latm [LEX 0 2]]} }
    method {rank specification}         {children} { IS {return [list rank [LEX 0 2]]} }
    method {null ranking specification} {children} { IS {return [list 0rank [PASS1]]} }
    method {null ranking constant}      {children} { LEX 0 2 }
    method {priority specification}     {children} { IS {return [list prio [PASS1]]} }
    method {pause specification}        {children} { IS {return [list pause [LEX 0 2]]} }
    method {event specification}        {children} { IS {return [list event [PASS1]]} }
    method {event initialization}       {children} { PASS }
    method {event initializer}          {children} { PASS1 }
    method {on or off}                  {children} { LEX 0 2 }
    method {event name}                 {children} { LEX 0 2 }
    method {latm specification}         {children} { IS {return [list latm [LEX 0 2]]} }
    method {blessing}                   {children} { PASS1 }
    method {blessing name}              {children} { IS {return [list bless [LEX 0 2]] }}
    method {naming}                     {children} { IS {return [list name [PASS1]]} }

    method {inaccessible treatment} {children} { LEX 0 2 }
    method quantifier {children} { LEX 0 2 }
    method {op declare} {children} {
	IS {
	    set str [LEX 0 2]
	    if {$str eq {::=}} {
		return g1
	    } else {
		return l0
	    }
	}
    }
    method priorities {children} {}
    method alternatives {children} {}
    method alternative {children} {}
    method {alternative name} {children} { PASS1 }
    method {lexer name} {children} { PASS1 }
    method lhs          {children} { PASS1 }
    method rhs {children} {}
    method {rhs primary} {children} {}
    method {parenthesized rhs primary list} {children} {}
    method {rhs primary list} {children} {}

    method {single symbol} {children} {
	IS {
	    lassign $children child
	    lassign $child head
	    if {$head eq "symbol"} {
		PASS1
	    } else {
		return [list cc [LEX 0 2]]
	    }
	}
    }
    method symbol {children} { IS { return [list sym [PASS1]]}}
    method {symbol name} {children} { LEX 0 2 }

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
