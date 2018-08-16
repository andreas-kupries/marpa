# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar mindt::parser::sf::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "mindt::parser::sf::tcl".
##	Generated On Wed Aug 15 21:14:06 PDT 2018
##		  By aku@hephaistos
##		 Via marpa-gen

package provide mindt::parser::sf::tcl 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define mindt/parser/sf/tcl
debug prefix mindt/parser/sf/tcl {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create mindt::parser::sf::tcl {
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
	debug.mindt/parser/sf/tcl
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<c>        c
	    @CHR:<d>        d
	    @CHR:<e>        e
	    @CHR:<i>        i
	    @CHR:<l>        l
	    @CHR:<m>        m
	    @CHR:<n>        n
	    @CHR:<o>        o
	    @CHR:<s>        s
	    @CHR:<t>        t
	    @CHR:<u>        u
	    @CHR:<v>        v
	    {@CHR:<\42>}    \42
	    {@CHR:<\133>}   \133
	    {@CHR:<\134>}   \134
	    {@CHR:<\135>}   \135
	    {@CHR:<\173>}   \173
	    {@CHR:<\175>}   \175
	    {@CHR:<\n>}     \n
	    {@CHR:<\r>}     \r
	}
    }

    method Classes {} {
	debug.mindt/parser/sf/tcl
	# Literals: The character classes in use
	return {
	    {@^CLS:<\173\175>.BMP}              {[^\173\175]}
	    {@^CLS:<\t-\r\40\42\133\135>.BMP}   {[^\t-\r\40\42\133\135]}
	    {@^CLS:<\t-\r\40\133\135>.BMP}      {[^\t-\r\40\133\135]}
	    {@CLS:<\n\r>}                       {[\n\r]}
	    {@CLS:<\t-\r\40>}                   {[\t-\r\40]}
	    {@RAN:<\ud800\udbff>}               {[\ud800-\udbff]}
	    {@RAN:<\udc00\udfff>}               {[\udc00-\udfff]}
	}
    }

    method Lexemes {} {
	debug.mindt/parser/sf/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    Braced    1
	    Include   1
	    Quote     1
	    Simple    1
	    Space     1
	    Start     1
	    Stop      1
	    Vset      1
	    White     1
	    Word      1
	}
    }

    method Discards {} {
	debug.mindt/parser/sf/tcl
	# Discarded symbols (whitespace)
	return {
	    
	}
    }

    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.mindt/parser/sf/tcl
	return {
	    {@^CLS:<\173\175>}
	    {@^CLS:<\t-\r\40\42\133\135>}
	    {@^CLS:<\t-\r\40\133\135>}
	    {@CLS:<\u10000-\u10ffff>.SMP}
	    {@STR:<\134\173>}
	    {@STR:<\134\175>}
	    {@STR:<\r\n>}
	    @STR:<comment>
	    @STR:<include>
	    @STR:<vset>
	    ANY_UNBRACED
	    BL
	    BR
	    BRACE_ESCAPED
	    BRACED
	    BRACED_ELEM
	    BRACED_ELEMS
	    CL
	    COMMAND
	    COMMENT
	    CONTINUATION
	    CR
	    INCLUDE
	    NEWLINE
	    NO_CFS1
	    NO_CFS_QUOTE
	    NO_CMD_FMT_SPACE
	    QUOTE
	    QUOTED
	    QUOTED_ELEM
	    QUOTED_ELEMS
	    SIMPLE
	    SPACE
	    SPACE0
	    SPACE1
	    UNQUOTED
	    UNQUOTED_ELEM
	    VSET
	    WHITE
	    WHITE0
	    WHITE1
	    WORD
	    WORDS1
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.mindt/parser/sf/tcl
	return {
	    {@STR:<comment> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {@STR:<include> := @CHR:<i> @CHR:<n> @CHR:<c> @CHR:<l> @CHR:<u> @CHR:<d> @CHR:<e>}
	    {@STR:<vset> := @CHR:<v> @CHR:<s> @CHR:<e> @CHR:<t>}
	    {ANY_UNBRACED := {@^CLS:<\173\175>}}
	    {BL := {@CHR:<\173>}}
	    {BR := {@CHR:<\175>}}
	    {BRACE_ESCAPED := {@STR:<\134\173>}}
	    {BRACE_ESCAPED := {@STR:<\134\175>}}
	    {BRACED := BL BRACED_ELEMS BR}
	    {Braced := BRACED}
	    {BRACED_ELEM := ANY_UNBRACED}
	    {BRACED_ELEM := BRACE_ESCAPED}
	    {BRACED_ELEM := BRACED}
	    {BRACED_ELEMS * BRACED_ELEM}
	    {CL := {@CHR:<\133>}}
	    {COMMAND := CL WHITE0 WORDS1 WHITE0 CR}
	    {COMMENT := CL WHITE0 @STR:<comment> WHITE1 WORD WHITE0 CR}
	    {CONTINUATION := SPACE0 {@CHR:<\134>} NEWLINE SPACE0}
	    {CR := {@CHR:<\135>}}
	    {INCLUDE := @STR:<include>}
	    {Include := INCLUDE}
	    {NEWLINE := {@CLS:<\n\r>}}
	    {NEWLINE := {@STR:<\r\n>}}
	    {NO_CFS1 + NO_CMD_FMT_SPACE}
	    {NO_CFS_QUOTE := {@^CLS:<\t-\r\40\42\133\135>}}
	    {NO_CMD_FMT_SPACE := {@^CLS:<\t-\r\40\133\135>}}
	    {Quote := QUOTE}
	    {QUOTE := {@CHR:<\42>}}
	    {QUOTED := QUOTE QUOTED_ELEMS QUOTE}
	    {QUOTED_ELEM := COMMAND}
	    {QUOTED_ELEM := SIMPLE}
	    {QUOTED_ELEM := SPACE1}
	    {QUOTED_ELEMS * QUOTED_ELEM}
	    {SIMPLE + NO_CFS_QUOTE}
	    {Simple := SIMPLE}
	    {Space := SPACE1}
	    {SPACE := {@CLS:<\t-\r\40>}}
	    {SPACE0 * SPACE}
	    {SPACE1 + SPACE}
	    {Start := CL}
	    {Stop := CR}
	    {UNQUOTED + UNQUOTED_ELEM}
	    {UNQUOTED_ELEM := COMMAND}
	    {UNQUOTED_ELEM := NO_CFS1}
	    {VSET := @STR:<vset>}
	    {Vset := VSET}
	    {WHITE := COMMENT}
	    {WHITE := CONTINUATION}
	    {WHITE := SPACE1}
	    {White := WHITE1}
	    {WHITE0 * WHITE}
	    {WHITE1 + WHITE}
	    {WORD := BRACED}
	    {WORD := QUOTED}
	    {WORD := UNQUOTED}
	    {Word := WORD}
	    {WORDS1 + WORD WHITE1 0}
	    {{@^CLS:<\173\175>} := {@^CLS:<\173\175>.BMP}}
	    {{@^CLS:<\173\175>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\t-\r\40\42\133\135>} := {@^CLS:<\t-\r\40\42\133\135>.BMP}}
	    {{@^CLS:<\t-\r\40\42\133\135>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\t-\r\40\133\135>} := {@^CLS:<\t-\r\40\133\135>.BMP}}
	    {{@^CLS:<\t-\r\40\133\135>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@CLS:<\u10000-\u10ffff>.SMP} := {@RAN:<\ud800\udbff>} {@RAN:<\udc00\udfff>}}
	    {{@STR:<\134\173>} := {@CHR:<\134>} {@CHR:<\173>}}
	    {{@STR:<\134\175>} := {@CHR:<\134>} {@CHR:<\175>}}
	    {{@STR:<\r\n>} := {@CHR:<\r>} {@CHR:<\n>}}
	}
    }

    method L0.Semantics {} {
	debug.mindt/parser/sf/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method L0.Events {} {
	debug.mindt/parser/sf/tcl
	# L0 parse event definitions (pre-, post-lexeme, discard)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.mindt/parser/sf/tcl
	return {
	    braced
	    form
	    include
	    path
	    q_elem
	    q_list
	    quote
	    quoted
	    recurse
	    simple
	    space
	    unquot
	    uq_elem
	    uq_lead
	    uq_list
	    value
	    var_def
	    var_ref
	    varname
	    vars
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.mindt/parser/sf/tcl
	return {
	    {__ :A {name values}}
	    {braced := Braced}
	    {__ :A Afirst}
	    {form := include}
	    {form := vars}
	    {__ :A {name values}}
	    {include :M {0 1 2 4} Start Include White path Stop}
	    {include :M {0 1 2 4 5} Start Include White path White Stop}
	    {include :M {0 1 2 3 5} Start White Include White path Stop}
	    {include :M {0 1 2 3 5 6} Start White Include White path White Stop}
	    {__ :A Afirst}
	    {path := recurse}
	    {q_elem := simple}
	    {q_elem := space}
	    {q_elem := vars}
	    {__ :A {name values}}
	    {q_list * q_elem}
	    {quote := Quote}
	    {__ :A Afirst}
	    {quoted :M {0 2} Quote q_list Quote}
	    {recurse := braced}
	    {recurse := quoted}
	    {recurse := unquot}
	    {__ :A {name values}}
	    {simple := Simple}
	    {space := Space}
	    {unquot := uq_lead uq_list}
	    {__ :A Afirst}
	    {uq_elem := quote}
	    {uq_elem := uq_lead}
	    {uq_lead := simple}
	    {uq_lead := vars}
	    {__ :A {name values}}
	    {uq_list * uq_elem}
	    {__ :A Afirst}
	    {value := Word}
	    {__ :A {name values}}
	    {var_def :M {0 1 2 4 6} Start Vset White varname White value Stop}
	    {var_def :M {0 1 2 4 6 7} Start Vset White varname White value White Stop}
	    {var_def :M {0 1 2 3 5 7} Start White Vset White varname White value Stop}
	    {var_def :M {0 1 2 3 5 7 8} Start White Vset White varname White value White Stop}
	    {var_ref :M {0 1 2 4} Start Vset White varname Stop}
	    {var_ref :M {0 1 2 4 5} Start Vset White varname White Stop}
	    {var_ref :M {0 1 2 3 5} Start White Vset White varname Stop}
	    {var_ref :M {0 1 2 3 5 6} Start White Vset White varname White Stop}
	    {__ :A Afirst}
	    {varname := recurse}
	    {vars := var_def}
	    {vars := var_ref}
	}
    }

    method G1.Events {} {
	debug.mindt/parser/sf/tcl
	# G1 parse event definitions (predicted, nulled, completed)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Each symbol can have more than one event per type.
	return {}
    }

    method Start {} {
	debug.mindt/parser/sf/tcl
	# G1 start symbol
	return {form}
    }
}

# # ## ### ##### ######## #############
return