# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Grammar container. Specialized to L0
# - Atom symbols (strings, charclasses)

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/l0/grammar
debug prefix marpa/slif/l0/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::l0::grammar {
    superclass marpa::slif::grammar

    marpa::E marpa/slif/l0/grammar SLIF L0 GRAMMAR

    ##
    # API:
    # * constructor (name)
    # * new-string    (name string modifier) -> instance
    # * new-charclass (name spec modifier) -> instance

    constructor {name container} {
	debug.marpa/slif/l0/grammar {}
	next $name $container

	debug.marpa/slif/l0/grammar {/ok}
	return
    }

    method new-charclass {literal start length} {
	debug.marpa/slif/l0/grammar {}

	# Decode into class and modifiers...

	# Special case: single character in class. That is a plain
	# character atom.

	if {[string length $literal] == 3} {
	    set char [string index $literal 1]
	    incr start
	    return [my Char $start $char 0]
	}

	# Use the literal as the symbol name. As it contains at least
	# '[' and ']' as non-symbol characters no regular symbol can
	# match it, and conflicts with them are not possible.
	if {[my has-symbol $literal obj]} {
	    debug.marpa/slif/l0/grammar {==> $obj (cached)}
	    return $obj
	}

	set obj [my New marpa::slif::charclass $literal $literal]
	$obj def $start $length

	# TODO: char classes -- leave the stuff below to backends!
	# TODO: determine positive/negated class
	# TODO: determine explicit/implicit set of characters
	# TODO: split into chars, ranges and named classes. sort, merge.
	# TODO: determine class modifiers (:i, :ic)

	debug.marpa/slif/l0/grammar {==> $obj}
	return $obj
    }

    method new-string {literal start length} {
	debug.marpa/slif/l0/grammar {}

	# We generally use the literal as the symbol name. As it
	# contains at least "'" as non-symbol character no regular
	# symbol can match it, and conflicts with them are not
	# possible. See however the note below as well.

	# Extract modifier information and actual string to recognize.
	lassign [my Decode $literal] rliteral nocase

	# A nocase-string is translated into a series of char classes,
	# one per character, each recognizing upper- and lower-case
	# variants of the original character. A regular string is just
	# translated into a series of characters. An empty string
	# becomes a symbol with an empty RHS.

	# Note: If the string consist of only a single character the
	# toplevel symbol is the is the atom for that character, be it
	# character or class. A helper symbol representing the entire
	# string is only created for a string of more than one
	# character.

	# This affects the ordering of the cases a bit, due to the
	# different symbol names for the string helper vs
	# atoms. Length 1 is handled first, doing its own caching and
	# check. Then the other lengths do their check with a
	# different symbol name.

	if {[string length $rliteral] == 1} {
	    incr start ;# Skip the initial quote.
	    set obj [my Char $start $rliteral $nocase]
	    debug.marpa/slif/l0/grammar {==> $obj}
	    return $obj
	}

	if {[my has-symbol $literal obj]} {
	    debug.marpa/slif/l0/grammar {==> $obj (cached)}
	    return $obj
	}

	if {![string length $rliteral]} {
	    # Empty string. 
	    set obj [my new-symbol $literal]
	    debug.marpa/slif/l0/grammar {==> $obj}
	    return $obj
	}

	set obj [my new-symbol $literal]
	$obj def $start $length

	incr start ;# Skip the initial quote.
	foreach char [split $rliteral] {
	    lappend rhs [my Char $start $char $nocase]
	    incr start
	}

	$obj add-bnf $rhs 0

	debug.marpa/slif/l0/grammar {==> $obj}
	return $obj
    }

    method Char {start char nocase} {
	if {$nocase} {
	    set up  [string toupper $char]
	    set low [string tolower $char]
	    if {$up ne $low} {
		# The character has different forms for upper- and
		# lower case. Return a character class matching both.
		return [my new-charclass \[$up$low\] $start 1]
	    }
	}

	# User either requested exact matching, or the character is
	# the same in both upper- and lower-case. Either way, return
	# an atom for this character.

	# We use the character itself, plus special prefix as the
	# symbol name. The prefix ensures that no regular symbol can
	# match it, and conflicts with them are not possible.

	# This also ensures that character symbols cannot overlap with
	# string symbols, as would be the case if we had used
	# '-quoting, with a character and strings of length 1 in
	# conflict.

	if {[my has-symbol @$char obj]} {
	    debug.marpa/slif/l0/grammar {==> $obj (cached)}
	    return $obj
	}

	set obj [my New marpa::slif::character @$char $char]
	$obj def $start 1

	debug.marpa/slif/l0/grammar {==> $obj}
	return $obj
    }

    method Decode {literal} {
	# Determine and chop of modifier
	set nocase no
	if {[string match {*:i} $literal]} {
	    set nocase yes
	    set literal [string range $literal 0 end-2]
	} elseif {[string match {*:ic} $literal]} {
	    set nocase yes
	    set literal [string range $literal 0 end-3]
	}

	# Chop the bracketing quotes
	set literal [string range $literal 1 end-1]

	return [list $literal $nocase]
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
