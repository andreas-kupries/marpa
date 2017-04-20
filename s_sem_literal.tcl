# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Semantics. Processing of literals.

# Literals are compiled into tagged tuple structures, simplified and
# then entered into the container associated with the semantics the
# processor is part of. The internal forms are:
#
# - "string" (codepoint...) nocase
# - "character" codepoint
# - "charclass" (cc-element) nocase
# where
#    cc-element = A: codepoint             - character
#               | B: (codepoint codepoint) - range
#               | C: name                  - named-cc
#               | D: ^name                 - named-cc
#
# D is technically the same as C, just treat ^ as part of the name.
#
# The rules for simplification are
#
# | Id | Type     | Nocase | Other     | Result                    | Note |
# |---:|----------|--------|-----------|---------------------------|------|
# |  1 | string   | 0      | len==1    | character                 |      |
# |  2 | string   | 0      | len>1     | sequence (character)      |      |
# |  3 | string   | 1      | len==1    | charclass/case            |      |
# |  4 | string   | 1      | len>1     | sequence (cc/case)        |      |
# |  5 | cclass   | 0      | len==1    | cc-elem itself            |      |
# |  6 | cclass   | 0      | *         | alternation (cc-elem)     |      |
# |  7 | cclass   | 1      | *         | alternation(cc-el/nocase) |      |
# |  8 | char     | -      | -         | nothing to do, simplest   |      |
# |  9 | range    | -      | -         | alternation(char)         | [1]  |
# | 10 | named-cc | -      | -         | Inline definition         | [1]  |
#
# [1] Reducing this one early/eager is likely not a good idea
#     (large ranges, classes) Better to defer the decision on this to
#     the generator consuming the grammar as it knows what the engine
#     itself will support.
#
# Important point of the simplification: After it is done we do not have a
# nocase-flag anywhere. (Except implied in the name of a named-cc).

# Type-coding used in the symbols for literals and literal-composites:
#
# | Type      | Coding    | Note     |
# |-----------|-----------|----------|
# | character | @chr<...> |          |
# | namedcc   | @ncc<...> |          |
# | range     | @int<...> | INTerval |

# | Type      | Coding    | Note     |
# |-----------|-----------|----------|
# | string    | @str<...> |          |
# | charclass | @cls<...> |          |
#

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require char          ;# quoting cstring - debugging narrative
package require oo::util      ;# mymethod

debug define marpa/slif/semantics/literal
#debug prefix marpa/slif/semantics/literal {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::semantics::Literal {
    marpa::E marpa/slif/semantics/literal SLIF SEMANTICS LITERAL

    # - -- --- ----- -------- -------------
    # Lifecycle

    constructor {container def use symtrack} {
	debug.marpa/slif/semantics/literal {}

	marpa::import $container Container
	marpa::import $def       Definition
	marpa::import $use       Usage
	marpa::import $symtrack  Symbol

	# Make the helper methods directly accessible
	foreach m {
	    PARSE-MODS PARSE-TYPE FIX-ESCAPES
	    PARSE-STRING PARSE-CHARCLASS CHAR CCODE CFOLD RANGES
	    MAKE-SYMBOL RECODE ENTER
	} { link [list $m $m] }

	# Type coding information for MAKE-SYMBOL
	set mytypecode {
	    character @CHR
	    namedcc   @NCC
	    range     @INT
	    string    @STR
	    charclass @CLS
	}
	return
    }

    variable mytypecode

    # - -- --- ----- -------- -------------
    # API

    # PARSE-MODS, PARSE-TYPE, FIX-ESCAPES, PARSE-<type>,
    # (simplify), MAKE-SYMBOL, ENTER

    method enter {literal start length} {
	debug.marpa/slif/semantics/literal {}

	# State variables (argument is one as well)
	set lwork   $literal
	set nocase  .
	set ltype   .
	set ldata   .
	# TODO inverted  - part of the simplification process
	PARSE-MODS  lwork ;# -> nocase
	PARSE-TYPE  lwork ;# -> ltype
	FIX-ESCAPES lwork
	switch -exact -- $ltype {
	    string    { PARSE-STRING    lwork }
	    charclass { PARSE-CHARCLASS lwork }
	}
	# TODO: Simplify the state
	return [ENTER [MAKE-SYMBOL]]
    }

    # - -- --- ----- -------- -------------
    # Helpers

    method ENTER {litsymbol} {
	upvar 1 ltype ltype ldata ldata start start length length literal literal

	Usage      add $start $length  $literal $litsymbol
	Definition add $start $length  $literal $litsymbol

	# The literal is (always) a terminal in the L0 grammar.
	# Create it only once, when it is encountred the 1st time.
	if {[Symbol context1 <literal> $litsymbol] eq "undef"} {
	    Container l0 $ltype $litsymbol {*}$ldata
	}
	return $litsymbol
    }

    method MAKE-SYMBOL {} {
	upvar 1 ltype ltype ldata ldata nocase nocase
	# crack ldata, get nocase, if needed (type dependent)
	set symbol [dict get $mytypecode $ltype]
	if {$nocase} { append symbol /i }
	append symbol :< [RECODE $ldata] >
	return $symbol
    }

    method RECODE {spec} {
	upvar 1 ltype ltype
	if {$ltype in {string charclass}} {
	    set spec [lindex $spec 0]
	}

	set symbol {}
	foreach value $spec {
	    switch -glob -- $value {
		:*  {
		    # Named CC (regular and negated)
		    append symbol \[${value}:\]
		}
		*  {
		    if {[string is int -strict $value]} {
			# Single character
			append symbol [char quote tcl [format %c $value]]
		    } else {
			# Character range (list of 2 elements)
			lassign $value s e
			append symbol \
			    [char quote tcl [format %c $s]] - \
			    [char quote tcl [format %c $e]]
		    }
		}
	    }
	}
	return $symbol
    }

    method FIX-ESCAPES {litvar} {
	upvar 1 $litvar literal
	set literal [subst -nocommands -novariables $literal]
	return
    }

    method PARSE-MODS {litvar} {
	# literal = .*(:i|:ic)*
	upvar 1 $litvar literal nocase nocase
	# Decode and strip literal modifiers
	set nocase 0
	while {1} {
	    switch -glob -- $literal {
		*:i {
		    set literal [string range $literal 0 end-2]
		    set nocase 1
		    continue
		}
		*:ic {
		    set literal [string range $literal 0 end-3]
		    set nocase 1
		    continue
		}
	    }
	    break
	}
	return
    }

    method PARSE-TYPE {litvar} {
	# literal = ['].*['] - string, single-quoted
	#         | '['.*']' - charclass
	upvar 1 $litvar literal ltype ltype

	# Decode and strip type information from the literal
	if {[string match "'*'" $literal]} {
	    set ltype string
	    set literal [string range $literal 1 end-1]
	} elseif {[string match {\[*\]} $literal]} {
	    set ltype charclass
	    set literal [string range $literal 1 end-1]
	} else {
	    my E "Unable to determine type of literal \"$literal\"" \
		UNKNOWN TYPE $literal
	}
	return
    }

    method PARSE-STRING {litvar} {
	# literal = char* (escapes already handled)
	upvar 1 $litvar literal nocase nocase ldata ldata
	set ldata {}
	foreach char [split $literal {}] {
	    # Remember characters as code points, possibly downcased for nocase.
	    lappend ldata [CHAR $char $nocase]
	}

	set ldata [list $ldata $nocase]
	return
    }

    method PARSE-CHARCLASS {litvar} {
	# literal = '^'?element* (escapes aready handled),
	# where
	#   element = [:^\w+:]      - negated named posix character class
	#           | [:\w+:]       - named posix character class
	#           | char '-' char - range of characters
	#           | char          - single character
	##
	upvar 1 $litvar literal nocase nocase ldata ldata

	# TODO: Handle inverted classes.

	set ldata {}
	while {[string length $literal]} {
	    #puts NCC|$literal|

	    # negated posix char class
	    if {[regexp -- "^\\\[:\[\[.^.\]\](\\w+):\\\](.*)$" $literal -> name remainder]} {
		lappend ldata :^$name
		set literal $remainder
		continue
	    }
	    # posix char class
	    if {[regexp -- "^\\\[:(\\w+):\\\](.*)$" $literal -> name remainder]} {
		lappend ldata :$name
		set literal $remainder
		continue
	    }

	    if {[regexp -- {^(.)-(.)(.*)$} $literal -> start end remainder]} {
		# Expand the range into the individual characters
		# (We cannot assume that folding preverses continuity, or order)
		set start [CCODE $start]
		set end   [CCODE $end]
		for {set codepoint $start} {$codepoint <= $end} {incr codepoint} {
		    lappend ldata [CFOLD $codepoint $nocase]
		}
		set literal $remainder
		continue
	    }

	    if {[regexp -- {^(.)(.*)$} $literal -> char remainder]} {
		# Remember characters as codepoints, possibly up/downcased
		lappend ldata [CHAR $char $nocase]
		set literal $remainder
		continue
	    }

	    my E "Unable to decode remainder of char-class: \"$literal\"" \
		INTERNAL ;# internal error - semantic/syntax mismatch
	    break
	}

	# Canonical sort order, removal of obvious duplicates, and
	# compression to ranges where possible.

	#puts NCC:E:($ldata)
	set ldata [RANGES [lsort -dict -unique $ldata]]
	#puts NCC:C:($ldata)

	set ldata [list $ldata $nocase]
	return
    }

    method CHAR {char nocase} {
	CFOLD [CCODE $char] $nocase
    }

    method CCODE {char} {
	# Input is unescaped tcl character.
	# Determine the decimal codepoint.
	scan $char %c codepoint
	return $codepoint
    }

    method CFOLD {codepoint nocase} {
	if {$nocase} {
	    set codepoint [marpa unicode data fold/c $codepoint]
	}
	return $codepoint
    }

    method RANGES {spec} {
	set result {}
	set buf {}
	foreach value $spec {
	    switch -glob -- $value {
		:* - ^* {
		    lappend result $value
		}
		* {
		    # char class calls ranges without ranges, only codepoints.
		    if {![llength $buf]} {
			lappend buf $value
			continue
		    }
		    if {([lindex $buf end] + 1) == $value} {
			lappend buf $value
			continue
		    }
		    # gap, flush buffer
		    if {[llength $buf] > 1} {
			set s [lindex $buf 0]
			set e [lindex $buf end]
			lappend result [list $s $e]
		    } else {
			lappend result [lindex $buf 0]
		    }
		    # restart accumulation
		    set buf [list $value]
		}
	    }
	}
	if {[llength $buf]} {
	    if {[llength $buf] > 1} {
		set s [lindex $buf 0]
		set e [lindex $buf end]
		lappend result [list $s $e]
	    } else {
		lappend result [lindex $buf 0]
	    }
	}
	return $result
    }

}

# # ## ### ##### ######## #############
## 

return
