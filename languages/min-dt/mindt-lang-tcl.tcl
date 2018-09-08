# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar mindt::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "mindt::parser::tcl".
##	Generated On Sat Sep 08 15:04:25 PDT 2018
##		  By aku@hephaistos
##		 Via remeta

package provide mindt::parser::tcl 0

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define mindt/parser/tcl
debug prefix mindt/parser/tcl {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create mindt::parser::tcl {
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
	debug.mindt/parser/tcl
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<c>        c
	    @CHR:<d>        d
	    @CHR:<e>        e
	    @CHR:<g>        g
	    @CHR:<i>        i
	    @CHR:<l>        l
	    @CHR:<m>        m
	    @CHR:<n>        n
	    @CHR:<o>        o
	    @CHR:<r>        r
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
	debug.mindt/parser/tcl
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
	debug.mindt/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    Braced     1
	    CDone      1
	    CInclude   1
	    Cl         1
	    CStrong    1
	    CVdef      1
	    CVref      1
	    Quote      1
	    Simple     1
	    Space      1
	}
    }

    method Discards {} {
	debug.mindt/parser/tcl
	# Discarded symbols (whitespace)
	return {
	    Whitespace
	}
    }

    method Events {} {
	debug.mindt/parser/tcl
	# Map declared events to their initial activation status
	# :: dict (event name -> active)
	return {
	    macro   on
	}
    }

    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.mindt/parser/tcl
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
	    @STR:<strong>
	    @STR:<vset>
	    ANY_UNBRACED
	    BL
	    BR
	    BRACE_ESCAPED
	    BRACED
	    BRACED_ELEM
	    BRACED_ELEMS
	    C_STRONG
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
	    VAR_DEF
	    VAR_REF
	    WHITE
	    WHITE0
	    WHITE1
	    Whitespace
	    WORD
	    WORDS1
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.mindt/parser/tcl
	return {
	    {@STR:<comment> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {@STR:<include> := @CHR:<i> @CHR:<n> @CHR:<c> @CHR:<l> @CHR:<u> @CHR:<d> @CHR:<e>}
	    {@STR:<strong> := @CHR:<s> @CHR:<t> @CHR:<r> @CHR:<o> @CHR:<n> @CHR:<g>}
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
	    {C_STRONG := @STR:<strong>}
	    {CDone := CR}
	    {CInclude := INCLUDE}
	    {Cl := CL}
	    {CL := {@CHR:<\133>}}
	    {COMMAND := CL WHITE0 WORDS1 WHITE0 CR}
	    {COMMENT := CL WHITE0 @STR:<comment> WHITE1 WORD WHITE0 CR}
	    {CONTINUATION := SPACE0 {@CHR:<\134>} NEWLINE SPACE0}
	    {CR := {@CHR:<\135>}}
	    {CStrong := C_STRONG}
	    {CVdef := VAR_DEF}
	    {CVref := VAR_REF}
	    {INCLUDE := CL WHITE0 @STR:<include> WHITE1 WORD WHITE0 CR}
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
	    {UNQUOTED + UNQUOTED_ELEM}
	    {UNQUOTED_ELEM := COMMAND}
	    {UNQUOTED_ELEM := NO_CFS1}
	    {VAR_DEF := CL WHITE0 @STR:<vset> WHITE1 WORD WHITE1 WORD WHITE0 CR}
	    {VAR_REF := CL WHITE0 @STR:<vset> WHITE1 WORD WHITE0 CR}
	    {WHITE := COMMENT}
	    {WHITE := CONTINUATION}
	    {WHITE := SPACE1}
	    {WHITE0 * WHITE}
	    {WHITE1 + WHITE}
	    {Whitespace := WHITE1}
	    {WORD := BRACED}
	    {WORD := QUOTED}
	    {WORD := UNQUOTED}
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
	debug.mindt/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method L0.Trigger {} {
	debug.mindt/parser/tcl
	# L0 trigger definitions (pre-, post-lexeme, discard)
	# :: dict (symbol -> (type -> list (event name)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {
	    CInclude {
	        after   macro
	    }
	    CVdef {
	        after   macro
	    }
	    CVref {
	        after   macro
	    }
	}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.mindt/parser/tcl
	return {
	    braced
	    g_text
	    include
	    markup
	    quote
	    quoted
	    quoted_elem
	    quoted_elems
	    simple
	    space
	    strong
	    tclword
	    unquoted
	    unquoted_elem
	    unquoted_elems
	    unquoted_leader
	    vdef
	    vref
	    word
	    words
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.mindt/parser/tcl
	return {
	    {__ :A {name values}}
	    {braced := Braced}
	    {g_text := quote}
	    {g_text := simple}
	    {include := CInclude}
	    {markup := include}
	    {markup := strong}
	    {markup := vdef}
	    {markup := vref}
	    {quote := Quote}
	    {quoted :M {0 2} Quote quoted_elems Quote}
	    {quoted_elem := markup}
	    {quoted_elem := simple}
	    {quoted_elem := space}
	    {quoted_elems * quoted_elem}
	    {simple := Simple}
	    {space := Space}
	    {strong :M {0 1 3} Cl CStrong tclword CDone}
	    {tclword := braced}
	    {tclword := quoted}
	    {tclword := unquoted}
	    {unquoted := unquoted_leader unquoted_elems}
	    {unquoted_elem := markup}
	    {unquoted_elem := quote}
	    {unquoted_elem := simple}
	    {unquoted_elems * unquoted_elem}
	    {unquoted_leader := markup}
	    {unquoted_leader := simple}
	    {vdef := CVdef}
	    {vref := CVref}
	    {word := g_text}
	    {word := markup}
	    {words * word}
	}
    }

    method G1.Trigger {} {
	debug.mindt/parser/tcl
	# G1 parse event definitions (predicted, nulled, completed)
	# :: dict (symbol -> (type -> list (event name)))
	# Each symbol can have more than one event per type.
	return {}
    }

    method Start {} {
	debug.mindt/parser/tcl
	# G1 start symbol
	return {words}
    }
}

# # ## ### ##### ######## #############
return