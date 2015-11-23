# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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
## Wrap around commands to be run from a debug narration command,
## ensure that the result is empty.

proc marpa::D {script} {
    uplevel 1 $script
    return
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
return
