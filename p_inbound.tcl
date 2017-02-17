# -*- tcl -*-
##
# (c) 2015-2016 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# First stream processor for characters to parse. Generates basic
# token information (location, per character) and then drives the rest
# of the chain (instance of "marpa::gate" or API compatible) with
# them. The store object is expected to be an instance of
# "marpa::tvstore" or API compatible.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO ;# Implies Tcl 8.5 requirement.
package require try   ;# Don't for 8.6+ ?
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
    # Driver  Inbound SemStore        Upstream
    # |               |               |
    # +-cons--\       |               |
    # |       |       |               |
    # /       /       /               /
    # |       |       |               |
    # +-enter->       |               |
    # |       +-put--->               |
    # |       |       |               |
    # |       +-enter-)--------------->
    # |       |       |               |
    # /       /       /               /
    # |       |       |               |
    # +-eof--->       |               |
    # |       +-eof------------------->
    # |       |       |               |
    # ```
    #
    # * Supplication of text via `read`
    # ```
    # Driver  Inbound SemStore        Upstream
    # |               |               |
    # +-cons--\       |               |
    # |       |       |               |
    # /       /       /               /
    # |       |       |               |
    # +-read-->       |               |
    # |       --\     |               |
    # |       | enter |               |
    # |       <-/     |               |
    # |       +-put--->               |
    # |       |       |               |
    # |       +-enter-)--------------->
    # |       |       |               |
    # /       /       /               /
    # |       |       |               |
    # +-eof--->       |               |
    # |       +-eof---)--------------->
    # |       |       |               |
    # ```
    #
    # __Note__, both `enter` and `read` can be mixed between
    # `constructor` and `eof`.

    # # -- --- ----- -------- -------------
    ## State

    variable mylocation ; # Input location

    # API:
    # 1 cons  (semstore, upstream) - Create, link
    # 2 enter (string)             - Incoming characters via string
    # 3 read  (chan)               - Incoming characters via channel
    # 4 eof   ()                   - End of input signal
    #   location? ()               - Retrieve current location
    ##
    # Sequence = 1[23]*4

    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {semstore upstream} {
	debug.marpa/inbound {[debug caller] | }

	marpa::import $semstore Store
	marpa::import $upstream Forward

	set mylocation -1 ; # location (of current character) in
			    # input, currently before the first
			    # character

	debug.marpa/inbound {[debug caller] | /ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API

    method location? {} {
	debug.marpa/inbound {[debug caller] | ==> $mylocation}
	return $mylocation
    }

    method enter {string} {
	debug.marpa/inbound {[debug caller] | }

	if {$string eq {}} return
	foreach ch [split $string {}] {
	    # Count character location (offset in input)
	    incr mylocation

	    # Generate semantic value for the character
	    set loc [marpa location atom $mylocation $ch]
	    set sv  [Store put $loc]

	    debug.marpa/inbound {[debug caller 1] | DO '[char quote cstring $ch]' $sv ([marpa location show $loc]) ______}

	    # And push into the pipeline
	    debug.marpa/inbound {[debug caller 1] | DO _______________________________________}
	    Forward enter $ch $sv
	}
	return
    }

    method read {chan} {
	debug.marpa/inbound {[debug caller] | }

	# Process channel in blocks
	while {![eof $chan]} {
	    my enter [read $chan 1024]
	}
	# **Attention**: We cannot signal eof here! Because we might
	# get more input to process, from other channels or strings.
	return
    }

    method eof {} {
	debug.marpa/inbound {[debug caller] | }
	Forward eof
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
    # Sequence = 1[23]*4
    #
    # *-1-> ready -2-> done|
    #       ^ |
    #       \-/3
    ##                 Table By State ________   Table By Method ________
    # 1: construction  Current  Method  New      Current  Method  New   
    # 2: eof           ~~~~~~~  ~~~~~~  ~~~~~~   ~~~~~~~  ~~~~~~  ~~~~~~
    # 3: enter, read   -        <cons>  ready    -        <cons>  ready 
    ##                 ~~~~~~~  ~~~~~~  ~~~~~~   ~~~~~~~  ~~~~~~  ~~~~~~
    #                  ready    enter   /KEEP    ready    enter   /KEEP 
    #                           read    /KEEP    done     enter   /FAIL 
    #                           eof     done     ~~~~~~~  ~~~~~~  ~~~~~~
    #                  ~~~~~~~  ~~~~~~  ~~~~~~   ready    read    /KEEP 
    #                  done     enter   /FAIL    done     read    /FAIL 
    #                           read    /FAIL    ~~~~~~~  ~~~~~~  ~~~~~~
    #                           eof     /FAIL    ready    eof     done	
    #                  ~~~~~~~  ~~~~~~  ~~~~~~   done     eof     /FAIL 
    #                  *        *       /KEEP    ~~~~~~~  ~~~~~~  ~~~~~~
    #                  ~~~~~~~  ~~~~~~  ~~~~~~   *        *       /KEEP 
    #		                                 ~~~~~~~  ~~~~~~  ~~~~~~

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
