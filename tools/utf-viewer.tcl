#!/usr/bin/env tclsh
# http://wiki.tcl.tk/1211 -- bit by bit
package require Tcl 8.5

if {![llength [info commands lmap]]} {
    # See also util/support.tcl `marpa::util`)
    # http://wiki.tcl.tk/40570
    # lmap forward compatibility

    proc lmap {args} {
	set body [lindex $args end]
	set args [lrange $args 0 end-1]
	set n 0
	set pairs [list]
	# Import all variables into local scope
	foreach {varnames listval} $args {
	    set varlist [list]
	    foreach varname $varnames {
		upvar 1 $varname var$n
		lappend varlist var$n
		incr n
	    }
	    lappend pairs $varlist $listval
	}
	# Run the actual operation via foreach
	set temp [list]
	foreach {*}$pairs {
	    lappend temp [uplevel 1 $body]
	}
	set temp
    }
}

# 0xxxxxxx	single-unit
# 10xxxxxx	trailer
# 110xxxxx	leader 2
# 1110xxxx	leader 3
# 11110xxx	leader 4
# 111110xx	leader 5
# 1111110x	leader 6

proc main {} {
    display {*}[transform [cmdline]]
}

proc cmdline {} {
    global argv
    if {[llength $argv] != 1} usage
    lassign $argv path

    if {$path eq "-"} {
	set chan stdin
    } else {
	set chan [open $path r]
    }
    fconfigure $chan -encoding binary
    set bytes [split [read $chan] {}]
    close $chan
    return $bytes
}

proc usage {} {
    global argv0
    puts stderr "Usage: $argv path|-"
    exit 1
}

proc transform {bytes} {
    # take bytes and annotate with class (0, 1, 2, 3, 4, 5, 6).
    # then look for complete characters and add value to the annotations.
    
    set codes [lmap b $bytes { C $b }]
    set types [lmap c $codes { T $c }]
    set at -1
    set notes [lmap c $codes t $types {
	incr at
	N/$t $c {*}[lrange $codes [expr {$at+1}] [expr {$at+$t-1}]]
    }]
    
    list $bytes $codes $types $notes
}

proc N/0 {code} {
    return "^"
}
proc N/1 {code} {
    set m "U+[format %04x $code]"
    if {(0xD7FF < $code) && ($code < 0xE000)} {
	append m " (surrogate)"
    }
    return $m
}
proc N/2 {code ta} {
    if {[T $ta] != 0} { return "Too short" }
    set uni [expr {(($code & 0b00011111) << 6)
		   |  ($ta & 0b00111111)
	       }]
    return [N/1 $uni]
}
proc N/3 {code ta tb} {
    if {[T $ta] != 0} { return "Too short" }
    if {[T $tb] != 0} { return "Too short" }
    set uni [expr {(($code & 0b00001111) << 12)
		   | (($ta & 0b00111111) << 6)
		   |  ($tb & 0b00111111)
	       }]
    return [N/1 $uni]
}
proc N/4 {code ta tb tc} {

    #puts ($code|$ta|$tb|$tc)
    #(240|155|191|191)
    #
    # 240 \360 11'110'000 | 000'011'011'111'111'111'111
    # 155 \233 10'011'011 | \0337777
    # 191 \277 10'111'111 | d114687
    # 191 \277 10'111'111 | x1BFFF
    
    if {[T $ta] != 0} { return "Too short" }
    if {[T $tb] != 0} { return "Too short" }
    if {[T $tc] != 0} { return "Too short" }
    set uni [expr {(($code & 0b00000111) << 18)
		   | (($ta & 0b00111111) << 12)
		   | (($tb & 0b00111111) << 6)
		   |  ($tc & 0b00111111)
	       }]
    return [N/1 $uni]
}
proc N/5 {code ta tb tc td} {
    if {[T $ta] != 0} { return "Too short" }
    if {[T $tb] != 0} { return "Too short" }
    if {[T $tc] != 0} { return "Too short" }
    if {[T $td] != 0} { return "Too short" }
    set uni [expr {(($code & 0b00000011) << 24)
		   | (($ta & 0b00111111) << 18)
		   | (($tb & 0b00111111) << 12)
		   | (($tc & 0b00111111) << 6)
		   |  ($td & 0b00111111)
	       }]
    return [N/1 $uni]
}
proc N/6 {code ta tb tc td te} {
    if {[T $ta] != 0} { return "Too short" }
    if {[T $tb] != 0} { return "Too short" }
    if {[T $tc] != 0} { return "Too short" }
    if {[T $td] != 0} { return "Too short" }
    if {[T $te] != 0} { return "Too short" }
    set uni [expr {(($code & 0b00000001) << 30)
		   | (($ta & 0b00111111) << 24)
		   | (($tb & 0b00111111) << 18)
		   | (($tc & 0b00111111) << 12)
		   | (($td & 0b00111111) << 6)
		   |  ($te & 0b00111111)
	       }]
    return [N/1 $uni]
}

proc C {b} {
    scan $b %c code
    return $code
}

proc T {code} {
    # \133 = 01'011'011
    if {($code & 0b10000000) == 0b00000000} { return 1 } ;# Single unit, ASCII
    if {($code & 0b11000000) == 0b10000000} { return 0 } ;# Trailer to Leader
    if {($code & 0b11100000) == 0b11000000} { return 2 } ;# Lead 2, one trailer
    if {($code & 0b11110000) == 0b11100000} { return 3 } ;# Lead 3, two trailer
    if {($code & 0b11111000) == 0b11110000} { return 4 } ;# Lead 4, three trailer
    if {($code & 0b11111100) == 0b11111000} { return 5 } ;# Lead 5, four trailer
    if {($code & 0b11111110) == 0b11111100} { return 6 } ;# Lead 6, five trailer
    error BAD-CODE|$code|[format %o $code]
}

proc display {bytes codes types notes} {
    set at 0
    set max [llength $bytes]
    set fmt %[string length $max]s
    foreach b $bytes c $codes t $types n $notes {
	set l [format $fmt $at]
	set c [format %3u $c]
	puts "\[$l] $b $c $t $n"
	incr at
    }
}

main
