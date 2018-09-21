# -*- tcl -*-
##
# (c) 2015-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
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
#debug on marpa/inbound

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
    # * Provision of text via `enter`   * Provision of text via `read`
    # ```
    # Driver  Inbound  Postprocessor    Driver  Inbound   Postprocessor
    # |                |	        |                 |
    # +-cons--\        |	        +-cons--\         |
    # |       |        |	        |       |         |
    # /       /        /	        /       /         /
    # |       |        |	        |       |         |
    # +-enter->        |	        +-read-->         |
    # |       |        |	        |       --\       |
    # |       +-enter-->	        |       | enter   |
    # |       |        |	        |       <-/       |
    # /       /        /	        |       |         |
    # |       |        |	        |       +-enter--->
    # |       +-eof---->	        |       |         |
    # |       |        |	        /       /         /
    #    			        |       |         |
    #				        |       +-eof----->
    #                                   |       |         |
    # ```
    #
    # - Callbacks for stop events not shown.
    # - `enter-more`, `read-more` usable from stop events not shown.

    # # -- --- ----- -------- -------------
    ## State

    variable mylocation     ; # Input location
    variable mystoplocation ; # Trigger location for stop events
    variable mytext         ; # Physical input stream
    			      # (list! of characters)
    variable mymax          ; # Location triggering EOF
    variable mysentinel     ; # Location triggering overrun
                              # == length of entire physical input stream less one
                              # (including stream separators)

    # Statistics
    variable mynumprocessed ; # total number of characters processed
                              # includes re-reading
    variable mynumstreams   ; # total number of input. Min 1 (primary input)

    # See also mysentinel under State.

    # total number of input characters = (sentinel + 1) - (numstreams - 1) [discount separators]
    #                                  = sentinel - numstreams + 2
    #
    # number of rereads = numprocessed - total input

    # API:
    #  1 cons       (postprocessor)    - Create, link
    #  2 enter      (string ?from to?) - Incoming characters via string
    #  3 read       (chan ?from to?)   - Incoming characters via channel
    #  4 enter-more (string)           - Additional characters, in stop events
    #  5 read-more  (chan)             - Ditto, via channel
    #  6 location   ()                 - Retrieve current location
    #  7 stop       ()
    #  8 dont-stop  ()
    #  9 from       (pos ...)
    # 10 relative   (delta)
    # 11 rewind     (delta)
    # 12 to         (pos)
    # 13 limit      (delta)
    ##
    # Sequence = 1[2,3][4,5,8-13]*
    # See mark <<s>>
    # See also `tests/inbound.test`
    # Sequence is simplified, 6 & 7 may be used any time, independent of state
    ##
    # # -- --- ----- -------- -------------
    ## Lifecycle

    constructor {postprocessor} {
	debug.marpa/inbound {[debug caller] | }

	marpa::import $postprocessor Forward

	set mytext         "" ; # Input is empty
	set mylocation     -1 ; # Location of the current character in
				# the input, currently set to just
				# before the first character (of
				# nothing).
	set mystoplocation -2 ; # Where to stop the engine, nowhere.
	set mysentinel     -2
	set mymax          -1
	set mynumstreams    0
	set mynumprocessed  0

	# Attach ourselves to the postprocessor, as its input
	Forward input: [self]

	debug.marpa/inbound {[debug caller] | /ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API 1 - Statistics

    method streams {} {
	debug.marpa/inbound {[debug caller] | ==> $mynumstreams}
	return $mynumstreams
    }

    method processed {} {
	debug.marpa/inbound {[debug caller] | ==> $mynumprocessed}
	return $mynumprocessed
    }

    method size {} {
	set size [expr {$mysentinel - $mynumstreams + 2}]
	debug.marpa/inbound {[debug caller] | ==> $size}
	return $size
    }

    # # -- --- ----- -------- -------------
    ## Public API 2 - Control

    method last {} {
	debug.marpa/inbound {[debug caller] | ==> $mymax}
	return $mymax
    }

    method location {} {
	debug.marpa/inbound {[debug caller] | ==> $mylocation}
	return $mylocation
    }

    method from {pos args} {
	debug.marpa/inbound {[debug caller] | }
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
	if {$mystoplocation < -1} { return {} }
	return $mystoplocation
    }

    method to {pos} {
	debug.marpa/inbound {[debug caller] | }
	set mystoplocation $pos
	return
    }

    method dont-stop {} {
	debug.marpa/inbound {[debug caller] | }
	set mystoplocation -2
	return
    }

    method limit {delta} {
	# assert delta > 0
	debug.marpa/inbound {[debug caller] | }
	set  mystoplocation $mylocation
	incr mystoplocation $delta
	return
    }

    method read {chan {from -1} {to -2}} {
	debug.marpa/inbound {[debug caller] | }
	# Read entire channel into memory for processing
	my enter [read $chan] $from $to
	return
    }

    method read-more {chan} {
	debug.marpa/inbound {[debug caller] | }
	return [my enter-more [read $chan]]
    }

    method enter {string {from -1} {to -2}} {
	debug.marpa/inbound {[debug caller 1] | }

	set mynumstreams   1
	set mynumprocessed 0
	set mytext         [split $string {}]
	set mylocation     $from
	set mystoplocation $to

	set  max [llength $mytext]
	incr max -1
	set  mysentinel $max
	set  mymax      $max

	# Example input, with secondary data (15 chars)
	#             0 1 2 3 4 5 6 7 8 9 A B C  D E
	# text     = {a l p h a n u m e r i c \0 u m}
	# max      = 11 --------------------^
	# sentinel = 14 ---------------------------^
	#
	# max = Trigger EOF when this (@11) is the previous processed
	#       character.
	#
	# sentinel = Trigger overrun when this (@14) is the previous
	#            processed character and engine was not stopped
	#            by EOF or stop marker.

	debug.marpa/inbound {[debug caller 1] | DO _______________________________________ /START}

	# Notes on locations.
	# [1] At the beginning of the loop `mylocation` points to the
	#     __last__ processed character.
	# [2] We move to the current character just before processing
	#     it (Forward enter ...).
	# [3] When parse events are invoked we point to the character
	#     to process next (i.e. one ahead), and have to compensate
	#     on return so that the loop entry condition [1] is true
	#     again. We actually make the translation in the location
	#     methods of this class, see `location` and below,
	#     without actually moving.
	# [4] The previous double loop construction was eliminated by
	#     hoisting the outer code into the proper contionals of
	#     the inner loop, leaving a single loop handling all the
	#     things.

	while {1} {
	    if {$mylocation == $mystoplocation} {
		debug.marpa/inbound {[debug caller 1] | STOP $mylocation}
		# Stop triggered.
		# Clear stop marker, post event, continue from the top
		set mystoplocation -2
		Forward signal-stop ;# notify gate

		debug.marpa/inbound {[debug caller 1] | RESUME $mylocation}
		continue
	    }

	    if {$mylocation == $max} {
		# Trigger end of data processing in the post-processors.
		# (Ad 4) Note that this may rewind the input to an
		# earlier place, forcing re-processing of some of the
		# last characters.
		debug.marpa/inbound {[debug caller 1] | DO _______________________________________ /EOF}

		Forward eof

		debug.marpa/inbound {[debug caller 1] | DO _______________________________________ /NEXT.EOF}

		if {$mylocation != $max} continue

		my EOF ;# Sequencing hook
		debug.marpa/inbound {[debug caller 1] | DO _______________________________________ /DONE}
		return
	    }

	    if {$mylocation == $mysentinel} {
		Forward signal-overrun
		return -code error "Input overrun after $mysentinel"
	    }

	    incr mylocation

	    set ch [lindex $mytext $mylocation]

	    # Semantic value is character location (s.a.)
	    # And push into the pipeline
	    debug.marpa/inbound {[debug caller 1] | DO '[char quote cstring $ch]' ($mylocation) ______}
	    debug.marpa/inbound {[debug caller 1] | DO _______________________________________}

	    Forward enter $ch $mylocation
	    incr mynumprocessed

	    # Note, the post-processor (gate, lexer) have access to the location, via methods
	    # moveto, moveby, and rewind. Examples of use:
	    # - Rewind after reading behind the current lexeme
	    # - Rewind for parse events.

	    debug.marpa/inbound {[debug caller 1] | DO _______________________________________ /NEXT}
	}

	return -code error "Should not be reached"
    }

    method enter-more {string} {
	debug.marpa/inbound {[debug caller 1] | }
	set start [llength $mytext]
	#   \-----------\ point @ separator, resume after
	lappend mytext \0 {*}[split $string {}]
	set  mysentinel [llength $mytext]
	incr mysentinel -1
	incr mynumstreams
	# Notes
	# - The {*} will put the entire string on the Tcl stack before
	#   it becomes part of the input buffer.
	# - The change to `mytext` does not affect the `max` used
	#   by `enter` to detect the end of the primary input.
	# - The new input will only be processed by moving explictly
	#   into its region. Processing it will not trigger EOI.
	# - The \0 separator ensures that positioning the cursor to
	#   just before the first of the secondary inputs will not
	#   trigger the EOF condition in `enter`.
	return $start
    }

    method barrier {} {
	debug.marpa/inbound {[debug caller] | }
	# Called from match facade, stop event handling.
	# Treat the stop as barrier like eof, and report if we got bounced.
	# The expected reaction to a bounce is the restoration of the stop
	# marker, to contain the next attempt at it.
	set here $mylocation
	Forward flush
	return [expr {$mylocation < $here}]
    }

    # Hook for sequencing checks
    method EOF {} {}

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
    # Sequence = 1[23][56]*4  # 1: construction
    # See mark <<s>>	      # 23: enter, read
    #                         # 45: enter-more, read-more
    #			      # x: EOF (internal, automatic)
    #
    # *-1-> ready -23-> running -x-> done|
    #                   ^ |
    #                   \-/45,8-13

    # Determin. state machine       # Table re-sorted, by method _=
    # Current  Method  New          # Current  Method  New
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~
    # -        <cons>  ready  	    # -        <cons>  ready
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~
    # ready    en|rd   running/done # ready    en|rd   running/done
    #          *-more  /FAIL  	    # running  en|rd   /FAIL
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ # done     en|rd   /FAIL
    # running  en|rd   /FAIL  	    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~
    #          *-more  /KEEP  	    # ready    *-more  /FAIL
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ # running  *-more  /KEEP
    # done     en|rd   /FAIL  	    # done     *-more  /FAIL
    #          *-more  /FAIL  	    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ # *        *       /KEEP
    # *        *       /KEEP  	    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~
    # ~~~~~~~  ~~~~~~  ~~~~~~~~~~~~ #

    # # -- --- ----- -------- -------------
    ## Mandatory overide of virtual base class method

    method __Init {} { my __States ready running done }

    # # -- --- ----- -------- -------------
    ## Checked API methods

    method enter {string {from -1} {to -2}} {
	my __Init
	my __Fail running ! "Unable to process input after start" START
	my __Fail done    ! "Unable to process input after EOF" EOF
	my __Goto running
	next $string $from $to
    }

    method enter-more {string} {
	my __Init
	my __Fail ready ! "Unable to extend input before start" START
	my __Fail done  ! "Unable to extend input after EOF" EOF
	next $string
    }

    # read      | Invokes `enter`, which does
    # read-more | the check and state change

    # location | Allowed anywhere, anytime.
    # stop     | No sequencing methods

    method dont-stop {} {
	my __Init
	my __Fail ready ! "Unable to clear stop location before start" START
	my __Fail done  ! "Unable to clear stop location after EOF" EOF
	next
    }

    method to {pos} {
	my __Init
	my __Fail ready ! "Unable to set stop location before start" START
	my __Fail done  ! "Unable to set stop location after EOF" EOF
	next $pos
    }

    method limit {delta} {
	my __Init
	my __Fail ready ! "Unable to set stop location before start" START
	my __Fail done  ! "Unable to set stop location after EOF" EOF
	next $delta
    }

    method from {pos} {
	my __Init
	my __Fail ready ! "Unable to set current location before start" START
	my __Fail done  ! "Unable to set current location after EOF" EOF
	next $pos
    }

    method relative {delta} {
	my __Init
	my __Fail ready ! "Unable to set current location before start" START
	my __Fail done  ! "Unable to set current location after EOF" EOF
	next $delta
    }

    method rewind {delta} {
	my __Init
	my __Fail ready ! "Unable to set current location before start" START
	my __Fail done  ! "Unable to set current location after EOF" EOF
	next $delta
    }

    method EOF {} {
	my __Init
	my __Fail done ! "Unable to process input after EOF" EOF
	next

	my __Goto done
    }
}

# # ## ### ##### ######## #############
return
