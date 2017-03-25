# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Start symbol

oo::class create marpa::slif::semantics::Start {
    marpa::EP marpa/slif/semantics \
	{Grammar error. Start symbol} \
	SLIF SEMANTICS START

    # Start symbol handling
    # Method   State --> New State Action
    # ------   -----     --------- ------
    # with:    undef     done      set
    #          maybe     done      set
    #          done      -          FAIL
    # ------   -----     --------- ------
    # maybe:   undef     maybe     save
    #          maybe     -         ignore
    #          done      done      ignore
    # ------   -----     --------- ------
    # complete undef     -          FAIL (INTERNAL?)
    #          maybe     -         set
    #          done      -         ignore
    # ------   -----     --------- ------
    ##
    # Order by state
    # State Method --> New State Action
    # ----- ------     --------- ------
    # undef with:      done      set
    #       maybe:     maybe     saved
    #       complete   -          FAIL
    # ----- ------     --------- ------
    # maybe with:      done      set
    #       maybe:     -         ignore
    #       complete   -         set
    # ----- ------     --------- ------
    # done  with:      -          FAIL
    #       maybe:     done      ignore
    #       complete   -         ignore
    # ----- ------     --------- ------

    # "maybe:" is used by the LHS of rules. It will pass its value
    # only on the 1st call, and even then only if no explicit setting
    # was made via "with:". "with:" always passes its value.

    variable mystate
    variable mysym

    constructor {container terminal} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	marpa::import $terminal  Terminal
	set mystate undef
	set mysym   {}
	return
    }

    # # -- --- ----- -------- -------------

    method maybe: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		set mysym   $symbol
		set mystate maybe
	    }
	    maybe -
	    done {}
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method with: {symbol} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef -
	    maybe {
		set mystate done
		set mysym   $symbol
		# We defer passing even and explicitly defined start
		# symbol to the completion phase. Because then we can
		# check if it has a definition or not (Terminal flags).
	    }
	    done {
		# TODO: Get location information from somewhere.
		my E "illegally declared for a second time" \
		    WITH TWICE
	    }
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method complete {} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		my E "not known" UNKNOWN
	    }
	    done -
	    maybe {
		# While the start symbol cannot be a terminal
		# << Why not? >>
		# there is
		# still the possibility that there is no rule defining
		# it either.
		# IOW instead of simply trying unset! we explictly check
		# that it is a non-terminal and bail if not.
		if {![Terminal unset? $mysym]} {
		    my E "<$mysym> has no G1 rule" UNDEFINED
		}
		Container start! $mysym
	    }
	    done {}
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }
}
