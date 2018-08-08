# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# See doc/atoms.md

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::redux 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Utilities operate on
# Meta description and transform L0 literals. Reduction core.
# Meta summary     L0 literal reduction core
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta require     marpa::slif::literal::util
# Meta require     marpa::slif::literal::norm
# Meta subject     marpa literal transform reduction
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

# Unicode tables, classes, operations.
package require marpa::util
package require marpa::slif::literal::util
package require marpa::slif::literal::norm

debug define marpa/slif/literal/rstate
#debug on marpa/slif/literal/rstate

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export rstate redux
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::redux {gc args} {
    [rstate new] process $gc {*}$args
    return
}

# # ## ### ##### ######## #############

oo::class create ::marpa::slif::literal::rstate {
    marpa::E marpa/slif/literal/rstate SLIF LITERAL

    variable mywork    ; # list (symbol) - stack of symbols to reduce
    variable myresults ; # list (symbol) - queue of completed symbols
    variable mydef     ; # dict (symbol -> literal) - definition database
    variable mysym     ; # symbol callback (reducer ++ 'symbol')

    # The active literal is the literal currently being reduced
    variable myctype    ; # Active literal, type
    variable mycdetails ; # Ditto, details
    variable mycsym     ; # Ditto, name of symbol

    # # ## ### ##### ######## #############

    constructor {} {
	debug.marpa/slif/literal/rstate {}
	set mywork     {}
	set myresults  {}
	set mydef      {}
	set mycsym     {}
	set myctype    {}
	set mycdetails {}
	return
    }

    method process {gc args} {
	debug.marpa/slif/literal/rstate {}
	my from-container $gc
	my to-container $gc [my reduce {*}$args]
	return
    }

    method to-container {gc reductions} {
	debug.marpa/slif/literal/rstate {}
	lassign $reductions worklist aliases

	foreach {litsymbol literal} $worklist {
	    $gc l0 remove $litsymbol

	    # Do not re-create symbols without definition. This is how
	    # the symbols we optimized away get removed.
	    if {$literal eq {}} continue

	    set data [lassign $literal type]
	    switch -exact -- $type {
		composite {
		    # Alternation of sequences of elements
		    # alt == data
		    foreach rhsequence $data {
			$gc l0 priority-rule $litsymbol $rhsequence 0
		    }
		}
		default {
		    # Regular literal, (re)create
		    $gc l0 literal $litsymbol $type {*}$data
		}
	    }
	}

	if {![dict size $aliases]} return
	# Pass the alias table to the relevant grammar so that it can
	# rewrite the rules which have the aliased symbols in their RHS.
	$gc l0 fixup $aliases
	return
    }

    method from-container {gc} {
	debug.marpa/slif/literal/rstate {}
	my work-on [concat {*}[lmap {sym rhs} [dict get [$gc l0 serialize] literal] {
	    list $sym [lindex $rhs 0]
	}]]
	return
    }

    method work-on {worklist} {
	debug.marpa/slif/literal/rstate {}
	#my XB
	foreach {litsymbol literal} $worklist {
	    set data [lassign $literal type]
	    if {![llength $data]} {
		my E "Unable to reduce incomplete literal ($type ($data))" \
		    SLIF LITERAL INCOMPLETE
	    }
	    dict set mydef $litsymbol [my NORM $literal]
	    lappend mywork $litsymbol
	}
	#my XC
	return
    }

    method reduce {cmd args} {
	debug.marpa/slif/literal/rstate {}
	set cmd [linsert $args 0 $cmd]
	set mysym   [linsert $cmd end symbol]
	set reducer [linsert $cmd end reduce]
	while {[my Work?]} {
	    my Take
	    {*}$reducer $myctype [self] {*}$mycdetails
	    if {[my Undecided]} {
		my E "Failed to reduce: \"$reducer $myctype [self] $mycdetails\"" \
		    UNDECIDED
	    }
	}
	set result [my Results]
	my destroy
	return $result
    }

    # Reducer API (reduction decisions)
    method keep {} {
	debug.marpa/slif/literal/rstate {}
	my Queue done $mycsym [linsert $mycdetails 0 $myctype]
	my ClearActive
	return -code return
    }

    method is-a {newtype args} {
	debug.marpa/slif/literal/rstate {}
	if {$newtype eq "composite"} {
	    my E "Bad type \"composite\" for simple change, use `rules` and variants" \
		ILLEGAL COMPOSITE
	}
	my Queue work $mycsym [linsert $args 0 $newtype]
	my ClearActive
	return -code return
    }

    method is-a! {newtype args} {
	debug.marpa/slif/literal/rstate {}
	if {$newtype eq "composite"} {
	    my E "Bad type \"composite\" for simple change, use `rules` and variants" \
		ILLEGAL COMPOSITE
	}
	my Queue done $mycsym [linsert $args 0 $newtype]
	my ClearActive
	return -code return
    }

    method rules {alternatives} {
	debug.marpa/slif/literal/rstate {}
	my Place done work $mycsym [linsert $alternatives 0 composite]
	my ClearActive
	return -code return
    }

    method rules! {alternatives} {
	debug.marpa/slif/literal/rstate {}
	my Place done done $mycsym [linsert $alternatives 0 composite]
	my ClearActive
	return -code return
    }

    method rules* {args} {
	debug.marpa/slif/literal/rstate {}
	my Place done work $mycsym [linsert $args 0 composite]
	my ClearActive
	return -code return
    }

    method rules*! {args} {
	debug.marpa/slif/literal/rstate {}
	my Place done done $mycsym [linsert $args 0 composite]
	my ClearActive
	return -code return
    }

    # # ## internals

    method ClearActive {} {
	debug.marpa/slif/literal/rstate {}
	set mycsym    {}
	set myctype   {}
	set mcdetails {}
	return
    }

    method Undecided {} {
	debug.marpa/slif/literal/rstate {}
	expr {$myctype ne {}}
    }

    method Work? {} {
	debug.marpa/slif/literal/rstate {}
	llength $mywork
    }

    method Take {} {
	#my XB
	debug.marpa/slif/literal/rstate {}
	if {![llength $mywork]} {
	    my E "No work available" EMPTY
	}
	# Treating the pending work as a stack.
	set litsymbol [lindex   $mywork end]
	set mywork    [lreplace $mywork end end]
	set literal   [dict get $mydef $litsymbol]
	dict unset mydef $litsymbol
	#my XC
	# Place taken information into active literal
	set mycsym     $litsymbol
	set mycdetails [lassign $literal myctype]

	if {$myctype eq "composite"} {
	    my E "Unable to reduce irreducible literal ($myctype ($mycdetails))" \
		SLIF LITERAL IRREDUCIBLE
	}
	return
    }

    # Debug method only, used by the tests. Replaced inspection of `Take` result.
    method Active {} {
	debug.marpa/slif/literal/rstate {}
	return [list $mycsym [linsert $mycdetails 0 $myctype]]
    }

    method Place {queue symqueue litsymbol literal} {
	#my XB
	debug.marpa/slif/literal/rstate {}
	set res [my Queue $queue $litsymbol \
		     [my Symbolize $symqueue $literal]]
	#my XC
	return $res
    }

    method Queue {queue litsymbol literal} {
	#my XB
	debug.marpa/slif/literal/rstate {}
	# queue in {work, done}
	# assert: The elements of a composite literal are symbols, not
	# literal specs to convert into.

	# Note, the incoming non-composite pieces are
	# normalized to simplify them further.
	if {[lindex $literal 0] ne "composite"} {
	    set literal [my NORM $literal]
	}
	dict set mydef $litsymbol $literal
	switch -exact -- $queue {
	    continue - work {
		if {[lindex $literal 0] eq "composite"} {
		    set details [lassign $literal type]
		    my E "Unable to reduce irreducible literal ($type ($details))" \
			SLIF LITERAL IRREDUCIBLE
		}
		lappend mywork $litsymbol
	    }
	    return   - done {
		lappend myresults $litsymbol
	    }
	    default {
		my E "Bad queue \"$queue\", expected one of done, or work" \
		    BAD QUEUE
	    }
	}
	#my XC
	return $litsymbol
    }

    method Symbolize {queue literal} {
	debug.marpa/slif/literal/rstate {}
	# queue in {work, done}
	set data [lassign $literal type]
	if {$type eq "composite"} {
	    # The literal is a set of alternates, each a sequence of
	    # elements.  This method assumes that each element is a
	    # literal itself. It generates and queues symbols for
	    # them, constructing a new literal referencing these
	    # symbols.
	    set literal [list $type {*}[lmap alternate $data {
		lmap child $alternate {
		    set cdata [lassign $child ctype]
		    if {$ctype eq "symbol"} {
			# Direct symbol reference.
			set cdata
		    } else {
			set childsym [my SYM $child]
			if {![dict exists $mydef $childsym]} {
			    my Queue $queue $childsym $child
			}
			set childsym
		    }
		}
	    }]]
	}
	return $literal
    }

    forward NORM   marpa::slif::literal::norm
    forward symbol my SYM

    # Test support only. Private.
    method ForSymbol {args} {
	debug.marpa/slif/literal/rstate {}
	set mysym $args
	return
    }

    method SYM {literal} {
	debug.marpa/slif/literal/rstate {}
	{*}$mysym [self] $literal
    }

    method Results {} {
	debug.marpa/slif/literal/rstate {}

	# Look for literals which exist as multiple symbols, which
	# we can and should merge.
	##
	# I. Invert, key by definition.
	# II. Choose one symbol for the multi-def literals, remember
	#     the aliases.
	# III. During result assembly suppress the secondaries, and
	#      rewrite other definitions to use the primary.

	set syms {}
	dict for {sym def} $mydef {
	    dict lappend syms $def $sym
	}

	# syms :: dict (def -> list(sym))
	#array set _XXX_syms $syms ; parray _XXX_syms ; unset _XXX_syms

	set ralias {}
	set alias  {}
	set keep   {}
	dict for {def symlist} $syms {
	    # For simplicity we map everything, even the unique
	    # definitions I.e. we can avoid conditionals. We still
	    # have to check to get proper supression.
	    if {[llength $symlist] == 1} {
		lassign $symlist primary
	    } else {
		foreach secondary [lassign [lsort -dict $symlist] primary] {
		    dict set ralias $secondary $primary ;# Needed mappings, for result
		    dict set alias  $secondary $primary ;# (1) Mapping for unconditional use
		    dict set keep   $secondary no
		}
	    }
	    dict set alias $primary $primary ;# See (1)
	    dict set keep  $primary yes
	}

	# alias :: dict (sym -> sym)  - Rewrite A to primary B
	# keep  :: dict (sym -> bool) - Flag if we keep a symbol or not.
	#array set _XXX_alias $alias ; parray _XXX_alias ; unset _XXX_alias
	#array set _XXX_keep  $keep  ; parray _XXX_keep  ; unset _XXX_keep
	set result {}
	foreach litsymbol [lreverse $myresults] {
	    # Reverse order, bottom up from atoms to composites
	    # Skip duplicate definitions.
	    if {[dict get $keep $litsymbol]} {
		set literal [dict get $mydef $litsymbol]
		set data    [lassign $literal type]

		if {$type eq "composite"} {
		    # Symbols on the RHS, map them over to chosen definitions.
		    set literal [list $type {*}[lmap alternate $data {
			lmap el $alternate { dict get $alias $el }
		    }]]
		}
	    } else {
		# Signal that this symbol should be destroyed.
		set literal {}
	    }

	    lappend result $litsymbol $literal
	}
	return [list $result $ralias]
    }

    # # ## ### ##### ######## #############

    method XB {} {
	puts __________________________________BEGIN\t[info level -1]
	puts XX_W\t[join $mywork    \nXX_W\t]\n
	puts XX_R\t[join $myresults \nXX_R\t]\n
	puts XX_D\t[join [lsort -dict [dict keys $mydef]] \nXX_D\t]
	puts __________________________________
    }

    method XC {} {
	puts __________________________________
	puts XX_W\t[join $mywork    \nXX_W\t]\n
	puts XX_R\t[join $myresults \nXX_R\t]\n
	puts XX_D\t[join [lsort -dict [dict keys $mydef]] \nXX_D\t]
	puts __________________________________COMPLETE/\t[info level -1]
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::redux 0
return
