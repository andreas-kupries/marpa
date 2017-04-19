# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Atom: L0 character range.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller 1.1

debug define marpa/slif/container/atom/range
debug prefix marpa/slif/container/atom/range {[debug caller] | }

# # ## ### ##### ######## #############
## Managing symbol information.

oo::class create marpa::slif::container::range {
    superclass marpa::slif::container::atom

    marpa::E marpa/slif/container/atom/range \
	SLIF CONTAINER ATOM RANGE

    variable mystart ;# :: codepoint
    variable myend   ;# :: codepoint

    # Note: codepoints <= 255 can be used for byte-based engines.

    # - -- --- ----- -------- -------------
    ## lifecycle

    constructor {start end} {
	debug.marpa/slif/container/atom/range {}

	set mystart $start
	set myend   $end

	debug.marpa/slif/container/atom/range {/ok}
	return
    }

    # - -- --- ----- -------- -------------
    ## Fill serdes virtual abstract methods

    method serialize {} {
	debug.marpa/slif/container/atom/range {}
	return [list [list range $mystart $myend]]
    }

    # - -- --- ----- -------- -------------
    ## Accessors

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
