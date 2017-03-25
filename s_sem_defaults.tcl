# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Generic management of defaults

oo::class create marpa::slif::semantics::Defaults {
    marpa::E marpa/slif/semantics SLIF SEMANTICS DEFAULTS

    variable mybase     ;# dictionary of the last defaults
    variable mydefaults ;# dictionary of current defaults

    constructor {container base} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	set mybase     $base
	set mydefaults $base
	return
    }

    method defaults: {defaults} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Set new defaults. Missing parts are filled from the base.
	set mydefaults [dict merge $mybase $defaults]
	return
    }

    method defaults {dict} {
	debug.marpa/slif/semantics {[debug caller] | }
	# Fill missing pieces in the incoming dict with the current defaults.
	return [dict merge $mydefaults $dict]
    }
}
