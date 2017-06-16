# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Generic management of locations per symbol

oo::class create marpa::slif::semantics::Locations {
    marpa::E marpa/slif/semantics SLIF SEMANTICS LOCATION

    variable mydata ;# dict (symbol --> list(location))

    constructor {container} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mydata {}
	return
    }

    method add {location span args} {
	debug.marpa/slif/semantics {[debug caller] | }
	set self [namespace tail [self]]
	foreach symbol $args {
	    Container comment $self $symbol $location $span
	    #if {![string is integer $location]} {error XXX}
	    #if {![string is integer $span]}     {error XXX}
	    dict lappend mydata $symbol [list $location $span]
	}
	return
    }

    method where {symbol} {
	debug.marpa/slif/semantics {[debug caller] | }
	if {![dict exists $mydata $symbol]} { return {} }
	return [lsort -unique -dict [dict get $mydata $symbol]]
    }

    method last {symbol} {
	debug.marpa/slif/semantics {[debug caller] | }
	#if {![dict exists $mydata $symbol]} { return {} }
	return [lindex [dict get $mydata $symbol] end]
    }
}
