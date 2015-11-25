# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Common class to lexer and parser. Holds the data structures for
# mapping symbol names to ids, and the methods to define a grammar.

# TODO: strict vs easy mode.
# TODO: In easy mode a symbol is automatically created when found in a rule and not known.
# TODO: strict mode throws an error instead.
# TODO: Currently we only have strict mode.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/engine
#debug prefix marpa/engine {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::engine {
    # Map symbol name to id, for rule conversion during setup, and
    # back-conversion in debug output.
    #
    # Map of the public symbol id to the associated upstream symbol
    # id.  These are the full set of symbols accepted by upstream and
    # are be gated by this engine.
    #
    # Map from upstream symbol id for a public symbol to the
    # associated local ACS id.
    #
    # Map from rules (ids) to their lhs, for debugging output

    variable mymap    ;# sym name        -> id:local
    variable myrmap   ;# sym id:local    -> name
    variable myrule   ;# rule id         -> lhs sym id

    ##
    # API self:
    #   cons    (upstream) - Create, link, attach to upstream.
    #   Symbols (symlist)  - (Downstream, self) bulk allocation of symbols
    #   Export  (symlist)  - Bulk allocation of public symbols
    #   Rules   (rules)    - Bulk specification of grammar rules
    ##
    # API upstream:
    #   symbols (symlist)  - Bulk allocate symbols for lexemes, chars and char classes.

    constructor {upstream} {
	debug.marpa/engine {[debug caller] | }

	marpa::import $upstream Forward

	# Dynamic state for processing
	##
	# Local grammar container. Stored in the instance namespace
	# for direct access. will be auto-cleaned in instance
	# destruction.
	marpa::Grammar create GRAMMAR [mymethod Events]

	# TODO: Events currently used only for debug output. When it
	# is needed for parsing support, etc, then the user may have
	# to specify callbacks.

	# Static configuration
	set mymap    {}
	set myrmap   {}
	set myrule   {}

	debug.marpa/engine {[debug caller] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## Hidden methods for API methods. Subclasses integrate these into
    ## their state management

    method Symbols {names} {
	debug.marpa/engine {[debug caller] | }
	# Bulk argument check, prevent duplicates
	foreach name $names {
	    if {[dict exists $mymap $name]} {
		my E "Duplicate symbol \"$name\"" \
		    SYMBOL DUPLICATE $name
	    }
	}

	# Bulk definition
	set ids {}
	foreach name $names {
	    set id [GRAMMAR sym-new]
	    lappend ids $id
	    # We remember the mapping for rule conversion. We can drop
	    # the mapping when the grammar is frozen, except when
	    # debugging is active, then we need it for the conversion
	    # of symbol ids back into readable names
	    dict set mymap  $name $id
	    dict set myrmap $id $name
	    debug.marpa/engine {[debug caller 1] | SYM ($name) = $id}
	}
	return $ids
    }

    method Rules {rules} {
	debug.marpa/engine {[debug caller 1] | }
	# Enter the rules. The second element of each rule is the
	# relevant method.
	foreach rule $rules {
	    my [lindex $rule 1] {*}$rule
	}
	return
    }

    # # ## ### ##### ######## #############
    ## Internal support - Data access

    method LHSid {id} {
	debug.marpa/engine {[debug caller] | }
	return [dict get $myrule $id]
    }

    method LHSname {id} {
	debug.marpa/engine {[debug caller] | }
	return [my 2Name1 [dict get $myrule $id]]
    }

    # # ## ### ##### ######## #############
    ## Internal support - Data management (setup)

    method := {lhs __ args} {
	debug.marpa/engine {[debug caller] | }
	set lhsid  [my 2ID1 $lhs]
	set rhsids [my 2ID  $args]

	set id [GRAMMAR rule-new $lhsid {*}$rhsids]
	return [my Rule $id $lhsid]
    }

    method * {lhs __ loop {separator {}} {proper no}} {
	debug.marpa/engine {[debug caller] | }
	return [my SEQ $lhs $loop $separator $proper no]
    }

    method + {lhs __ loop {separator {}} {proper no}} {
	debug.marpa/engine {[debug caller] | }
	return [my SEQ $lhs $loop $separator $proper yes]
    }

    method SEQ {lhs loop separator proper positive} {
	debug.marpa/engine {[debug caller] | }

	set lhsid  [my 2ID1 $lhs]
	set loopid [my 2ID1 $loop]
	set sepid  [expr {$separator eq {} ? -1 : [my 2ID1 $separator]}]

	# lhs * loop,separator,proper
	set id [GRAMMAR rule-sequence-new $lhsid $loopid $sepid $positive $proper]
	return [my Rule $id $lhsid]
    }

    method Rule {id lhsid} {
	# Remember the mapping from rule to generated symbol, for
	# debugging output
	debug.marpa/engine {[debug caller] | }
	dict set myrule $id $lhsid
	return $id
    }

    method 2ID* {args} {
	return [my 2ID $args]
    }
    method 2ID {names} {
	set ids {}
	foreach name $names { lappend ids [my 2ID1 $name] }
	return $ids
    }
    method 2ID1 {name} {
	return [dict get $mymap $name]
    }

    method 2Name* {args} {
	return [my 2Name $args]
    }
    method 2Name {ids} {
	set names {}
	foreach id $ids { lappend names [my 2Name1 $id] }
	return $names
    }
    method 2Name1 {id} {
	return [dict get $myrmap $id]
    }

    method Freeze {} {
	debug.marpa/engine {[debug caller] | }
	# Freeze grammar, prevent further editing
	GRAMMAR freeze
	return
    }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/engine {[debug caller] | }
	return -code error \
	    -errorcode [linsert $args 0 MARPA ENGINE] \
	    $msg
    }

    # # ## ### ##### ######## #############

    method Events {g type value} {
	# Show events, debugging only.
	debug.marpa/engine {[debug caller] | }
	switch -exact -- $type {
	    e-none             {}
	    e-exhausted        {}
	    e-nulling-terminal -
	    e-symbol-completed -
	    e-symbol-expected  -
	    e-symbol-nulled    -
	    e-symbol-predicted -
	    e-counted-nullable { debug.marpa/engine {[debug caller] | sym = [my 2Name1 $value]} }
	    e-item-threshold   { debug.marpa/engine {[debug caller] | have = $value} }
	    e-loop-rules       { debug.marpa/engine {[debug caller] | loops = $value} }
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
