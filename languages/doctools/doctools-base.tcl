# -*- tcl -*-
##
# BSD-licensed.
# (c) 2018-present - Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                    http://core.tcl.tk/akupries/
##

# doctools base class providing the parse event handling to complete
# the processing of the special forms. Derived from the multistop
# helper for easier handling of the multiple stop points which will be
# introduced by nested includes.

# @@ Meta Begin
# Package doctools::base 1
# Meta author      {Andreas Kupries}
# Meta category    Parser
# Meta description A DOCTOOLS parser.
# Meta description Returns the abstract syntax tree of
# Meta description the doctools read from file or stdin.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta subject     parsing doctools {abstract syntax tree}
# Meta summary     A doctools parser based on the Tcl binding to
# Meta summary     Jeffrey Kegler's libmarpa.
# @@ Meta End

# # ## ### ##### ######## #############

package provide doctools::base 1

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO
package require debug           ;# Tracing
package require debug::caller   ;# Tracing
package require marpa::util	;# marpa::import
package require marpa::multi-stop

# # ## ### ##### ######## #############

debug define doctools/base
#debug prefix doctools/base {[debug caller] | }
#debug on doctools/base

debug define doctools/base/include
#debug prefix doctools/base/include {}
#debug on doctools/base/include

# # ## ### ##### ######## #############

oo::class create doctools::base {

    constructor {parser sfparser} {
	debug.doctools/base {[debug caller] | }
	marpa::import $sfparser SF
	marpa::multi-stop create PAR $parser
	PAR on-event [self namespace]::my ProcessSpecialForms
	set mypath [file join [pwd] __fake__]
	set myvar  {}
	return
    }

    destructor {
	debug.doctools/base {[debug caller] | }
	PAR destroy
	SF  destroy
	return
    }

    # TODO: rewrite parse errors based on location to show proper
    # line/col/path information.

    method process {string args} {
	debug.doctools/base {[debug caller 1] | }
	PAR process $string {*}[my Options $args]
    }

    method process-file {path args} {
	debug.doctools/base {[debug caller] | }
	# Note, the user is able to override the default path
	# information through the option `path`.
	set mypath [my N $path]
	PAR process-file $path {*}[my Options $args]
    }

    method Options {words} {
	debug.doctools/base {[debug caller] | }
	# PAR supported options in `words` are
	# - `from`
	# - `to`
	# - `limit`
	# This code adds support for option
	# - `path`
	# Used for resolution of relative include paths.
	set new {}
	foreach {option value} $words {
	    if {$option eq "path"} {
		set mypath [my N $value]
		debug.doctools/base {[debug caller] | mypath = $mypath }
		continue
	    }
	    lappend new $option $value
	}

	debug.doctools/base {[debug caller] | => ($new) }
	return $new
    }

    method Resolve {path} {
	debug.doctools/base {[debug caller] | }
	set basedir [file dirname $mypath]
	foreach base [list $basedir [pwd]] {
	    set full [file join $base $path]
	    if {![file exists $full]} continue
	    return [my N $full]
	}
	return -code error \
	    "File `$path` not found, searching in `$basedir` and `[pwd]`"
    }

    method N {path} {
	debug.doctools/base {[debug caller] | }
	set path [file dirname [file normalize [file join $path ...]]]
	debug.doctools/base {[debug caller] | norm = $path}
	return $path
    }
    
    method ProcessSpecialForms {__ type enames} {
	debug.doctools/base {[debug caller 1] | }
	# Discard matched lexeme
	PAR match clear

	set s [PAR match start]
	set l [PAR match length]
	set v [PAR match value]

	debug.doctools/base {[debug caller 1] | <${s}:${l}> = ($v)}
	set vast [SF process $v]

	debug.doctools/base {[debug caller 1] | ast = $vast}

	# Treat AST nodes as deeply-nested command structure.
	# Each node is responsible for handling its children.
	# Which are provided as the first argument, a list of nodes.
	my {*}$vast -- 1 $s $l
	#my X {*}$vast -- 1 $s $l

	debug.doctools/base {[debug caller 1] | /done}
	return
    }

    method X {args} {
	puts [info level 0]
	my {*}$args
    }

    method var_def {children -- top start length} {
	# Variable definition.
	# Extends `myvar` with a mapping from variable name to value.

	# children = (varname value)
	debug.doctools/base {[debug caller] | }

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
	dict set myvar $varname $spec
	return ""
    }

    method Braced {x} { string match "\{*\}" $x }
    method Quoted {x} { string match "\"*\"" $x }
    method Strip  {x} { string range $x 1 end-1 }

    method var_ref {children -- top start length} {
	# Variable reference/use
	# Retrieves the value associated with the variable name from
	# `myvar` and either returns it to the caller (inner
	# references) or into the parser (toplevel use).

	# children = (varname)
	debug.doctools/base {[debug caller] | }

	lassign $children varname
	# varname = ast
	set varname [my {*}$varname -- 0 $start $length]
	lassign [dict get $myvar $varname] vs vl simple vtext

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
	# File inclusion. Resolves the path name, then directs the
	# parser to read from the file, returning to the current
	# location when the included file ends.

	# children = (path)
	debug.doctools/base {[debug caller] | }

	lassign $children path
	# path = ast
	set path [my {*}$path -- 0 $start $length]

	# Resolve to absolute path, using current path as context,
	# then use it to extend the input stream, if not in a
	# recursion.

	set full [my Resolve $path]
	set sz   [file size $full]
	debug.doctools/base/include {@inc #$sz $full}

	# Shortcircuit inclusion of empty file.
	# Nothing needs to be done.
	if {!$sz} {
	    debug.doctools/base/include {@ret =[PAR match location] $mypath}
	    return
	}
	
	if {[PAR match mark-exists $full]} {
	    return -code error \
		"Detected recursive include of file `$full`, aborting."
	}

	# Extend input and set up the return when reaching the new
	# secondary's end.

	set  here  [PAR match location]
	set  start [PAR extend-file $full]

	debug.doctools/base/include {@inc @$start}
	
	set  stop $sz    ;# end relative to start of new file itself
	incr stop $start ;# end relative to entire extended input
	incr stop -1     ;# last character

	PAR match mark-add $full $stop [self namespace]::my ReturnTo $here $mypath

	# Start reading from the included file, also using it as the
	# new path resolution context

	set mypath $full
	PAR match from $start
	return
    }

    method ReturnTo {location path __ mark} {
	debug.doctools/base {[debug caller] | }
	# Restore the origin location and path context when reaching
	# the end of an included file.
	debug.doctools/base/include {@ret @$location $path}

	set mypath     $path
	PAR match from $location
	return
    }

    # # ## ### ##### ######## ##### ### ## # #

    method braced {children -- top start length} {
	# children = (terminal)
	debug.doctools/base {[debug caller] | }
	return [my Strip [lindex $children 0 2]]
    }

    method q_list {children -- top start length} {
	# children = ...
	debug.doctools/base {[debug caller] | }
	return [join [lmap child $children {
	    my {*}$child -- 0 $start $length
	}] {}]
    }

    method simple {children -- top start length} {
	# children = (terminal)
	debug.doctools/base {[debug caller] | }
	return [lindex $children 0 2]
    }

    method space {children -- top start length} {
	# children = (terminal)
	debug.doctools/base {[debug caller] | }
	return [lindex $children 0 2]
    }

    method unquot {children -- top start length} {
	# children = (lead tail)
	debug.doctools/base {[debug caller] | }
	lassign $children lead tail
	append r [my {*}$lead -- 0 $start $length]
	if {![llength $tail]} { return $r }
	append r [my {*}$tail -- 0 $start $length]
	return $r
    }

    method uq_list {children -- top start length} {
	# children = ...
	debug.doctools/base {[debug caller] | }
	return [join [lmap child $children {
	    my {*}$child -- 0 $start $length
	}] {}]
    }

    method quote {children -- top start length} {
	# children = (terminal)
	debug.doctools/base {[debug caller] | }
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
    # - var     :: dict (name :: string -> content :: *1)
    #   content :: list/2,3 (start :: int, length :: int, ?value :: string?)
    # - label   :: string

    # myvar   : mapping from variable nmes to content (location, actual
    #           value for braced literals
    # mypath  : Path for the file representing the currently active input stream.
    #           Set initially, on includes, and on returns from includes.
    #           The stack of paths is implied in the actions for file markers.

    variable myvar mypath
}

# # ## ### ##### ######## #############
return
