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
    namespace export D DX E EP X import filter K A C C*
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

proc marpa::import {cmd {dst {}} {up 2}} {
    debug.marpa/support {}

    set fqn  [uplevel $up [list namespace which -command $cmd]]
    set cn [uplevel 1 {namespace current}]
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
return
