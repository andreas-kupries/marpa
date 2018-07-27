# -*- tcl -*-
## Basic output utilities
#
# Copyright 2017-present Andreas Kupries
#
# - wr,  wr*,  write-comment,   write-sep,   write-items
# - wrc, wrc*, write-c-comment, write-c-sep, write-c-items
# - wrh, wrh*, write-h-comment, write-h-sep

# # ## ### ##### ########

proc write-destinations {tcl hdr c} {
    global outtcl outc outh
    set outtcl [open $tcl w]
    set outh   [open $hdr w]
    set outc   [open $c   w]
    return
}

# # ## ### ##### ########

proc write-items {max pfx items} {
    set col 0
    set prefix $pfx
    foreach item $items {
	wr* $prefix[list $item]
	set prefix { }
	incr col
	if {$col == $max} {
	    set prefix \n$pfx
	    set col 0
	}
    }
    return
}

proc write-c-items {max pfx items} {
    set col 0
    set prefix $pfx
    foreach item [lrange $items 0 end-1] {
	wrc* $prefix[list $item],
	set prefix { }
	incr col
	if {$col == $max} {
	    set prefix \n$pfx
	    set col 0
	}
    }

    # Final element
    wrc* $prefix[list [lindex $items end]]
    return
}

# # ## ### ##### ########

proc write-sep {label} {
    wr "# _ __ ___ _____ ________ _____________ _____________________ $label"
    wr "##"
    wr ""
    return
}

proc write-h-sep {label} {
    wrh "/* _ __ ___ _____ ________ _____________ _____________________ $label"
    wrh "*/"
    wrh ""
    return
}

proc write-c-sep {label} {
    wrc "/* _ __ ___ _____ ________ _____________ _____________________ $label"
    wrc "*/"
    wrc ""
    return
}

# # ## ### ##### ########

proc wr {text} {
    global outtcl
    puts $outtcl $text
    return
}

proc wr* {text} {
    global outtcl
    puts -nonewline $outtcl $text
    return
}

proc write-comment {text} {
    wr "# [join [split $text \n] "\n# "]"
    return
}

proc wrc {text} {
    global outc
    puts $outc $text
    return
}

proc wrc* {text} {
    global outc
    puts -nonewline $outc $text
    return
}

proc write-c-comment {text} {
    wrc "/* [join [split $text \n] "\n# "] */"
    return
}

proc wrh {text} {
    global outh
    puts $outh $text
    return
}

proc wrh* {text} {
    global outh
    puts -nonewline $outh $text
    return
}

proc write-h-comment {text} {
    wrh "/* [join [split $text \n] "\n# "] */"
    return
}

# # ## ### ##### ########
## init
global outtcl
global outc
global outh
return
