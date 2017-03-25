# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Generic management of fixups

oo::class create marpa::slif::semantics::Fixup {
    marpa::E marpa/slif/semantics SLIF SEMANTICS DE

    variable mycmd     ;# command invoked to perform actual fixup.
    variable myglobal  ;# global setting, if any.
    variable mypending ;# symbols waiting for fixup by global setting

    constructor {container cmd} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mycmd     $cmd
	set myglobal  {}
	set mypending {}
	return
    }

    method global! {x} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Set global state, handle all pending fixup
	# Note! Caller makes sure to call this only once.
	set myglobal $x
	foreach symbol $mypending { my fixup $symbol 0 }
	set mypending {}
	return
    }

    method fixup {sym {immediate 1}} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Run fixup immediate if we have state, else defer
	if {$myglobal ne {}} {
	    {*}$mycmd $sym $myglobal $immediate
	    return
	}
	lappend mypending $sym
	return
    }
}
