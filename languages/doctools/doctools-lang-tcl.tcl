# -*- tcl -*-
##
# This template is BSD-licensed.
# (c) 2017-present Template - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                          http://core.tcl.tk/akupries/
##
# (c) 2018 Grammar doctools::parser::tcl By Andreas Kupries
##
##	`marpa::runtime::tcl`-derived Parser for grammar "doctools::parser::tcl".
##	Generated On Thu Aug 23 23:02:46 PDT 2018
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
	    {@^CLS:<\173\175>.BMP}                   {[^\173\175]}
	    {@^CLS:<\t-\r\40\42\133-\135\173>.BMP}   {[^\t-\r\40\42\133-\135\173]}
	    {@CLS:<\n\r>}                            {[\n\r]}
	    {@CLS:<\t-\r\40>}                        {[\t-\r\40]}
	    {@CLS:<\t\40>}                           {[\t\40]}
	    {@RAN:<\ud800\udbff>}                    {[\ud800-\udbff]}
	    {@RAN:<\udc00\udfff>}                    {[\udc00-\udfff]}
	}
    }

    method Lexemes {} {
	debug.doctools/parser/tcl
	# Lexer API: Lexeme symbols (Cannot be terminal). G1 terminals
	return {
	    Braced          1
	    Bracel          1
	    Breaker         1
	    CArg            1
	    CArgDef         1
	    CCall           1
	    CCategory       1
	    CClass          1
	    CCmd            1
	    CCmdDef         1
	    CConst          1
	    CCopyright      1
	    CDef            1
	    CDescription    1
	    CDone           1
	    CEmph           1
	    CEnum           1
	    CExample        1
	    CExampleBegin   1
	    CExampleEnd     1
	    CFile           1
	    CFun            1
	    CImage          1
	    CInclude        0
	    CItem           1
	    CKeywords       1
	    Cl              1
	    CLb             1
	    CListBegin      1
	    CListEnd        1
	    CManpage        1
	    CManpageBegin   1
	    CManpageEnd     1
	    CMethod         1
	    CModdesc        1
	    CNamespace      1
	    CNl             1
	    COpt            1
	    COptDef         1
	    COption         1
	    CPackage        1
	    CPara           1
	    CRb             1
	    CRequire        1
	    CSection        1
	    CSectref        1
	    CSectrefExt     1
	    CSeeAlso        1
	    CStrong         1
	    CSubsection     1
	    CSysCmd         1
	    CTerm           1
	    CTitledesc      1
	    CTkoptDef       1
	    CType           1
	    CUri            1
	    CUsage          1
	    CVar            1
	    CVdef           0
	    CVref           0
	    CWidget         1
	    Escaped         1
	    LArg            1
	    LCmd            1
	    LDef            1
	    LEnum           1
	    LItem           1
	    LOpt            1
	    LTkopt          1
	    Nbsimplex       1
	    Nbspace         1
	    Quote           1
	    Simple          1
	    Simplex         1
	    Space           1
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
	    {@^CLS:<\173\175>}
	    {@^CLS:<\t-\r\40\42\133-\135\173>}
	    {@CLS:<\u10000-\u10ffff>.SMP}
	    {@STR:<\134\42>}
	    {@STR:<\134\133>}
	    {@STR:<\134\135>}
	    {@STR:<\134\173>}
	    {@STR:<\134\175>}
	    {@STR:<\r\n>}
	    @STR:<arg>
	    @STR:<arg_def>
	    @STR:<arguments>
	    @STR:<call>
	    @STR:<category>
	    @STR:<class>
	    @STR:<cmd>
	    @STR:<cmd_def>
	    @STR:<commands>
	    @STR:<comment>
	    @STR:<const>
	    @STR:<copyright>
	    @STR:<def>
	    @STR:<definitions>
	    @STR:<description>
	    @STR:<emph>
	    @STR:<enum>
	    @STR:<enumerated>
	    @STR:<example>
	    @STR:<example_begin>
	    @STR:<example_end>
	    @STR:<file>
	    @STR:<fun>
	    @STR:<image>
	    @STR:<include>
	    @STR:<item>
	    @STR:<itemized>
	    @STR:<keywords>
	    @STR:<lb>
	    @STR:<list_begin>
	    @STR:<list_end>
	    @STR:<manpage>
	    @STR:<manpage_begin>
	    @STR:<manpage_end>
	    @STR:<method>
	    @STR:<moddesc>
	    @STR:<namespace>
	    @STR:<nl>
	    @STR:<opt>
	    @STR:<opt_def>
	    @STR:<option>
	    @STR:<options>
	    @STR:<package>
	    @STR:<para>
	    @STR:<rb>
	    @STR:<require>
	    @STR:<section>
	    @STR:<sectref-external>
	    @STR:<sectref>
	    @STR:<see_also>
	    @STR:<strong>
	    @STR:<subsection>
	    @STR:<syscmd>
	    @STR:<term>
	    @STR:<titledesc>
	    @STR:<tkoption_def>
	    @STR:<tkoptions>
	    @STR:<type>
	    @STR:<uri>
	    @STR:<usage>
	    @STR:<var>
	    @STR:<vset>
	    @STR:<widget>
	    ANY_UNBRACED
	    BL
	    BR
	    BRACE_ESCAPED
	    BRACED
	    BRACED_ELEM
	    BRACED_ELEMS
	    BREAKER
	    C_ARG
	    C_ARGDEF
	    C_CALL
	    C_CATEGORY
	    C_CLASS
	    C_CMD
	    C_CMDDEF
	    C_CONST
	    C_COPYRIGHT
	    C_DEF
	    C_DESCRIPTION
	    C_EMPH
	    C_ENUM
	    C_EXAMPLE
	    C_EXAMPLE_BEGIN
	    C_EXAMPLE_END
	    C_FILE
	    C_FUN
	    C_IMAGE
	    C_ITEM
	    C_KEYWORDS
	    C_LB
	    C_LIST_BEGIN
	    C_LIST_END
	    C_MANPAGE
	    C_MANPAGE_BEGIN
	    C_MANPAGE_END
	    C_METHOD
	    C_MODDESC
	    C_NAMESPACE
	    C_NL
	    C_OPT
	    C_OPTDEF
	    C_OPTION
	    C_PACKAGE
	    C_PARA
	    C_RB
	    C_REQUIRE
	    C_SECTION
	    C_SECTREF
	    C_SECTREF_EXT
	    C_SEEALSO
	    C_STRONG
	    C_SUBSECTION
	    C_SYSCMD
	    C_TERM
	    C_TITLEDESC
	    C_TKOPTIONDEF
	    C_TYPE
	    C_URI
	    C_USAGE
	    C_VAR
	    C_WIDGET
	    CL
	    COMMAND
	    COMMENT
	    CONTINUATION
	    CR
	    ESCAPED
	    INCLUDE
	    L_ARG
	    L_CMD
	    L_DEF
	    L_ENUM
	    L_ITEM
	    L_OPT
	    L_TKOPT
	    NBSIMPLEN
	    NBSIMPLEX
	    NBSPACE
	    NBSPACE1
	    NEWLINE
	    QUOTE
	    QUOTED
	    QUOTED_ELEM
	    QUOTED_ELEMS
	    SIMPLE
	    SIMPLE_CHAR
	    SIMPLEN
	    SIMPLEX
	    SPACE
	    SPACE0
	    SPACE1
	    UNQUOTED
	    UNQUOTED_ELEM
	    UNQUOTED_ELEMS
	    UNQUOTED_LEAD
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
	debug.doctools/parser/tcl
	return {
	    {@STR:<arg> := @CHR:<a> @CHR:<r> @CHR:<g>}
	    {@STR:<arg_def> := @CHR:<a> @CHR:<r> @CHR:<g> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {@STR:<arguments> := @CHR:<a> @CHR:<r> @CHR:<g> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t> @CHR:<s>}
	    {@STR:<call> := @CHR:<c> @CHR:<a> @CHR:<l> @CHR:<l>}
	    {@STR:<category> := @CHR:<c> @CHR:<a> @CHR:<t> @CHR:<e> @CHR:<g> @CHR:<o> @CHR:<r> @CHR:<y>}
	    {@STR:<class> := @CHR:<c> @CHR:<l> @CHR:<a> @CHR:<s> @CHR:<s>}
	    {@STR:<cmd> := @CHR:<c> @CHR:<m> @CHR:<d>}
	    {@STR:<cmd_def> := @CHR:<c> @CHR:<m> @CHR:<d> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {@STR:<commands> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<d> @CHR:<s>}
	    {@STR:<comment> := @CHR:<c> @CHR:<o> @CHR:<m> @CHR:<m> @CHR:<e> @CHR:<n> @CHR:<t>}
	    {@STR:<const> := @CHR:<c> @CHR:<o> @CHR:<n> @CHR:<s> @CHR:<t>}
	    {@STR:<copyright> := @CHR:<c> @CHR:<o> @CHR:<p> @CHR:<y> @CHR:<r> @CHR:<i> @CHR:<g> @CHR:<h> @CHR:<t>}
	    {@STR:<def> := @CHR:<d> @CHR:<e> @CHR:<f>}
	    {@STR:<definitions> := @CHR:<d> @CHR:<e> @CHR:<f> @CHR:<i> @CHR:<n> @CHR:<i> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {@STR:<description> := @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c> @CHR:<r> @CHR:<i> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {@STR:<emph> := @CHR:<e> @CHR:<m> @CHR:<p> @CHR:<h>}
	    {@STR:<enum> := @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m>}
	    {@STR:<enumerated> := @CHR:<e> @CHR:<n> @CHR:<u> @CHR:<m> @CHR:<e> @CHR:<r> @CHR:<a> @CHR:<t> @CHR:<e> @CHR:<d>}
	    {@STR:<example> := @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e>}
	    {@STR:<example_begin> := @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {@STR:<example_end> := @CHR:<e> @CHR:<x> @CHR:<a> @CHR:<m> @CHR:<p> @CHR:<l> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {@STR:<file> := @CHR:<f> @CHR:<i> @CHR:<l> @CHR:<e>}
	    {@STR:<fun> := @CHR:<f> @CHR:<u> @CHR:<n>}
	    {@STR:<image> := @CHR:<i> @CHR:<m> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {@STR:<include> := @CHR:<i> @CHR:<n> @CHR:<c> @CHR:<l> @CHR:<u> @CHR:<d> @CHR:<e>}
	    {@STR:<item> := @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m>}
	    {@STR:<itemized> := @CHR:<i> @CHR:<t> @CHR:<e> @CHR:<m> @CHR:<i> @CHR:<z> @CHR:<e> @CHR:<d>}
	    {@STR:<keywords> := @CHR:<k> @CHR:<e> @CHR:<y> @CHR:<w> @CHR:<o> @CHR:<r> @CHR:<d> @CHR:<s>}
	    {@STR:<lb> := @CHR:<l> @CHR:<b>}
	    {@STR:<list_begin> := @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {@STR:<list_end> := @CHR:<l> @CHR:<i> @CHR:<s> @CHR:<t> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {@STR:<manpage> := @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {@STR:<manpage_begin> := @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<b> @CHR:<e> @CHR:<g> @CHR:<i> @CHR:<n>}
	    {@STR:<manpage_end> := @CHR:<m> @CHR:<a> @CHR:<n> @CHR:<p> @CHR:<a> @CHR:<g> @CHR:<e> @CHR:<_> @CHR:<e> @CHR:<n> @CHR:<d>}
	    {@STR:<method> := @CHR:<m> @CHR:<e> @CHR:<t> @CHR:<h> @CHR:<o> @CHR:<d>}
	    {@STR:<moddesc> := @CHR:<m> @CHR:<o> @CHR:<d> @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c>}
	    {@STR:<namespace> := @CHR:<n> @CHR:<a> @CHR:<m> @CHR:<e> @CHR:<s> @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<e>}
	    {@STR:<nl> := @CHR:<n> @CHR:<l>}
	    {@STR:<opt> := @CHR:<o> @CHR:<p> @CHR:<t>}
	    {@STR:<opt_def> := @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {@STR:<option> := @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {@STR:<options> := @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {@STR:<package> := @CHR:<p> @CHR:<a> @CHR:<c> @CHR:<k> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {@STR:<para> := @CHR:<p> @CHR:<a> @CHR:<r> @CHR:<a>}
	    {@STR:<rb> := @CHR:<r> @CHR:<b>}
	    {@STR:<require> := @CHR:<r> @CHR:<e> @CHR:<q> @CHR:<u> @CHR:<i> @CHR:<r> @CHR:<e>}
	    {@STR:<section> := @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {@STR:<sectref-external> := @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<r> @CHR:<e> @CHR:<f> @CHR:<-> @CHR:<e> @CHR:<x> @CHR:<t> @CHR:<e> @CHR:<r> @CHR:<n> @CHR:<a> @CHR:<l>}
	    {@STR:<sectref> := @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<r> @CHR:<e> @CHR:<f>}
	    {@STR:<see_also> := @CHR:<s> @CHR:<e> @CHR:<e> @CHR:<_> @CHR:<a> @CHR:<l> @CHR:<s> @CHR:<o>}
	    {@STR:<strong> := @CHR:<s> @CHR:<t> @CHR:<r> @CHR:<o> @CHR:<n> @CHR:<g>}
	    {@STR:<subsection> := @CHR:<s> @CHR:<u> @CHR:<b> @CHR:<s> @CHR:<e> @CHR:<c> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n>}
	    {@STR:<syscmd> := @CHR:<s> @CHR:<y> @CHR:<s> @CHR:<c> @CHR:<m> @CHR:<d>}
	    {@STR:<term> := @CHR:<t> @CHR:<e> @CHR:<r> @CHR:<m>}
	    {@STR:<titledesc> := @CHR:<t> @CHR:<i> @CHR:<t> @CHR:<l> @CHR:<e> @CHR:<d> @CHR:<e> @CHR:<s> @CHR:<c>}
	    {@STR:<tkoption_def> := @CHR:<t> @CHR:<k> @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<_> @CHR:<d> @CHR:<e> @CHR:<f>}
	    {@STR:<tkoptions> := @CHR:<t> @CHR:<k> @CHR:<o> @CHR:<p> @CHR:<t> @CHR:<i> @CHR:<o> @CHR:<n> @CHR:<s>}
	    {@STR:<type> := @CHR:<t> @CHR:<y> @CHR:<p> @CHR:<e>}
	    {@STR:<uri> := @CHR:<u> @CHR:<r> @CHR:<i>}
	    {@STR:<usage> := @CHR:<u> @CHR:<s> @CHR:<a> @CHR:<g> @CHR:<e>}
	    {@STR:<var> := @CHR:<v> @CHR:<a> @CHR:<r>}
	    {@STR:<vset> := @CHR:<v> @CHR:<s> @CHR:<e> @CHR:<t>}
	    {@STR:<widget> := @CHR:<w> @CHR:<i> @CHR:<d> @CHR:<g> @CHR:<e> @CHR:<t>}
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
	    {Bracel := BL}
	    {Breaker := BREAKER}
	    {BREAKER := NEWLINE SPACE1}
	    {C_ARG := @STR:<arg>}
	    {C_ARGDEF := @STR:<arg_def>}
	    {C_CALL := @STR:<call>}
	    {C_CATEGORY := @STR:<category>}
	    {C_CLASS := @STR:<class>}
	    {C_CMD := @STR:<cmd>}
	    {C_CMDDEF := @STR:<cmd_def>}
	    {C_CONST := @STR:<const>}
	    {C_COPYRIGHT := @STR:<copyright>}
	    {C_DEF := @STR:<def>}
	    {C_DESCRIPTION := @STR:<description>}
	    {C_EMPH := @STR:<emph>}
	    {C_ENUM := @STR:<enum>}
	    {C_EXAMPLE := @STR:<example>}
	    {C_EXAMPLE_BEGIN := @STR:<example_begin>}
	    {C_EXAMPLE_END := @STR:<example_end>}
	    {C_FILE := @STR:<file>}
	    {C_FUN := @STR:<fun>}
	    {C_IMAGE := @STR:<image>}
	    {C_ITEM := @STR:<item>}
	    {C_KEYWORDS := @STR:<keywords>}
	    {C_LB := @STR:<lb>}
	    {C_LIST_BEGIN := @STR:<list_begin>}
	    {C_LIST_END := @STR:<list_end>}
	    {C_MANPAGE := @STR:<manpage>}
	    {C_MANPAGE_BEGIN := @STR:<manpage_begin>}
	    {C_MANPAGE_END := @STR:<manpage_end>}
	    {C_METHOD := @STR:<method>}
	    {C_MODDESC := @STR:<moddesc>}
	    {C_NAMESPACE := @STR:<namespace>}
	    {C_NL := @STR:<nl>}
	    {C_OPT := @STR:<opt>}
	    {C_OPTDEF := @STR:<opt_def>}
	    {C_OPTION := @STR:<option>}
	    {C_PACKAGE := @STR:<package>}
	    {C_PARA := @STR:<para>}
	    {C_RB := @STR:<rb>}
	    {C_REQUIRE := @STR:<require>}
	    {C_SECTION := @STR:<section>}
	    {C_SECTREF := @STR:<sectref>}
	    {C_SECTREF_EXT := @STR:<sectref-external>}
	    {C_SEEALSO := @STR:<see_also>}
	    {C_STRONG := @STR:<strong>}
	    {C_SUBSECTION := @STR:<subsection>}
	    {C_SYSCMD := @STR:<syscmd>}
	    {C_TERM := @STR:<term>}
	    {C_TITLEDESC := @STR:<titledesc>}
	    {C_TKOPTIONDEF := @STR:<tkoption_def>}
	    {C_TYPE := @STR:<type>}
	    {C_URI := @STR:<uri>}
	    {C_USAGE := @STR:<usage>}
	    {C_VAR := @STR:<var>}
	    {C_WIDGET := @STR:<widget>}
	    {CArg := C_ARG}
	    {CArgDef := C_ARGDEF}
	    {CCall := C_CALL}
	    {CCategory := C_CATEGORY}
	    {CClass := C_CLASS}
	    {CCmd := C_CMD}
	    {CCmdDef := C_CMDDEF}
	    {CConst := C_CONST}
	    {CCopyright := C_COPYRIGHT}
	    {CDef := C_DEF}
	    {CDescription := C_DESCRIPTION}
	    {CDone := CR}
	    {CEmph := C_EMPH}
	    {CEnum := C_ENUM}
	    {CExample := C_EXAMPLE}
	    {CExampleBegin := C_EXAMPLE_BEGIN}
	    {CExampleEnd := C_EXAMPLE_END}
	    {CFile := C_FILE}
	    {CFun := C_FUN}
	    {CImage := C_IMAGE}
	    {CInclude := INCLUDE}
	    {CItem := C_ITEM}
	    {CKeywords := C_KEYWORDS}
	    {Cl := CL}
	    {CL := {@CHR:<\133>}}
	    {CLb := C_LB}
	    {CListBegin := C_LIST_BEGIN}
	    {CListEnd := C_LIST_END}
	    {CManpage := C_MANPAGE}
	    {CManpageBegin := C_MANPAGE_BEGIN}
	    {CManpageEnd := C_MANPAGE_END}
	    {CMethod := C_METHOD}
	    {CModdesc := C_MODDESC}
	    {CNamespace := C_NAMESPACE}
	    {CNl := C_NL}
	    {COMMAND := CL WHITE0 WORDS1 WHITE0 CR}
	    {COMMENT := CL WHITE0 @STR:<comment> WHITE1 WORD WHITE0 CR}
	    {CONTINUATION := SPACE0 {@CHR:<\134>} NEWLINE SPACE0}
	    {COpt := C_OPT}
	    {COptDef := C_OPTDEF}
	    {COption := C_OPTION}
	    {CPackage := C_PACKAGE}
	    {CPara := C_PARA}
	    {CR := {@CHR:<\135>}}
	    {CRb := C_RB}
	    {CRequire := C_REQUIRE}
	    {CSection := C_SECTION}
	    {CSectref := C_SECTREF}
	    {CSectrefExt := C_SECTREF_EXT}
	    {CSeeAlso := C_SEEALSO}
	    {CStrong := C_STRONG}
	    {CSubsection := C_SUBSECTION}
	    {CSysCmd := C_SYSCMD}
	    {CTerm := C_TERM}
	    {CTitledesc := C_TITLEDESC}
	    {CTkoptDef := C_TKOPTIONDEF}
	    {CType := C_TYPE}
	    {CUri := C_URI}
	    {CUsage := C_USAGE}
	    {CVar := C_VAR}
	    {CVdef := VAR_DEF}
	    {CVref := VAR_REF}
	    {CWidget := C_WIDGET}
	    {Escaped := ESCAPED}
	    {ESCAPED := {@CHR:<\134>}}
	    {ESCAPED := {@STR:<\134\42>}}
	    {ESCAPED := {@STR:<\134\133>}}
	    {ESCAPED := {@STR:<\134\135>}}
	    {INCLUDE := CL WHITE0 @STR:<include> WHITE1 WORD WHITE0 CR}
	    {L_ARG := @STR:<arguments>}
	    {L_CMD := @STR:<commands>}
	    {L_DEF := @STR:<definitions>}
	    {L_ENUM := @STR:<enum>}
	    {L_ENUM := @STR:<enumerated>}
	    {L_ITEM := @STR:<itemized>}
	    {L_OPT := @STR:<options>}
	    {L_TKOPT := @STR:<tkoptions>}
	    {LArg := L_ARG}
	    {LCmd := L_CMD}
	    {LDef := L_DEF}
	    {LEnum := L_ENUM}
	    {LItem := L_ITEM}
	    {LOpt := L_OPT}
	    {LTkopt := L_TKOPT}
	    {NBSIMPLEN + SIMPLE NBSPACE1 0}
	    {Nbsimplex := NBSIMPLEX}
	    {NBSIMPLEX := SIMPLE NBSPACE1 NBSIMPLEN}
	    {NBSIMPLEX := SPACE1 SIMPLE NBSPACE1 NBSIMPLEN}
	    {Nbspace := NBSPACE}
	    {NBSPACE := {@CLS:<\t\40>}}
	    {NBSPACE1 + NBSPACE}
	    {NEWLINE := {@CLS:<\n\r>}}
	    {NEWLINE := {@STR:<\r\n>}}
	    {Quote := QUOTE}
	    {QUOTE := {@CHR:<\42>}}
	    {QUOTED := QUOTE QUOTED_ELEMS QUOTE}
	    {QUOTED_ELEM := BL}
	    {QUOTED_ELEM := COMMAND}
	    {QUOTED_ELEM := ESCAPED}
	    {QUOTED_ELEM := SIMPLE_CHAR}
	    {QUOTED_ELEM := SPACE}
	    {QUOTED_ELEMS * QUOTED_ELEM}
	    {SIMPLE + SIMPLE_CHAR}
	    {Simple := SIMPLE}
	    {SIMPLE_CHAR := {@^CLS:<\t-\r\40\42\133-\135\173>}}
	    {SIMPLEN + SIMPLE SPACE1 0}
	    {SIMPLEX := SIMPLE SPACE1 SIMPLEN}
	    {Simplex := SIMPLEX}
	    {SIMPLEX := SPACE1 SIMPLE SPACE1 SIMPLEN}
	    {Space := SPACE1}
	    {SPACE := {@CLS:<\t-\r\40>}}
	    {SPACE0 * SPACE}
	    {SPACE1 + SPACE}
	    {UNQUOTED := UNQUOTED_LEAD}
	    {UNQUOTED := UNQUOTED_LEAD UNQUOTED_ELEMS}
	    {UNQUOTED_ELEM := BL}
	    {UNQUOTED_ELEM := QUOTE}
	    {UNQUOTED_ELEM := UNQUOTED_LEAD}
	    {UNQUOTED_ELEMS + UNQUOTED_ELEM}
	    {UNQUOTED_LEAD := COMMAND}
	    {UNQUOTED_LEAD := ESCAPED}
	    {UNQUOTED_LEAD := SIMPLE_CHAR}
	    {VAR_DEF := CL WHITE0 @STR:<vset> WHITE1 WORD WHITE1 WORD WHITE0 CR}
	    {VAR_REF := CL WHITE0 @STR:<vset> WHITE1 WORD WHITE0 CR}
	    {WHITE := COMMENT}
	    {WHITE := CONTINUATION}
	    {WHITE := SPACE}
	    {WHITE0 * WHITE}
	    {WHITE1 + WHITE}
	    {Whitespace := WHITE1}
	    {WORD := BRACED}
	    {WORD := QUOTED}
	    {WORD := UNQUOTED}
	    {WORDS1 + WORD WHITE1 0}
	    {{@^CLS:<\173\175>} := {@^CLS:<\173\175>.BMP}}
	    {{@^CLS:<\173\175>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@^CLS:<\t-\r\40\42\133-\135\173>} := {@^CLS:<\t-\r\40\42\133-\135\173>.BMP}}
	    {{@^CLS:<\t-\r\40\42\133-\135\173>} := {@CLS:<\u10000-\u10ffff>.SMP}}
	    {{@CLS:<\u10000-\u10ffff>.SMP} := {@RAN:<\ud800\udbff>} {@RAN:<\udc00\udfff>}}
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
	return {
	    CInclude {
	        after {special on}
	    }
	    CVdef {
	        after {special on}
	    }
	    CVref {
	        after {special on}
	    }
	}
    }

    method G1.Symbols {} {
	# Structural symbols
	debug.doctools/parser/tcl
	return {
	    arg_list_elem
	    argument_list
	    body
	    braced
	    bracel
	    breaker
	    cmd_list_elem
	    command_list
	    def_list_elem
	    definition_list
	    enum_list
	    enum_list_elem
	    escaped
	    example
	    example_element
	    example_text
	    g_text
	    header
	    headers
	    item_list
	    item_list_elem
	    list
	    m_arg
	    m_arg_def
	    m_call
	    m_category
	    m_class
	    m_cmd
	    m_cmd_def
	    m_const
	    m_copyright
	    m_def
	    m_description
	    m_emph
	    m_enum
	    m_example
	    m_example_begin
	    m_example_end
	    m_file
	    m_fun
	    m_image
	    m_item
	    m_keywords
	    m_lb
	    m_list_begin_arg
	    m_list_begin_cmd
	    m_list_begin_def
	    m_list_begin_enum
	    m_list_begin_item
	    m_list_begin_opt
	    m_list_begin_tko
	    m_list_end
	    m_manpage
	    m_manpage_begin
	    m_manpage_end
	    m_method
	    m_moddesc
	    m_namespace
	    m_opt
	    m_opt_def
	    m_option
	    m_package
	    m_para
	    m_rb
	    m_require
	    m_section
	    m_sectref
	    m_sectref_ext
	    m_see_also
	    m_strong
	    m_subsection
	    m_syscmd
	    m_term
	    m_titledesc
	    m_tkoption_def
	    m_type
	    m_uri
	    m_usage
	    m_var
	    m_widget
	    manpage
	    markup
	    nbsimplex
	    nbspace
	    opt_list_elem
	    option_list
	    p_separator
	    paragraph
	    paragraphs
	    quote
	    quoted
	    quoted_elem
	    quoted_elems
	    section
	    sections
	    simple
	    simplex
	    space
	    subsection
	    subsections
	    tclword
	    tclwords
	    tko_list_elem
	    tkoption_list
	    unquoted
	    unquoted_elem
	    unquoted_elems
	    unquoted_lead
	    word
	    xref
	}
    }

    method G1.Rules {} {
	# Structural rules, including actions, masks, and names
	debug.doctools/parser/tcl
	return {
	    {__ :A {name values}}
	    {arg_list_elem := m_arg_def paragraphs}
	    {argument_list + arg_list_elem}
	    {body :M 0 m_description}
	    {body :M 0 m_description paragraphs sections}
	    {body :M 0 m_description paragraphs subsections sections}
	    {body :M 0 m_description paragraphs subsections}
	    {body :M 0 m_description paragraphs}
	    {body :M 0 m_description sections}
	    {body :M 0 m_description subsections sections}
	    {body :M 0 m_description subsections}
	    {braced := Braced}
	    {bracel := Bracel}
	    {breaker := Breaker}
	    {cmd_list_elem := m_cmd_def paragraphs}
	    {command_list + cmd_list_elem}
	    {def_list_elem := m_call paragraphs}
	    {def_list_elem := m_def paragraphs}
	    {definition_list + def_list_elem}
	    {enum_list + enum_list_elem}
	    {enum_list_elem :M 0 m_enum paragraphs}
	    {escaped := Escaped}
	    {__ :A Afirst}
	    {example := m_example}
	    {example :M {0 2} m_example_begin example_text m_example_end}
	    {example_element := bracel}
	    {example_element := breaker}
	    {example_element := markup}
	    {example_element := nbsimplex}
	    {example_element := nbspace}
	    {example_element := quote}
	    {example_element := simple}
	    {__ :A {name values}}
	    {example_text + example_element}
	    {__ :A Afirst}
	    {g_text := bracel}
	    {g_text := quote}
	    {g_text := simple}
	    {g_text := simplex}
	    {g_text := space}
	    {header := m_copyright}
	    {header := m_moddesc}
	    {header := m_require}
	    {header := m_titledesc}
	    {header := xref}
	    {__ :A {name values}}
	    {headers * header}
	    {item_list + item_list_elem}
	    {item_list_elem :M 0 m_item paragraphs}
	    {__ :A Afirst}
	    {list :M {0 2} m_list_begin_arg argument_list m_list_end}
	    {list :M {0 2} m_list_begin_cmd command_list m_list_end}
	    {list :M {0 2} m_list_begin_def definition_list m_list_end}
	    {list :M {0 2} m_list_begin_enum enum_list m_list_end}
	    {list :M {0 2} m_list_begin_item item_list m_list_end}
	    {list :M {0 2} m_list_begin_opt option_list m_list_end}
	    {list :M {0 2} m_list_begin_tko tkoption_list m_list_end}
	    {__ :A {name values}}
	    {m_arg :M {0 1 2 4} Cl CArg Space tclword CDone}
	    {m_arg_def :M {0 1 2 4 6} Cl CArgDef Space tclword Space tclword CDone}
	    {m_arg_def :M {0 1 2 4 6 8} Cl CArgDef Space tclword Space tclword Space tclword CDone}
	    {m_call :M {0 1 2 4} Cl CCall Space tclwords CDone}
	    {m_category :M {0 1 2 4} Cl CCategory Space tclword CDone}
	    {m_class :M {0 1 2 4} Cl CClass Space tclword CDone}
	    {m_cmd :M {0 1 2 4} Cl CCmd Space tclword CDone}
	    {m_cmd_def :M {0 1 2 4} Cl CCmdDef Space tclword CDone}
	    {m_const :M {0 1 2 4} Cl CConst Space tclword CDone}
	    {m_copyright :M {0 1 2 4} Cl CCopyright Space tclword CDone}
	    {m_def :M {0 1 2 4} Cl CDef Space tclword CDone}
	    {m_description :M {0 1 2} Cl CDescription CDone}
	    {m_emph :M {0 1 2 4} Cl CEmph Space tclword CDone}
	    {m_enum :M {0 1 2} Cl CEnum CDone}
	    {m_example :M {0 1 2 4} Cl CExample Space tclword CDone}
	    {m_example_begin :M {0 1 2} Cl CExampleBegin CDone}
	    {m_example_end :M {0 1 2} Cl CExampleEnd CDone}
	    {m_file :M {0 1 2 4} Cl CFile Space tclword CDone}
	    {m_fun :M {0 1 2 4} Cl CFun Space tclword CDone}
	    {m_image :M {0 1 2 4} Cl CImage Space tclword CDone}
	    {m_image :M {0 1 2 4 6} Cl CImage Space tclword Space tclword CDone}
	    {m_item :M {0 1 2} Cl CItem CDone}
	    {m_keywords :M {0 1 2 4} Cl CKeywords Space tclwords CDone}
	    {m_lb :M {0 1 2} Cl CLb CDone}
	    {m_list_begin_arg :M {0 1 2 3 4} Cl CListBegin Space LArg CDone}
	    {m_list_begin_cmd :M {0 1 2 3 4} Cl CListBegin Space LCmd CDone}
	    {m_list_begin_def :M {0 1 2 3 4} Cl CListBegin Space LDef CDone}
	    {m_list_begin_enum :M {0 1 2 3 4} Cl CListBegin Space LEnum CDone}
	    {m_list_begin_item :M {0 1 2 3 4} Cl CListBegin Space LItem CDone}
	    {m_list_begin_opt :M {0 1 2 3 4} Cl CListBegin Space LOpt CDone}
	    {m_list_begin_tko :M {0 1 2 3 4} Cl CListBegin Space LTkopt CDone}
	    {m_list_end :M {0 1 2} Cl CListEnd CDone}
	    {m_manpage :M {0 1 2 4} Cl CManpage Space tclword CDone}
	    {m_manpage_begin :M {0 1 2 4 6 8} Cl CManpageBegin Space tclword Space tclword Space tclword CDone}
	    {m_manpage_end :M {0 1 2} Cl CManpageEnd CDone}
	    {m_method :M {0 1 2 4} Cl CMethod Space tclword CDone}
	    {m_moddesc :M {0 1 2 4} Cl CModdesc Space tclword CDone}
	    {m_namespace :M {0 1 2 4} Cl CNamespace Space tclword CDone}
	    {m_opt :M {0 1 2 4} Cl COpt Space tclword CDone}
	    {m_opt_def :M {0 1 2 4} Cl COptDef Space tclword CDone}
	    {m_opt_def :M {0 1 2 4 6} Cl COptDef Space tclword Space tclword CDone}
	    {m_option :M {0 1 2 4} Cl COption Space tclword CDone}
	    {m_package :M {0 1 2 4} Cl CPackage Space tclword CDone}
	    {m_para :M {0 1 2} Cl CNl CDone}
	    {m_para :M {0 1 2} Cl CPara CDone}
	    {m_rb :M {0 1 2} Cl CRb CDone}
	    {m_require :M {0 1 2 4} Cl CRequire Space tclword CDone}
	    {m_require :M {0 1 2 4 6} Cl CRequire Space tclword Space tclword CDone}
	    {m_section :M {0 1 2 4} Cl CSection Space tclword CDone}
	    {m_sectref :M {0 1 2 4} Cl CSectref Space tclword CDone}
	    {m_sectref :M {0 1 2 4 6} Cl CSectref Space tclword Space tclword CDone}
	    {m_sectref_ext :M {0 1 2 4} Cl CSectrefExt Space tclword CDone}
	    {m_see_also :M {0 1 2 4} Cl CSeeAlso Space tclwords CDone}
	    {m_strong :M {0 1 2 4} Cl CStrong Space tclword CDone}
	    {m_subsection :M {0 1 2 4} Cl CSubsection Space tclword CDone}
	    {m_syscmd :M {0 1 2 4} Cl CSysCmd Space tclword CDone}
	    {m_term :M {0 1 2 4} Cl CTerm Space tclword CDone}
	    {m_titledesc :M {0 1 2 4} Cl CTitledesc Space tclword CDone}
	    {m_tkoption_def :M {0 1 2 4 6 8} Cl CTkoptDef Space tclword Space tclword Space tclword CDone}
	    {m_type :M {0 1 2 4} Cl CType Space tclword CDone}
	    {m_uri :M {0 1 2 4} Cl CUri Space tclword CDone}
	    {m_uri :M {0 1 2 4 6} Cl CUri Space tclword Space tclword CDone}
	    {m_usage :M {0 1 2 4} Cl CUsage Space tclwords CDone}
	    {m_var :M {0 1 2 4} Cl CVar Space tclword CDone}
	    {m_widget :M {0 1 2 4} Cl CWidget Space tclword CDone}
	    {manpage :M 3 m_manpage_begin headers body m_manpage_end}
	    {__ :A Afirst}
	    {markup := m_arg}
	    {markup := m_class}
	    {markup := m_cmd}
	    {markup := m_const}
	    {markup := m_emph}
	    {markup := m_file}
	    {markup := m_fun}
	    {markup := m_image}
	    {markup := m_lb}
	    {markup := m_manpage}
	    {markup := m_method}
	    {markup := m_namespace}
	    {markup := m_opt}
	    {markup := m_option}
	    {markup := m_package}
	    {markup := m_rb}
	    {markup := m_sectref}
	    {markup := m_sectref_ext}
	    {markup := m_strong}
	    {markup := m_syscmd}
	    {markup := m_term}
	    {markup := m_type}
	    {markup := m_uri}
	    {markup := m_usage}
	    {markup := m_var}
	    {markup := m_widget}
	    {__ :A {name values}}
	    {nbsimplex := Nbsimplex}
	    {nbspace := Nbspace}
	    {opt_list_elem := m_opt_def paragraphs}
	    {option_list + opt_list_elem}
	    {p_separator :M 0 m_para}
	    {p_separator :M {0 1} m_para p_separator}
	    {paragraph + word}
	    {paragraphs + paragraph p_separator 1}
	    {quote := Quote}
	    {quoted :M {0 2} Quote quoted_elems Quote}
	    {__ :A Afirst}
	    {quoted_elem := bracel}
	    {quoted_elem := escaped}
	    {quoted_elem := markup}
	    {quoted_elem := simple}
	    {quoted_elem := space}
	    {__ :A {name values}}
	    {quoted_elems * quoted_elem}
	    {section := m_section}
	    {section := m_section paragraphs subsections}
	    {section := m_section paragraphs}
	    {section := m_section subsections}
	    {sections + section}
	    {simple := Simple}
	    {simplex := Simplex}
	    {space := Space}
	    {subsection := m_subsection}
	    {subsection := m_subsection paragraphs}
	    {subsections + subsection}
	    {__ :A Afirst}
	    {tclword := braced}
	    {tclword := quoted}
	    {tclword := unquoted}
	    {__ :A {name values}}
	    {tclwords + tclword space 1}
	    {tko_list_elem := m_tkoption_def paragraphs}
	    {tkoption_list + tko_list_elem}
	    {__ :A Afirst}
	    {unquoted := unquoted_lead}
	    {__ :A {name values}}
	    {unquoted := unquoted_lead unquoted_elems}
	    {__ :A Afirst}
	    {unquoted_elem := bracel}
	    {unquoted_elem := quote}
	    {unquoted_elem := unquoted_lead}
	    {__ :A {name values}}
	    {unquoted_elems + unquoted_elem}
	    {__ :A Afirst}
	    {unquoted_lead := escaped}
	    {unquoted_lead := markup}
	    {unquoted_lead := simple}
	    {word := example}
	    {word := g_text}
	    {word := list}
	    {word := markup}
	    {word := xref}
	    {xref := m_category}
	    {xref := m_keywords}
	    {xref := m_see_also}
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