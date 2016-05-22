#!/usr/bin/env tclsh
## -*- tcl -*-
# # ## ### ##### ######## #############
## Bootstrapping.
## Parsing the L0 grammar, i.e. lexemes and their rules.
## Manually extracted, per
## -- Marpa--R2/cpan/lib/Marpa/R2/meta/metag.bnf
##    -- Artifact as of commit 15fdfc349167808b356c0c2680a54358658318c6.
## See also
## -- Marpa--R2/cpan/lib/Marpa/R2/MetaG.pm

package require marpa
package require char ;# quoting

# # ## ### ##### ######## #############
## Semantic procedures based on the G1 symbols.
## Variant 1: Print AST properly indented.

global indent
set    indent ""
global step
set    step "  "

proc PR {symbol children} {
    global indent step
    set previous $indent
    puts $indent$symbol:
    append indent $step
    foreach child $children {
	eval $child
    }
    set indent $previous
    return
}

foreach s {
    statements    statement    {null statement}    {statement group}
    {start rule}    {default rule}    {lexeme default statement}
    {discard default statement}    {priority rule}    {empty rule}
    {quantified rule}    quantifier    {discard rule}    {lexeme rule}
    {completion event declaration}    {nulled event declaration}
    {prediction event declaration}    {current lexer statement}
    {inaccessible statement}    {inaccessible treatment}
    {op declare}    priorities    alternatives    alternative
    {adverb list}    {adverb list items}    {adverb item}    {null adverb}
    action    {left association}    {right association}    {group association}
    {separator specification}    {proper specification}    {rank specification}
    {null ranking specification}    {null ranking constant}
    {priority specification}    {pause specification}    {event specification}
    {event initialization}    {event initializer}    {on or off}
    {event initializer}    {latm specification}    {blessing}
    {naming}    {alternative name}    {lexer name}    {event name}
    {blessing name}    lhs    rhs    {rhs primary}
    {parenthesized rhs primary list}    {rhs primary list}    {single symbol}
    symbol    {symbol name}    {action name}
} {
    foreach i {
	0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    } {
	interp alias {} $s/$i {} PR $s/$i
    }
}

proc unknown {args} {
    global indent
    puts $indent[marpa::location::Show $args]
}

# # ## ### ##### ######## #############
## Read parse result, AST, print

proc B {ast} {
    eval $ast
}

proc EOF {} {}

source [lindex $argv 0]
exit
