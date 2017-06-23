# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# General utilities

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller

debug define marpa/support
debug prefix marpa/support {[debug caller] | }

# # ## ### ##### ######## #############

namespace eval marpa {
    namespace export D DX E EP X import fqn filter K A C C* asset
}

# # ## ### ##### ######## #############
## Incremental dict assembly, helper for moving.

proc marpa::A {k v} {
    upvar 1 tmp tmp
    dict set tmp $k $v
    return
}

proc marpa::C {k} {
    upvar 1 tmp tmp spec spec
    dict set spec $k $tmp
    unset tmp
    return
}

proc marpa::C* {k} {
    upvar 1 spec spec
    dict set spec $k {}
    return
}

proc marpa::dict-move {dvdst key dvsrc} {
upvar 1 $dvdst dst $dvsrc src
    dict set dst $key $src
    unset src
    return
}

# # ## ### ##### ######## #############
## Wrap around commands to be run from a debug narration command,
## ensure that the result is empty.

proc marpa::D {script} {
    uplevel 1 $script
    return
}

proc marpa::DX {label script} {
    uplevel 1 $script
    # The label is what the debug code will print
    return $label
}

# # ## ### ##### ######## #############
## Generate an error generation method for a class

proc marpa::E {label args} {
    debug.marpa/support {}
    uplevel 1 [list marpa::EP $label {} {*}$args]
}

proc marpa::EP {label prefix args} {
    debug.marpa/support {}

#     set class [string tolower [lindex [info level -1] 1]]
#     set label [string map {:: /} [string trim $class :]]
#     set args  [string toupper [split [string map {marpa/ {}} $label] /]]

# puts $class
# puts -\tL($label)
# puts -\tP($prefix)
# puts -\t$args

    if {$prefix ne {}} { append prefix { } }

    lappend map @args@  $args
    lappend map @label@ $label
    lappend map @prefix@ $prefix
    uplevel 1 [list method E {msg args} [string map $map {
	debug.@label@ {}
	return -code error \
	    -errorcode [linsert $args 0 MARPA @args@] \
	    "@prefix@${msg}"
    }]]
}

proc marpa::X {msg args} {
    return -code error \
	-errorcode [linsert $args 0 MARPA] \
	$msg
}

# # ## ### ##### ######## #############
## Link external command into local namespace

proc marpa::fqn {cmd {up 1}} {
    debug.marpa/support {}
    return [uplevel $up [list namespace which -command $cmd]]
}

proc marpa::import {cmd {dst {}} {up 2}} {
    debug.marpa/support {}

    set fqn  [uplevel $up [list namespace which -command $cmd]]
    set cn   [uplevel 1 {namespace current}]
    if {$dst eq {}} { set dst [namespace tail $cmd] }
    interp alias {} ${cn}::$dst {} $fqn

    debug.marpa/support {/ok: ${cn}::$dst}
    return

    # I do not quite like the use of aliases for this.
    # Unfort I was unable to get things working with 'namespace import'.
    # Possibly an issue with ensemble commands, (not) being exported, and the like.
    # Alias works.
    return
}

# # ## ### ##### ######## #############
## Filter a list by removing the indices found in mask.
## ATTENTION: Assumes that the mask is sorted in decreasing order, to make it easy to perform.

proc marpa::filter {values mask} {
    debug.marpa/support {}
    foreach pos $mask {
	set values [lreplace [K $values [unset values]] $pos $pos]
    }
    return $values
}

proc marpa::K {x y} { return $x }

# # ## ### ##### ######## #############
## Forward compatibility for lmap, conditional.

if {![llength [info commands ::lmap]]} {
    # http://wiki.tcl.tk/40570
    # lmap forward compatibility

    proc lmap {args} {
	set body [lindex $args end]
	set args [lrange $args 0 end-1]
	set n 0
	set pairs [list]
	# Import all variables into local scope
	foreach {varnames listval} $args {
	    set varlist [list]
	    foreach varname $varnames {
		upvar 1 $varname var$n
		lappend varlist var$n
		incr n
	    }
	    lappend pairs $varlist $listval
	}
	# Run the actual operation via foreach
	set temp [list]
	foreach {*}$pairs {
	    lappend temp [uplevel 1 $body]
	}
	set temp
    }
}

# # ## ### ##### ######## #############
## Access to attached assets.

## This feature makes use of the fact that Tcl's source command uses
## the ^Z character as -eofchar by default. This allows us to attach
## anything after the code without breaking the interpreter.  Basic
## interpreter introspection and shenanigans with -eofchar enable us
## to access and load the attached data when needed.

namespace eval marpa {
    variable asset {}
}

proc marpa::asset {self} {
    # This command assumes a single attached text asset, and returns it.
    # For speed the content is memoized.
    debug.marpa/support {}

    variable asset
    if {[dict exists $asset $self]} {
	return [dict get $asset $self]
    }
    
    set ch [open $self]
    # Skip over code, use special EOF handling analogous to `source`.
    fconfigure $ch -eofchar \x1A
    read $ch
    # Switch to regular EOF handling and skip the separator character
    fconfigure $ch -eofchar {}
    read $ch 1
    # Read asset, close, memoize, and return
    set content [read $ch]
    close $ch
    dict set asset $self $content
    return $content
}

# # ## ### ##### ######## #############
return
