# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Parser class/engine. Semantic value of the parse is an
# AST.  The current parser embeds a manually translated SLIF grammar.
# This parser will be generated in the next step of boot strapping.

## Manually extracted, per
## -- Marpa--R2/cpan/lib/Marpa/R2/meta/metag.bnf
##    -- Artifact as of commit 15fdfc349167808b356c0c2680a54358658318c6.
## See also
## -- Marpa--R2/cpan/lib/Marpa/R2/MetaG.pm

## Rewritten to use the new parse runtime targeted by export::tparse.

# # ## ### ##### ######## #############
## Requisites

package require oo::util ;# mymethod
#package require char     ;# quoting

debug define marpa/slif/parser
debug prefix marpa/slif/parser {[debug caller] | }

# # ## ### ##### ######## #############
##

oo::class create marpa::slif::parser {
    superclass marpa::engine::tcl::parse
    # # ## ### ##### ######## #############
    marpa::E marpa/slif/parser SLIF PARSER

    method Characters {} {
	return {
	    # # ' ' ( ( ) ) * * + + , , - - 1 1 : : ; ;
	    < < = = > > [ [ \\ \\ ] ] ^ ^ a a b b c c d d
	    e e f f g g h h i i k k l l m m n n o o p p
	    r r s s t t u u v v w w x x y y \{ \{ | | \} \} ~ ~
	}
    }
    
    method Classes {} {
	return {
	    @cc-sign           {[+-]}
	    @cc-bool           {[01]}
	    @cc-alnum          {[[:alnum:]]}
	    @cc-ddigit         {[\d]}
	    @cc-sw             {[\s\w]}
	    @cc-space          {[\s]}
	    @cc-word           {[\w]}
	    @cc-vertical       {[\n\v\f\r\u2028\u2029]}
	    @cc-nvq            {[^'\n\v\f\r\u2028\u2029]}
	    @cc-nvcbr          {[^\135\n\v\f\r\u2028\u2029\u0085]}
	    @cc-nvnb           {[^\134\n\v\f\r\u2028\u2029\u0085]}
	    @cc-nv             {[^\n\v\f\r\u2028\u2029]}
	    @cc-letter         {[a-zA-Z]}
	}
    }
    
    method L0.Semantics {} {
	return {start length value}
    }
    
    method Lexemes {} {
	return {
	    @lex-(         1 @lex-)            1 @lex-*            1 @lex-+       1
	    @lex-,         1 @lex-:default     1 @lex-:discard     1 @lex-:lexeme 1
	    @lex-:start    1 @lex-\;           1 @lex-=            1 @lex-=>      1
	    @lex-action    1 @lex-assoc        1                     @lex-by      1
	    @lex-completed 1 @lex-current      1 @lex-default      1 @lex-discard 1
	    @lex-event     1 @lex-fatal        1 @lex-forgiving    1 @lex-group   1
	    @lex-high      1 @lex-inaccessible 1 @lex-is           1 @lex-latm    1
	    @lex-left      1 @lex-lexeme       1 @lex-lexer        1 @lex-low     1
	    @lex-name      1 @lex-null         1 @lex-null-ranking 1 @lex-nulled  1
	    @lex-off       1 @lex-ok           1 @lex-on           1 @lex-pause   1
	    @lex-predicted 1 @lex-priority     1 @lex-proper       1 @lex-rank    1
	    @lex-right     1 @lex-separator    1 @lex-start        1 @lex-symbol  1
	    @lex-warn      1 @lex-\{           1 @lex-\}           1

	    {reserved event name}    1 {op declare bnf}	  1 {op declare match}     1
	    {op loosen}              1 {op equal priority}  1 {before or after}      1
	    {signed integer}         1 boolean              1 {reserved action name} 1
	                               {Perl name}          1 {bare name}            1
	    {standard name}          1 {bracketed name}     1 {array descriptor}     1
	    {single quoted string}   1 {single quoted name} 1 {character class}      1
	}
    }
    
    method L0.Symbols {} {
	return {
	    whitespace     {hash comment}
	    {terminated hash comment}    {unterminated final hash comment}
	    {hash comment body}    {vertical space char}
	    {hash comment char}    sign
	    integer    {one or more word characters}
	    {zero or more word characters}    {Perl identifier}
	    {bracketed name string}    {double colon}
	    {array descriptor left bracket}    {array descriptor left bracket}
	    {array descriptor right bracket}    {array descriptor right bracket}
	    {result item descriptor list}    {result item descriptor separator}
	    {result item descriptor separator}    {result item descriptor}
	    {string without single quote or vertical space}    {cc elements}
	    {cc element}    {safe cc character}
	    {cc element}    {escaped cc character}
	    {cc element}    {cc element}
	    {character class modifiers}    {character class modifier}
	    {posix char class}    {negated posix char class}
	    {posix char class name}    {horizontal character}
	}
    }
    
    method L0.Rules {} {
	return {
	    {@lex-(                                           := (}
	    {@lex-)                                           := )}
	    {@lex-*                                           := *}
	    {@lex-+                                           := +}
	    {@lex-,                                           := ,}
	    {@lex-:default                                    := : d e f a u l t}
	    {@lex-:discard                                    := : d i s c a r d}
	    {@lex-:lexeme                                     := : l e x e m e}
	    {@lex-:start                                      := : s t a r t}
	    {@lex-\;                                          := \;}
	    {@lex-=                                           := =}
	    {@lex-=>                                          := = >}
	    {@lex-action                                      := a c t i o n}
	    {@lex-assoc                                       := a s s o c}
	    {@lex-by                                          := b y}
	    {@lex-completed                                   := c o m p l e t e d}
	    {@lex-current                                     := c u r r e n t}
	    {@lex-default                                     := d e f a u l t}
	    {@lex-discard                                     := d i s c a r d}
	    {@lex-event                                       := e v e n t}
	    {@lex-fatal                                       := f a t a l}
	    {@lex-forgiving                                   := f o r g i v i n g}
	    {@lex-group                                       := g r o u p}
	    {@lex-high                                        := h i g h}
	    {@lex-inaccessible                                := i n a c c e s s i b l e}
	    {@lex-is                                          := i s}
	    {@lex-latm                                        := l a t m}
	    {@lex-left                                        := l e f t}
	    {@lex-lexeme                                      := l e x e m e}
	    {@lex-lexer                                       := l e x e r}
	    {@lex-low                                         := l o w}
	    {@lex-name                                        := n a m e}
	    {@lex-null                                        := n u l l}
	    {@lex-null-ranking                                := n u l l - r a n k i n g}
	    {@lex-nulled                                      := n u l l e d}
	    {@lex-off                                         := o f f}
	    {@lex-ok                                          := o k}
	    {@lex-on                                          := o n}
	    {@lex-pause                                       := p a u s e}
	    {@lex-predicted                                   := p r e d i c t e d}
	    {@lex-priority                                    := p r i o r i t y}
	    {@lex-proper                                      := p r o p e r}
	    {@lex-rank                                        := r a n k}
	    {@lex-right                                       := r i g h t}
	    {@lex-separator                                   := s e p a r a t o r}
	    {@lex-start                                       := s t a r t}
	    {@lex-symbol                                      := s y m b o l}
	    {@lex-warn                                        := w a r n}
	    {@lex-\{                                          := \{}
	    {@lex-\}                                          := \}}
	    {{reserved event name}                            := {double colon} {one or more word characters}}
	    {{op declare bnf}                                 := {double colon} =}
	    {{op declare match}                               := ~}
	    {{op loosen}                                      := | |}
	    {{op equal priority}                              := |}
	    {{before or after}                                := b e f o r e}
	    {{before or after}                                := a f t e r}
	    {{signed integer}                                 := integer}
	    {{signed integer}                                 := sign integer}
	    {boolean                                          := @cc-bool}
	    {{reserved action name}                           := {double colon} {one or more word characters}}
	    {{Perl name}                                      + {Perl identifier} {double colon}}
	    {{bare name}                                      + @cc-word}
	    {{standard name}                                  := @cc-letter {zero or more word characters}}
	    {{bracketed name}                                 := < {bracketed name string} >}
	    {{array descriptor}                               := {array descriptor left bracket} {result item descriptor list} {array descriptor right bracket}}
	    {{single quoted string}                           := ' {string without single quote or vertical space} ' {character class modifiers}}
	    {{single quoted name}                             := ' {string without single quote or vertical space} '}
	    {{character class}                                := \[ {cc elements} \] {character class modifiers}}
	    {whitespace                                       + @cc-space}
	    {{hash comment}                                   := {terminated hash comment}}
	    {{hash comment}                                   := {unterminated final hash comment}}
	    {{terminated hash comment}                        := \# {hash comment body} {vertical space char}}
	    {{unterminated final hash comment}                := \# {hash comment body}}
	    {{hash comment body}                              * {hash comment char}}
	    {{vertical space char}                            := @cc-vertical}
	    {{hash comment char}                              := @cc-nv}
	    {sign                                             := @cc-sign}
	    {integer                                          + @cc-ddigit}
	    {{one or more word characters}                    + @cc-word}
	    {{zero or more word characters}                   * @cc-word}
	    {{Perl identifier}                                + @cc-word}
	    {{bracketed name string}                          + @cc-sw}
	    {{double colon}                                   := : :}
	    {{array descriptor left bracket}                  := \[}
	    {{array descriptor left bracket}                  := \[ whitespace}
	    {{array descriptor right bracket}                 := \]}
	    {{array descriptor right bracket}                 := whitespace \]}
	    {{result item descriptor list}                    * {result item descriptor} {result item descriptor separator} no}
	    {{result item descriptor separator}               := ,}
	    {{result item descriptor separator}               := , whitespace}
	    {{result item descriptor}                         := s t a r t}
	    {{result item descriptor}                         := l e n g t h}
	    {{result item descriptor}                         := g 1 s t a r t}
	    {{result item descriptor}                         := g 1 l e n g t h}
	    {{result item descriptor}                         := n a m e}
	    {{result item descriptor}                         := l h s}
	    {{result item descriptor}                         := s y m b o l}
	    {{result item descriptor}                         := r u l e}
	    {{result item descriptor}                         := v a l u e}
	    {{result item descriptor}                         := v a l u e s}
	    {{result item descriptor}                         := o r d}
	    {{string without single quote or vertical space}  + @cc-nvq}
	    {{cc elements}                                    + {cc element}}
	    {{cc element}                                     := {safe cc character}}
	    {{cc element}                                     := {escaped cc character}}
	    {{safe cc character}                              := @cc-nvnb}
	    {{escaped cc character}                           := \\ {horizontal character}}
	    {{cc element}                                     := {posix char class}}
	    {{cc element}                                     := {negated posix char class}}
	    {{character class modifiers}                      * {character class modifier}}
	    {{character class modifier}                       := : i c}
	    {{character class modifier}                       := : i}
	    {{posix char class}                               := \[ : {posix char class name} : \]}
	    {{negated posix char class}                       := \[ : ^ {posix char class name} : \]}
	    {{posix char class name}                          + @cc-alnum}
	    {{horizontal character}                           := @cc-nv}
	}
    }
    
    method G1.Symbols {} {
	return  {
	    statements    statement
	    {null statement}    {statement group}
	    {start rule}    {default rule}
	    {lexeme default statement}    {discard default statement}
	    {priority rule}    {empty rule}
	    {quantified rule}    quantifier    {discard rule}
	    {lexeme rule}    {completion event declaration}
	    {nulled event declaration}    {prediction event declaration}
	    {current lexer statement}    {inaccessible statement}    {inaccessible treatment}
	    {priorities bnf} {priorities match}
	    {alternatives bnf}    {alternative bnf}
	    {alternatives match}    {alternative match}

	    {adverb list default}		{adverb list items default}		{adverb item default}
	    {adverb list discard}		{adverb list items discard}		{adverb item discard}
	    {adverb list lexeme}		{adverb list items lexeme}		{adverb item lexeme}
	    {adverb list discard default}	{adverb list items discard default}	{adverb item discard default}
	    {adverb list lexeme default}	{adverb list items lexeme default}	{adverb item lexeme default}
	    {adverb list bnf alternative}	{adverb list items bnf alternative}	{adverb item bnf alternative}
	    {adverb list bnf empty}		{adverb list items bnf empty}		{adverb item bnf empty}
	    {adverb list bnf quantified}	{adverb list items bnf quantified}	{adverb item bnf quantified}
	    {adverb list match alternative}	{adverb list items match alternative}	{adverb item match alternative}
	    {adverb list match empty}		{adverb list items match empty}		{adverb item match empty}
	    {adverb list match quantified}	{adverb list items match quantified}	{adverb item match quantified}

	    {null adverb}
	    action    {left association}
	    {right association}    {group association}
	    {separator specification}    {proper specification}
	    {rank specification}    {null ranking specification}
	    {null ranking constant}    {priority specification}
	    {pause specification}    {event specification}
	    {event initialization}    {event initializer}
	    {on or off}    {event initializer}
	    {latm specification}
	    {naming}    {alternative name}
	    {lexer name}    {event name}
	    lhs	    rhs    {rhs primary}
	    {parenthesized rhs primary list}    {rhs primary list}
	    {single symbol}    symbol
	    {symbol name}    {action name}
	}
    }
    
    method G1.Rules {} {
	return {
	    {__________ :A {symbol ord values}}
	    {statements				+ statement}
	    {statement				:= {start rule}}
	    {statement				:= {empty rule}}
	    {statement				:= {null statement}}
	    {statement				:= {statement group}}
	    {statement				:= {priority rule}}
	    {statement				:= {quantified rule}}
	    {statement				:= {discard rule}}
	    {statement				:= {default rule}}
	    {statement				:= {lexeme default statement}}
	    {statement				:= {discard default statement}}
	    {statement				:= {lexeme rule}}
	    {statement				:= {completion event declaration}}
	    {statement				:= {nulled event declaration}}
	    {statement				:= {prediction event declaration}}
	    {statement				:= {current lexer statement}}
	    {statement				:= {inaccessible statement}}
	    {{null statement}			:= @lex-\;}
	    {{statement group}			:M {0 2} @lex-\{ statements @lex-\}}
	    {{start rule}			:M {0 1} @lex-:start {op declare bnf} symbol}
	    {{start rule}			:M {0 1 2} @lex-start @lex-symbol @lex-is symbol}
	    {{default rule}			:M {0 1} @lex-:default {op declare bnf} {adverb list default}}
	    {{lexeme default statement}		:M {0 1 2} @lex-lexeme @lex-default @lex-= {adverb list lexeme default}}
	    {{discard default statement}	:M {0 1 2} @lex-discard @lex-default @lex-= {adverb list discard default}}
	    {{priority rule}			:M {1} lhs {op declare bnf} {priorities bnf}}
	    {{priority rule}			:M {1} lhs {op declare match} {priorities match}}
	    {{empty rule}			:M {1} lhs {op declare bnf} {adverb list bnf empty}}
	    {{empty rule}			:M {1} lhs {op declare match} {adverb list match empty}}
	    {{quantified rule}			:M {1} lhs {op declare bnf} {single symbol} quantifier {adverb list bnf quantified}}
	    {{quantified rule}			:M {1} lhs {op declare match} {single symbol} quantifier {adverb list match quantified}}
	    {quantifier                         := @lex-*}
	    {quantifier                         := @lex-+}
	    {{discard rule}			:M {0 1} @lex-:discard {op declare match} symbol {adverb list discard}}
	    {{discard rule}			:M {0 1} @lex-:discard {op declare match} {character class} {adverb list discard}}
	    {{lexeme rule}			:M {0 1} @lex-:lexeme {op declare match} symbol {adverb list lexeme}}
	    {{completion event declaration}	:M {0 2 3} @lex-event {event initialization} @lex-= @lex-completed {symbol name}}
	    {{nulled event declaration}		:M {0 2 3} @lex-event {event initialization} @lex-= @lex-nulled {symbol name}}
	    {{prediction event declaration}	:M {0 2 3} @lex-event {event initialization} @lex-= @lex-predicted {symbol name}}
	    {{current lexer statement}		:M {0 1 2} @lex-current @lex-lexer @lex-is {lexer name}}
	    {{inaccessible statement}		:M {0 1 3 4} @lex-inaccessible @lex-is {inaccessible treatment} @lex-by @lex-default}
	    {{inaccessible treatment}		:= @lex-warn}
	    {{inaccessible treatment}		:= @lex-ok}
	    {{inaccessible treatment}		:= @lex-fatal}

	    {{priorities bnf}			+ {alternatives bnf}   {op loosen} yes}
	    {{priorities match}			+ {alternatives match} {op loosen} yes}

	    {{alternatives bnf}			+ {alternative bnf}   {op equal priority} yes}
	    {{alternatives match}		+ {alternative match} {op equal priority} yes}

	    {{alternative bnf}			:= rhs {adverb list bnf alternative}}
	    {{alternative match}		:= rhs {adverb list match alternative}}

	    {{adverb list default}		:= {adverb list items default}}
	    {{adverb list discard}		:= {adverb list items discard}}
	    {{adverb list lexeme}		:= {adverb list items lexeme}}
	    {{adverb list discard default}	:= {adverb list items discard default}}
	    {{adverb list lexeme default}	:= {adverb list items lexeme default}}
	    {{adverb list bnf alternative}	:= {adverb list items bnf alternative}}
	    {{adverb list bnf empty}		:= {adverb list items bnf empty}}
	    {{adverb list bnf quantified}	:= {adverb list items bnf quantified}}
	    {{adverb list match alternative}	:= {adverb list items match alternative}}
	    {{adverb list match empty}		:= {adverb list items match empty}}
	    {{adverb list match quantified}	:= {adverb list items match quantified}}

	    {{adverb list items default}		* {adverb item default}}
	    {{adverb list items discard}		* {adverb item discard}}
	    {{adverb list items lexeme}			* {adverb item lexeme}}
	    {{adverb list items discard default}	* {adverb item discard default}}
	    {{adverb list items lexeme default}		* {adverb item lexeme default}}
	    {{adverb list items bnf alternative}	* {adverb item bnf alternative}}
	    {{adverb list items bnf empty}		* {adverb item bnf empty}}
	    {{adverb list items bnf quantified}		* {adverb item bnf quantified}}
	    {{adverb list items match alternative}	* {adverb item match alternative}}
	    {{adverb list items match empty}		* {adverb item match empty}}
	    {{adverb list items match quantified}	* {adverb item match quantified}}

	    {{adverb item default}		:= action}
	    {{adverb item default}		:= {null adverb}}

	    {{adverb item discard}		:= {event specification}}
	    {{adverb item discard}		:= {null adverb}}

	    {{adverb item lexeme}		:= {event specification}}
	    {{adverb item lexeme}		:= {latm specification}}
	    {{adverb item lexeme}		:= {priority specification}}
	    {{adverb item lexeme}		:= {pause specification}}
	    {{adverb item lexeme}		:= {null adverb}}

	    {{adverb item discard default}	:= {event specification}}
	    {{adverb item discard default}	:= {null adverb}}

	    {{adverb item lexeme default}	:= action}
	    {{adverb item lexeme default}	:= {latm specification}}
	    {{adverb item lexeme default}	:= {null adverb}}

	    {{adverb item bnf alternative}	:= action}
	    {{adverb item bnf alternative}	:= {left association}}
	    {{adverb item bnf alternative}	:= {right association}}
	    {{adverb item bnf alternative}	:= {group association}}
	    {{adverb item bnf alternative}	:= naming}
	    {{adverb item bnf alternative}	:= {null adverb}}

	    {{adverb item bnf empty}		:= action}
	    {{adverb item bnf empty}		:= {left association}}
	    {{adverb item bnf empty}		:= {right association}}
	    {{adverb item bnf empty}		:= {group association}}
	    {{adverb item bnf empty}		:= naming}
	    {{adverb item bnf empty}		:= {null adverb}}

	    {{adverb item bnf quantified}	:= action}
	    {{adverb item bnf quantified}	:= {separator specification}}
	    {{adverb item bnf quantified}	:= {proper specification}}
	    {{adverb item bnf quantified}	:= {null adverb}}

	    {{adverb item match alternative}	:= naming}
	    {{adverb item match alternative}	:= {null adverb}}

	    {{adverb item match empty}		:= naming}
	    {{adverb item match empty}		:= {null adverb}}

	    {{adverb item match quantified}	:= {separator specification}}
	    {{adverb item match quantified}	:= {proper specification}}
	    {{adverb item match quantified}	:= {null adverb}}

	    {{null adverb}			:= @lex-,}
	    {action				:M {0 1} @lex-action @lex-=> {action name}}
	    {{left association}			:M {0 1 2} @lex-assoc @lex-=> @lex-left}
	    {{right association}		:M {0 1 2} @lex-assoc @lex-=> @lex-right}
	    {{group association}		:M {0 1 2} @lex-assoc @lex-=> @lex-group}
	    {{separator specification}		:M {0 1} @lex-separator @lex-=> {single symbol}}
	    {{proper specification}		:M {0 1} @lex-proper @lex-=> boolean}
	    {{rank specification}		:M {0 1} @lex-rank @lex-=> {signed integer}}
	    {{null ranking specification}	:M {0 1} @lex-null-ranking @lex-=> {null ranking constant}}
	    {{null ranking specification}	:M {0 1 2} @lex-null @lex-rank @lex-=> {null ranking constant}}
	    {{null ranking constant}		:= @lex-low}
	    {{null ranking constant}		:= @lex-high}
	    {{priority specification}		:M {0 1} @lex-priority @lex-=> {signed integer}}
	    {{pause specification}		:M {0 1} @lex-pause @lex-=> {before or after}}
	    {{event specification}		:M {0 1} @lex-event @lex-=> {event initialization}}
	    {{event initialization}		:= {event name} {event initializer}}
	    {{event initializer}		:M {0} @lex-= {on or off}}
	    {{on or off}			:= @lex-on}
	    {{on or off}			:= @lex-off}
	    {{event initializer}		:= }
	    {{latm specification}		:M {0 1} @lex-forgiving @lex-=> boolean}
	    {{latm specification}		:M {0 1} @lex-latm @lex-=> boolean}
	    {{naming}				:M {0 1} @lex-name @lex-=> {alternative name}}
	    {{alternative name}			:= {standard name}}
	    {{alternative name}			:= {single quoted name}}
	    {{lexer name}			:= {standard name}}
	    {{lexer name}			:= {single quoted name}}
	    {{event name}			:= {standard name}}
	    {{event name}			:= {single quoted name}}
	    {{event name}			:= {reserved event name}}
	    {lhs				:= {symbol name}}
	    {rhs				+ {rhs primary}}
	    {{rhs primary}			:= {single symbol}}
	    {{rhs primary}			:= {single quoted string}}
	    {{rhs primary}			:= {parenthesized rhs primary list}}
	    {{parenthesized rhs primary list}	:M {0 2} @lex-( {rhs primary list} @lex-)}
	    {{rhs primary list}			+ {rhs primary}}
	    {{single symbol}			:= symbol}
	    {{single symbol}			:= {character class}}
	    {symbol				:= {symbol name}}
	    {{symbol name}			:= {bare name}}
	    {{symbol name}			:= {bracketed name}}
	    {{action name}			:= {Perl name}}
	    {{action name}			:= {reserved action name}}
	    {{action name}			:= {array descriptor}}
	}
    }
    
    method Discards {} {
	return {
	    whitespace
	    {hash comment}
	}
    }

    method Start {} {
	return statements
    }
}

# # ## ### ##### ######## #############
return
