# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Generic management of defaults vs user choice.
## The object remembers the symbols which were set by the user.
## Fixup is then for all the symbols not in the set.

oo::class create marpa::slif::semantics::Fixup {
    marpa::E marpa/slif/semantics SLIF SEMANTICS DE

    variable myignore ;# Set of symbols to ignore on account of being
		       # handled by the user.
		       # Stored as: dict (symbol -> .)

    variable mydefault

    constructor {container default} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set myignore {}
	set mydefault $default
	return
    }

    # # ## ### ##### ######## #############

    method exclude {symbol} {
	debug.marpa/slif/semantics {[debug caller] | }
	Container comment [namespace tail [self]] skip $symbol
	dict set myignore $symbol .
	return
    }

    method default: {x} {
	debug.marpa/slif/semantics {[debug caller] | }
	Container comment [namespace tail [self]] default: $x
	set mydefault $x
	return
    }

    method fix {symbols cmd} {
	debug.marpa/slif/semantics {[debug caller] | }
	Container comment [namespace tail [self]] fix $mydefault
	foreach symbol $symbols {
	    if {[dict exists $myignore $symbol]} continue
	    {*}$cmd $symbol $mydefault
	}
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
