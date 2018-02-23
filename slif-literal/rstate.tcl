# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# See doc/atoms.md
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::rstate 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Utilities operate on
# Meta description and transform L0 literals.
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

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export rstate
    namespace ensemble create
}

# # ## ### ##### ######## #############
## Public API

# # ## ### ##### ######## #############

oo::class create ::marpa::slif::literal::rstate {
    marpa::E marpa/slif/literal/rstate SLIF LITERAL

    variable mywork    ; # list (symbol) - stack of symbols to reduce
    variable myresults ; # list (symbol) - queue of completed symbols
    variable mydef     ; # dict (symbol -> literal) - definition database

    # # ## ### ##### ######## #############

    constructor {worklist} {
	debug.marpa/slif/literal/rstate {}
	set mywork    {}
	set myresults {}
	set mydef     {}
	#my XB
	foreach {litsymbol literal} $worklist {
	    set data [lassign $literal type]
	    if {![llength $data]} {
		my E "Unable to reduce incomplete literal ($type ($data))" \
		    SLIF LITERAL INCOMPLETE
	    }
	    dict set mydef $litsymbol $literal
	    lappend mywork $litsymbol
	}
	#my XC
	return
    }

    method work? {} {
	debug.marpa/slif/literal/rstate {}
	llength $mywork
    }

    method take {} {
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
	list $litsymbol $literal
    }

    method place {queue symqueue litsymbol literal} {
	#my XB
	debug.marpa/slif/literal/rstate {}
	set res [my queue $queue $litsymbol \
		     [my symbolize $symqueue $literal]]
	#my XC
	return $res
    }

    method queue {queue litsymbol literal} {
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
	    continue - work { lappend mywork    $litsymbol }
	    return   - done { lappend myresults $litsymbol }
	    default {
		my E "Bad queue \"$queue\", expected one of done, or work" \
		    BAD QUEUE
	    }
	}
	#my XC
	return $litsymbol
    }

    method symbolize {queue literal} {
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
			    my queue $queue $childsym $child
			}
			set childsym
		    }
		}
	    }]]
	}
	return $literal
    }

    forward SYM  marpa::slif::literal::util::symbol
    forward NORM marpa::slif::literal::norm

    method results {} {
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
package provide marpa::slif::literal::rstate 0
return
