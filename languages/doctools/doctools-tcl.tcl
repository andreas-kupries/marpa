# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017 Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                     http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar doctools::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "doctools::parser::tcl".
##	Generated On Sat Mar 24 21:59:30 PDT 2018
##		  By aku@hephaistos
##		 Via marpa-gen

package provide doctools::parser::tcl 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5             ;# -- Foundation
package require TclOO               ;# -- Implies Tcl 8.5 requirement.
package require debug               ;# Tracing
package require debug::caller       ;# Tracing
package require marpa::runtime::tcl ;# Engine

# # ## ### ##### ######## #############

debug define doctools/parser/tcl
debug prefix doctools/parser/tcl {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create doctools::parser::tcl {
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
	debug.doctools/parser/tcl
	# Literals: The directly referenced (allowed) characters.
	return {
	    @CHR:<->        -
	    @CHR:<_>        _
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
	    @CHR:<q>        q
	    @CHR:<r>        r
	    @CHR:<s>        s
	    @CHR:<t>        t
	    @CHR:<u>        u
	    @CHR:<v>        v
	    @CHR:<w>        w
	    @CHR:<x>        x
	    @CHR:<y>        y
	    @CHR:<z>        z
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
	debug.doctools/parser/tcl
	# Literals: The character classes in use
	return {
	    {@^CLS:<\42\133\135\173\175>.BMP}            {[^\42\133\135\173\175]}
	    {@^CLS:<\42\133\135\173\175[:space:]>.BMP}   {[^\42\133\135\173\175[:space:]]}
	    {@^CLS:<\133\135[:space:]>.BMP}              {[^\133\135[:space:]]}
	    {@^CLS:<\173\175>.BMP}                       {[^\173\175]}
	    {@^CLS:<\t-\r\133\135>.BMP}                  {[^\t-\r\133\135]}
	    {@CLS:<\n\r>}                                {[\n\r]}
	    {@NCC:<[:space:]>}                           {[[:space:]]}
	    {@RAN:<\ud800\udbff>}                        {[\ud800-\udbff]}
	    {@RAN:<\udc00\udfff>}                        {[\udc00-\udfff]}
	}
    }
    
    method Lexemes {} {
	debug.doctools/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    BracedWord                            1
	    C_closer                              1
	    Escaped                               1
	    GeneralText                           1
	    SimpleWord                            1
	    SimpleWordPlusSpace                   1
	    SpacePlus                             1
	    {@LEX:@CHR:<\42>}                     1
	    {@LEX:@STR:<\133arg>}                 1
	    {@LEX:@STR:<\133arg_def>}             1
	    {@LEX:@STR:<\133call>}                1
	    {@LEX:@STR:<\133category>}            1
	    {@LEX:@STR:<\133class>}               1
	    {@LEX:@STR:<\133cmd>}                 1
	    {@LEX:@STR:<\133cmd_def>}             1
	    {@LEX:@STR:<\133const>}               1
	    {@LEX:@STR:<\133copyright>}           1
	    {@LEX:@STR:<\133def>}                 1
	    {@LEX:@STR:<\133description\135>}     1
	    {@LEX:@STR:<\133emph>}                1
	    {@LEX:@STR:<\133enum\135>}            1
	    {@LEX:@STR:<\133example>}             1
	    {@LEX:@STR:<\133example_begin\135>}   1
	    {@LEX:@STR:<\133example_end\135>}     1
	    {@LEX:@STR:<\133file>}                1
	    {@LEX:@STR:<\133fun>}                 1
	    {@LEX:@STR:<\133image>}               1
	    {@LEX:@STR:<\133include>}             1
	    {@LEX:@STR:<\133item\135>}            1
	    {@LEX:@STR:<\133keywords>}            1
	    {@LEX:@STR:<\133lb\135>}              1
	    {@LEX:@STR:<\133list_begin>}          1
	    {@LEX:@STR:<\133list_end\135>}        1
	    {@LEX:@STR:<\133manpage_begin>}       1
	    {@LEX:@STR:<\133manpage_end\135>}     1
	    {@LEX:@STR:<\133method>}              1
	    {@LEX:@STR:<\133moddesc>}             1
	    {@LEX:@STR:<\133namespace>}           1
	    {@LEX:@STR:<\133nl\135>}              1
	    {@LEX:@STR:<\133opt>}                 1
	    {@LEX:@STR:<\133opt_def>}             1
	    {@LEX:@STR:<\133option>}              1
	    {@LEX:@STR:<\133package>}             1
	    {@LEX:@STR:<\133para\135>}            1
	    {@LEX:@STR:<\133rb\135>}              1
	    {@LEX:@STR:<\133require>}             1
	    {@LEX:@STR:<\133section>}             1
	    {@LEX:@STR:<\133sectref-external>}    1
	    {@LEX:@STR:<\133sectref>}             1
	    {@LEX:@STR:<\133see_also>}            1
	    {@LEX:@STR:<\133strong>}              1
	    {@LEX:@STR:<\133subsection>}          1
	    {@LEX:@STR:<\133syscmd>}              1
	    {@LEX:@STR:<\133term>}                1
	    {@LEX:@STR:<\133titledesc>}           1
	    {@LEX:@STR:<\133tkoption_def>}        1
	    {@LEX:@STR:<\133type>}                1
	    {@LEX:@STR:<\133uri>}                 1
	    {@LEX:@STR:<\133usage>}               1
	    {@LEX:@STR:<\133var>}                 1
	    {@LEX:@STR:<\133vset>}                1
	    {@LEX:@STR:<\133widget>}              1
	    {@LEX:@STR:<arguments\135>}           1
	    {@LEX:@STR:<commands\135>}            1
	    {@LEX:@STR:<definitions\135>}         1
	    {@LEX:@STR:<enumerated\135>}          1
	    {@LEX:@STR:<itemized\135>}            1
	    {@LEX:@STR:<options\135>}             1
	    {@LEX:@STR:<tkoptions\135>}           1
	}
    }
    
    method Discards {} {
	debug.doctools/parser/tcl
	# Discarded symbols (whitespace)
	return {
	    Whitespace
	}
    }
    
    method L0.Symbols {} {
	# Non-lexeme, non-literal symbols
	debug.doctools/parser/tcl
	return {
	    {@^CLS:<\42\133\135\173\175>}
	    {@^CLS:<\42\133\135\173\175[:space:]>}
	    {@^CLS:<\133\135[:space:]>}
	    {@^CLS:<\173\175>}
	    {@^CLS:<\t-\r\133\135>}
	    {@CLS:<\u10000-\u10ffff>.SMP}
	    {@STR:<\133arg>}
	    {@STR:<\133arg_def>}
	    {@STR:<\133call>}
	    {@STR:<\133category>}
	    {@STR:<\133class>}
	    {@STR:<\133cmd>}
	    {@STR:<\133cmd_def>}
	    {@STR:<\133comment>}
	    {@STR:<\133const>}
	    {@STR:<\133copyright>}
	    {@STR:<\133def>}
	    {@STR:<\133description\135>}
	    {@STR:<\133emph>}
	    {@STR:<\133enum\135>}
	    {@STR:<\133example>}
	    {@STR:<\133example_begin\135>}
	    {@STR:<\133example_end\135>}
	    {@STR:<\133file>}
	    {@STR:<\133fun>}
	    {@STR:<\133image>}
	    {@STR:<\133include>}
	    {@STR:<\133item\135>}
	    {@STR:<\133keywords>}
	    {@STR:<\133lb\135>}
	    {@STR:<\133list_begin>}
	    {@STR:<\133list_end\135>}
	    {@STR:<\133manpage_begin>}
	    {@STR:<\133manpage_end\135>}
	    {@STR:<\133method>}
	    {@STR:<\133moddesc>}
	    {@STR:<\133namespace>}
	    {@STR:<\133nl\135>}
	    {@STR:<\133opt>}
	    {@STR:<\133opt_def>}
	    {@STR:<\133option>}
	    {@STR:<\133package>}
	    {@STR:<\133para\135>}
	    {@STR:<\133rb\135>}
	    {@STR:<\133require>}
	    {@STR:<\133section>}
	    {@STR:<\133sectref-external>}
	    {@STR:<\133sectref>}
	    {@STR:<\133see_also>}
	    {@STR:<\133strong>}
	    {@STR:<\133subsection>}
	    {@STR:<\133syscmd>}
	    {@STR:<\133term>}
	    {@STR:<\133titledesc>}
	    {@STR:<\133tkoption_def>}
	    {@STR:<\133type>}
	    {@STR:<\133uri>}
	    {@STR:<\133usage>}
	    {@STR:<\133var>}
	    {@STR:<\133vset>}
	    {@STR:<\133widget>}
	    {@STR:<\134\42>}
	    {@STR:<\134\133>}
	    {@STR:<\134\135>}
	    {@STR:<\134\173>}
	    {@STR:<\134\175>}
	    {@STR:<\r\n>}
	    {@STR:<arguments\135>}
	    {@STR:<commands\135>}
	    {@STR:<definitions\135>}
	    {@STR:<enumerated\135>}
	    {@STR:<itemized\135>}
	    {@STR:<options\135>}
	    {@STR:<tkoptions\135>}
	    ANY_UNBRACED
	    BRACE_ESCAPED
	    BRACED_ELEMENT
	    BRACED_ELEMENTS
	    BRACED_WORD
	    C_CLOSER
	    COMMENT
	    CONTINUATION
	    CX_ARG
	    ESCAPED
	    GT_LIMITER
	    GT_MIDDLE
	    NEWLINE
	    QUOTED_ELEMENT
	    QUOTED_ELEMENTS
	    QUOTED_WORD
	    SIMPLE_ELEMENT
	    SIMPLE_ELEMENT_PLUS_SPACE
	    SIMPLE_WORD
	    SPACE_NULL
	    SPACE_PLUS
	    Whitespace
	}
    }

    method L0.Rules {} {
	# Rules for all symbols but the literals
	debug.doctools/parser/tcl
	return {
	    {ANY_UNBRACED := {@^CLS:<\173\175>}}
	    {BRACE_ESCAPED := {@STR:<\134\173>}}
	    {BRACE_ESCAPED := {@STR:<\134\175>}}
	    {BRACED_ELEMENT := ANY_UNBRACED}
	    {BRACED_ELEMENT := BRACE_ESCAPED}
	    {BRACED_ELEMENT := BRACED_WORD}
	    {BRACED_ELEMENTS * BRACED_ELEMENT}
	    {BRACED_WORD := {@CHR:<\173>} BRACED_ELEMENTS {@CHR:<\175>}}
	    {BracedWord := BRACED_WORD}
	    {C_closer := C_CLOSER}
	    {C_CLOSER := {@CHR:<\135>}}
	    {COMMENT := {@STR:<\133comment>} SPACE_PLUS CX_ARG SPACE_NULL C_CLOSER}
	    {CONTINUATION := SPACE_NULL {@CHR:<\134>} NEWLINE SPACE_NULL}
	    {CX_ARG := BRACED_WORD}
	    {CX_ARG := QUOTED_WORD}
	    {CX_ARG := SIMPLE_WORD}
	    {ESCAPED := {@CHR:<\133>}}
	    {ESCAPED := {@CHR:<\135>}}
	    {ESCAPED := {@STR:<\134\42>}}
	    {Escaped := {@STR:<\134\42>}}
	    {Escaped := {@STR:<\134\133>}}
	    {Escaped := {@STR:<\134\135>}}
	    {ESCAPED := {@STR:<\134\173>}}
	    {Escaped := {@STR:<\134\173>}}
	    {ESCAPED := {@STR:<\134\175>}}
	    {Escaped := {@STR:<\134\175>}}
	    {GeneralText := GT_LIMITER}
	    {GeneralText := GT_LIMITER GT_LIMITER}
	    {GeneralText := GT_LIMITER GT_MIDDLE GT_LIMITER}
	    {GT_LIMITER := {@^CLS:<\133\135[:space:]>}}
	    {GT_MIDDLE + {@^CLS:<\t-\r\133\135>}}
	    {NEWLINE := {@CLS:<\n\r>}}
	    {NEWLINE := {@STR:<\r\n>}}
	    {QUOTED_ELEMENT := ESCAPED}
	    {QUOTED_ELEMENT := SIMPLE_WORD}
	    {QUOTED_ELEMENT := SPACE_PLUS}
	    {QUOTED_ELEMENTS * QUOTED_ELEMENT}
	    {QUOTED_WORD := {@CHR:<\42>} QUOTED_ELEMENTS {@CHR:<\42>}}
	    {SIMPLE_ELEMENT := {@^CLS:<\42\133\135\173\175[:space:]>}}
	    {SIMPLE_ELEMENT_PLUS_SPACE := {@^CLS:<\42\133\135\173\175>}}
	    {SIMPLE_WORD + SIMPLE_ELEMENT}
	    {SimpleWord := SIMPLE_WORD}
	    {SimpleWordPlusSpace + SIMPLE_ELEMENT_PLUS_SPACE}
	    {SPACE_NULL * {@NCC:<[:space:]>}}
	    {SPACE_PLUS + {@NCC:<[:space:]>}}
	    {SpacePlus := SPACE_PLUS}
	    {Whitespace := COMMENT}
	    {Whitespace := CONTINUATION}
	    {Whitespace := SPACE_PLUS}
	    {{@^CLS:<\42\133\135\173\175>} := {@^CLS:<\42\133\135\173\175>.BMP}}
	    {{@^CLS:<\42\133\135\173\175>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\42\133\135\173\175[:space:]>} := {@^CLS:<\42\133\135\173\175[:space:]>.BMP}}
	    {{@^CLS:<\42\133\135\173\175[:space:]>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\133\135[:space:]>} := {@^CLS:<\133\135[:space:]>.BMP}}
	    {{@^CLS:<\133\135[:space:]>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\173\175>} := {@^CLS:<\173\175>.BMP}}
	    {{@^CLS:<\173\175>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\t-\r\133\135>} := {@^CLS:<\t-\r\133\135>.BMP}}
	    {{@^CLS:<\t-\r\133\135>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@CLS:<\u10000-\u10ffff>.SMP} := {@RAN:<\ud800\udbff>} {@RAN:<\udc00\udfff>}}
	    {{@LEX:@CHR:<\42>} := {@CHR:<\42>}}
	    {{@LEX:@STR:<\133arg>} := {@STR:<\133arg>}}
	    {{@LEX:@STR:<\133arg_def>} := {@STR:<\133arg_def>}}
	    {{@LEX:@STR:<\133call>} := {@STR:<\133call>}}
	    {{@LEX:@STR:<\133category>} := {@STR:<\133category>}}
	    {{@LEX:@STR:<\133class>} := {@STR:<\133class>}}
	    {{@LEX:@STR:<\133cmd>} := {@STR:<\133cmd>}}
	    {{@LEX:@STR:<\133cmd_def>} := {@STR:<\133cmd_def>}}
	    {{@LEX:@STR:<\133const>} := {@STR:<\133const>}}
	    {{@LEX:@STR:<\133copyright>} := {@STR:<\133copyright>}}
	    {{@LEX:@STR:<\133def>} := {@STR:<\133def>}}
	    {{@LEX:@STR:<\133description\135>} := {@STR:<\133description\135>}}
	    {{@LEX:@STR:<\133emph>} := {@STR:<\133emph>}}
	    {{@LEX:@STR:<\133enum\135>} := {@STR:<\133enum\135>}}
	    {{@LEX:@STR:<\133example>} := {@STR:<\133example>}}
	    {{@LEX:@STR:<\133example_begin\135>} := {@STR:<\133example_begin\135>}}
	    {{@LEX:@STR:<\133example_end\135>} := {@STR:<\133example_end\135>}}
	    {{@LEX:@STR:<\133file>} := {@STR:<\133file>}}
	    {{@LEX:@STR:<\133fun>} := {@STR:<\133fun>}}
	    {{@LEX:@STR:<\133image>} := {@STR:<\133image>}}
	    {{@LEX:@STR:<\133include>} := {@STR:<\133include>}}
	    {{@LEX:@STR:<\133item\135>} := {@STR:<\133item\135>}}
	    {{@LEX:@STR:<\133keywords>} := {@STR:<\133keywords>}}
	    {{@LEX:@STR:<\133lb\135>} := {@STR:<\133lb\135>}}
	    {{@LEX:@STR:<\133list_begin>} := {@STR:<\133list_begin>}}
	    {{@LEX:@STR:<\133list_end\135>} := {@STR:<\133list_end\135>}}
	    {{@LEX:@STR:<\133manpage_begin>} := {@STR:<\133manpage_begin>}}
	    {{@LEX:@STR:<\133manpage_end\135>} := {@STR:<\133manpage_end\135>}}
	    {{@LEX:@STR:<\133method>} := {@STR:<\133method>}}
	    {{@LEX:@STR:<\133moddesc>} := {@STR:<\133moddesc>}}
	    {{@LEX:@STR:<\133namespace>} := {@STR:<\133namespace>}}
	    {{@LEX:@STR:<\133nl\135>} := {@STR:<\133nl\135>}}
	    {{@LEX:@STR:<\133opt>} := {@STR:<\133opt>}}
	    {{@LEX:@STR:<\133opt_def>} := {@STR:<\133opt_def>}}
	    {{@LEX:@STR:<\133option>} := {@STR:<\133option>}}
	    {{@LEX:@STR:<\133package>} := {@STR:<\133package>}}
	    {{@LEX:@STR:<\133para\135>} := {@STR:<\133para\135>}}
	    {{@LEX:@STR:<\133rb\135>} := {@STR:<\133rb\135>}}
	    {{@LEX:@STR:<\133require>} := {@STR:<\133require>}}
	    {{@LEX:@STR:<\133section>} := {@STR:<\133section>}}
	    {{@LEX:@STR:<\133sectref-external>} := {@STR:<\133sectref-external>}}
	    {{@LEX:@STR:<\133sectref>} := {@STR:<\133sectref>}}
	    {{@LEX:@STR:<\133see_also>} := {@STR:<\133see_also>}}
	    {{@LEX:@STR:<\133strong>} := {@STR:<\133strong>}}
	    {{@LEX:@STR:<\133subsection>} := {@STR:<\133subsection>}}
	    {{@LEX:@STR:<\133syscmd>} := {@STR:<\133syscmd>}}
	    {{@LEX:@STR:<\133term>} := {@STR:<\133term>}}
	    {{@LEX:@STR:<\133titledesc>} := {@STR:<\133titledesc>}}
	    {{@LEX:@STR:<\133tkoption_def>} := {@STR:<\133tkoption_def>}}
	    {{@LEX:@STR:<\133type>} := {@STR:<\133type>}}
	    {{@LEX:@STR:<\133uri>} := {@STR:<\133uri>}}
	    {{@LEX:@STR:<\133usage>} := {@STR:<\133usage>}}
	    {{@LEX:@STR:<\133var>} := {@STR:<\133var>}}
	    {{@LEX:@STR:<\133vset>} := {@STR:<\133vset>}}
	    {{@LEX:@STR:<\133widget>} := {@STR:<\133widget>}}
	    {{@LEX:@STR:<arguments\135>} := {@STR:<arguments\135>}}
	    {{@LEX:@STR:<commands\135>} := {@STR:<commands\135>}}
	    {{@LEX:@STR:<definitions\135>} := {@STR:<definitions\135>}}
	    {{@LEX:@STR:<enumerated\135>} := {@STR:<enumerated\135>}}
	    {{@LEX:@STR:<itemized\135>} := {@STR:<itemized\135>}}
	    {{@LEX:@STR:<options\135>} := {@STR:<options\135>}}
	    {{@LEX:@STR:<tkoptions\135>} := {@STR:<tkoptions\135>}}
	    {{@STR:<\133arg>} := {@CHR:<\133>} @CHR:<a> @CHR:<r> @CHR:<g>}
	    {{@STR:<\133arg_def>} := {@CHR:<\133>} @CHR:<a> @CHR:<r> @CHR:<g> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133call>} := {@CHR:<\133>} @CHR:<c> @CHR:<a> @CHR:<l> @CHR:<l>}
	    {{@STR:<\133category>} := {@CHR:<\133>} @CHR:<c> @CHR:<a> @CHR:<t> @CHR:<e> @CHR:<g> @CHR:<o> @CHR:<r> @CHR:<y>}
	    {{@STR:<\133class>} := {@CHR:<\133>} @CHR:<c> @CHR:<l> @CHR:<a> @CHR:<s> @CHR:<s>}
	    {{@STR:<\133cmd>} := {@CHR:<\133>} @CHR:<c> @CHR:<m> @CHR:<d>}
	    {{@STR:<\133cmd_def>} := {@CHR:<\133>} @CHR:<c> @CHR:<m> @CHR:<d> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133comment>} := {@CHR:<\133>} @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {{@STR:<\133const>} := {@CHR:<\133>} @CHR:<c> @CHR:<o> @CHR:<n> @CHR:<s> @CHR:<t>}
	    {{@STR:<\133copyright>} := {@CHR:<\133>} @CHR:<c> @CHR:<o> @CHR:<p> @CHR:<y> @CHR:<r> @CHR:<i> @CHR:<g> @CHR:<h> @CHR:<t>}
	    {{@STR:<\133def>} := {@CHR:<\133>} @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133description\135>} := {@CHR:<\133>} @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c> @CHR:<r> @CHR:<i> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> {@CHR:<\135>}}
	    {{@STR:<\133emph>} := {@CHR:<\133>} @CHR:<e> @CHR:<m> @CHR:<p> @CHR:<h>}
	    {{@STR:<\133enum\135>} := {@CHR:<\133>} @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m> {@CHR:<\135>}}
	    {{@STR:<\133example>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e>}
	    {{@STR:<\133example_begin\135>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n> {@CHR:<\135>}}
	    {{@STR:<\133example_end\135>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d> {@CHR:<\135>}}
	    {{@STR:<\133file>} := {@CHR:<\133>} @CHR:<f> @CHR:<i> @CHR:<l> @CHR:<e>}
	    {{@STR:<\133fun>} := {@CHR:<\133>} @CHR:<f> @CHR:<u> @CHR:<n>}
	    {{@STR:<\133image>} := {@CHR:<\133>} @CHR:<i> @CHR:<m> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {{@STR:<\133include>} := {@CHR:<\133>} @CHR:<i> @CHR:<n> @CHR:<c> @CHR:<l> @CHR:<u> @CHR:<d> @CHR:<e>}
	    {{@STR:<\133item\135>} := {@CHR:<\133>} @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m> {@CHR:<\135>}}
	    {{@STR:<\133keywords>} := {@CHR:<\133>} @CHR:<k> @CHR:<e> @CHR:<y> @CHR:<w> @CHR:<o> @CHR:<r> @CHR:<d> @CHR:<s>}
	    {{@STR:<\133lb\135>} := {@CHR:<\133>} @CHR:<l> @CHR:<b> {@CHR:<\135>}}
	    {{@STR:<\133list_begin>} := {@CHR:<\133>} @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {{@STR:<\133list_end\135>} := {@CHR:<\133>} @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d> {@CHR:<\135>}}
	    {{@STR:<\133manpage_begin>} := {@CHR:<\133>} @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {{@STR:<\133manpage_end\135>} := {@CHR:<\133>} @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d> {@CHR:<\135>}}
	    {{@STR:<\133method>} := {@CHR:<\133>} @CHR:<m> @CHR:<e> @CHR:<t> @CHR:<h> @CHR:<o> @CHR:<d>}
	    {{@STR:<\133moddesc>} := {@CHR:<\133>} @CHR:<m> @CHR:<o> @CHR:<d> @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c>}
	    {{@STR:<\133namespace>} := {@CHR:<\133>} @CHR:<n> @CHR:<a> @CHR:<m> @CHR:<e> @CHR:<s> @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<e>}
	    {{@STR:<\133nl\135>} := {@CHR:<\133>} @CHR:<n> @CHR:<l> {@CHR:<\135>}}
	    {{@STR:<\133opt>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t>}
	    {{@STR:<\133opt_def>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133option>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {{@STR:<\133package>} := {@CHR:<\133>} @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<k> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {{@STR:<\133para\135>} := {@CHR:<\133>} @CHR:<p> @CHR:<a> @CHR:<r> @CHR:<a> {@CHR:<\135>}}
	    {{@STR:<\133rb\135>} := {@CHR:<\133>} @CHR:<r> @CHR:<b> {@CHR:<\135>}}
	    {{@STR:<\133require>} := {@CHR:<\133>} @CHR:<r> @CHR:<e> @CHR:<q> @CHR:<u> @CHR:<i> @CHR:<r> @CHR:<e>}
	    {{@STR:<\133section>} := {@CHR:<\133>} @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {{@STR:<\133sectref-external>} := {@CHR:<\133>} @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<r> @CHR:<e> @CHR:<f> @CHR:<-> @CHR:<e> @CHR:<x> @CHR:<t> @CHR:<e> @CHR:<r> @CHR:<n> @CHR:<a> @CHR:<l>}
	    {{@STR:<\133sectref>} := {@CHR:<\133>} @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<r> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133see_also>} := {@CHR:<\133>} @CHR:<s> @CHR:<e> @CHR:<e> @CHR:<_> @CHR:<a> @CHR:<l> @CHR:<s> @CHR:<o>}
	    {{@STR:<\133strong>} := {@CHR:<\133>} @CHR:<s> @CHR:<t> @CHR:<r> @CHR:<o> @CHR:<n> @CHR:<g>}
	    {{@STR:<\133subsection>} := {@CHR:<\133>} @CHR:<s> @CHR:<u> @CHR:<b> @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {{@STR:<\133syscmd>} := {@CHR:<\133>} @CHR:<s> @CHR:<y> @CHR:<s> @CHR:<c> @CHR:<m> @CHR:<d>}
	    {{@STR:<\133term>} := {@CHR:<\133>} @CHR:<t> @CHR:<e> @CHR:<r> @CHR:<m>}
	    {{@STR:<\133titledesc>} := {@CHR:<\133>} @CHR:<t> @CHR:<i> @CHR:<t> @CHR:<l> @CHR:<e> @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c>}
	    {{@STR:<\133tkoption_def>} := {@CHR:<\133>} @CHR:<t> @CHR:<k> @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133type>} := {@CHR:<\133>} @CHR:<t> @CHR:<y> @CHR:<p> @CHR:<e>}
	    {{@STR:<\133uri>} := {@CHR:<\133>} @CHR:<u> @CHR:<r> @CHR:<i>}
	    {{@STR:<\133usage>} := {@CHR:<\133>} @CHR:<u> @CHR:<s> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {{@STR:<\133var>} := {@CHR:<\133>} @CHR:<v> @CHR:<a> @CHR:<r>}
	    {{@STR:<\133vset>} := {@CHR:<\133>} @CHR:<v> @CHR:<s> @CHR:<e> @CHR:<t>}
	    {{@STR:<\133widget>} := {@CHR:<\133>} @CHR:<w> @CHR:<i> @CHR:<d> @CHR:<g> @CHR:<e> @CHR:<t>}
	    {{@STR:<\134\42>} := {@CHR:<\134>} {@CHR:<\42>}}
	    {{@STR:<\134\133>} := {@CHR:<\134>} {@CHR:<\133>}}
	    {{@STR:<\134\135>} := {@CHR:<\134>} {@CHR:<\135>}}
	    {{@STR:<\134\173>} := {@CHR:<\134>} {@CHR:<\173>}}
	    {{@STR:<\134\175>} := {@CHR:<\134>} {@CHR:<\175>}}
	    {{@STR:<\r\n>} := {@CHR:<\r>} {@CHR:<\n>}}
	    {{@STR:<arguments\135>} := @CHR:<a> @CHR:<r> @CHR:<g> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t> @CHR:<s> {@CHR:<\135>}}
	    {{@STR:<commands\135>} := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<d> @CHR:<s> {@CHR:<\135>}}
	    {{@STR:<definitions\135>} := @CHR:<d> @CHR:<e> @CHR:<f> @CHR:<i> @CHR:<n> @CHR:<i> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s> {@CHR:<\135>}}
	    {{@STR:<enumerated\135>} := @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<r> @CHR:<a> @CHR:<t> @CHR:<e> @CHR:<d> {@CHR:<\135>}}
	    {{@STR:<itemized\135>} := @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m> @CHR:<i> @CHR:<z> @CHR:<e> @CHR:<d> {@CHR:<\135>}}
	    {{@STR:<options\135>} := @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s> {@CHR:<\135>}}
	    {{@STR:<tkoptions\135>} := @CHR:<t> @CHR:<k> @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s> {@CHR:<\135>}}
	}
    }

    method L0.Semantics {} {
	debug.doctools/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.doctools/parser/tcl
	return {
	    arg_list_elem
	    argument_list
	    body
	    c_arg
	    c_arg_def
	    c_call
	    c_category
	    c_class
	    c_cmd
	    c_cmd_def
	    c_const
	    c_copyright
	    c_def
	    c_description
	    c_emph
	    c_enum
	    c_example
	    c_example_begin
	    c_example_end
	    c_file
	    c_fun
	    c_image
	    c_include
	    c_item
	    c_keywords
	    c_lb
	    c_list_begin_arg
	    c_list_begin_cmd
	    c_list_begin_def
	    c_list_begin_enum
	    c_list_begin_item
	    c_list_begin_opt
	    c_list_begin_tko
	    c_list_end
	    c_manpage_begin
	    c_manpage_end
	    c_method
	    c_moddesc
	    c_namespace
	    c_opt
	    c_opt_def
	    c_option
	    c_package
	    c_para
	    c_rb
	    c_require
	    c_section
	    c_sectref
	    c_sectref_ext
	    c_see_also
	    c_strong
	    c_subsection
	    c_syscmd
	    c_term
	    c_titledesc
	    c_tkoption_def
	    c_type
	    c_uri
	    c_usage
	    c_var
	    c_vget
	    c_vset
	    c_widget
	    cmd_list_elem
	    command_list
	    cx_arg
	    cx_args
	    def_list_elem
	    definition
	    definition_list
	    definitions
	    enum_list
	    enum_list_elem
	    example
	    example_block
	    example_text
	    general_text
	    header
	    headers
	    item_list
	    item_list_elem
	    list
	    manpage
	    markup
	    opt_list_elem
	    option_list
	    paragraph
	    paragraphs
	    quoted_element
	    quoted_elements
	    quoted_word
	    section
	    subsection
	    tko_list_elem
	    tkoption_list
	    word
	    words
	    xref
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.doctools/parser/tcl
	return {
	    {__ :A {name values}}
	    {arg_list_elem := c_arg_def paragraphs}
	    {argument_list + arg_list_elem}
	    {body := section}
	    {body := section c_section body}
	    {c_arg :M {0 2} {@LEX:@STR:<\133arg>} cx_arg C_closer}
	    {c_arg_def :M {0 3} {@LEX:@STR:<\133arg_def>} cx_arg cx_arg C_closer}
	    {c_arg_def :M {0 4} {@LEX:@STR:<\133arg_def>} cx_arg cx_arg cx_arg C_closer}
	    {c_call :M {0 2} {@LEX:@STR:<\133call>} cx_args C_closer}
	    {c_category :M {0 2} {@LEX:@STR:<\133category>} cx_arg C_closer}
	    {c_class :M {0 2} {@LEX:@STR:<\133class>} cx_arg C_closer}
	    {c_cmd :M {0 2} {@LEX:@STR:<\133cmd>} cx_arg C_closer}
	    {c_cmd_def :M {0 2} {@LEX:@STR:<\133cmd_def>} cx_arg C_closer}
	    {c_const :M {0 2} {@LEX:@STR:<\133const>} cx_arg C_closer}
	    {c_copyright :M {0 2} {@LEX:@STR:<\133copyright>} cx_arg C_closer}
	    {c_def :M {0 2} {@LEX:@STR:<\133def>} cx_arg C_closer}
	    {c_description :M 0 {@LEX:@STR:<\133description\135>}}
	    {c_emph :M {0 2} {@LEX:@STR:<\133emph>} cx_arg C_closer}
	    {c_enum :M 0 {@LEX:@STR:<\133enum\135>}}
	    {c_example :M {0 2} {@LEX:@STR:<\133example>} cx_arg C_closer}
	    {c_example_begin :M 0 {@LEX:@STR:<\133example_begin\135>}}
	    {c_example_end :M 0 {@LEX:@STR:<\133example_end\135>}}
	    {c_file :M {0 2} {@LEX:@STR:<\133file>} cx_arg C_closer}
	    {c_fun :M {0 2} {@LEX:@STR:<\133fun>} cx_arg C_closer}
	    {c_image :M {0 2} {@LEX:@STR:<\133image>} cx_arg C_closer}
	    {c_image :M {0 3} {@LEX:@STR:<\133image>} cx_arg cx_arg C_closer}
	    {c_include :M {0 2} {@LEX:@STR:<\133include>} cx_arg C_closer}
	    {c_item :M 0 {@LEX:@STR:<\133item\135>}}
	    {c_keywords :M {0 2} {@LEX:@STR:<\133keywords>} cx_args C_closer}
	    {c_lb :M 0 {@LEX:@STR:<\133lb\135>}}
	    {c_list_begin_arg :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<arguments\135>}}
	    {c_list_begin_cmd :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<commands\135>}}
	    {c_list_begin_def :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<definitions\135>}}
	    {c_list_begin_enum :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<enumerated\135>}}
	    {c_list_begin_item :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<itemized\135>}}
	    {c_list_begin_opt :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<options\135>}}
	    {c_list_begin_tko :M {0 1 2} {@LEX:@STR:<\133list_begin>} SpacePlus {@LEX:@STR:<tkoptions\135>}}
	    {c_list_end :M 0 {@LEX:@STR:<\133list_end\135>}}
	    {c_manpage_begin :M {0 4} {@LEX:@STR:<\133manpage_begin>} cx_arg cx_arg cx_arg C_closer}
	    {c_manpage_end :M 0 {@LEX:@STR:<\133manpage_end\135>}}
	    {c_method :M {0 2} {@LEX:@STR:<\133method>} cx_arg C_closer}
	    {c_moddesc :M {0 2} {@LEX:@STR:<\133moddesc>} cx_arg C_closer}
	    {c_namespace :M {0 2} {@LEX:@STR:<\133namespace>} cx_arg C_closer}
	    {c_opt :M {0 2} {@LEX:@STR:<\133opt>} cx_arg C_closer}
	    {c_opt_def :M {0 2} {@LEX:@STR:<\133opt_def>} cx_arg C_closer}
	    {c_opt_def :M {0 3} {@LEX:@STR:<\133opt_def>} cx_arg cx_arg C_closer}
	    {c_option :M {0 2} {@LEX:@STR:<\133option>} cx_arg C_closer}
	    {c_package :M {0 2} {@LEX:@STR:<\133package>} cx_arg C_closer}
	    {c_para :M 0 {@LEX:@STR:<\133nl\135>}}
	    {c_para :M 0 {@LEX:@STR:<\133para\135>}}
	    {c_rb :M 0 {@LEX:@STR:<\133rb\135>}}
	    {c_require :M {0 2} {@LEX:@STR:<\133require>} cx_arg C_closer}
	    {c_require :M {0 3} {@LEX:@STR:<\133require>} cx_arg cx_arg C_closer}
	    {c_section :M {0 2} {@LEX:@STR:<\133section>} cx_arg C_closer}
	    {c_sectref :M {0 2} {@LEX:@STR:<\133sectref>} cx_arg C_closer}
	    {c_sectref :M {0 3} {@LEX:@STR:<\133sectref>} cx_arg cx_arg C_closer}
	    {c_sectref_ext :M {0 2} {@LEX:@STR:<\133sectref-external>} cx_arg C_closer}
	    {c_see_also :M {0 2} {@LEX:@STR:<\133see_also>} cx_args C_closer}
	    {c_strong :M {0 2} {@LEX:@STR:<\133strong>} cx_arg C_closer}
	    {c_subsection :M {0 2} {@LEX:@STR:<\133subsection>} cx_arg C_closer}
	    {c_syscmd :M {0 2} {@LEX:@STR:<\133syscmd>} cx_arg C_closer}
	    {c_term :M {0 2} {@LEX:@STR:<\133term>} cx_arg C_closer}
	    {c_titledesc :M {0 2} {@LEX:@STR:<\133titledesc>} cx_arg C_closer}
	    {c_tkoption_def :M {0 4} {@LEX:@STR:<\133tkoption_def>} cx_arg cx_arg cx_arg C_closer}
	    {c_type :M {0 2} {@LEX:@STR:<\133type>} cx_arg C_closer}
	    {c_uri :M {0 2} {@LEX:@STR:<\133uri>} cx_arg C_closer}
	    {c_uri :M {0 3} {@LEX:@STR:<\133uri>} cx_arg cx_arg C_closer}
	    {c_usage :M {0 2} {@LEX:@STR:<\133usage>} cx_args C_closer}
	    {c_var :M {0 2} {@LEX:@STR:<\133var>} cx_arg C_closer}
	    {c_vget :M {0 2} {@LEX:@STR:<\133vset>} cx_arg C_closer}
	    {c_vset :M {0 3} {@LEX:@STR:<\133vset>} cx_arg cx_arg C_closer}
	    {c_widget :M {0 2} {@LEX:@STR:<\133widget>} cx_arg C_closer}
	    {cmd_list_elem := c_cmd_def paragraphs}
	    {command_list + cmd_list_elem}
	    {cx_arg := BracedWord}
	    {cx_arg := c_vget}
	    {cx_arg := markup}
	    {cx_arg := quoted_word}
	    {cx_arg := SimpleWord}
	    {cx_args + cx_arg}
	    {def_list_elem := c_call paragraphs}
	    {def_list_elem := c_def paragraphs}
	    {definition := c_include}
	    {definition := c_vset}
	    {definition_list + def_list_elem}
	    {definitions * definition}
	    {enum_list + enum_list_elem}
	    {enum_list_elem :M 0 c_enum paragraphs}
	    {example := c_example}
	    {example :M {0 2} c_example_begin example_block c_example_end}
	    {example_block + example_text}
	    {example_text := definition}
	    {example_text := general_text}
	    {example_text := markup}
	    {general_text := GeneralText}
	    {header := c_copyright}
	    {header := c_moddesc}
	    {header := c_require}
	    {header := c_titledesc}
	    {header := definition}
	    {header := xref}
	    {headers + header}
	    {item_list + item_list_elem}
	    {item_list_elem :M 0 c_item paragraphs}
	    {list :M {0 2} c_list_begin_arg argument_list c_list_end}
	    {list :M {0 2} c_list_begin_cmd command_list c_list_end}
	    {list :M {0 2} c_list_begin_def definition_list c_list_end}
	    {list :M {0 2} c_list_begin_enum enum_list c_list_end}
	    {list :M {0 2} c_list_begin_item item_list c_list_end}
	    {list :M {0 2} c_list_begin_opt option_list c_list_end}
	    {list :M {0 2} c_list_begin_tko tkoption_list c_list_end}
	    {manpage :M {3 5} definitions c_manpage_begin headers c_description body c_manpage_end}
	    {markup := c_arg}
	    {markup := c_class}
	    {markup := c_cmd}
	    {markup := c_const}
	    {markup := c_emph}
	    {markup := c_file}
	    {markup := c_fun}
	    {markup := c_image}
	    {markup := c_lb}
	    {markup := c_method}
	    {markup := c_namespace}
	    {markup := c_opt}
	    {markup := c_option}
	    {markup := c_package}
	    {markup := c_rb}
	    {markup := c_sectref}
	    {markup := c_sectref_ext}
	    {markup := c_strong}
	    {markup := c_syscmd}
	    {markup := c_term}
	    {markup := c_type}
	    {markup := c_uri}
	    {markup := c_usage}
	    {markup := c_var}
	    {markup := c_widget}
	    {opt_list_elem := c_opt_def paragraphs}
	    {option_list + opt_list_elem}
	    {paragraph := words}
	    {paragraph :=}
	    {paragraphs := paragraph}
	    {paragraphs :M 1 paragraph c_para paragraphs}
	    {quoted_element := Escaped}
	    {quoted_element := markup}
	    {quoted_element := SimpleWordPlusSpace}
	    {quoted_elements * quoted_element}
	    {quoted_word :M {0 2} {@LEX:@CHR:<\42>} quoted_elements {@LEX:@CHR:<\42>}}
	    {section := subsection}
	    {section := subsection c_subsection section}
	    {subsection := paragraphs}
	    {tko_list_elem := c_tkoption_def paragraphs}
	    {tkoption_list + tko_list_elem}
	    {word := c_vget}
	    {word := definition}
	    {word := example}
	    {word := general_text}
	    {word := list}
	    {word := markup}
	    {word := xref}
	    {words + word}
	    {xref := c_category}
	    {xref := c_keywords}
	    {xref := c_see_also}
	}
    }

    method Start {} {
	debug.doctools/parser/tcl
	# G1 start symbol
	return {manpage}
    }
}

# # ## ### ##### ######## #############
return