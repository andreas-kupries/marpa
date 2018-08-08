# -*- tcl -*-
## Datastructures and accessors for char class aliases management
#
# Copyright 2017-present Andreas Kupries
#
# - alias-def
# - alias-exists
# - alias-write-tcl

# Notes: The names of aliases and charclasses are expected to be in
# lower-case.

# # ## ### ##### ########

proc alias-write-tcl {} {
    global ccalias

    set sorted {}
    foreach name [lsort -dict [dict keys $ccalias]] {
	lappend sorted $name [dict get $ccalias $name]
    }

    write-sep {character class aliases}
    wr ""
    wr "set marpa::unicode::ccalias \{"
    write-items 8 \t $sorted
    wr "\}"
    wr ""

    return
}

proc alias-def {name cc} {
    global ccalias
    # Prevent alias-chaining.
    while {[dict exists $ccalias $cc]} {
	set cc [dict get $ccalias $cc]
    }
    if {![cc-exists $cc]} {
	error "Bad base class $cc in alias"
    }
    dict set ccalias $name $cc
    return
}

proc alias-exists {name} {
    global ccalias
    return [dict exists $ccalias $name]
}

# # ## ### ##### ########
## init
global ccalias ; set ccalias {} ;# char class alias mapped to base class
return
