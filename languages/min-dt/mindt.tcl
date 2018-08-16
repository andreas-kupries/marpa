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

    constructor {parser sfparser} {
	debug.mindt/parser {[debug caller] | }
	marpa::import $sfparser SF
	marpa::multi-stop create PAR $parser
	PAR on-event [self namespace]::my ProcessSpecialForms
	set label   *primary*
	set var     {}
	return
    }

    destructor {
	debug.mindt/parser {[debug caller] | }
	PAR destroy
	SF  destroy
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
	set v [PAR match value]

	debug.mindt/parser {[debug caller 1] | [${s}:$l] = ($v)}
puts "ZZZ\t\[${s}:$l] = ($v)"
	set vast [SF process $v]

	debug.mindt/parser {[debug caller 1] | ast = $vast}

	my {*}$vast -- 1 $s $l
	return
    }

    method var_def {children -- top start length} {
	# children = (varname value)
	debug.mindt/parser {[debug caller] | }

	lassign $children varname value
	# varname = ast
	# value   = terminal (start, length, text)
	set varname [my {*}$varname -- 0 $start $length]
	lassign $value vs vl vtext

	incr vs $start

	if {[my Braced $vtext]} {
	    # Braced value. Store with braces stripped, adjust range,
	    # mark as Simple for toplevel references.
	    incr vs
	    incr vl -2
	    set spec [list $vs $vl 1 [my Strip $vtext]]
	} elseif {[my Quoted $vtext]} {
	    # Quoted value. Store with quotes stripped, for use in
	    # nested references, adjust range. Mark as non-simple.
	    incr vs
	    incr vl -2
	    set spec [list $vs $vl 0 [my Strip $vtext]]
	} else {
	    # Plain value. Store unchanged. Mark as non-simple.
	    set spec [list $vs $vl 0 $vtext]
	}

	# Remember mapping
	dict set var $varname $spec
	return ""
    }

    method Braced {x} { string match "\{*\}" $x }
    method Quoted {x} { string match "\"*\"" $x }
    method Strip  {x} { string range $x 1 end-1 }

    method var_ref {children -- top start length} {
	# children = (varname)
	debug.mindt/parser {[debug caller] | }

	lassign $children varname
	# varname = ast
	set varname [my {*}$varname -- 0 $start $length]
	lassign [dict get $var $varname] vs vl simple vtext
	
	if {$top} {
	    # Top level references go directly into the engine, with
	    # action dependent on if the value is simple or not.
	    
	    if {$simple} {
		# Return directly as a lexeme in place of vref
		PAR match alternate Simple [list $vs $vl $vtext]
	    } else {
		# The value is not simple. Insertion means re-scanning.
		# Redirect the IO system to its start, and set up a return
		# to here when done.
		set here [PAR match location]
		incr vl $vs
		PAR match from     $vs
		PAR match mark-add ${varname}:$here $vl @from $here
	    }
	} else {
	    # Nested reference simply returns content to caller for
	    # direct use in constructing variable names or paths.
	    return $vtext
	}
    }

    method include {children -- top start length} {
	# children = (path)
	debug.mindt/parser {[debug caller] | }

	lassign $children path
	# path = ast
	set path [my {*}$path -- 0 $start $length]

puts INC\t($path)

	# here = match location
	# resolve path
	# size = ...
	# off = extend-file ...
	# match from off, limit size,
	# action = return to <here>
	return
    }

    # # ## ### ##### ######## ##### ### ## # #

    method braced {children -- top start length} {
	# children = (terminal)
	debug.mindt/parser {[debug caller] | }
	return [my Strip [lindex $children 0 2]]
    }
    
    method q_list {children -- top start length} {
	# children = ...
	debug.mindt/parser {[debug caller] | }
	return [join [lmap child $children {
	    my {*}$child -- 0 $start $length
	}] {}]
    }
    
    method simple {children -- top start length} {
	# children = (terminal)
	debug.mindt/parser {[debug caller] | }
	return [lindex $children 0 2]
    }

    method space {children -- top start length} {
	# children = (terminal)
	debug.mindt/parser {[debug caller] | }
	return [lindex $children 0 2]
    }

    method unquot {children -- top start length} {
	# children = (lead tail)
	debug.mindt/parser {[debug caller] | }
	lassign $children lead tail
	append r [my {*}$lead -- 0 $start $length]
	if {![llength $tail]} { return $r }
	append r [my {*}$tail -- 0 $start $length]
	return $r
    }

    method uq_list {children -- top start length} {
	# children = ...
	debug.mindt/parser {[debug caller] | }
	return [join [lmap child $children {
	    my {*}$child -- 0 $start $length
	}] {}]
    }

    method quote {children -- top start length} {
	# children = (terminal)
	debug.mindt/parser {[debug caller] | }
	return "\""
    }

    # Various symbols do not appear in the AST due to use of ::first
    # in sf.slif
    ##
    # - form
    # - vars
    # - varname
    # - path
    # - value
    # - recurse
    # - quoted
    # - q_elem
    # - uq_lead
    # - uq_elem

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
