# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar json::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "json::parser::tcl".
##	Generated On Fri Sep 07 20:57:56 PDT 2018
##		  By aku@hephaistos
##		 Via remeta

package provide json::parser::tcl 0

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define json/parser/tcl
debug prefix json/parser/tcl {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create json::parser::tcl {
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
	debug.json/parser/tcl
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<+>        +
	    @CHR:<,>        ,
	    @CHR:<->        -
	    @CHR:<.>        .
	    @CHR:<0>        0
	    @CHR:<:>        :
	    @CHR:<a>        a
	    @CHR:<e>        e
	    @CHR:<f>        f
	    @CHR:<l>        l
	    @CHR:<n>        n
	    @CHR:<r>        r
	    @CHR:<s>        s
	    @CHR:<t>        t
	    @CHR:<u>        u
	    {@CHR:<\42>}    \42
	    {@CHR:<\133>}   \133
	    {@CHR:<\134>}   \134
	    {@CHR:<\135>}   \135
	    {@CHR:<\173>}   \173
	    {@CHR:<\175>}   \175
	}
    }

    method Classes {} {
	debug.json/parser/tcl
	# Literals: The character classes in use
	return {
	    @CLS:<Ee>                     {[Ee]}
	    @RAN:<09>                     {[0-9]}
	    @RAN:<19>                     {[1-9]}
	    {@^CLS:<\0-\37\42\134>.BMP}   {[^\0-\37\42\134]}
	    {@CLS:<\42/\134bfnrt>}        {[\42/\134bfnrt]}
	    {@CLS:<\t-\n\r\40>}           {[\t\n\r\40]}
	    {@NCC:<[:xdigit:]>}           {[[:xdigit:]]}
	    {@RAN:<\ud800\udbff>}         {[\ud800-\udbff]}
	    {@RAN:<\udc00\udfff>}         {[\udc00-\udfff]}
	}
    }

    method Lexemes {} {
	debug.json/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    colon      1
	    comma      1
	    lbrace     1
	    lbracket   1
	    lfalse     1
	    lnull      1
	    lnumber    1
	    lstring    1
	    ltrue      1
	    quote      1
	    rbrace     1
	    rbracket   1
	}
    }

    method Discards {} {
	debug.json/parser/tcl
	# Discarded symbols (whitespace)
	return {
	    whitespace
	}
    }

    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.json/parser/tcl
	return {
	    {@^CLS:<\0-\37\42\134>}
	    {@CLS:<\u10000-\u10ffff>.SMP}
	    {@STR:<\134u>}
	    @STR:<false>
	    @STR:<null>
	    @STR:<true>
	    char
	    decimal
	    digits
	    digitz
	    e
	    exponent
	    fraction
	    hex
	    int
	    plain
	    positive
	    whitespace
	    whole
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.json/parser/tcl
	return {
	    {@STR:<false> := @CHR:<f> @CHR:<a> @CHR:<l> @CHR:<s> @CHR:<e>}
	    {@STR:<null> := @CHR:<n> @CHR:<u> @CHR:<l> @CHR:<l>}
	    {@STR:<true> := @CHR:<t> @CHR:<r> @CHR:<u> @CHR:<e>}
	    {char := plain}
	    {char := {@CHR:<\134>} {@CLS:<\42/\134bfnrt>}}
	    {char := {@STR:<\134u>} hex hex hex hex}
	    {colon := @CHR:<:>}
	    {comma := @CHR:<,>}
	    {decimal := @RAN:<09>}
	    {digits + decimal}
	    {digitz * decimal}
	    {e := @CLS:<Ee>}
	    {e := @CLS:<Ee> @CHR:<+>}
	    {e := @CLS:<Ee> @CHR:<->}
	    {exponent := e digits}
	    {fraction := @CHR:<.> digits}
	    {hex := {@NCC:<[:xdigit:]>}}
	    {int := @CHR:<-> whole}
	    {int := whole}
	    {lbrace := {@CHR:<\173>}}
	    {lbracket := {@CHR:<\133>}}
	    {lfalse := @STR:<false>}
	    {lnull := @STR:<null>}
	    {lnumber := int}
	    {lnumber := int exponent}
	    {lnumber := int fraction}
	    {lnumber := int fraction exponent}
	    {lstring * char}
	    {ltrue := @STR:<true>}
	    {plain := {@^CLS:<\0-\37\42\134>}}
	    {positive := @RAN:<19> digitz}
	    {quote := {@CHR:<\42>}}
	    {rbrace := {@CHR:<\175>}}
	    {rbracket := {@CHR:<\135>}}
	    {whitespace + {@CLS:<\t-\n\r\40>}}
	    {whole := @CHR:<0>}
	    {whole := positive}
	    {{@^CLS:<\0-\37\42\134>} := {@^CLS:<\0-\37\42\134>.BMP}}
	    {{@^CLS:<\0-\37\42\134>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@CLS:<\u10000-\u10ffff>.SMP} := {@RAN:<\ud800\udbff>} {@RAN:<\udc00\udfff>}}
	    {{@STR:<\134u>} := {@CHR:<\134>} @CHR:<u>}
	}
    }

    method L0.Semantics {} {
	debug.json/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method L0.Events {} {
	debug.json/parser/tcl
	# L0 parse event definitions (pre-, post-lexeme, discard)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.json/parser/tcl
	return {
	    array
	    element
	    elements
	    false
	    null
	    number
	    object
	    pair
	    pairs
	    string
	    true
	    value
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.json/parser/tcl
	return {
	    {__ :A {name values}}
	    {array :M {0 2} lbracket elements rbracket}
	    {element := value}
	    {elements * element comma 1}
	    {false := lfalse}
	    {null := lnull}
	    {number := lnumber}
	    {object :M {0 2} lbrace pairs rbrace}
	    {pair :M 1 string colon value}
	    {pairs * pair comma 1}
	    {string :M {0 2} quote lstring quote}
	    {true := ltrue}
	    {value := array}
	    {value := false}
	    {value := null}
	    {value := number}
	    {value := object}
	    {value := string}
	    {value := true}
	}
    }

    method G1.Events {} {
	debug.json/parser/tcl
	# G1 parse event definitions (predicted, nulled, completed)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Each symbol can have more than one event per type.
	return {}
    }

    method Start {} {
	debug.json/parser/tcl
	# G1 start symbol
	return {value}
    }
}

# # ## ### ##### ######## #############
return