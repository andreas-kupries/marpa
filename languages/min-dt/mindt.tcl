# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##

# mini doctools adapter providing the parse event handling to complete
# the processing of the special forms. Derived from the multistop
# helper for easier handling of the multiple stop points which will be
# introduced by nested includes.

# @@ Meta Begin
# Package mindt::parser 1
# Meta author      {Andreas Kupries}
# Meta category    Parser
# Meta description A minimal MINDT parser.
# Meta description Returns the abstract syntax tree of
# Meta description the MINDT read from file or stdin.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     parsing mindt {abstract syntax tree}
# Meta summary     A minimal MINDT parser based on the Tcl binding to
# Meta summary     Jeffrey Kegler's libmarpa.
# @@ Meta End

# # ## ### ##### ######## #############

package provide mindt::parser 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug           ;# Tracing
package require debug::caller   ;# Tracing
package require marpa::util	;# marpa::import

# # ## ### ##### ######## #############

debug define mindt/parser
#debug prefix mindt/parser {[debug caller] | }

# # ## ### ##### ######## #############

oo::class create mindt::parser {
    #superclass marpa::multi-stop

    constructor {parser} {
	debug.mindt/parser {[debug caller] | }
	#marpa::import $parser PAR
	marpa::multi-stop create PAR $parser
	PAR on-event [self namespace]::my ProcessSpecialForms
	set label *primary*
	set var   {}
	return
    }

    destructor {
	debug.mindt/parser {[debug caller] | }
	PAR destroy
	return
    }

    forward process  PAR process
    # TODO: wrap as method to rewrite parse errors based on
    
    if 0 {method process {string args} {
	debug.mindt/parser {[debug caller 0] | }
	PAR process $string {*}$args
    }}

    method ProcessSpecialForms {__ type enames} {
	debug.mindt/parser {[debug caller 1] | }
	# Discard matched lexeme
	PAR match clear

	set s [PAR match start]
	set l [PAR match length]
	set v [string range [PAR match value] 1 end-1]
	# v :: Outer brackets [] stripped

	# Use a separate parser to get the internal structure of the
	# separate form. Then transform and resolve all the inner
	# pieces before applying the outer form to the system state.

	
	# Event handling below may create alternatives.
	#foreach e $enames { my Process$e $s $l $v }
	#puts XA\t$s,$l\t($v)
	my {*}$v
	return
    }

    method vset {name {value {}}} {
	puts =V=\t([info level 0])
	puts =V=\t|$name|
	puts =V=\t|$value|
    }
    
    method include {path} {
	puts =I=\t([info level 0])
    }
    
    method ProcessVdef {start len value} {
	puts VD\t[info level 0]
    }

    method ProcessVref {start len value} {
	puts VU\t[info level 0]
    }

    method ProcessInclude {start len value} {
	puts I\t[info level 0]
    }

    # State information
    # - var   :: dict (name :: string -> content :: *1)
    #  content :: list/2,3 (start :: int, length :: int, ?value :: string?)
    # - label :: string

    # var   : mapping from variable nmes to content (location, actual
    #         value for braced literals
    # label : previous label of the input stream (include nesting)

    variable var label
}

# # ## ### ##### ######## #############
return
