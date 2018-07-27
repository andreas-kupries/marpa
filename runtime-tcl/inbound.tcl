# -*- tcl -*-
##
# (c) 2015-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# First stream processor for characters to parse. Generates basic
# token information (location, per character) and then drives the rest
# of the chain (instance of "marpa::gate" or API compatible) with
# them.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

debug define marpa/inbound
#debug prefix marpa/inbound {[debug caller] | }

# # ## ### ##### ######## #############
## Entry object for character streams.
#
# Counts locations, saves per-character semantic values, before
# driving the next element in the chain.

oo::class create marpa::inbound {
    marpa::E marpa/inbound INBOUND
    validate-sequencing

    ## Interaction sequences
    #
    # * Supplication of text via `enter`
    # ```
    # Driver  Inbound  Postprocessor
    # |                |
    # +-cons--\        |
    # |       |        |
    # /       /        /
    # |       |        |
    # +-enter->        |
    # |       |        |
    # |       +-enter-->
    # |       |        |
    # /       /        /
    # |       |        |
    # +-eof--->        |
    # |       +-eof---->
    # |       |        |
    # ```
    #
    # * Supplication of text via `read`
    # ```
    # Driver  Inbound   Postprocessor
    # |                 |
    # +-cons--\         |
    # |       |         |
    # /       /         /
    # |       |         |
    # +-read-->         |
    # |       --\       |
    # |       | enter   |
    # |       <-/       |
    # |       |         |
    # |       +-enter--->
    # |       |         |
    # /       /         /
    # |       |         |
    # +-eof--->         |
    # |       +-eof----->
    # |       |         |
    # ```
    #
    # __Note__, both `enter` and `read` can be mixed between
    # `constructor` and `eof`.

    # # -- --- ----- -------- -------------
    ## State

    variable mylocation     ; # Input location
    variable mystoplocation ; # Trigger location for stop events
    variable mytext         ; # Physical input stream
    			      # (list! of characters)

    # API:
    # 1 cons  (postprocessor) - Create, link
    # 2 enter (string)        - Incoming characters via string
    # 3 read  (chan)          - Incoming characters via channel
    # 4 eof   ()              - End of input signal
    #   location? ()          - Retrieve current location
    ##
    # Sequence = 1[23]*4
    # See mark <<s>>
    ##
    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {postprocessor} {
	debug.marpa/inbound {[debug caller] | }

	marpa::import $postprocessor Forward

	set mytext     "" ; # Input is empty
	set mylocation -1 ; # Location of the current character in
			    # the input, currently set to just before
			    # the first character (of nothing).

	# Attach ourselves to the postprocessor, as its input
	Forward input: [self]

	debug.marpa/inbound {[debug caller] | /ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method location {} {
	debug.marpa/inbound {[debug caller] | ==> $mylocation}
	return [expr {$mylocation + 1}]
    }

    method from {pos args} {
	debug.marpa/inbound {[debug caller] | }
	incr pos -1
	set mylocation $pos
	foreach delta $args { incr mylocation $delta }
	return
    }

    method rewind {delta} {
	debug.marpa/inbound {[debug caller] | }
	incr mylocation [expr {-1 * $delta}]
	return
    }

    method relative {delta} {
	debug.marpa/inbound {[debug caller] | }
	incr mylocation $delta
	return
    }

    method stop {} {
	debug.marpa/inbound {[debug caller] | }
	if {$mystoplocation < 0} { return {} }
	return $mystoplocation
    }

    method to {pos} {
	debug.marpa/inbound {[debug caller] | }
	set mystoplocation $pos
	return
    }

    method dont-stop {} {
	debug.marpa/inbound {[debug caller] | }
	set mystoplocation -1
	return
    }

    method limit {delta} {
	# assert delta > 0
	debug.marpa/inbound {[debug caller] | }
	set  mystoplocation $mylocation
	incr mystoplocation
	incr mystoplocation $delta
	return
    }

    method enter {string} {
	debug.marpa/inbound {[debug caller] | }
	my Def $string
	my Process
	# XXX eof here
	return
    }

    method read {chan} {
	debug.marpa/inbound {[debug caller] | }
	# Read entire channel into memory for processing
	my Def [read $chan]
	my Process
	# XXX eof here
	return
    }

    method eof {} {
	debug.marpa/inbound {[debug caller] | }
	Forward eof
	return
    }

    # # ## ### ##### ######## #############
    ## Internal support functionality

    method Def {string} {
	debug.marpa/inbound {[debug caller] | }
	set mytext     [split $string {}]
	set mylocation -1
	# stop before input - cannot trigger == do not stop
	set mystoplocation -1
	return
    }

    method Process {} {
	debug.marpa/inbound {[debug caller] | }

	set  max [llength $mytext]
	incr max -1

	debug.marpa/inbound {[debug caller] | DO _______________________________________ /START}

	# Notes on locations.
	# [1] At the beginning of the loop `mylocation` points to the
	#     __last__ processed character.
	# [2] We move to the current character just before processing
	#     it (Forward enter ...).
	# [3] When parse events are invoked we point to the character
	#     to process next (i.e. one ahead), and have to compensate
	#     on return so that the loop entry condition [1] is true
	#     again. We actually make the translation in the location
	#     methods of this class, see `location?` and below,
	#     without actually moving.
	# [4] The double-loop construction is present to ensure that
	#     when the inner main processing loop hits EOF the eof
	#     handling can bounce the engine away from EOF and
	#     processing is restarted for the last characters.

	while {$mylocation < $max} {
	    while {$mylocation < $max} {
		incr mylocation

		if {$mylocation == $mystoplocation} {
		    # Stop triggered.
		    # Bounce, clear stop marker, post event, restart
		    incr mylocation -1
		    set mystoplocation -1
		    Forward signal-stop ;# notify gate
		    continue
		}

		set ch [lindex $mytext $mylocation]

		# Semantic value is character location (s.a.)
		# And push into the pipeline
		debug.marpa/inbound {[debug caller] | DO '[char quote cstring $ch]' ($mylocation) ______}
		debug.marpa/inbound {[debug caller] | DO _______________________________________}

		Forward enter $ch $mylocation
		# Note, the post-processor (gate, lexer) have access to the location, via methods
		# moveto, moveby, and rewind. Examples of use:
		# - Rewind after reading behind the current lexeme
		# - Rewind for parse events.

		debug.marpa/inbound {[debug caller] | DO _______________________________________ /NEXT}
	    }
	    # Trigger end of data processing in the post-processors.
	    # (Ad 4) Note that this may rewind the input to an earlier
	    # place, forcing re-processing of some of the last
	    # characters.
	    debug.marpa/inbound {[debug caller] | DO _______________________________________ /EOF}
	    Forward eof

	    debug.marpa/inbound {[debug caller] | DO _______________________________________ /NEXT.EOF}
	}

	debug.marpa/inbound {[debug caller] | DO _______________________________________ /DONE}
	return
    }

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Mixin helper class. State machine checking the method call
## sequencing of marpa::inbound instances.

## The mixin is done on user request (method in main class).
## Uses: testing
##       debugging in production

oo::class create marpa::inbound::sequencer {
    superclass sequencer

    # State machine for marpa::inbound
    ##
    # Sequence = 1[23]*4      # 1: construction
    # See mark <<s>>	      # 2: eof
    #			      # 3: enter, read
    # *-1-> ready -2-> done|  #
    #       ^ |               #
    #       \-/3              #
    #
    # Determin. state machine # Table re-sorted, by method _=
    # Current  Method  New    # Current  Method  New
    # ~~~~~~~  ~~~~~~  ~~~~~~ # ~~~~~~~  ~~~~~~  ~~~~~~
    # -        <cons>  ready  # -        <cons>  ready
    # ~~~~~~~  ~~~~~~  ~~~~~~ # ~~~~~~~  ~~~~~~  ~~~~~~
    # ready    enter   /KEEP  # ready    enter   /KEEP
    #          read    /KEEP  # done     enter   /FAIL
    #          eof     done   # ~~~~~~~  ~~~~~~  ~~~~~~
    # ~~~~~~~  ~~~~~~  ~~~~~~ # ready    read    /KEEP
    # done     enter   /FAIL  # done     read    /FAIL
    #          read    /FAIL  # ~~~~~~~  ~~~~~~  ~~~~~~
    #          eof     /FAIL  # ready    eof     done
    # ~~~~~~~  ~~~~~~  ~~~~~~ # done     eof     /FAIL
    # *        *       /KEEP  # ~~~~~~~  ~~~~~~  ~~~~~~
    # ~~~~~~~  ~~~~~~  ~~~~~~ # *        *       /KEEP
    #                         # ~~~~~~~  ~~~~~~  ~~~~~~

    # # -- --- ----- -------- -------------
    ## Mandatory overide of virtual base class method

    method __Init {} { my __States ready done }

    # # -- --- ----- -------- -------------
    ## Checked API methods

    method enter {string} {
	my __Init
	my __Fail done ! "Unable to process input after EOF" EOF
	next $string
    }

    method read {chan} {
	my __Init
	my __Fail done ! "Unable to process input after EOF" EOF
	next $chan
    }

    method eof {} {
	my __Init
	my __Fail done ! "Unable to process input after EOF" EOF
	next

	my __Goto done
    }
}

# # ## ### ##### ######## #############
return
