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
    method statement {children} { EVAL }

    # Executing the statements in order updates the grammar
    method {null statement} {children} { IS }
    method {statement group} {children} { IS }
    method {start rule} {children} { IS }
    method {default rule} {children} { IS }
    method {lexeme default statement} {children} { IS }
    method {discard default statement} {children} { IS }
    method {priority rule} {children} { IS }
    method {empty rule} {children} { IS }
    method {quantified rule} {children} { IS }
    method {discard rule} {children} { IS }
    method {lexeme rule} {children} { IS }
    method {completion event declaration} {children} { IS }
    method {nulled event declaration} {children} { IS }
    method {prediction event declaration} {children} { IS }
    method {current lexer statement} {children} { IS }
    method {inaccessible statement} {children} { IS }

    # Adverb processing, generates a dict of the adverbs
    method {adverb list} {children} { PASS }
    method {adverb list items} {children} { FLAT }
    method {adverb item} {children} { PASS1 }
    method {null adverb} {children} {}
    method action {children} {}
    method {left association} {children} {}
    method {right association} {children} {}
    method {group association} {children} {}
    method {separator specification} {children} {}
    method {proper specification} {children} {}
    method {rank specification} {children} {}
    method {null ranking specification} {children} {}
    method {null ranking constant} {children} {}
    method {priority specification} {children} {}
    method {pause specification} {children} {}
    method {event specification} {children} {}
    method {event initialization} {children} {}
    method {event initializer} {children} {}
    method {on or off} {children} {}
    method {event initializer} {children} {}
    method {latm specification} {children} {}
    method {blessing} {children} {}
    method {naming} {children} {}

    method quantifier {children} {}
    method {inaccessible treatment} {children} {}
    method {op declare} {children} {}
    method priorities {children} {}
    method alternatives {children} {}
    method alternative {children} {}
    method {alternative name} {children} {}
    method {lexer name} {children} {}
    method {event name} {children} {}
    method {blessing name} {children} {}
    method lhs {children} {}
    method rhs {children} {}
    method {rhs primary} {children} {}
    method {parenthesized rhs primary list} {children} {}
    method {rhs primary list} {children} {}
    method {single symbol} {children} {}
    method symbol {children} {}
    method {symbol name} {children} {}
    method {action name} {children} {}

    method EVAL {} {
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] |}
	upvar 1 children children
	foreach c $children { eval $c }
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] | /ok}
	return
    }

    method PASS1 {{index 0}} {
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] |}
	upvar 1 children children
	set r [eval [lindex $children $index]]
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] | ==> ($r)}
	return $r
    }

    method PASS {} {
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] | ==> ($r)}
	upvar 1 children children
	set r {}
	foreach c $children { lappend r [eval $c] }
	return $r
    }

    method FLAT {} {
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] |}
	upvar 1 children children
	set r {}
	foreach c $children { lappend r {*}[eval $c] }
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] | ==> ($r)}
	return $r
    }

    method IS {{script {}}} {
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] |}
	upvar 1 children children
	uplevel 1 $script
	debug.marpa/grammar {[uplevel 1 {debug caller 1}] | /ok}
	return
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
