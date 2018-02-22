# -*- tcl -*-
##
# (c) 2017-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Utilies for working with L0 literals.
# Normalization (Simplifications without breaking the literal into many)
# See doc/atoms.md
    
# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::slif::literal::norm 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Simplify literals without breaking
# Meta description it apart into many.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::unicode
# Meta require     marpa::util
# Meta require     marpa::slif::literal::util
# Meta subject     marpa literal transform simplify normalize
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

# Unicode tables, classes, operations.
package require marpa::unicode
package require marpa::util
package require marpa::slif::literal::util

debug define marpa/slif/literal/norm

# # ## ### ##### ######## #############

namespace eval ::marpa::slif::literal {
    namespace export norm
    namespace ensemble create
}

namespace eval ::marpa::slif::literal::norm {
    namespace import ::marpa::X
    namespace import ::marpa::slif::literal::util::*
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::slif::literal::norm {literal} {
    norm::DO $literal
}

# # ## ### ##### ######## #############
## Internals

proc ::marpa::slif::literal::norm::DO {literal} {
    debug.marpa/slif/literal/norm {}
    set data [lassign $literal type]
    while {1} {
	switch -exact -- $type {
	    string {
		if {[llength $data] == 1} {
		    TO character ;# N01
		} else STOP ;# N02
	    }
	    %string {
		if {[llength $data] == 1} {
		    TO %character ;# N03
		} else STOP ;# N04
	    }
	    charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO [eltype $data] ;# N05, N06, N07
		} else STOP ;# N08
	    }
	    %charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO %[eltype $data] ;# N09, N10, N11
		} else {
		    set data [ccunfold $data]
		    TO charclass ;# N12
		}
	    }
	    ^charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO ^[eltype $data] ;# N13, N14, N15
		} else STOP ;# N16
	    }
	    ^%charclass {
		if {[llength $data] == 1} {
		    set data [lindex $data 0]
		    TO ^%[eltype $data] ;# N17, N18, N19
		} else {
		    set data [ccunfold $data]
		    TO ^charclass ;# N20
		}
	    }
	    character {
		STOP ;# N21
	    }
	    %character {
		set data [marpa unicode data fold $data]
		TO charclass ;# N22
	    }
	    ^character {
		STOP ;# N23
	    }
	    ^%character {
		set data [marpa unicode data fold $data]
		TO ^charclass ;# N24
	    }
	    range {
		lassign $data s e
		if {$s == $e} {
		    set data $s
		    TO character ;# N25
		} else STOP ;# N26
	    }
	    %range {
		set data [marpa unicode unfold [list $data]]
		TO charclass ;# N28
	    }
	    ^range {
		STOP ;# N29
	    }
	    ^%range {
		set data [marpa unicode unfold [list $data]]
		TO ^charclass ;# N30
	    }
	    named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO %named-class ;# N32
		    }
		    *   STOP
		}
	    }
	    %named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO %named-class ;# N36
		    }
		    *   STOP
		}
	    }
	    ^named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO ^%named-class ;# N40
		    }
		    *   STOP
		}
	    }
	    ^%named-class {
		switch -glob -- $data {
		    ^*  FAIL
		    %*  {
			set data [string range $data 1 end]
			TO ^%named-class ;# N44
		    }
		    *   STOP
		}
	    }
	    byte {
		STOP ;# N47
	    }
	    brange {
		STOP ;# N48
	    }
	    default FAIL
	}
	# Recurse (tailcall -> loop)
    }
}

proc ::marpa::slif::literal::norm::FAIL {} {
    upvar 1 type type data data
    X "Unable to normalize type ($type ($data))" \
	SLIF LITERAL INTERNAL
}

proc ::marpa::slif::literal::norm::TO {new args} {
    debug.marpa/slif/literal/norm {}
    upvar 1 type type
    set type $new
    return -code continue
}

proc ::marpa::slif::literal::norm::STOP {} {
    debug.marpa/slif/literal/norm {}
    upvar 1 type type data data
    return -code return [linsert $data 0 $type]
}

# # ## ### ##### ######## #############
package provide marpa::slif::literal::norm 0
return
