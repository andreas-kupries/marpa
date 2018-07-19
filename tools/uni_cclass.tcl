# -*- tcl -*-
## Datastructures and accessors for char class management
#
# Copyright 2017-2018 Andreas Kupries
#
# - cc-write-tcl
# - cc-normalize
# - cc-parts
# - cc-extend name ...
# - cc-label  name label
# - cc-exists name
# - cc-get    name
# - cc-label  name label

# # ## ### ##### ########

proc cc-parts {} {
    foreach id [CC-keys] {
	pong "Parts of $id ..."

	lassign [CC-parts $id] bmp smp
	set b [llength $bmp]
	set s [llength $smp]

	if {$b && $s} {
	    # No aliases, both parts exist and are therefore true
	    # sub-sets. New classes.
	    cc-extend ${id}:bmp {*}$bmp
	    cc-extend ${id}:smp {*}$smp
	    continue
	}
	if {$b} {
	    # Only BMP found, must be the class, therefore alias
	    alias-def ${id}:bmp $id
	    continue
	}
	if {$s} {
	    # Only SMP found, must be the class, therefore alias
	    alias-def ${id}:smp $id
	    continue
	}

	error "Empty class"
    }
}

proc cc-normalize {} {
    global cc
    foreach id [CC-keys] {
	pong "Normalizing $id"
	dict set cc $id [norm-class [dict get $cc $id]]
    }
    return
}

# # ## ### ##### ########

# Notes: The names of charclasses can be in any case.
#        Internally they are all lower-case.

# # ## ### ##### ########

proc cc-extend {name args} {
    global cc ccname
    set id [string tolower $name]

    dict set     ccname $id $name
    dict lappend cc     $id {*}$args
    return
}

proc cc-label {name label} {
    global cclabel
    set id [string tolower $name]
    dict set cclabel $id $label
    return
}

proc cc-exists {name} {
    global cc
    set id [string tolower $name]
    return [dict exists $cc $id]
}

proc cc-get {name} {
    global cc
    set id [string tolower $name]
    return [dict get $cc $id]
}

# # ## ### ##### ########

proc cc-write-tcl {} {
    write-sep {character classes -- named, represented as ranges}
    foreach id [lsort -dict [CC-keys]] {
	set name [CC-name $id]
	pong "Writing $name"
	set ranges [cc-get  $id]
	set sz     [CC-size $ranges]
	set label  "$name ($sz)[CC-label $id]"

	write-sep $label
	write-comment "I Class $name: Unicode ranges:  [llength $ranges]"
	wr ""
	wr "dict set marpa::unicode::cc $id \{"
	write-items 5 \t $ranges
	wr "\}"
	wr ""
    }
    return
}

proc CC-name {name} {
    global ccname
    set id [string tolower $name]
    return [dict get $ccname $id]
}

proc CC-label {id} {
    global cclabel
    if {[dict exists $cclabel $id]} {
	return " :[dict get $cclabel $id]"
    } else {
	return {}
    }
}

proc CC-keys {} {
    global cc
    return [dict keys $cc]
}

proc CC-size {ranges} {
    set sz 0
    foreach r $ranges {
	lassign $r s e
	if {$e eq {}} {
	    incr sz 1
	} else {
	    incr sz [expr {$e - $s + 1}]
	}
    }
    return $sz
}

proc CC-parts {id} {
    global bmpmax
    set ranges [cc-get $id]
    set bmp {}
    set smp {}
    foreach item $ranges {
	set n [llength $item]
	lassign $item a b
	if {$n == 1} {
	    if {$a <= $bmpmax} {
		lappend bmp $item
	    } else {
		lappend smp $item
	    }
	} elseif {$n == 2} {
	    if {$b <= $bmpmax} {
		# range fully BMP
		lappend bmp $item
		continue
	    }
	    if {$bmpmax < $a} {
		# range fully SMP
		lappend smp $item
		continue
	    }
	    # a <= bmpmax < b
	    # straddler.
	    lappend bmp [list $a $bmpmax]
	    set m $bmpmax ; incr m
	    lappend smp [list $m $b]
	} else {
	    error "Bad element $item"
	}
    }
    list [norm-class $bmp] [norm-class $smp]
}

# # ## ### ##### ########
## init
global ccname  ; set ccname  {} ;# char class ids mapped to name
global cc      ; set cc      {} ;# char classes as ranges of unicode points
global cclabel ; set cclabel {} ;# char class ids mapped to labels
return
