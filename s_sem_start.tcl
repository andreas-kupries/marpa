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
    # was made via "with:". "with:" also defers its value, to avoid
    # issues should the symbol be left undefined.

    variable mystate
    variable mysym

    constructor {container st def use semantics} {
	debug.marpa/slif/semantics {[debug caller] | }
	marpa::import $container Container
	marpa::import $st        Symbol
	marpa::import $def       Definition
	marpa::import $use       Usage
	marpa::import $semantics Semantics
	set mystate undef
	set mysym   {}
	return
    }

    # # -- --- ----- -------- -------------

    method maybe: {symbol} {
	# Weak definition, from structural rule. Remember first.
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		# First call, remember
		set mysym   $symbol
		set mystate maybe
	    }
	    maybe -
	    done {
		# Ignore further weak definitions
	    }
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method with: {symbol} {
	# Explicit, strong definition. Once only.
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef -
	    maybe {
		set mystate done
		set mysym $symbol
		Symbol context1 g1-usage $symbol
	    }
	    done {
		# TODO: Get location information from somewhere.
		set def [Definition where $symbol]
		set dd  [Semantics LOCFMT $def]

		my E "illegally declared for a second time$dd" \
		    WITH TWICE $def
	    }
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }

    method complete {} {
	debug.marpa/slif/semantics {[debug caller] | state=$mystate}
	switch -exact -- $mystate {
	    undef {
		# Nothing defined. Error.
		my E "not known" UNKNOWN
	    }
	    done {
		# Explicit definition. Pass it now.
		Container start! $mysym
	    }
	    maybe {
		# Weak definition survived to the end. Pass it now on.
		Container start! $mysym
	    }
	    done {}
	}
	debug.marpa/slif/semantics {[debug caller] | /done}
	return
    }
}
