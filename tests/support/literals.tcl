# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Support functions for literal testing

proc F {defs} {
    join [lmap {sym lit} $defs { list $sym $lit }] \n
}

proc FE {str} {
    join [lmap line [split [string trim $str] \n] {
	string trim $line
    }] \n
}

proc RR {result rules literal} {
    set data [lassign $literal type]
    set dlit "($type ($data))"

    # Before the resolution of file names in @result<...> clauses
    lappend map <M> full ;#XXX [marpa unicode mode]
    set result [string map $map $result]
    unset map

    lappend map @@@ [marpa unicode max]
    lappend map @!  {STATE place done work <symbol>}
    lappend map @=  {STATE place done done <symbol>}
    lappend map @q  {STATE queue done <symbol>}
    lappend map @x  {STATE queue work <symbol>}
    lappend map RIL "Unable to reduce incomplete literal $dlit"
    lappend map RT  "Unable to reduce type $dlit"
    lappend map REL "Unable to reduce empty literal $dlit"

    # Resolve result fragment references
    while {[regexp {@result<([^>]*)>} $result -> path]} {
	set content [fget [redir $path]]
	set result [string map [list @result<${path}> $content] $result]
    }

    # Resolve standard, fixed shorthands, and strip indentation
    FE [string map $map $result]
}

# # ## ### ##### ######## #############
return
