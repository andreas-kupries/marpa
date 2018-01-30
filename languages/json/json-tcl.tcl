# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar json::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "json::parser::tcl".
##	Generated On Tue Jan 30 15:23:20 PST 2018
##		  By aku@hephaistos
##		 Via marpa-gen

package provide json::parser::tcl 1

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
	    @CHR:<b>        b
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
	    @CLS:<Ee>                      {[Ee]}
	    @RAN:<09>                      {[0-9]}
	    @RAN:<19>                      {[1-9]}
	    {@^CLS:<\42\134[:control:]>}   {[^\0-\37\42\134\177-\u009f\u00ad\u0600-\u0605\u061c\u06dd\u070f\u08e2\u180e\u200b-\u200f\u202a-\u202e\u2060-\u2064\u2066-\u206f\ue000-\uf8ff\ufeff\ufff9-\ufffb]}
	    {@CLS:<\10\42/bfnrt>}          {[\10\42/bfnrt]}
	    {@NCC:<[:space:]>}             {[[:space:]]}
	    {@NCC:<[:xdigit:]>}            {[[:xdigit:]]}
	}
    }
    
    method Lexemes {} {
	debug.json/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    colon      1
	    comma      1
	    false      1
	    lbrace     1
	    lbracket   1
	    null       1
	    number     1
	    rbrace     1
	    rbracket   1
	    string     1
	    true       1
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
	    {@STR:<\134b>}
	    {@STR:<\134u>}
	    @STR:<false>
	    @STR:<null>
	    @STR:<true>
	    char
	    chars
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
	    quote
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
	    {char := {@STR:<\134b>} {@CLS:<\10\42/bfnrt>}}
	    {char := {@STR:<\134u>} hex hex hex hex}
	    {chars * char}
	    {colon := @CHR:<:>}
	    {comma := @CHR:<,>}
	    {decimal := @RAN:<09>}
	    {digits + decimal}
	    {digitz * decimal}
	    {e := @CLS:<Ee>}
	    {e := @CLS:<Ee> @CHR:<+>}
	    {e := @CLS:<Ee> @CHR:<->}
	    {exponent := e digits}
	    {false := @STR:<false>}
	    {fraction := @CHR:<.> digits}
	    {hex := {@NCC:<[:xdigit:]>}}
	    {int := @CHR:<-> whole}
	    {int := whole}
	    {lbrace := {@CHR:<\173>}}
	    {lbracket := {@CHR:<\133>}}
	    {null := @STR:<null>}
	    {number := int}
	    {number := int exponent}
	    {number := int fraction}
	    {number := int fraction exponent}
	    {plain := {@^CLS:<\42\134[:control:]>}}
	    {positive := @RAN:<19> digitz}
	    {quote := {@CHR:<\42>}}
	    {rbrace := {@CHR:<\175>}}
	    {rbracket := {@CHR:<\135>}}
	    {string := quote chars quote}
	    {true := @STR:<true>}
	    {whitespace + {@NCC:<[:space:]>}}
	    {whole := @CHR:<0>}
	    {whole := positive}
	    {{@STR:<\134b>} := {@CHR:<\134>} @CHR:<b>}
	    {{@STR:<\134u>} := {@CHR:<\134>} @CHR:<u>}
	}
    }

    method L0.Semantics {} {
	debug.json/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.json/parser/tcl
	return {
	    array
	    element
	    elements
	    object
	    pair
	    pairs
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
	    {object :M {0 2} lbrace pairs rbrace}
	    {pair :M 1 string colon value}
	    {pairs * pair comma 1}
	    {value := array}
	    {value := false}
	    {value := null}
	    {value := number}
	    {value := object}
	    {value := string}
	    {value := true}
	}
    }

    method Start {} {
	debug.json/parser/tcl
	# G1 start symbol
	return {value}
    }
}

# # ## ### ##### ######## #############
return