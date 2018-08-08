# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar doctools::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "doctools::parser::tcl".
##	Generated On Wed Aug 08 15:08:51 PDT 2018
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
	    BracedWord            1
	    Breaker               1
	    C_arg                 1
	    C_arg_def             1
	    C_call                1
	    C_category            1
	    C_class               1
	    C_closer              1
	    C_cmd                 1
	    C_cmd_def             1
	    C_const               1
	    C_copyright           1
	    C_def                 1
	    C_description         1
	    C_emph                1
	    C_enum                1
	    C_example             1
	    C_example_begin       1
	    C_example_end         1
	    C_file                1
	    C_fun                 1
	    C_image               1
	    C_include             1
	    C_item                1
	    C_keywords            1
	    C_lb                  1
	    C_list_begin          1
	    C_list_end            1
	    C_manpage_begin       1
	    C_manpage_end         1
	    C_method              1
	    C_moddesc             1
	    C_namespace           1
	    C_nl                  1
	    C_opt                 1
	    C_opt_def             1
	    C_option              1
	    C_package             1
	    C_para                1
	    C_rb                  1
	    C_require             1
	    C_section             1
	    C_sectref             1
	    C_sectref_ext         1
	    C_see_also            1
	    C_strong              1
	    C_subsection          1
	    C_syscmd              1
	    C_term                1
	    C_titledesc           1
	    C_tkoption_def        1
	    C_type                1
	    C_uri                 1
	    C_usage               1
	    C_var                 1
	    C_vset                1
	    C_widget              1
	    Escaped               1
	    GeneralText           1
	    L_arguments           1
	    L_commands            1
	    L_definitions         1
	    L_enumerated          1
	    L_itemized            1
	    L_options             1
	    L_tkoptions           1
	    Quote                 1
	    SimpleWord            1
	    SimpleWordPlusSpace   1
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
	    {@STR:<\133description>}
	    {@STR:<\133emph>}
	    {@STR:<\133enum>}
	    {@STR:<\133example>}
	    {@STR:<\133example_begin>}
	    {@STR:<\133example_end>}
	    {@STR:<\133file>}
	    {@STR:<\133fun>}
	    {@STR:<\133image>}
	    {@STR:<\133include>}
	    {@STR:<\133item>}
	    {@STR:<\133keywords>}
	    {@STR:<\133lb>}
	    {@STR:<\133list_begin>}
	    {@STR:<\133list_end>}
	    {@STR:<\133manpage_begin>}
	    {@STR:<\133manpage_end>}
	    {@STR:<\133method>}
	    {@STR:<\133moddesc>}
	    {@STR:<\133namespace>}
	    {@STR:<\133nl>}
	    {@STR:<\133opt>}
	    {@STR:<\133opt_def>}
	    {@STR:<\133option>}
	    {@STR:<\133package>}
	    {@STR:<\133para>}
	    {@STR:<\133rb>}
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
	    @STR:<arguments>
	    @STR:<commands>
	    @STR:<definitions>
	    @STR:<enumerated>
	    @STR:<itemized>
	    @STR:<options>
	    @STR:<tkoptions>
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
	    QUOTE
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
	    {@STR:<arguments> := @CHR:<a> @CHR:<r> @CHR:<g> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t> @CHR:<s>}
	    {@STR:<commands> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<d> @CHR:<s>}
	    {@STR:<definitions> := @CHR:<d> @CHR:<e> @CHR:<f> @CHR:<i> @CHR:<n> @CHR:<i> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {@STR:<enumerated> := @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<r> @CHR:<a> @CHR:<t> @CHR:<e> @CHR:<d>}
	    {@STR:<itemized> := @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m> @CHR:<i> @CHR:<z> @CHR:<e> @CHR:<d>}
	    {@STR:<options> := @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {@STR:<tkoptions> := @CHR:<t> @CHR:<k> @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {ANY_UNBRACED := {@^CLS:<\173\175>}}
	    {BRACE_ESCAPED := {@STR:<\134\173>}}
	    {BRACE_ESCAPED := {@STR:<\134\175>}}
	    {BRACED_ELEMENT := ANY_UNBRACED}
	    {BRACED_ELEMENT := BRACE_ESCAPED}
	    {BRACED_ELEMENT := BRACED_WORD}
	    {BRACED_ELEMENTS * BRACED_ELEMENT}
	    {BRACED_WORD := {@CHR:<\173>} BRACED_ELEMENTS {@CHR:<\175>}}
	    {BracedWord := BRACED_WORD}
	    {Breaker := NEWLINE SPACE_NULL}
	    {C_arg := {@STR:<\133arg>} SPACE_PLUS}
	    {C_arg_def := {@STR:<\133arg_def>} SPACE_PLUS}
	    {C_call := {@STR:<\133call>} SPACE_PLUS}
	    {C_category := {@STR:<\133category>} SPACE_PLUS}
	    {C_class := {@STR:<\133class>} SPACE_PLUS}
	    {C_closer := C_CLOSER}
	    {C_CLOSER := {@CHR:<\135>}}
	    {C_cmd := {@STR:<\133cmd>} SPACE_PLUS}
	    {C_cmd_def := {@STR:<\133cmd_def>} SPACE_PLUS}
	    {C_const := {@STR:<\133const>} SPACE_PLUS}
	    {C_copyright := {@STR:<\133copyright>} SPACE_PLUS}
	    {C_def := {@STR:<\133def>} SPACE_PLUS}
	    {C_description := {@STR:<\133description>} SPACE_NULL C_CLOSER}
	    {C_emph := {@STR:<\133emph>} SPACE_PLUS}
	    {C_enum := {@STR:<\133enum>} SPACE_NULL C_CLOSER}
	    {C_example := {@STR:<\133example>} SPACE_PLUS}
	    {C_example_begin := {@STR:<\133example_begin>} SPACE_NULL C_CLOSER}
	    {C_example_end := {@STR:<\133example_end>} SPACE_NULL C_CLOSER}
	    {C_file := {@STR:<\133file>} SPACE_PLUS}
	    {C_fun := {@STR:<\133fun>} SPACE_PLUS}
	    {C_image := {@STR:<\133image>} SPACE_PLUS}
	    {C_include := {@STR:<\133include>} SPACE_PLUS}
	    {C_item := {@STR:<\133item>} SPACE_NULL C_CLOSER}
	    {C_keywords := {@STR:<\133keywords>} SPACE_PLUS}
	    {C_lb := {@STR:<\133lb>} SPACE_NULL C_CLOSER}
	    {C_list_begin := {@STR:<\133list_begin>} SPACE_PLUS}
	    {C_list_end := {@STR:<\133list_end>} SPACE_NULL C_CLOSER}
	    {C_manpage_begin := {@STR:<\133manpage_begin>} SPACE_PLUS}
	    {C_manpage_end := {@STR:<\133manpage_end>} SPACE_NULL C_CLOSER}
	    {C_method := {@STR:<\133method>} SPACE_PLUS}
	    {C_moddesc := {@STR:<\133moddesc>} SPACE_PLUS}
	    {C_namespace := {@STR:<\133namespace>} SPACE_PLUS}
	    {C_nl := {@STR:<\133nl>} SPACE_NULL C_CLOSER}
	    {C_opt := {@STR:<\133opt>} SPACE_PLUS}
	    {C_opt_def := {@STR:<\133opt_def>} SPACE_PLUS}
	    {C_option := {@STR:<\133option>} SPACE_PLUS}
	    {C_package := {@STR:<\133package>} SPACE_PLUS}
	    {C_para := {@STR:<\133para>} SPACE_NULL C_CLOSER}
	    {C_rb := {@STR:<\133rb>} SPACE_NULL C_CLOSER}
	    {C_require := {@STR:<\133require>} SPACE_PLUS}
	    {C_section := {@STR:<\133section>} SPACE_PLUS}
	    {C_sectref := {@STR:<\133sectref>} SPACE_PLUS}
	    {C_sectref_ext := {@STR:<\133sectref-external>} SPACE_PLUS}
	    {C_see_also := {@STR:<\133see_also>} SPACE_PLUS}
	    {C_strong := {@STR:<\133strong>} SPACE_PLUS}
	    {C_subsection := {@STR:<\133subsection>} SPACE_PLUS}
	    {C_syscmd := {@STR:<\133syscmd>} SPACE_PLUS}
	    {C_term := {@STR:<\133term>} SPACE_PLUS}
	    {C_titledesc := {@STR:<\133titledesc>} SPACE_PLUS}
	    {C_tkoption_def := {@STR:<\133tkoption_def>} SPACE_PLUS}
	    {C_type := {@STR:<\133type>} SPACE_PLUS}
	    {C_uri := {@STR:<\133uri>} SPACE_PLUS}
	    {C_usage := {@STR:<\133usage>} SPACE_PLUS}
	    {C_var := {@STR:<\133var>} SPACE_PLUS}
	    {C_vset := {@STR:<\133vset>} SPACE_PLUS}
	    {C_widget := {@STR:<\133widget>} SPACE_PLUS}
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
	    {L_arguments := @STR:<arguments>}
	    {L_commands := @STR:<commands>}
	    {L_definitions := @STR:<definitions>}
	    {L_enumerated := @STR:<enumerated>}
	    {L_itemized := @STR:<itemized>}
	    {L_options := @STR:<options>}
	    {L_tkoptions := @STR:<tkoptions>}
	    {NEWLINE := {@CLS:<\n\r>}}
	    {NEWLINE := {@STR:<\r\n>}}
	    {Quote := QUOTE}
	    {QUOTE := {@CHR:<\42>}}
	    {QUOTED_ELEMENT := ESCAPED}
	    {QUOTED_ELEMENT := SIMPLE_WORD}
	    {QUOTED_ELEMENT := SPACE_PLUS}
	    {QUOTED_ELEMENTS * QUOTED_ELEMENT}
	    {QUOTED_WORD := QUOTE QUOTED_ELEMENTS QUOTE}
	    {SIMPLE_ELEMENT := {@^CLS:<\42\133\135\173\175[:space:]>}}
	    {SIMPLE_ELEMENT_PLUS_SPACE := {@^CLS:<\42\133\135\173\175>}}
	    {SIMPLE_WORD + SIMPLE_ELEMENT}
	    {SimpleWord := SIMPLE_WORD}
	    {SimpleWordPlusSpace + SIMPLE_ELEMENT_PLUS_SPACE}
	    {SPACE_NULL * {@NCC:<[:space:]>}}
	    {SPACE_PLUS + {@NCC:<[:space:]>}}
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
	    {{@STR:<\133description>} := {@CHR:<\133>} @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c> @CHR:<r> @CHR:<i> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {{@STR:<\133emph>} := {@CHR:<\133>} @CHR:<e> @CHR:<m> @CHR:<p> @CHR:<h>}
	    {{@STR:<\133enum>} := {@CHR:<\133>} @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m>}
	    {{@STR:<\133example>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e>}
	    {{@STR:<\133example_begin>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {{@STR:<\133example_end>} := {@CHR:<\133>} @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {{@STR:<\133file>} := {@CHR:<\133>} @CHR:<f> @CHR:<i> @CHR:<l> @CHR:<e>}
	    {{@STR:<\133fun>} := {@CHR:<\133>} @CHR:<f> @CHR:<u> @CHR:<n>}
	    {{@STR:<\133image>} := {@CHR:<\133>} @CHR:<i> @CHR:<m> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {{@STR:<\133include>} := {@CHR:<\133>} @CHR:<i> @CHR:<n> @CHR:<c> @CHR:<l> @CHR:<u> @CHR:<d> @CHR:<e>}
	    {{@STR:<\133item>} := {@CHR:<\133>} @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m>}
	    {{@STR:<\133keywords>} := {@CHR:<\133>} @CHR:<k> @CHR:<e> @CHR:<y> @CHR:<w> @CHR:<o> @CHR:<r> @CHR:<d> @CHR:<s>}
	    {{@STR:<\133lb>} := {@CHR:<\133>} @CHR:<l> @CHR:<b>}
	    {{@STR:<\133list_begin>} := {@CHR:<\133>} @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {{@STR:<\133list_end>} := {@CHR:<\133>} @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {{@STR:<\133manpage_begin>} := {@CHR:<\133>} @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {{@STR:<\133manpage_end>} := {@CHR:<\133>} @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {{@STR:<\133method>} := {@CHR:<\133>} @CHR:<m> @CHR:<e> @CHR:<t> @CHR:<h> @CHR:<o> @CHR:<d>}
	    {{@STR:<\133moddesc>} := {@CHR:<\133>} @CHR:<m> @CHR:<o> @CHR:<d> @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c>}
	    {{@STR:<\133namespace>} := {@CHR:<\133>} @CHR:<n> @CHR:<a> @CHR:<m> @CHR:<e> @CHR:<s> @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<e>}
	    {{@STR:<\133nl>} := {@CHR:<\133>} @CHR:<n> @CHR:<l>}
	    {{@STR:<\133opt>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t>}
	    {{@STR:<\133opt_def>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {{@STR:<\133option>} := {@CHR:<\133>} @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {{@STR:<\133package>} := {@CHR:<\133>} @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<k> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {{@STR:<\133para>} := {@CHR:<\133>} @CHR:<p> @CHR:<a> @CHR:<r> @CHR:<a>}
	    {{@STR:<\133rb>} := {@CHR:<\133>} @CHR:<r> @CHR:<b>}
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
	}
    }

    method L0.Semantics {} {
	debug.doctools/parser/tcl
	# NOTE. This is currently limited to array semantics.
	# NOTE. No support for command semantics in the lexer yet.
	return {start length value}
    }

    method L0.Events {} {
	debug.doctools/parser/tcl
	# L0 parse event definitions (pre-, post-lexeme, discard)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Due to the nature of SLIF syntax we can only associate one
	# event per type with each symbol, for a maximum of three.
	return {}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.doctools/parser/tcl
	return {
	    arg_list_elem
	    argument_list
	    body
	    braced_word
	    breaker
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
	    example_element
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
	    p_separator
	    paragraph
	    paragraphs
	    quoted_element
	    quoted_elements
	    quoted_word
	    section
	    sections
	    simple_word
	    subsection
	    subsections
	    tko_list_elem
	    tkoption_list
	    word
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
	    {body := paragraphs}
	    {body := sections}
	    {body := paragraphs sections}
	    {body :=}
	    {braced_word := BracedWord}
	    {breaker := Breaker}
	    {c_arg :M {0 2} C_arg cx_arg C_closer}
	    {c_arg_def :M {0 3} C_arg_def cx_arg cx_arg C_closer}
	    {c_arg_def :M {0 4} C_arg_def cx_arg cx_arg cx_arg C_closer}
	    {c_call :M {0 2} C_call cx_args C_closer}
	    {c_category :M {0 2} C_category cx_arg C_closer}
	    {c_class :M {0 2} C_class cx_arg C_closer}
	    {c_cmd :M {0 2} C_cmd cx_arg C_closer}
	    {c_cmd_def :M {0 2} C_cmd_def cx_arg C_closer}
	    {c_const :M {0 2} C_const cx_arg C_closer}
	    {c_copyright :M {0 2} C_copyright cx_arg C_closer}
	    {c_def :M {0 2} C_def cx_arg C_closer}
	    {c_description :M 0 C_description}
	    {c_emph :M {0 2} C_emph cx_arg C_closer}
	    {c_enum :M 0 C_enum}
	    {c_example :M {0 2} C_example cx_arg C_closer}
	    {c_example_begin :M 0 C_example_begin}
	    {c_example_end :M 0 C_example_end}
	    {c_file :M {0 2} C_file cx_arg C_closer}
	    {c_fun :M {0 2} C_fun cx_arg C_closer}
	    {c_image :M {0 2} C_image cx_arg C_closer}
	    {c_image :M {0 3} C_image cx_arg cx_arg C_closer}
	    {c_include :M {0 2} C_include cx_arg C_closer}
	    {c_item :M 0 C_item}
	    {c_keywords :M {0 2} C_keywords cx_args C_closer}
	    {c_lb :M 0 C_lb}
	    {c_list_begin_arg :M {0 1 2} C_list_begin L_arguments C_closer}
	    {c_list_begin_cmd :M {0 1 2} C_list_begin L_commands C_closer}
	    {c_list_begin_def :M {0 1 2} C_list_begin L_definitions C_closer}
	    {c_list_begin_enum :M {0 1 2} C_list_begin L_enumerated C_closer}
	    {c_list_begin_item :M {0 1 2} C_list_begin L_itemized C_closer}
	    {c_list_begin_opt :M {0 1 2} C_list_begin L_options C_closer}
	    {c_list_begin_tko :M {0 1 2} C_list_begin L_tkoptions C_closer}
	    {c_list_end :M 0 C_list_end}
	    {c_manpage_begin :M {0 4} C_manpage_begin cx_arg cx_arg cx_arg C_closer}
	    {c_manpage_end :M 0 C_manpage_end}
	    {c_method :M {0 2} C_method cx_arg C_closer}
	    {c_moddesc :M {0 2} C_moddesc cx_arg C_closer}
	    {c_namespace :M {0 2} C_namespace cx_arg C_closer}
	    {c_opt :M {0 2} C_opt cx_arg C_closer}
	    {c_opt_def :M {0 2} C_opt_def cx_arg C_closer}
	    {c_opt_def :M {0 3} C_opt_def cx_arg cx_arg C_closer}
	    {c_option :M {0 2} C_option cx_arg C_closer}
	    {c_package :M {0 2} C_package cx_arg C_closer}
	    {c_para :M 0 C_nl}
	    {c_para :M 0 C_para}
	    {c_rb :M 0 C_rb}
	    {c_require :M {0 2} C_require cx_arg C_closer}
	    {c_require :M {0 3} C_require cx_arg cx_arg C_closer}
	    {c_section :M {0 2} C_section cx_arg C_closer}
	    {c_sectref :M {0 2} C_sectref cx_arg C_closer}
	    {c_sectref :M {0 3} C_sectref cx_arg cx_arg C_closer}
	    {c_sectref_ext :M {0 2} C_sectref_ext cx_arg C_closer}
	    {c_see_also :M {0 2} C_see_also cx_args C_closer}
	    {c_strong :M {0 2} C_strong cx_arg C_closer}
	    {c_subsection :M {0 2} C_subsection cx_arg C_closer}
	    {c_syscmd :M {0 2} C_syscmd cx_arg C_closer}
	    {c_term :M {0 2} C_term cx_arg C_closer}
	    {c_titledesc :M {0 2} C_titledesc cx_arg C_closer}
	    {c_tkoption_def :M {0 4} C_tkoption_def cx_arg cx_arg cx_arg C_closer}
	    {c_type :M {0 2} C_type cx_arg C_closer}
	    {c_uri :M {0 2} C_uri cx_arg C_closer}
	    {c_uri :M {0 3} C_uri cx_arg cx_arg C_closer}
	    {c_usage :M {0 2} C_usage cx_args C_closer}
	    {c_var :M {0 2} C_var cx_arg C_closer}
	    {c_vget :M {0 2} C_vset cx_arg C_closer}
	    {c_vset :M {0 3} C_vset cx_arg cx_arg C_closer}
	    {c_widget :M {0 2} C_widget cx_arg C_closer}
	    {cmd_list_elem := c_cmd_def paragraphs}
	    {command_list + cmd_list_elem}
	    {__ :A Afirst}
	    {cx_arg := braced_word}
	    {cx_arg := c_vget}
	    {cx_arg := markup}
	    {cx_arg := quoted_word}
	    {cx_arg := simple_word}
	    {__ :A {name values}}
	    {cx_args + cx_arg}
	    {def_list_elem := c_call paragraphs}
	    {def_list_elem := c_def paragraphs}
	    {definition := c_include}
	    {definition := c_vset}
	    {definition_list + def_list_elem}
	    {definitions * definition}
	    {enum_list + enum_list_elem}
	    {enum_list_elem :M 0 c_enum paragraphs}
	    {__ :A Afirst}
	    {example := c_example}
	    {example :M {0 2} c_example_begin example_text c_example_end}
	    {example_element := breaker}
	    {example_element := definition}
	    {example_element := general_text}
	    {example_element := markup}
	    {__ :A {name values}}
	    {example_text + example_element}
	    {general_text := GeneralText}
	    {__ :A Afirst}
	    {header := c_copyright}
	    {header := c_moddesc}
	    {header := c_require}
	    {header := c_titledesc}
	    {header := definition}
	    {header := xref}
	    {__ :A {name values}}
	    {headers * header}
	    {item_list + item_list_elem}
	    {item_list_elem :M 0 c_item paragraphs}
	    {__ :A Afirst}
	    {list :M {0 2} c_list_begin_arg argument_list c_list_end}
	    {list :M {0 2} c_list_begin_cmd command_list c_list_end}
	    {list :M {0 2} c_list_begin_def definition_list c_list_end}
	    {list :M {0 2} c_list_begin_enum enum_list c_list_end}
	    {list :M {0 2} c_list_begin_item item_list c_list_end}
	    {list :M {0 2} c_list_begin_opt option_list c_list_end}
	    {list :M {0 2} c_list_begin_tko tkoption_list c_list_end}
	    {__ :A {name values}}
	    {manpage :M {3 5} definitions c_manpage_begin headers c_description body c_manpage_end}
	    {__ :A Afirst}
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
	    {__ :A {name values}}
	    {opt_list_elem := c_opt_def paragraphs}
	    {option_list + opt_list_elem}
	    {p_separator :M 0 c_para}
	    {p_separator :M {0 1} c_para p_separator}
	    {paragraph + word}
	    {paragraphs + paragraph p_separator 1}
	    {quoted_element := Escaped}
	    {quoted_element := markup}
	    {quoted_element := SimpleWordPlusSpace}
	    {quoted_elements * quoted_element}
	    {quoted_word :M {0 2} Quote quoted_elements Quote}
	    {section := c_section}
	    {section := c_section paragraphs subsections}
	    {section := c_section paragraphs}
	    {section := c_section subsections}
	    {sections + section}
	    {simple_word := SimpleWord}
	    {subsection := c_subsection}
	    {subsection := c_subsection paragraphs}
	    {subsections + subsection}
	    {tko_list_elem := c_tkoption_def paragraphs}
	    {tkoption_list + tko_list_elem}
	    {__ :A Afirst}
	    {word := c_vget}
	    {word := definition}
	    {word := example}
	    {word := general_text}
	    {word := list}
	    {word := markup}
	    {word := xref}
	    {xref := c_category}
	    {xref := c_keywords}
	    {xref := c_see_also}
	}
    }

    method G1.Events {} {
	debug.doctools/parser/tcl
	# G1 parse event definitions (predicted, nulled, completed)
	# events = dict (symbol -> (e-type -> (e-name -> boolean)))
	# Each symbol can have more than one event per type.
	return {}
    }

    method Start {} {
	debug.doctools/parser/tcl
	# G1 start symbol
	return {manpage}
    }
}

# # ## ### ##### ######## #############
return