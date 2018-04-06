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
# Counts locations, saves per-char semantic values, before driving the
# next element in the chain.

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

    variable mylocation ; # Input location
    variable mytext     ; # Physical input stream
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
	set mylocation -1 ; # location (of current character) in
			    # input, currently before the first
			    # character

	# Attach ourselves to the postprocessor, as its input
	Forward input: [self]

	debug.marpa/inbound {[debug caller] | /ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method location? {} {
	debug.marpa/inbound {[debug caller] | ==> $mylocation}
	return $mylocation
    }

    method moveto {pos} {
	debug.marpa/inbound {[debug caller] | }
	set  mylocation $pos
	incr mylocation -1
	return
    }

    method rewind {delta} {
	debug.marpa/inbound {[debug caller] | }
	incr mylocation -$delta
	return
    }

    method moveby {delta} {
	debug.marpa/inbound {[debug caller] | }
	incr mylocation $delta
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
	return
    }

    method Process {} {
	debug.marpa/inbound {[debug caller] | }

	set  max [llength $mytext]
	incr max -1

	debug.marpa/inbound {[debug caller] | DO _______________________________________ /START}

	while {$mylocation < $max} {
	    # The outer loop catches when gate, lexer, etc. bounce us
	    # back after reaching EOF. Because this means that the
	    # last characters need re-processing.

	    while {$mylocation < $max} {
		# On loop entry the location points to the previously processed character
		# We now move to the current character, then extract and process it.
		incr mylocation
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

	    # Trigger end of data processing in the post-porcessors.
	    # Note that this may rewind the input to an earlier place,
	    # forcing re-processing of some of the last characters.
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
