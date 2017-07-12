# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2017 Grammar marpa::slif::parser By Jeffrey Kegler + Andreas Kupries
##
##	rt_parse-derived Engine for grammar "marpa::slif::parser"
##	Generated On Wed Jul 12 01:50:10 PDT 2017
##		  By aku@hephaistos
##		 Via remeta
##
##	(*) Tcl-based Parser

#package provide marpa::slif::parser 1

# # ## ### ##### ######## #############
## Requisites

#package require marpa	      ;# marpa::slif::container
#package require Tcl 8.5       ;# -- Foundation
#package require TclOO         ;# -- Implies Tcl 8.5 requirement.
#package require debug         ;# Tracing
#package require debug::caller ;#

# # ## ### ##### ######## #############

debug define marpa/slif/parser
debug prefix marpa/slif/parser {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create marpa::slif::parser {
    superclass marpa::engine::tcl::parse

    # Lifecycle: No constructor needed. No state.
    # All data is embedded as literals into methods

    # Declare the various things needed by the engine for its
    # operation.  To get the information the base class will call on
    # these methods in the proper order. The methods simply return the
    # requested information. Their base-class implementations simply
    # throw errors, thus preventing the construction of an incomplete
    # parser.
    
    method Characters {} {
	debug.marpa/slif/parser
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<#>        #
	    @CHR:<'>        '
	    @CHR:<*>        *
	    @CHR:<+>        +
	    @CHR:<,>        ,
	    @CHR:<->        -
	    @CHR:<1>        1
	    @CHR:<:>        :
	    @CHR:<<>        <
	    @CHR:<=>        =
	    @CHR:<>>        >
	    @CHR:<^>        ^
	    @CHR:<a>        a
	    @CHR:<b>        b
	    @CHR:<c>        c
	    @CHR:<d>        d
	    @CHR:<e>        e
	    @CHR:<f>        f
	    @CHR:<g>        g
	    @CHR:<h>        h
	    @CHR:<i>        i
	    @CHR:<k>        k
	    @CHR:<l>        l
	    @CHR:<m>        m
	    @CHR:<n>        n
	    @CHR:<o>        o
	    @CHR:<p>        p
	    @CHR:<r>        r
	    @CHR:<s>        s
	    @CHR:<t>        t
	    @CHR:<u>        u
	    @CHR:<v>        v
	    @CHR:<w>        w
	    @CHR:<x>        x
	    @CHR:<y>        y
	    @CHR:<|>        |
	    @CHR:<~>        ~
	    {@CHR:<\50>}    \50
	    {@CHR:<\51>}    \51
	    {@CHR:<\73>}    \73
	    {@CHR:<\133>}   \133
	    {@CHR:<\134>}   \134
	    {@CHR:<\135>}   \135
	    {@CHR:<\173>}   \173
	    {@CHR:<\175>}   \175
	}
    }
    
    method Classes {} {
	debug.marpa/slif/parser
	# Literals: The character classes in use
	return {
	    @CLS:<+->                                           {[+\055]}
	    @CLS:<A-Za-z>                                       {[A-Za-z]}
	    @RAN:<01>                                           {[01]}
	    @RAN:<03>                                           {[0-3]}
	    @RAN:<07>                                           {[0-7]}
	    {@^CLS:<\7-\10\n-\r'0-7\134\u2028-\u2029>}          {[^\007\10\n-\r'0-7\134\u2028\u2029]}
	    {@^CLS:<\7-\10\n-\r'\134\u2028-\u2029>}             {[^\007\10\n-\r'\134\u2028\u2029]}
	    {@^CLS:<\7-\10\n-\r'\134\u2028-\u2029[:xdigit:]>}   {[^\007\10\n-\r'\134\u2028\u2029[:xdigit:]]}
	    {@^CLS:<\7-\r-0-7\134-\135\u2028-\u2029>}           {[^\007-\r\0550-7\134\135\u2028\u2029]}
	    {@^CLS:<\7-\r-\134-\135\u2028-\u2029>}              {[^\007-\r\055\134\135\u2028\u2029]}
	    {@^CLS:<\7-\r-\134-\135\u2028-\u2029[:xdigit:]>}    {[^\007-\r\055\134\135\u2028\u2029[:xdigit:]]}
	    {@^CLS:<\n-\r\u2028-\u2029>}                        {[^\n-\r\u2028\u2029]}
	    {@CLS:<\134a-bfnrtv>}                               {[\134abfnrtv]}
	    {@CLS:<\n-\r\u2028-\u2029>}                         {[\n-\r\u2028\u2029]}
	    {@CLS:<_[:alnum:]>}                                 {[_[:alnum:]]}
	    {@CLS:<_[:alnum:][:space:]>}                        {[_[:alnum:][:space:]]}
	    {@NCC:<[:alnum:]>}                                  {[[:alnum:]]}
	    {@NCC:<[:digit:]>}                                  {[[:digit:]]}
	    {@NCC:<[:space:]>}                                  {[[:space:]]}
	    {@NCC:<[:xdigit:]>}                                 {[[:xdigit:]]}
	}
    }
    
    method Lexemes {} {
	debug.marpa/slif/parser
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    @LEX:@CHR:<*>              1
	    @LEX:@CHR:<+>              1
	    @LEX:@CHR:<,>              1
	    @LEX:@CHR:<=>              1
	    @LEX:@STR:<:default>       1
	    @LEX:@STR:<:discard>       1
	    @LEX:@STR:<:lexeme>        1
	    @LEX:@STR:<:start>         1
	    @LEX:@STR:<=>>             1
	    @LEX:@STR:<action>         1
	    @LEX:@STR:<assoc>          1
	    @LEX:@STR:<by>             1
	    @LEX:@STR:<completed>      1
	    @LEX:@STR:<current>        1
	    @LEX:@STR:<default>        1
	    @LEX:@STR:<discard>        1
	    @LEX:@STR:<event>          1
	    @LEX:@STR:<fatal>          1
	    @LEX:@STR:<forgiving>      1
	    @LEX:@STR:<group>          1
	    @LEX:@STR:<high>           1
	    @LEX:@STR:<inaccessible>   1
	    @LEX:@STR:<is>             1
	    @LEX:@STR:<latm>           1
	    @LEX:@STR:<left>           1
	    @LEX:@STR:<lexeme>         1
	    @LEX:@STR:<lexer>          1
	    @LEX:@STR:<low>            1
	    @LEX:@STR:<name>           1
	    @LEX:@STR:<null-ranking>   1
	    @LEX:@STR:<null>           1
	    @LEX:@STR:<nulled>         1
	    @LEX:@STR:<off>            1
	    @LEX:@STR:<ok>             1
	    @LEX:@STR:<on>             1
	    @LEX:@STR:<pause>          1
	    @LEX:@STR:<predicted>      1
	    @LEX:@STR:<priority>       1
	    @LEX:@STR:<proper>         1
	    @LEX:@STR:<rank>           1
	    @LEX:@STR:<right>          1
	    @LEX:@STR:<separator>      1
	    @LEX:@STR:<start>          1
	    @LEX:@STR:<symbol>         1
	    @LEX:@STR:<warn>           1
	    boolean                    1
	    {@LEX:@CHR:<\50>}          1
	    {@LEX:@CHR:<\51>}          1
	    {@LEX:@CHR:<\73>}          1
	    {@LEX:@CHR:<\173>}         1
	    {@LEX:@CHR:<\175>}         1
	    {array descriptor}         1
	    {bare name}                1
	    {before or after}          1
	    {bracketed name}           1
	    {character class}          1
	    {op declare bnf}           1
	    {op declare match}         1
	    {op equal priority}        1
	    {op loosen}                1
	    {Perl name}                1
	    {reserved action name}     1
	    {reserved event name}      1
	    {signed integer}           1
	    {single quoted name}       1
	    {single quoted string}     1
	    {standard name}            1
	}
    }
    
    method Discards {} {
	debug.marpa/slif/parser
	# Discarded symbols (whitespace)
	return {
	    {hash comment}
	    whitespace
	}
    }
    
    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.marpa/slif/parser
	return {
	    @STR:<::=>
	    @STR:<::>
	    {@STR:<:\135>}
	    @STR:<:default>
	    @STR:<:discard>
	    @STR:<:i>
	    @STR:<:ic>
	    @STR:<:lexeme>
	    @STR:<:start>
	    @STR:<=>>
	    {@STR:<\133:>}
	    {@STR:<\133^>}
	    @STR:<action>
	    @STR:<after>
	    @STR:<assoc>
	    @STR:<before>
	    @STR:<by>
	    @STR:<completed>
	    @STR:<current>
	    @STR:<default>
	    @STR:<discard>
	    @STR:<event>
	    @STR:<fatal>
	    @STR:<forgiving>
	    @STR:<g1length>
	    @STR:<g1start>
	    @STR:<group>
	    @STR:<high>
	    @STR:<inaccessible>
	    @STR:<is>
	    @STR:<latm>
	    @STR:<left>
	    @STR:<length>
	    @STR:<lexeme>
	    @STR:<lexer>
	    @STR:<lhs>
	    @STR:<low>
	    @STR:<name>
	    @STR:<null-ranking>
	    @STR:<null>
	    @STR:<nulled>
	    @STR:<off>
	    @STR:<ok>
	    @STR:<on>
	    @STR:<ord>
	    @STR:<pause>
	    @STR:<predicted>
	    @STR:<priority>
	    @STR:<proper>
	    @STR:<rank>
	    @STR:<right>
	    @STR:<rule>
	    @STR:<separator>
	    @STR:<start>
	    @STR:<symbol>
	    @STR:<value>
	    @STR:<values>
	    @STR:<warn>
	    @STR:<||>
	    {a character class}
	    {a single quoted string}
	    {array descriptor left bracket}
	    {array descriptor right bracket}
	    {bracketed name string}
	    {cc close}
	    {cc element and more}
	    {cc open}
	    {cc range completion}
	    {cc range completion post short octal escape}
	    {cc range completion post short unicode escape}
	    {character class modifier}
	    {character class modifiers}
	    control
	    {double colon}
	    escape
	    {escaped cc char}
	    {escaped cc char details}
	    {escaped cc element}
	    {escaped cc element details}
	    {escaped string char}
	    {escaped string char details}
	    {hash comment}
	    {hash comment body}
	    {hash comment char}
	    hex
	    integer
	    {leading octal}
	    {non empty string}
	    {nullable cc}
	    {nullable cc post short octal escape}
	    {nullable cc post short unicode escape}
	    {nullable string}
	    {nullable string post short octal escape}
	    {nullable string post short unicode escape}
	    octal
	    {one or more word characters}
	    {Perl identifier}
	    {plain cc char}
	    {plain cc char without hex}
	    {plain cc char without octal}
	    {plain cc element}
	    {plain cc element without hex}
	    {plain cc element without octal}
	    {plain string char}
	    {plain string char without hex}
	    {plain string char without octal}
	    {posix char class}
	    {posix char class name}
	    {result item descriptor}
	    {result item descriptor list}
	    {result item descriptor separator}
	    sign
	    {string close}
	    {string open}
	    {terminated hash comment}
	    {unterminated final hash comment}
	    {vertical space char}
	    whitespace
	    {zero or more word characters}
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.marpa/slif/parser
	return {
	    {@LEX:@CHR:<*> := @CHR:<*>}
	    {@LEX:@CHR:<+> := @CHR:<+>}
	    {@LEX:@CHR:<,> := @CHR:<,>}
	    {@LEX:@CHR:<=> := @CHR:<=>}
	    {@LEX:@STR:<:default> := @STR:<:default>}
	    {@LEX:@STR:<:discard> := @STR:<:discard>}
	    {@LEX:@STR:<:lexeme> := @STR:<:lexeme>}
	    {@LEX:@STR:<:start> := @STR:<:start>}
	    {@LEX:@STR:<=>> := @STR:<=>>}
	    {@LEX:@STR:<action> := @STR:<action>}
	    {@LEX:@STR:<assoc> := @STR:<assoc>}
	    {@LEX:@STR:<by> := @STR:<by>}
	    {@LEX:@STR:<completed> := @STR:<completed>}
	    {@LEX:@STR:<current> := @STR:<current>}
	    {@LEX:@STR:<default> := @STR:<default>}
	    {@LEX:@STR:<discard> := @STR:<discard>}
	    {@LEX:@STR:<event> := @STR:<event>}
	    {@LEX:@STR:<fatal> := @STR:<fatal>}
	    {@LEX:@STR:<forgiving> := @STR:<forgiving>}
	    {@LEX:@STR:<group> := @STR:<group>}
	    {@LEX:@STR:<high> := @STR:<high>}
	    {@LEX:@STR:<inaccessible> := @STR:<inaccessible>}
	    {@LEX:@STR:<is> := @STR:<is>}
	    {@LEX:@STR:<latm> := @STR:<latm>}
	    {@LEX:@STR:<left> := @STR:<left>}
	    {@LEX:@STR:<lexeme> := @STR:<lexeme>}
	    {@LEX:@STR:<lexer> := @STR:<lexer>}
	    {@LEX:@STR:<low> := @STR:<low>}
	    {@LEX:@STR:<name> := @STR:<name>}
	    {@LEX:@STR:<null-ranking> := @STR:<null-ranking>}
	    {@LEX:@STR:<null> := @STR:<null>}
	    {@LEX:@STR:<nulled> := @STR:<nulled>}
	    {@LEX:@STR:<off> := @STR:<off>}
	    {@LEX:@STR:<ok> := @STR:<ok>}
	    {@LEX:@STR:<on> := @STR:<on>}
	    {@LEX:@STR:<pause> := @STR:<pause>}
	    {@LEX:@STR:<predicted> := @STR:<predicted>}
	    {@LEX:@STR:<priority> := @STR:<priority>}
	    {@LEX:@STR:<proper> := @STR:<proper>}
	    {@LEX:@STR:<rank> := @STR:<rank>}
	    {@LEX:@STR:<right> := @STR:<right>}
	    {@LEX:@STR:<separator> := @STR:<separator>}
	    {@LEX:@STR:<start> := @STR:<start>}
	    {@LEX:@STR:<symbol> := @STR:<symbol>}
	    {@LEX:@STR:<warn> := @STR:<warn>}
	    {@STR:<::=> := @CHR:<:> @CHR:<:> @CHR:<=>}
	    {@STR:<::> := @CHR:<:> @CHR:<:>}
	    {@STR:<:default> := @CHR:<:> @CHR:<d> @CHR:<e> @CHR:<f> @CHR:<a> @CHR:<u> @CHR:<l> @CHR:<t>}
	    {@STR:<:discard> := @CHR:<:> @CHR:<d> @CHR:<i> @CHR:<s> @CHR:<c> @CHR:<a> @CHR:<r> @CHR:<d>}
	    {@STR:<:i> := @CHR:<:> @CHR:<i>}
	    {@STR:<:ic> := @CHR:<:> @CHR:<i> @CHR:<c>}
	    {@STR:<:lexeme> := @CHR:<:> @CHR:<l> @CHR:<e> @CHR:<x> @CHR:<e> @CHR:<m> @CHR:<e>}
	    {@STR:<:start> := @CHR:<:> @CHR:<s> @CHR:<t> @CHR:<a> @CHR:<r> @CHR:<t>}
	    {@STR:<=>> := @CHR:<=> @CHR:<>>}
	    {@STR:<action> := @CHR:<a> @CHR:<c> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {@STR:<after> := @CHR:<a> @CHR:<f> @CHR:<t> @CHR:<e> @CHR:<r>}
	    {@STR:<assoc> := @CHR:<a> @CHR:<s> @CHR:<s> @CHR:<o> @CHR:<c>}
	    {@STR:<before> := @CHR:<b> @CHR:<e> @CHR:<f> @CHR:<o> @CHR:<r> @CHR:<e>}
	    {@STR:<by> := @CHR:<b> @CHR:<y>}
	    {@STR:<completed> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<t> @CHR:<e> @CHR:<d>}
	    {@STR:<current> := @CHR:<c> @CHR:<u> @CHR:<r> @CHR:<r> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {@STR:<default> := @CHR:<d> @CHR:<e> @CHR:<f> @CHR:<a> @CHR:<u> @CHR:<l> @CHR:<t>}
	    {@STR:<discard> := @CHR:<d> @CHR:<i> @CHR:<s> @CHR:<c> @CHR:<a> @CHR:<r> @CHR:<d>}
	    {@STR:<event> := @CHR:<e> @CHR:<v> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {@STR:<fatal> := @CHR:<f> @CHR:<a> @CHR:<t> @CHR:<a> @CHR:<l>}
	    {@STR:<forgiving> := @CHR:<f> @CHR:<o> @CHR:<r> @CHR:<g> @CHR:<i> @CHR:<v> @CHR:<i> @CHR:<n> @CHR:<g>}
	    {@STR:<g1length> := @CHR:<g> @CHR:<1> @CHR:<l> @CHR:<e> @CHR:<n> @CHR:<g> @CHR:<t> @CHR:<h>}
	    {@STR:<g1start> := @CHR:<g> @CHR:<1> @CHR:<s> @CHR:<t> @CHR:<a> @CHR:<r> @CHR:<t>}
	    {@STR:<group> := @CHR:<g> @CHR:<r> @CHR:<o> @CHR:<u> @CHR:<p>}
	    {@STR:<high> := @CHR:<h> @CHR:<i> @CHR:<g> @CHR:<h>}
	    {@STR:<inaccessible> := @CHR:<i> @CHR:<n> @CHR:<a> @CHR:<c> @CHR:<c> @CHR:<e> @CHR:<s> @CHR:<s> @CHR:<i> @CHR:<b> @CHR:<l> @CHR:<e>}
	    {@STR:<is> := @CHR:<i> @CHR:<s>}
	    {@STR:<latm> := @CHR:<l> @CHR:<a> @CHR:<t> @CHR:<m>}
	    {@STR:<left> := @CHR:<l> @CHR:<e> @CHR:<f> @CHR:<t>}
	    {@STR:<length> := @CHR:<l> @CHR:<e> @CHR:<n> @CHR:<g> @CHR:<t> @CHR:<h>}
	    {@STR:<lexeme> := @CHR:<l> @CHR:<e> @CHR:<x> @CHR:<e> @CHR:<m> @CHR:<e>}
	    {@STR:<lexer> := @CHR:<l> @CHR:<e> @CHR:<x> @CHR:<e> @CHR:<r>}
	    {@STR:<lhs> := @CHR:<l> @CHR:<h> @CHR:<s>}
	    {@STR:<low> := @CHR:<l> @CHR:<o> @CHR:<w>}
	    {@STR:<name> := @CHR:<n> @CHR:<a> @CHR:<m> @CHR:<e>}
	    {@STR:<null-ranking> := @CHR:<n> @CHR:<u> @CHR:<l> @CHR:<l> @CHR:<-> @CHR:<r> @CHR:<a> @CHR:<n> @CHR:<k> @CHR:<i> @CHR:<n> @CHR:<g>}
	    {@STR:<null> := @CHR:<n> @CHR:<u> @CHR:<l> @CHR:<l>}
	    {@STR:<nulled> := @CHR:<n> @CHR:<u> @CHR:<l> @CHR:<l> @CHR:<e> @CHR:<d>}
	    {@STR:<off> := @CHR:<o> @CHR:<f> @CHR:<f>}
	    {@STR:<ok> := @CHR:<o> @CHR:<k>}
	    {@STR:<on> := @CHR:<o> @CHR:<n>}
	    {@STR:<ord> := @CHR:<o> @CHR:<r> @CHR:<d>}
	    {@STR:<pause> := @CHR:<p> @CHR:<a> @CHR:<u> @CHR:<s> @CHR:<e>}
	    {@STR:<predicted> := @CHR:<p> @CHR:<r> @CHR:<e> @CHR:<d> @CHR:<i> @CHR:<c> @CHR:<t> @CHR:<e> @CHR:<d>}
	    {@STR:<priority> := @CHR:<p> @CHR:<r> @CHR:<i> @CHR:<o> @CHR:<r> @CHR:<i> @CHR:<t> @CHR:<y>}
	    {@STR:<proper> := @CHR:<p> @CHR:<r> @CHR:<o> @CHR:<p> @CHR:<e> @CHR:<r>}
	    {@STR:<rank> := @CHR:<r> @CHR:<a> @CHR:<n> @CHR:<k>}
	    {@STR:<right> := @CHR:<r> @CHR:<i> @CHR:<g> @CHR:<h> @CHR:<t>}
	    {@STR:<rule> := @CHR:<r> @CHR:<u> @CHR:<l> @CHR:<e>}
	    {@STR:<separator> := @CHR:<s> @CHR:<e> @CHR:<p> @CHR:<a> @CHR:<r> @CHR:<a> @CHR:<t> @CHR:<o> @CHR:<r>}
	    {@STR:<start> := @CHR:<s> @CHR:<t> @CHR:<a> @CHR:<r> @CHR:<t>}
	    {@STR:<symbol> := @CHR:<s> @CHR:<y> @CHR:<m> @CHR:<b> @CHR:<o> @CHR:<l>}
	    {@STR:<value> := @CHR:<v> @CHR:<a> @CHR:<l> @CHR:<u> @CHR:<e>}
	    {@STR:<values> := @CHR:<v> @CHR:<a> @CHR:<l> @CHR:<u> @CHR:<e> @CHR:<s>}
	    {@STR:<warn> := @CHR:<w> @CHR:<a> @CHR:<r> @CHR:<n>}
	    {@STR:<||> := @CHR:<|> @CHR:<|>}
	    {boolean := @RAN:<01>}
	    {control := {@CLS:<\134a-bfnrtv>}}
	    {escape := {@CHR:<\134>}}
	    {hex := {@NCC:<[:xdigit:]>}}
	    {integer + {@NCC:<[:digit:]>}}
	    {octal := @RAN:<07>}
	    {sign := @CLS:<+->}
	    {whitespace + {@NCC:<[:space:]>}}
	    {{@LEX:@CHR:<\50>} := {@CHR:<\50>}}
	    {{@LEX:@CHR:<\51>} := {@CHR:<\51>}}
	    {{@LEX:@CHR:<\73>} := {@CHR:<\73>}}
	    {{@LEX:@CHR:<\173>} := {@CHR:<\173>}}
	    {{@LEX:@CHR:<\175>} := {@CHR:<\175>}}
	    {{@STR:<:\135>} := @CHR:<:> {@CHR:<\135>}}
	    {{@STR:<\133:>} := {@CHR:<\133>} @CHR:<:>}
	    {{@STR:<\133^>} := {@CHR:<\133>} @CHR:<^>}
	    {{a character class} := {cc open} {cc element and more}}
	    {{a single quoted string} := {string open} {non empty string}}
	    {{array descriptor left bracket} := {@CHR:<\133>}}
	    {{array descriptor left bracket} := {@CHR:<\133>} whitespace}
	    {{array descriptor right bracket} := whitespace {@CHR:<\135>}}
	    {{array descriptor right bracket} := {@CHR:<\135>}}
	    {{array descriptor} := {array descriptor left bracket} {result item descriptor list} {array descriptor right bracket}}
	    {{bare name} := {one or more word characters}}
	    {{before or after} := @STR:<after>}
	    {{before or after} := @STR:<before>}
	    {{bracketed name string} + {@CLS:<_[:alnum:][:space:]>}}
	    {{bracketed name} := @CHR:<<> {bracketed name string} @CHR:<>>}
	    {{cc close} := {@CHR:<\135>}}
	    {{cc element and more} := {escaped cc element}}
	    {{cc element and more} := {plain cc element}}
	    {{cc open} := {@CHR:<\133>}}
	    {{cc open} := {@STR:<\133^>}}
	    {{cc range completion post short octal escape} := @CHR:<-> {escaped cc char}}
	    {{cc range completion post short octal escape} := @CHR:<-> {plain cc char} {nullable cc}}
	    {{cc range completion post short octal escape} := {cc close}}
	    {{cc range completion post short octal escape} := {escaped cc element}}
	    {{cc range completion post short octal escape} := {plain cc element without octal}}
	    {{cc range completion post short unicode escape} := @CHR:<-> {escaped cc char}}
	    {{cc range completion post short unicode escape} := @CHR:<-> {plain cc char} {nullable cc}}
	    {{cc range completion post short unicode escape} := {cc close}}
	    {{cc range completion post short unicode escape} := {escaped cc element}}
	    {{cc range completion post short unicode escape} := {plain cc element without hex}}
	    {{cc range completion} := @CHR:<-> {escaped cc char}}
	    {{cc range completion} := @CHR:<-> {plain cc char} {nullable cc}}
	    {{cc range completion} := {nullable cc}}
	    {{character class modifiers} * {character class modifier}}
	    {{character class modifier} := @STR:<:i>}
	    {{character class modifier} := @STR:<:ic>}
	    {{character class} := {a character class} {character class modifiers}}
	    {{double colon} := @STR:<::>}
	    {{escaped cc char details} := @CHR:<u> hex hex hex hex {nullable cc}}
	    {{escaped cc char details} := @CHR:<u> hex hex hex {nullable cc post short unicode escape}}
	    {{escaped cc char details} := @CHR:<u> hex hex {nullable cc post short unicode escape}}
	    {{escaped cc char details} := @CHR:<u> hex {nullable cc post short unicode escape}}
	    {{escaped cc char details} := @CHR:<x> hex hex {nullable cc}}
	    {{escaped cc char details} := control {nullable cc}}
	    {{escaped cc char details} := octal octal {nullable cc post short octal escape}}
	    {{escaped cc char details} := octal {nullable cc post short octal escape}}
	    {{escaped cc char details} := {leading octal} octal octal {nullable cc}}
	    {{escaped cc char} := escape {escaped cc char details}}
	    {{escaped cc element details} := @CHR:<u> hex hex hex hex {cc range completion}}
	    {{escaped cc element details} := @CHR:<u> hex hex hex {cc range completion post short unicode escape}}
	    {{escaped cc element details} := @CHR:<u> hex hex {cc range completion post short unicode escape}}
	    {{escaped cc element details} := @CHR:<u> hex {cc range completion post short unicode escape}}
	    {{escaped cc element details} := @CHR:<x> hex hex {cc range completion}}
	    {{escaped cc element details} := control {cc range completion}}
	    {{escaped cc element details} := octal octal {cc range completion post short octal escape}}
	    {{escaped cc element details} := octal {cc range completion post short octal escape}}
	    {{escaped cc element details} := {leading octal} octal octal {cc range completion}}
	    {{escaped cc element} := escape {escaped cc element details}}
	    {{escaped string char details} := @CHR:<u> hex hex hex hex {nullable string}}
	    {{escaped string char details} := @CHR:<u> hex hex hex {nullable string post short unicode escape}}
	    {{escaped string char details} := @CHR:<u> hex hex {nullable string post short unicode escape}}
	    {{escaped string char details} := @CHR:<u> hex {nullable string post short unicode escape}}
	    {{escaped string char details} := @CHR:<x> hex hex {nullable string}}
	    {{escaped string char details} := control {nullable string}}
	    {{escaped string char details} := octal octal {nullable string post short octal escape}}
	    {{escaped string char details} := octal {nullable string post short octal escape}}
	    {{escaped string char details} := {leading octal} octal octal {nullable string}}
	    {{escaped string char} := escape {escaped string char details}}
	    {{hash comment body} * {hash comment char}}
	    {{hash comment char} := {@^CLS:<\n-\r\u2028-\u2029>}}
	    {{hash comment} := {terminated hash comment}}
	    {{hash comment} := {unterminated final hash comment}}
	    {{leading octal} := @RAN:<03>}
	    {{non empty string} := {escaped string char}}
	    {{non empty string} := {plain string char} {nullable string}}
	    {{nullable cc post short octal escape} := {cc close}}
	    {{nullable cc post short octal escape} := {escaped cc char}}
	    {{nullable cc post short octal escape} := {plain cc char without octal} {nullable cc}}
	    {{nullable cc post short unicode escape} := {cc close}}
	    {{nullable cc post short unicode escape} := {escaped cc char}}
	    {{nullable cc post short unicode escape} := {plain cc char without hex} {nullable cc}}
	    {{nullable cc} := {cc close}}
	    {{nullable cc} := {cc element and more}}
	    {{nullable string post short octal escape} := {escaped string char}}
	    {{nullable string post short octal escape} := {plain string char without octal} {nullable string}}
	    {{nullable string post short octal escape} := {string close}}
	    {{nullable string post short unicode escape} := {escaped string char}}
	    {{nullable string post short unicode escape} := {plain string char without hex} {nullable string}}
	    {{nullable string post short unicode escape} := {string close}}
	    {{nullable string} := {non empty string}}
	    {{nullable string} := {string close}}
	    {{one or more word characters} + {@CLS:<_[:alnum:]>}}
	    {{op declare bnf} := @STR:<::=>}
	    {{op declare match} := @CHR:<~>}
	    {{op equal priority} := @CHR:<|>}
	    {{op loosen} := @STR:<||>}
	    {{Perl identifier} := {one or more word characters}}
	    {{Perl name} + {Perl identifier} {double colon} 1}
	    {{plain cc char without hex} := {@^CLS:<\7-\r-\134-\135\u2028-\u2029[:xdigit:]>}}
	    {{plain cc char without octal} := {@^CLS:<\7-\r-0-7\134-\135\u2028-\u2029>}}
	    {{plain cc char} := {@^CLS:<\7-\r-\134-\135\u2028-\u2029>}}
	    {{plain cc element without hex} := {plain cc char without hex} {cc range completion}}
	    {{plain cc element without hex} := {posix char class} {nullable cc}}
	    {{plain cc element without octal} := {plain cc char without octal} {cc range completion}}
	    {{plain cc element without octal} := {posix char class} {nullable cc}}
	    {{plain cc element} := {plain cc char} {cc range completion}}
	    {{plain cc element} := {posix char class} {nullable cc}}
	    {{plain string char without hex} := {@^CLS:<\7-\10\n-\r'\134\u2028-\u2029[:xdigit:]>}}
	    {{plain string char without octal} := {@^CLS:<\7-\10\n-\r'0-7\134\u2028-\u2029>}}
	    {{plain string char} := {@^CLS:<\7-\10\n-\r'\134\u2028-\u2029>}}
	    {{posix char class name} + {@NCC:<[:alnum:]>}}
	    {{posix char class} := {@STR:<\133:>} {posix char class name} {@STR:<:\135>}}
	    {{reserved action name} := {double colon} {one or more word characters}}
	    {{reserved event name} := {double colon} {one or more word characters}}
	    {{result item descriptor list} * {result item descriptor} {result item descriptor separator} 0}
	    {{result item descriptor separator} := @CHR:<,>}
	    {{result item descriptor separator} := @CHR:<,> whitespace}
	    {{result item descriptor} := @STR:<g1length>}
	    {{result item descriptor} := @STR:<g1start>}
	    {{result item descriptor} := @STR:<length>}
	    {{result item descriptor} := @STR:<lhs>}
	    {{result item descriptor} := @STR:<name>}
	    {{result item descriptor} := @STR:<ord>}
	    {{result item descriptor} := @STR:<rule>}
	    {{result item descriptor} := @STR:<start>}
	    {{result item descriptor} := @STR:<symbol>}
	    {{result item descriptor} := @STR:<value>}
	    {{result item descriptor} := @STR:<values>}
	    {{signed integer} := integer}
	    {{signed integer} := sign integer}
	    {{single quoted name} := {a single quoted string}}
	    {{single quoted string} := {a single quoted string} {character class modifiers}}
	    {{standard name} := @CLS:<A-Za-z> {zero or more word characters}}
	    {{string close} := @CHR:<'>}
	    {{string open} := @CHR:<'>}
	    {{terminated hash comment} := @CHR:<#> {hash comment body} {vertical space char}}
	    {{unterminated final hash comment} := @CHR:<#> {hash comment body}}
	    {{vertical space char} := {@CLS:<\n-\r\u2028-\u2029>}}
	    {{zero or more word characters} * {@CLS:<_[:alnum:]>}}
	}
    }

    method L0.Semantics {} {
	debug.marpa/slif/parser
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.marpa/slif/parser
	return {
	    action
	    {action name}
	    {adverb item bnf alternative}
	    {adverb item bnf empty}
	    {adverb item bnf quantified}
	    {adverb item default}
	    {adverb item discard}
	    {adverb item discard default}
	    {adverb item lexeme}
	    {adverb item lexeme default}
	    {adverb item match alternative}
	    {adverb item match empty}
	    {adverb item match quantified}
	    {adverb list bnf alternative}
	    {adverb list bnf empty}
	    {adverb list bnf quantified}
	    {adverb list default}
	    {adverb list discard}
	    {adverb list discard default}
	    {adverb list items bnf alternative}
	    {adverb list items bnf empty}
	    {adverb list items bnf quantified}
	    {adverb list items default}
	    {adverb list items discard}
	    {adverb list items discard default}
	    {adverb list items lexeme}
	    {adverb list items lexeme default}
	    {adverb list items match alternative}
	    {adverb list items match empty}
	    {adverb list items match quantified}
	    {adverb list lexeme}
	    {adverb list lexeme default}
	    {adverb list match alternative}
	    {adverb list match empty}
	    {adverb list match quantified}
	    {alternative bnf}
	    {alternative match}
	    {alternative name}
	    {alternatives bnf}
	    {alternatives match}
	    {completion event declaration}
	    {current lexer statement}
	    {default rule}
	    {discard default statement}
	    {discard rule}
	    {empty rule}
	    {event initialization}
	    {event initializer}
	    {event name}
	    {event specification}
	    {group association}
	    {inaccessible statement}
	    {inaccessible treatment}
	    {latm specification}
	    {left association}
	    {lexeme default statement}
	    {lexeme rule}
	    {lexer name}
	    lhs
	    naming
	    {null adverb}
	    {null ranking constant}
	    {null ranking specification}
	    {null statement}
	    {nulled event declaration}
	    {on or off}
	    {parenthesized rhs primary list}
	    {pause specification}
	    {prediction event declaration}
	    {priorities bnf}
	    {priorities match}
	    {priority rule}
	    {priority specification}
	    {proper specification}
	    {quantified rule}
	    quantifier
	    {rank specification}
	    rhs
	    {rhs primary}
	    {rhs primary list}
	    {right association}
	    {separator specification}
	    {single symbol}
	    {start rule}
	    statement
	    {statement group}
	    statements
	    symbol
	    {symbol name}
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.marpa/slif/parser
	return {
	    {__ :A {name values}}
	    {__ :N action/0}
	    {action :M {0 1} @LEX:@STR:<action> @LEX:@STR:<=>> {action name}}
	    {__ :N {action name/2}}
	    {{action name} := {array descriptor}}
	    {__ :N {action name/0}}
	    {{action name} := {Perl name}}
	    {__ :N {action name/1}}
	    {{action name} := {reserved action name}}
	    {__ :N {adverb item bnf alternative/0}}
	    {{adverb item bnf alternative} := action}
	    {__ :N {adverb item bnf alternative/4}}
	    {{adverb item bnf alternative} := naming}
	    {__ :N {adverb item bnf alternative/3}}
	    {{adverb item bnf alternative} := {group association}}
	    {__ :N {adverb item bnf alternative/1}}
	    {{adverb item bnf alternative} := {left association}}
	    {__ :N {adverb item bnf alternative/5}}
	    {{adverb item bnf alternative} := {null adverb}}
	    {__ :N {adverb item bnf alternative/2}}
	    {{adverb item bnf alternative} := {right association}}
	    {__ :N {adverb item bnf empty/0}}
	    {{adverb item bnf empty} := action}
	    {__ :N {adverb item bnf empty/4}}
	    {{adverb item bnf empty} := naming}
	    {__ :N {adverb item bnf empty/3}}
	    {{adverb item bnf empty} := {group association}}
	    {__ :N {adverb item bnf empty/1}}
	    {{adverb item bnf empty} := {left association}}
	    {__ :N {adverb item bnf empty/5}}
	    {{adverb item bnf empty} := {null adverb}}
	    {__ :N {adverb item bnf empty/2}}
	    {{adverb item bnf empty} := {right association}}
	    {__ :N {adverb item bnf quantified/0}}
	    {{adverb item bnf quantified} := action}
	    {__ :N {adverb item bnf quantified/3}}
	    {{adverb item bnf quantified} := naming}
	    {__ :N {adverb item bnf quantified/4}}
	    {{adverb item bnf quantified} := {null adverb}}
	    {__ :N {adverb item bnf quantified/2}}
	    {{adverb item bnf quantified} := {proper specification}}
	    {__ :N {adverb item bnf quantified/1}}
	    {{adverb item bnf quantified} := {separator specification}}
	    {__ :N {adverb item default/0}}
	    {{adverb item default} := action}
	    {__ :N {adverb item default/1}}
	    {{adverb item default} := {null adverb}}
	    {__ :N {adverb item discard/0}}
	    {{adverb item discard} := {event specification}}
	    {__ :N {adverb item discard/1}}
	    {{adverb item discard} := {null adverb}}
	    {__ :N {adverb item discard default/0}}
	    {{adverb item discard default} := {event specification}}
	    {__ :N {adverb item discard default/1}}
	    {{adverb item discard default} := {null adverb}}
	    {__ :N {adverb item lexeme/0}}
	    {{adverb item lexeme} := {event specification}}
	    {__ :N {adverb item lexeme/1}}
	    {{adverb item lexeme} := {latm specification}}
	    {__ :N {adverb item lexeme/4}}
	    {{adverb item lexeme} := {null adverb}}
	    {__ :N {adverb item lexeme/3}}
	    {{adverb item lexeme} := {pause specification}}
	    {__ :N {adverb item lexeme/2}}
	    {{adverb item lexeme} := {priority specification}}
	    {__ :N {adverb item lexeme default/0}}
	    {{adverb item lexeme default} := action}
	    {__ :N {adverb item lexeme default/1}}
	    {{adverb item lexeme default} := {latm specification}}
	    {__ :N {adverb item lexeme default/2}}
	    {{adverb item lexeme default} := {null adverb}}
	    {__ :N {adverb item match alternative/0}}
	    {{adverb item match alternative} := naming}
	    {__ :N {adverb item match alternative/1}}
	    {{adverb item match alternative} := {null adverb}}
	    {__ :N {adverb item match empty/0}}
	    {{adverb item match empty} := naming}
	    {__ :N {adverb item match empty/1}}
	    {{adverb item match empty} := {null adverb}}
	    {__ :N {adverb item match quantified/2}}
	    {{adverb item match quantified} := {null adverb}}
	    {__ :N {adverb item match quantified/1}}
	    {{adverb item match quantified} := {proper specification}}
	    {__ :N {adverb item match quantified/0}}
	    {{adverb item match quantified} := {separator specification}}
	    {__ :N {adverb list bnf alternative/0}}
	    {{adverb list bnf alternative} := {adverb list items bnf alternative}}
	    {__ :N {adverb list bnf empty/0}}
	    {{adverb list bnf empty} := {adverb list items bnf empty}}
	    {__ :N {adverb list bnf quantified/0}}
	    {{adverb list bnf quantified} := {adverb list items bnf quantified}}
	    {__ :N {adverb list default/0}}
	    {{adverb list default} := {adverb list items default}}
	    {__ :N {adverb list discard/0}}
	    {{adverb list discard} := {adverb list items discard}}
	    {__ :N {adverb list discard default/0}}
	    {{adverb list discard default} := {adverb list items discard default}}
	    {__ :N {adverb list items bnf alternative/0}}
	    {{adverb list items bnf alternative} * {adverb item bnf alternative}}
	    {__ :N {adverb list items bnf empty/0}}
	    {{adverb list items bnf empty} * {adverb item bnf empty}}
	    {__ :N {adverb list items bnf quantified/0}}
	    {{adverb list items bnf quantified} * {adverb item bnf quantified}}
	    {__ :N {adverb list items default/0}}
	    {{adverb list items default} * {adverb item default}}
	    {__ :N {adverb list items discard/0}}
	    {{adverb list items discard} * {adverb item discard}}
	    {__ :N {adverb list items discard default/0}}
	    {{adverb list items discard default} * {adverb item discard default}}
	    {__ :N {adverb list items lexeme/0}}
	    {{adverb list items lexeme} * {adverb item lexeme}}
	    {__ :N {adverb list items lexeme default/0}}
	    {{adverb list items lexeme default} * {adverb item lexeme default}}
	    {__ :N {adverb list items match alternative/0}}
	    {{adverb list items match alternative} * {adverb item match alternative}}
	    {__ :N {adverb list items match empty/0}}
	    {{adverb list items match empty} * {adverb item match empty}}
	    {__ :N {adverb list items match quantified/0}}
	    {{adverb list items match quantified} * {adverb item match quantified}}
	    {__ :N {adverb list lexeme/0}}
	    {{adverb list lexeme} := {adverb list items lexeme}}
	    {__ :N {adverb list lexeme default/0}}
	    {{adverb list lexeme default} := {adverb list items lexeme default}}
	    {__ :N {adverb list match alternative/0}}
	    {{adverb list match alternative} := {adverb list items match alternative}}
	    {__ :N {adverb list match empty/0}}
	    {{adverb list match empty} := {adverb list items match empty}}
	    {__ :N {adverb list match quantified/0}}
	    {{adverb list match quantified} := {adverb list items match quantified}}
	    {__ :N {alternative bnf/0}}
	    {{alternative bnf} := rhs {adverb list bnf alternative}}
	    {__ :N {alternative match/0}}
	    {{alternative match} := rhs {adverb list match alternative}}
	    {__ :N {alternative name/1}}
	    {{alternative name} := {single quoted name}}
	    {__ :N {alternative name/0}}
	    {{alternative name} := {standard name}}
	    {__ :N {alternatives bnf/0}}
	    {{alternatives bnf} + {alternative bnf} {op equal priority} 1}
	    {__ :N {alternatives match/0}}
	    {{alternatives match} + {alternative match} {op equal priority} 1}
	    {__ :N {completion event declaration/0}}
	    {{completion event declaration} :M {0 2 3} @LEX:@STR:<event> {event initialization} @LEX:@CHR:<=> @LEX:@STR:<completed> {symbol name}}
	    {__ :N {lexeme rule/1}}
	    {{current lexer statement} :M {0 1 2} @LEX:@STR:<current> @LEX:@STR:<lexer> @LEX:@STR:<is> {lexer name}}
	    {__ :N {default rule/0}}
	    {{default rule} :M {0 1} @LEX:@STR:<:default> {op declare bnf} {adverb list default}}
	    {__ :N {discard default statement/0}}
	    {{discard default statement} :M {0 1 2} @LEX:@STR:<discard> @LEX:@STR:<default> @LEX:@CHR:<=> {adverb list discard default}}
	    {__ :N {discard rule/0}}
	    {{discard rule} :M {0 1} @LEX:@STR:<:discard> {op declare match} symbol {adverb list discard}}
	    {__ :N {discard rule/1}}
	    {{discard rule} :M {0 1} @LEX:@STR:<:discard> {op declare match} {character class} {adverb list discard}}
	    {__ :N {empty rule/0}}
	    {{empty rule} :M 1 lhs {op declare bnf} {adverb list bnf empty}}
	    {__ :N {empty rule/1}}
	    {{empty rule} :M 1 lhs {op declare match} {adverb list match empty}}
	    {__ :N {event initialization/0}}
	    {{event initialization} := {event name} {event initializer}}
	    {__ :N {event initializer/0}}
	    {{event initializer} :M 0 @LEX:@CHR:<=> {on or off}}
	    {__ :N {event initializer/1}}
	    {{event initializer} :=}
	    {__ :N {event name/2}}
	    {{event name} := {reserved event name}}
	    {__ :N {event name/1}}
	    {{event name} := {single quoted name}}
	    {__ :N {event name/0}}
	    {{event name} := {standard name}}
	    {__ :N {event specification/0}}
	    {{event specification} :M {0 1} @LEX:@STR:<event> @LEX:@STR:<=>> {event initialization}}
	    {__ :N {group association/0}}
	    {{group association} :M {0 1 2} @LEX:@STR:<assoc> @LEX:@STR:<=>> @LEX:@STR:<group>}
	    {__ :N {inaccessible statement/0}}
	    {{inaccessible statement} :M {0 1 3 4} @LEX:@STR:<inaccessible> @LEX:@STR:<is> {inaccessible treatment} @LEX:@STR:<by> @LEX:@STR:<default>}
	    {__ :N {inaccessible treatment/2}}
	    {{inaccessible treatment} := @LEX:@STR:<fatal>}
	    {__ :N {inaccessible treatment/1}}
	    {{inaccessible treatment} := @LEX:@STR:<ok>}
	    {__ :N {inaccessible treatment/0}}
	    {{inaccessible treatment} := @LEX:@STR:<warn>}
	    {__ :N {latm specification/0}}
	    {{latm specification} :M {0 1} @LEX:@STR:<forgiving> @LEX:@STR:<=>> boolean}
	    {__ :N {latm specification/1}}
	    {{latm specification} :M {0 1} @LEX:@STR:<latm> @LEX:@STR:<=>> boolean}
	    {__ :N {left association/0}}
	    {{left association} :M {0 1 2} @LEX:@STR:<assoc> @LEX:@STR:<=>> @LEX:@STR:<left>}
	    {__ :N {lexeme default statement/0}}
	    {{lexeme default statement} :M {0 1 2} @LEX:@STR:<lexeme> @LEX:@STR:<default> @LEX:@CHR:<=> {adverb list lexeme default}}
	    {__ :N {lexeme rule/0}}
	    {{lexeme rule} :M {0 1} @LEX:@STR:<:lexeme> {op declare match} symbol {adverb list lexeme}}
	    {__ :N {lexer name/1}}
	    {{lexer name} := {single quoted name}}
	    {__ :N {lexer name/0}}
	    {{lexer name} := {standard name}}
	    {__ :N lhs/0}
	    {lhs := {symbol name}}
	    {__ :N naming/0}
	    {naming :M {0 1} @LEX:@STR:<name> @LEX:@STR:<=>> {alternative name}}
	    {__ :N {null adverb/0}}
	    {{null adverb} := @LEX:@CHR:<,>}
	    {__ :N {null ranking constant/0}}
	    {{null ranking constant} := @LEX:@STR:<high>}
	    {__ :N {null ranking constant/0}}
	    {{null ranking constant} := @LEX:@STR:<low>}
	    {__ :N {null ranking specification/0}}
	    {{null ranking specification} :M {0 1} @LEX:@STR:<null-ranking> @LEX:@STR:<=>> {null ranking constant}}
	    {__ :N {null ranking specification/1}}
	    {{null ranking specification} :M {0 1 2} @LEX:@STR:<null> @LEX:@STR:<rank> @LEX:@STR:<=>> {null ranking constant}}
	    {__ :N {null statement/0}}
	    {{null statement} := {@LEX:@CHR:<\73>}}
	    {__ :N {nulled event declaration/0}}
	    {{nulled event declaration} :M {0 2 3} @LEX:@STR:<event> {event initialization} @LEX:@CHR:<=> @LEX:@STR:<nulled> {symbol name}}
	    {__ :N {on or off/1}}
	    {{on or off} := @LEX:@STR:<off>}
	    {__ :N {on or off/0}}
	    {{on or off} := @LEX:@STR:<on>}
	    {__ :N {parenthesized rhs primary list/0}}
	    {{parenthesized rhs primary list} :M {0 2} {@LEX:@CHR:<\50>} {rhs primary list} {@LEX:@CHR:<\51>}}
	    {__ :N {pause specification/0}}
	    {{pause specification} :M {0 1} @LEX:@STR:<pause> @LEX:@STR:<=>> {before or after}}
	    {__ :N {prediction event declaration/0}}
	    {{prediction event declaration} :M {0 2 3} @LEX:@STR:<event> {event initialization} @LEX:@CHR:<=> @LEX:@STR:<predicted> {symbol name}}
	    {__ :N {priorities bnf/0}}
	    {{priorities bnf} + {alternatives bnf} {op loosen} 1}
	    {__ :N {priorities match/0}}
	    {{priorities match} + {alternatives match} {op loosen} 1}
	    {__ :N {priority rule/0}}
	    {{priority rule} :M 1 lhs {op declare bnf} {priorities bnf}}
	    {__ :N {priority rule/1}}
	    {{priority rule} :M 1 lhs {op declare match} {priorities match}}
	    {__ :N {priority specification/0}}
	    {{priority specification} :M {0 1} @LEX:@STR:<priority> @LEX:@STR:<=>> {signed integer}}
	    {__ :N {proper specification/0}}
	    {{proper specification} :M {0 1} @LEX:@STR:<proper> @LEX:@STR:<=>> boolean}
	    {__ :N {quantified rule/0}}
	    {{quantified rule} :M 1 lhs {op declare bnf} {single symbol} quantifier {adverb list bnf quantified}}
	    {__ :N {quantified rule/1}}
	    {{quantified rule} :M 1 lhs {op declare match} {single symbol} quantifier {adverb list match quantified}}
	    {__ :N quantifier/0}
	    {quantifier := @LEX:@CHR:<*>}
	    {__ :N quantifier/1}
	    {quantifier := @LEX:@CHR:<+>}
	    {__ :N {rank specification/0}}
	    {{rank specification} :M {0 1} @LEX:@STR:<rank> @LEX:@STR:<=>> {signed integer}}
	    {__ :N rhs/0}
	    {rhs + {rhs primary}}
	    {__ :N {rhs primary/2}}
	    {{rhs primary} := {parenthesized rhs primary list}}
	    {__ :N {rhs primary/1}}
	    {{rhs primary} := {single quoted string}}
	    {__ :N {rhs primary/0}}
	    {{rhs primary} := {single symbol}}
	    {__ :N {rhs primary list/0}}
	    {{rhs primary list} + {rhs primary}}
	    {__ :N {right association/0}}
	    {{right association} :M {0 1 2} @LEX:@STR:<assoc> @LEX:@STR:<=>> @LEX:@STR:<right>}
	    {__ :N {separator specification/0}}
	    {{separator specification} :M {0 1} @LEX:@STR:<separator> @LEX:@STR:<=>> {single symbol}}
	    {__ :N {single symbol/0}}
	    {{single symbol} := symbol}
	    {__ :N {single symbol/1}}
	    {{single symbol} := {character class}}
	    {__ :N {start rule/0}}
	    {{start rule} :M {0 1} @LEX:@STR:<:start> {op declare bnf} symbol}
	    {__ :N {start rule/1}}
	    {{start rule} :M {0 1 2} @LEX:@STR:<start> @LEX:@STR:<symbol> @LEX:@STR:<is> symbol}
	    {__ :N statement/11}
	    {statement := {completion event declaration}}
	    {__ :N statement/14}
	    {statement := {current lexer statement}}
	    {__ :N statement/7}
	    {statement := {default rule}}
	    {__ :N statement/9}
	    {statement := {discard default statement}}
	    {__ :N statement/6}
	    {statement := {discard rule}}
	    {__ :N statement/1}
	    {statement := {empty rule}}
	    {__ :N statement/15}
	    {statement := {inaccessible statement}}
	    {__ :N statement/8}
	    {statement := {lexeme default statement}}
	    {__ :N statement/10}
	    {statement := {lexeme rule}}
	    {__ :N statement/2}
	    {statement := {null statement}}
	    {__ :N statement/12}
	    {statement := {nulled event declaration}}
	    {__ :N statement/13}
	    {statement := {prediction event declaration}}
	    {__ :N statement/4}
	    {statement := {priority rule}}
	    {__ :N statement/5}
	    {statement := {quantified rule}}
	    {__ :N statement/0}
	    {statement := {start rule}}
	    {__ :N statement/3}
	    {statement := {statement group}}
	    {__ :N {statement group/0}}
	    {{statement group} :M 0 {@LEX:@CHR:<\173>} statements {@LEX:@CHR:<\175>}}
	    {__ :N statements/0}
	    {statements + statement}
	    {__ :N symbol/0}
	    {symbol := {symbol name}}
	    {__ :N {symbol name/0}}
	    {{symbol name} := {bare name}}
	    {__ :N {symbol name/1}}
	    {{symbol name} := {bracketed name}}
	}
    }

    method Start {} {
	debug.marpa/slif/parser
	# G1 start symbol
	return {statements}
    }
}

# # ## ### ##### ######## #############
return