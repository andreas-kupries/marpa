# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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

# # ## ### ##### ######## #############
## Requisites

package require oo::util ;# mymethod
#package require char     ;# quoting

debug define marpa/slif/parser
debug prefix marpa/slif/parser {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::parser {
    # # ## ### ##### ######## #############

    constructor {} {
	# Build the processing pipeline, and configure the various
	# engines.
	my Pipeline
	my Grammar
    }

    method Pipeline {} {
	## - Object creation is backward.
	## - Spec loading is forward.
	## - Initialization is backward again.

	# Capture final AST
	set B [marpa::slif::parser::Capture create B]

	# Store for token values.
	set ST [marpa::semstore create ST]

	# G1 semantics, empty, builds AST
	# :default ::= action => [start,length,values]
	#              bless  => ::lhs
	set GS [marpa::semcore create GS  $ST]

	# Parser engine - Structural symbols and rules. User
	# semantics.
	set G1 [marpa::parser create G1  $ST $GS $B]

	# Lexer engine - Lexical symbol and rules - Symbol gate for
	# parser, mapping to parser symbols. Fixed semantics
	# (character aggregation)
	set L0 [marpa::lexer create L0  $ST $G1]

	# Character gate, class handling and mapping to lexer symbols
	set LG [marpa::gate create LG  $ST $L0]

	# Basic character processing, location as token value, file
	# handling ...
	marpa::inbound create IN  $ST $LG

	#         v----\ v----\
	# IN --> LG --> L0 --> G1 --> B
	# v /---/      /       v     /
	# ST <--------/        GS   /
	# ^^------------------/    /
	#  \----------------------/
    }

    method Grammar {} {
	#GS add-rule @default {marpa::semstd::builtin {start length values}}
	GS add-rule @default {marpa::semstd::builtin {name values}}
	# start
	# length
	# values
	my Gate
	my Lexer
	my Structure
    }

    method Gate {} {
	# # ## ### ##### ######## #############
	## Configure pipeline - Gate specification

	# I. Symbols for individual characters
	##
	# Define the set of acceptable characters as taken from the grammar
	# specification. A tcl dictionary, i.e. hash-table is used to map them
	# to tokens, i.e. integer ids. These ids actually come from the up-
	# stream object, i.e. the L0 engine. The engine also knows the mapping
	# (ns upvar'd into scope), for use in grammar rules.
	##
	# II. Symbols for character classes
	##
	# Indirectly extend the set of acceptable characters via character classes.
	# For all known characters (see above) memebership is computed as part of
	# the setup. Unknown characters are lazily computed when they occur.

	# Like for characters a tcl dictionary, i.e. hash-table is used to map
	# them to tokens, i.e. integer ids. The same dictionary, actually.
	# These ids again come from the up-stream object, i.e. the L0
	# engine.

	LG def {
	    # ' ( ) * + , - 1 : ; < = > [ \\ ] ^ a b c d e f
	    g h i k l m n o p r s t u v w x y \{ | \} ~
	} {
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
	    @cc-nv             {[^\n\11\12\r\u2028\u2029]}
	    @cc-letter         {[a-zA-Z]}
	}
    }

    method Lexer {} {
	# # ## ### ##### ######## #############
	## Configure pipeline with lexer definitions.

	# III. Lexeme for un-named strings and classes in the L0 definition,
	#      and those explicitly named in the G1 grammar for use in
	#      structural rules
	##
	# These symbols are part of the interface to G1. They actually have
	# two ids associated with them, one each for L0 and G1.

	L0 latm   yes
	L0 action {start length value}

	L0 export {
	    @lex-(         @lex-)            @lex-*            @lex-+                
	    @lex-,         @lex-:default     @lex-:discard     @lex-:lexeme          
	    @lex-:start    @lex-\;           @lex-=            @lex-=>               
	    @lex-action    @lex-assoc        @lex-bless        @lex-by               
	    @lex-completed @lex-current      @lex-default      @lex-discard          
	    @lex-event     @lex-fatal        @lex-forgiving    @lex-group            
	    @lex-high      @lex-inaccessible @lex-is           @lex-latm             
	    @lex-left      @lex-lexeme       @lex-lexer        @lex-low              
	    @lex-name      @lex-null         @lex-null-ranking @lex-nulled           
	    @lex-off       @lex-ok           @lex-on           @lex-pause            
	    @lex-predicted @lex-priority     @lex-proper       @lex-rank             
	    @lex-right     @lex-separator    @lex-start        @lex-symbol           
	    @lex-warn      @lex-\{           @lex-\}               

	    {reserved event name}    {op declare bnf}	  {op declare match}
	    {op loosen}              {op equal priority}  {before or after}
	    {signed integer}         boolean              {reserved action name}
	    {reserved blessing name} {Perl name}          {bare name}
	    {standard name}          {bracketed name}     {array descriptor}
	    {single quoted string}   {single quoted name} {character class}
	}

	# V. Lexemes explicitly named in the G1 grammar and NOT used in
	#    structural rules, only in match rules.
	##
	# These symbols are NOT part of the interface to G1.

	L0 symbols {
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

	# VI. Match rules for all symbols, exported and not.

	L0 rules {
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
	    {@lex-bless                                       := b l e s s}
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
	    {{reserved blessing name}                         := {double colon} {one or more word characters}}
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
	    {{string without single quote or vertical space}  + @cc-nvq}
	    {{cc elements}                                    + {cc element}}
	    {{cc element}                                     := {safe cc character}}
	    {{cc element}                                     := {escaped cc character}}
	    {{safe cc character}                              := @cc-nv}
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

    method Structure {} {
	# VII. Structural symbols, and rules

	G1 symbols {
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
	    {latm specification}    {blessing}
	    {naming}    {alternative name}
	    {lexer name}    {event name}
	    {blessing name}    lhs
	    rhs    {rhs primary}
	    {parenthesized rhs primary list}    {rhs primary list}
	    {single symbol}    symbol
	    {symbol name}    {action name}
	}

	# VII. Structural rules.

	G1 action {name values}
	G1 rules {
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
	    {{discard rule}			:M {0 1} @lex-:discard {op declare match} {single symbol} {adverb list discard}}
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
	    {{adverb item default}		:= blessing}
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
	    {{adverb item lexeme default}	:= blessing}
	    {{adverb item lexeme default}	:= {latm specification}}
	    {{adverb item lexeme default}	:= {null adverb}}

	    {{adverb item bnf alternative}	:= action}
	    {{adverb item bnf alternative}	:= blessing}
	    {{adverb item bnf alternative}	:= {left association}}
	    {{adverb item bnf alternative}	:= {right association}}
	    {{adverb item bnf alternative}	:= {group association}}
	    {{adverb item bnf alternative}	:= naming}
	    {{adverb item bnf alternative}	:= {null adverb}}

	    {{adverb item bnf empty}		:= action}
	    {{adverb item bnf empty}		:= blessing}
	    {{adverb item bnf empty}		:= {left association}}
	    {{adverb item bnf empty}		:= {right association}}
	    {{adverb item bnf empty}		:= {group association}}
	    {{adverb item bnf empty}		:= naming}
	    {{adverb item bnf empty}		:= {null adverb}}

	    {{adverb item bnf quantified}	:= action}
	    {{adverb item bnf quantified}	:= blessing}
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
	    {{blessing}				:M {0 1} @lex-bless @lex-=> {blessing name}}
	    {{naming}				:M {0 1} @lex-name @lex-=> {alternative name}}
	    {{alternative name}			:= {standard name}}
	    {{alternative name}			:= {single quoted name}}
	    {{lexer name}			:= {standard name}}
	    {{lexer name}			:= {single quoted name}}
	    {{event name}			:= {standard name}}
	    {{event name}			:= {single quoted name}}
	    {{event name}			:= {reserved event name}}
	    {{blessing name}			:= {standard name}}
	    {{blessing name}			:= {reserved blessing name}}
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

	# # ## ### ##### ######## #############
	## Complete parser and lexer specification, initialize feedback loops
	## and switch the objects into active more.

	G1 parse statements {
	    whitespace
	    {hash comment}
	}
    }

    method process-file {path} {
	set chan [open $path r]
	# Drive the pipeline from the channel.
	IN read $chan
	IN eof
	return [B result]
    }

    method process {string} {
	# Drive the pipeline from the string
	IN enter $string
	IN eof
	return [B result]
    }

    # # ## ### ##### ######## #############
}

# Capture final AST, internal class.
oo::class create marpa::slif::parser::Capture {
    variable myresult
    variable mycode
    method result {} {
	return -code $mycode $myresult
    }
    method enter {ast} {
	set mycode ok
	set myresult $ast
    }
    method eof {} {}
    method fail {msg} {
	set mycode error
	set myresult $msg
    }
    # TODO: Extend fail to provide more information, and capture this here.
}

# # ## ### ##### ######## #############
return
