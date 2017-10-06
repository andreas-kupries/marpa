# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Singletons

oo::class create marpa::slif::semantics::Singleton {
    marpa::EP marpa/slif/semantics \
	{Grammar error.} \
	SLIF SEMANTICS SINGLETON

    variable mymsg  ;# error message
    variable mycode ;# error code
    variable myok   ;# flag tracking calls

    constructor {msg args} {
	debug.marpa/slif/semantics {}
	set mymsg  $msg
	set mycode $args
	set myok   1
	return
    }

    method pass {} {
	debug.marpa/slif/semantics {}
	if {!$myok} {
	    my E $mymsg {*}$mycode
	}
	set myok 0
	return
    }
}
