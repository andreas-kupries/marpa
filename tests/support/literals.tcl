# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
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
    lappend map RX  "Unable to reduce type"

    # Resolve result fragment references
    while {[regexp {@result<([^>]*)>} $result -> path]} {
	set content [fget [redir $path]]
	set result [string map [list @result<${path}> $content] $result]
    }

    # Resolve standard, fixed shorthands, and strip indentation
    FE [string map $map $result]
}

proc ++ {args} {
    global map
    lappend map {*}$args
    return
}

proc >> {} {
    global map maps
    lappend maps $map
    set map {}
    return
}

proc << {} {
    global map maps
    set res $map
    set map  [lindex $maps end]
    set maps [lrange $maps 0 end-1]
    lappend map $res
    return
}

proc ** {} {
    global map maps
    set res $map
    unset -nocomplain map maps
    return $res
}

proc L {literal} {
    global nlit
    set nlit [string map [list @@@ [marpa unicode max]] $literal]
    return
}

proc +C {rules code result} {
    global nlit nmap
    set expected [RR $result $rules $nlit]
    dict set nmap $nlit $rules [list $code $expected]
    return
}

proc // {} {
    global nmap nlit
    set r $nmap
    unset -nocomplain nmap nlit
    return $r
}

# # ## ### ##### ######## #############
return
