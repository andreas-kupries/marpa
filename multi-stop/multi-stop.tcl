# -*- tcl -*-
# Marpa -- A binding to Jeffrey Kegler's libmarpa, an
#          Earley/Leo/Aycock/Horspool parser engine.
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Notes
# - lremove $L E = lsearch -all -inline -not -exact $L E

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO		;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require marpa::util	;# marpa::import

debug define marpa/multi-stop
debug prefix marpa/multi-stop {[debug caller] | }

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::multi-stop 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Management of multiple (stop) markers for a parser.
# Meta description Facade / adapter class wrapping around any marpa parser.
# Meta description Intercepts various methods to put its own marker
# Meta description management into place. The adapter takes ownership
# Meta description of the parser it wraps. Destruction of the adapter
# Meta description destroys the parser as well.
# Meta description
# Meta description
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta require     TclOO
# Meta require     oo::util
# Meta require     marpa::util
# Meta subject     marpa
# Meta summary     Utility commands
# @@ Meta End

# # ## ### ##### ######## #############
## Main adapter

oo::class create marpa::multi-stop {
    marpa::E marpa/multi-stop MULTI-STOP

    constructor {parser} {
	debug.marpa/multi-stop {}
	marpa::import $parser PAR
	marpa::multi-stop::mgr create MGR [self] $parser
	return
    }

    destructor {
	debug.marpa/multi-stop {}
	PAR destroy
	MGR destroy
    }

    # Intercepts, and pass through

    forward process      PAR process
    forward process-file PAR process-file
    forward extend       PAR extend
    forward extend-file  PAR extend-file

    forward on-event     MGR oe
    forward match        MGR
}

# # ## ### ##### ######## #############
## Manager used by the adapter

oo::class create marpa::multi-stop::mgr {
    marpa::E marpa/multi-stop MULTI-STOP-MGR

    constructor {shell parser} {
	debug.marpa/multi-stop {}
	marpa::import $parser PAR
	set myshell  $shell
	set mypos    {}
	set myname   {}
	set myindex  {}
	set myaction {}
	return
    }

    method oe {args} {
	debug.marpa/multi-stop {}
	# Place our interceptor between parser and user's handler.
	PAR on-event [self namespace]::my EVENT $args
	return
    }

    # State
    variable myname mypos myindex myaction myshell
    # myname   :: dict (pos ::int     -> list (name :: string))
    # mypos    :: dict (name ::string -> pos :: int)
    # myaction :: dict (name ::string -> list (word :: string))
    # myindex  :: list (pos :: int)    ! sorted, integer, increasing

    # Intercepts and pass through
    #
    ## Original match api
    # - location                 | Pass
    # - from      pos ?delta...? | Intercept - Recompute active marker
    # - from+     delta          | Intercept - s.a.
    # - stop                     | Pass, renamed (`mark-active`)
    # - to        pos            | Hide
    # - limit     delta          | Hide
    # - dont-stop                | Hide
    #
    # - symbols                  | Pass
    # - sv                       | Pass
    # - start                    | Pass
    # - length                   | Pass
    # - value                    | Pass
    # - alternate                | Pass
    # - clear                    | Pass
    # - view                     | Pass
    ##
    # New api
    # - mark-add      name pos ?cmd...? | Replaces `to`, `limit`
    # - mark-cancel   name              | Replaces `dont-stop`
    # - marks         ?pattern?         | New
    # - mark-exists   name              | New
    # - mark-location name              | New, semi-replaces `stop`
    # - mark-active                     | Is `stop` under a different name

    forward location        PAR match location
    #
    forward from      my RA PAR match from
    forward from+     my RA PAR match from+
    #
    forward symbols         PAR match symbols
    forward sv              PAR match sv
    forward start           PAR match start
    forward length          PAR match length
    forward value           PAR match value
    forward alternate       PAR match alternate
    forward clear           PAR match clear
    forward view            PAR match view
    #
    forward barrier         PAR match barrier
    
    method RA {args} {
	debug.marpa/multi-stop {}
	set res [{*}$args]
	my RecomputeActive
	return $res
    }

    method RecomputeActive {} {
	debug.marpa/multi-stop {}
	# Find the smallest marked location above (or equal to) the current location
	set at [PAR match location]
	foreach pos $myindex {
	    if {$pos < $at} continue
	    PAR match to $pos
	    return
	}
	PAR match dont-stop
    }

    method mark-add {name pos args} {
	debug.marpa/multi-stop {}
	# args = cmd

	# Clear existing marker, new definition replaces it.
	if {[dict exists $mypos $name]} { my Cancel $name 0 }

	dict set mypos    $name $pos
	dict set myaction $name $args

	if {[dict exists $myname $pos]} {
	    # Additional marker at known pos.
	    dict lappend myname $pos $name
	} else {
	    # First marker at a new pos
	    dict set myname $pos [list $name]
	    lappend myindex $pos
	    set myindex [lsort -integer $myindex]
	}

	my RecomputeActive
	return
    }

    method mark-cancel {name} {
	debug.marpa/multi-stop {}
	my Cancel $name 1
	return
    }

    method marks {{pattern *}} {
	debug.marpa/multi-stop {}
	return [dict keys mypos $pattern]
    }

    method mark-location {name} {
	debug.marpa/multi-stop {}
	return [dict get $mypos $name]
    }

    method mark-exists {name} {
	debug.marpa/multi-stop {}
	return [dict exists $mypos $name]
    }

    forward mark-active PAR match stop

    method Cancel {name ra} {
	debug.marpa/multi-stop {}

	set pos [dict get $mypos $name]
	dict unset mypos    $name
	dict unset myaction $name

	set names [dict get $myname $pos]
	if {[llength $names] == 1} {
	    # Last marker for the pos
	    dict unset myname $pos
	    set myindex [lsearch -all -inline -not -exact $myindex $pos]
	    if {!$ra} return
	    my RecomputeActive
	} else {
	    # Still markers at the pos, remove just this name
	    set names [lsearch -all -inline -not -exact $names $name]
	    dict set myname $pos $names
	}
	return
    }

    method EVENT {usercmd par type enames} {
	debug.marpa/multi-stop {}
	# Our event interceptor handles only stop events.
	# Everything else is passed to the user callback.
	if {$type ne "stop"} {
	    if {![llength $usercmd]} return
	    return [uplevel 1 [list {*}$usercmd $myshell $type $enames]]
	}

	set pos   [PAR match location]
	set names [dict get $myname $pos]
	dict unset myname $pos

	# Clear the triggered markers from our datastructures
	set myindex [lsearch -all -inline -not -exact $myindex $pos]

	foreach name $names {
	    lappend cmds [dict get $myaction $name]
	    dict unset mypos    $name
	    dict unset myaction $name
	}

	# Run the actions of the triggered markers. With the internal
	# structures clear the actions are free to re-add markers,
	# etc.
	foreach name $names cmd $cmds {
	    if {![llength $cmd]} continue
	    # Special forms handled by the manager.
	    # @from  - absolute jump
	    # @from+ - relative jump
	    # @eof   - jump to EOF trigger location, forced engine abort
	    # ?? - recreate mark ?
	    #    - other
	    switch -exact -- [lindex $cmd 0] {
		@from  { lassign $cmd __ pos   ; PAR match from  $pos            ; continue }
		@from+ { lassign $cmd __ delta ; PAR match from+ $delta          ; continue }
		@eof   {                         PAR match from [PAR match last] ; continue }
	    }
	    uplevel 1 [list {*}$cmd $myshell $name]
	}

	my RecomputeActive
	return
    }
}

# # ## ### ##### ######## #############

package provide marpa::multi-stop 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
