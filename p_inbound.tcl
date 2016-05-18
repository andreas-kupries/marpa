# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
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
    variable mylocation ; # Input location

    # API:
    #   cons  (semstore, upstream) - Create, link
    #   enter (string)             - Incoming characters via string
    #   read  (chan)               - Incoming characters via channel
    #   eof   ()                   - End of input signal
    #   location? ()               - Retrieve current location

    constructor {semstore upstream} {
	debug.marpa/inbound {[debug caller] | }

	marpa::import $semstore Store
	marpa::import $upstream Forward

	set mylocation -1 ; # location (of current character) in
			    # input, currently before the first
			    # character

	my ToStart
	debug.marpa/inbound {[debug caller] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## State methods for API methods
    #
    #  API ::=  Start   Done
    ## ---      ------- ------
    #  enter    * Enter   Fail
    #  read     * Read    Fail
    #  eof      * Eof     Fail
    ## ---      ------- ------
    #
    #  Start -<Eof>---> Done
    #  Start -<Enter>-> Start
    #  Start -<Read>--> Start

    method location? {} {
	debug.marpa/inbound {[debug caller] | ==> $mylocation}
	return $mylocation
    }

    method Enter {string} {
	debug.marpa/inbound {[debug caller] | }

	if {$string eq {}} return
	foreach ch [split $string {}] {
	    # Count character location (offset in input)
	    incr mylocation

	    # Generate semantic value for the character
	    set sv [Store put [set loc [list $mylocation $mylocation $ch]]]

	    debug.marpa/inbound {[debug caller 1] | DO '[char quote cstring $ch]' $sv ([marpa::location::Show $loc]) ______}

	    # And push into the pipeline
	    debug.marpa/inbound {[debug caller 1] | DO _______________________________________}
	    Forward enter $ch $sv
	}
	return
    }

    method Read {chan} {
	debug.marpa/inbound {[debug caller] | }

	while {![eof $chan]} {
	    my enter [read $chan 1024]
	}
	# **Attention**: We cannot signal eof here! Because we might
	# get more input to process, from other channels or strings.
	return
    }

    method Eof {} {
	debug.marpa/inbound {[debug caller] | }

	my ToDone
	Forward eof
	return
    }

    method Fail {args} {
	debug.marpa/inbound {[debug caller] | }
	my E "Unable to process input after EOF" EOF
    }

    # # ## ### ##### ######## #############
    ## Internal support - Error generation

    method E {msg args} {
	debug.marpa/inbound {[debug caller] | }
	return -code error \
	    -errorcode [linsert $args 0 MARPA INBOUND] \
	    $msg
    }

    # # ## ### ##### ######## #############
    ## State transitions

    method ToStart {} {
	# () :: Start
	debug.marpa/inbound {[debug caller] | }
	oo::objdefine [self] forward enter my Enter
	oo::objdefine [self] forward read  my Read
	oo::objdefine [self] forward eof   my Eof
	return
    }

    method ToDone {} {
	# (Start) :: Done
	debug.marpa/inbound {[debug caller] | }
	oo::objdefine [self] forward enter my Fail
	oo::objdefine [self] forward read  my Fail
	oo::objdefine [self] forward eof   my Fail
	return
    }

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
