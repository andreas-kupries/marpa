# -*- tcl -*-
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Common class to lexer and parser. Holds the data structures for
# mapping symbol names to ids, and the methods to define a grammar.

# Note: strict vs easy.  In an 'easy' implementation a symbol would be
# automatically created when found in a rule and not known. A 'strict'
# implementation throws an error instead. This implementation is
# strict.  We will not implement 'easy'. This is ok because this is
# part of a runtime targeted at generated lexers and parsers, and the
# generator can trivially make sure that all symbols are known before
# their use in rules. Only the boot parser for SLIF needed manual
# configuration.

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
    marpa::E marpa/engine ENGINE

    # Map symbol name to id, for rule conversion during setup, and
    # back-conversion in debug output.
    #
    # Map of the public symbol id to the associated postprocessor
    # symbol id.  These are the full set of symbols accepted by the
    # postprocessor and are gated by this engine.
    #
    # Map from postprocessor symbol id for a public symbol to the
    # associated local ACS id.
    #
    # Map from rules (ids) to their lhs, for debugging output
    # -- TODO -- check if the data truly is debug only

    variable mymap    ;# sym name     -> id:local
    variable myrmap   ;# sym id:local -> name
    variable myrule   ;# rule id      -> list (lhs sym id, list (rhs sym id))

    variable myevents ;# symbol -> (type -> (name -> active))

    ##
    # API self:
    #   cons    (postprocessor) - Create, link, attach to postprocessor.
    #   Symbols (symlist)       - (preprocessor, self) bulk allocation of symbols
    #   Export  (symlist)       - Bulk allocation of public symbols
    #   Rules   (rules)         - Bulk specification of grammar rules
    ##
    # API postprocessor:
    #   symbols (symlist)  - Bulk allocate symbols for lexemes, chars and char classes.

    constructor {postprocessor} {
	debug.marpa/engine {[debug caller] | }

	marpa::import $postprocessor Forward

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
	set myevents {}

	debug.marpa/engine {[debug caller] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## Hidden methods for API methods. Subclasses integrate these into
    ## their state management

    method events {spec} {
	debug.marpa/engine {[debug caller] | }
	set myevents $spec
	return
    }

    method symbols {names} {
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

    method rules {rules} {
	debug.marpa/engine {[debug caller 1] | }
	# Enter the rules. The second element of each rule is the
	# relevant method.
	foreach rule $rules {
	    my [lindex $rule 1] {*}$rule
	}
	return
    }

    # # ## ### ##### ######## #############
    ## Internal support - Data management (setup)

    method := {lhs __ args} {
	debug.marpa/engine {[debug caller] | }
	set lhsid  [my 2ID1 $lhs]
	set rhsids [my 2ID  $args]
	return [my RuleP $lhsid {*}$rhsids]
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
	return [my RuleS $lhsid  $loopid $sepid $positive $proper]
    }

    method RuleP {lhsid args} {
	# Remember the mapping from rule to generating symbol and its
	# specification, for debugging output (See method `report`, et al)
	debug.marpa/engine {[debug caller] | }
	set rid [GRAMMAR rule-new $lhsid {*}$args]
	dict set myrule $rid [list $lhsid $args]
	return $rid
    }

    method RuleS {lhsid loopid sepid positive proper} {
	# Remember the mapping from rule to generating symbol and its
	# specification, for debugging output (See method `report`, et al)
	debug.marpa/engine {[debug caller] | }
	set rid [GRAMMAR rule-sequence-new $lhsid $loopid $sepid $positive $proper]
	dict set myrule $rid [list $lhsid [list $loopid]]
	return $rid
    }

    method events? {type syms} {
	debug.marpa/engine {[debug caller] | }
	set events {}
	foreach sym $syms {
	    if {![dict exists $myevents $sym $type]} continue
	    dict for {name active} [dict get $myevents $sym $type] {
		if {!$active} continue
		lappend events $name
	    }
	}
	return [lsort -unique $events]
    }

    # # ## ### ##### ######## #############
    ## Convert between symbol names and ids (local)
    ## NOTE: Current use mixes debugging and generation of data for semantics.
    ## Consider disentangling the two uses.

    method 2ID* {args}  { my 2ID $args }
    method 2ID  {names} { lmap name $names { my 2ID1 $name } }
    method 2ID1 {name} {
	if {![dict exists $mymap $name]} {
	    my E "Unknown symbol \"$name\"" UNKNOWN SYMBOL $name
	}
	return [dict get $mymap $name]
    }

    method 2Name* {args} { my 2Name $args }
    method 2Name  {ids}  { lmap id $ids { my 2Name1 $id } }
    method 2Name1 {id} {
	if {![dict exists $myrmap $id]} {
	    my E "Bad id \"$id\"" BAD ID $id
	}
	return [dict get $myrmap $id]
    }

    # # ## ### ##### ######## #############

    method DNames    {names} { return [lmap n $names { set _ <${n}> }] }
    method DIds      {ids}   { my DNames [my 2Name $ids] }
    method DLocation {sv}    { return [marpa location show [Store get $sv]] }
    # DLocation is predicated on a semantic action of (start length value).

    # # ## ### ##### ######## #############
    ## Internal support - Data access

    method RuleData {rid} {
	debug.marpa/engine {[debug caller] | }
	return [dict get $myrule $rid]
    }

    method RuleNameData {rid} {
	debug.marpa/engine {[debug caller] | }
	lassign [dict get $myrule $rid] lhs rhs
	return [list [my 2Name1 $lhs] [my 2Name $rhs]]
    }

    # # ## ### ##### ######## #############

    method Freeze {} {
	debug.marpa/engine {[debug caller] | }
	# Freeze grammar, prevent further editing
	GRAMMAR freeze
	return
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
