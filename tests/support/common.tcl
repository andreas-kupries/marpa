# -*- tcl -*-
##
# (c) 2016-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

package require TclOO
package require fileutil

# # ## ### ##### ######## #############

proc cases {name} {
    set num 0
    lmap line [split [fileutil::cat [file join [td] cases $name]] \n] {
	incr num
	set line [string trim $line]
	if {$line eq {}} continue
	if {[string match #* $line]} continue
	list $num $line
    }
}

# # ## ### ##### ######## #############

proc iota {n} {
    if {$n < 0} { set n 0 }
    for {set i 0} {$i < $n} {incr i} {
	lappend r $i
    }
    return $r
}

# # ## ### ##### ######## #############
## Small wrapper around foreach to make tables of test cases look
## nicer.

proc testcases {var varlist cases script} {
    upvar 1 $var k
    foreach v $varlist { upvar 1 $v $v }
    set k 0
    foreach $varlist $cases {
	incr k
	set code [catch {
	    uplevel 1 $script
	} m]
	switch -exact -- $code {
	    0 {}
	    1 { return -code error $m }
	    2 { return -code return }
	    3 { break }
	    4 {}
	    default { return -code $code $m }
	}
    }
    unset -nocomplain k {*}$varlist
    return
}

# # ## ### ##### ######## #############
## Simplified interceptors

proc jack {label method alist body args} {
    global  __logs
    set lambda [list $alist $body]
    dict set __logs $label [set l [Marpa::Testing::Jack new $label $method $lambda [__logcenter] {*}$args]]
    return $l
}

# # ## ### ##### ######## #############
## Simplified Log API. Hiding (the complexity of) the classes and
## instances from the users. Auto-creation and -destruction as much as
## possible. All logs go into a shared recorder.

proc log {label} {
    global  __logs
    dict set __logs $label [set l [Marpa::Testing::Divert new $label [__logcenter] lognull]]
    return $l
}
proc log2 {label args} {
    global  __logs
    dict set __logs $label [set l [Marpa::Testing::Divert new $label [__logcenter] {*}$args]]
    return $l
}
proc /trace {label} {
    global  __logs
    [dict get $__logs $label] /trace
}
proc log-add {label args} {
    global  __logs
    [dict get $__logs $label] {*}$args
}
proc __logcenter {} {
    global __logcenter
    if {![info exists __logcenter]} {
	set __logcenter [Marpa::Testing::Log new]
    }
    return $__logcenter
}
proc logclear {} {
    [__logcenter] __clear
    return
}
proc logged {{sep "\n  "}} {
    global __logcenter __logs
    dict for {_ l} $__logs { $l destroy }
    set entries [$__logcenter __calls]
    unset __logcenter __logs
    if {![llength $entries]} { return {} }
    #set sep "\n  "
    return ${sep}[join $entries $sep]\n
}
proc logged/keep {{sep "\n  "}} {
    global __logcenter
    set entries [$__logcenter __calls/keep]
    if {![llength $entries]} { return {} }
    #set sep "\n  "
    return ${sep}[join $entries $sep]\n
}
proc lognull {args} {}

proc ... {args} {
    [__logcenter] {*}$args
    return
}

# # ## ### ##### ######## #############
## Recorder class (importable)

oo::class create Marpa::Testing::Log {
    variable mycalls

    constructor {} { my __clear }

    method __calls {} {
	set result $mycalls
	my destroy
	return $result
    }

    method __calls/keep {} {
	return $mycalls
    }

    method __clear {} { set mycalls {} ; return }

    export __calls
    export __clear

    # # -- --- ----- -------- -------------
    ## Record all methods

    method unknown {args} {
	lappend mycalls $args
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Recorder class (importable), interception and forwarding

oo::class create Marpa::Testing::Intercept {
    variable mytarget
    variable mycalls

    constructor {args} {
	set mytarget $args
	set mycalls {}
	return
    }

    method __calls {} {
	set result $mycalls
	my destroy
	return $result
    }

    # # -- --- ----- -------- -------------
    ## Record all methods. Forward to actual destination

    method unknown {args} {
	lappend mycalls C $args
	set result [uplevel 1 [list {*}$mytarget {*}$args]]
	lappend mycalls $result
	return $result
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Recorder class (importable), interception and forwarding, outside log

oo::class create Marpa::Testing::Divert {
    variable mylogger
    variable mytarget
    variable mylabel
    variable mytrace

    constructor {label logger args} {
	set mylabel  $label
	set mylogger $logger
	set mytarget $args
	set mytrace 0
	return
    }

    method /trace {} {
	set mytrace 1
	return
    }
    export /trace

    # # -- --- ----- -------- -------------
    ## Record all methods. Forward to actual destination.
    ## Recording is handled by a separate outside logger.
    ## Which can be fed by multiple interceptors

    method unknown {args} {
	if {$mytrace} {
	    # Tracing is a shorter log. Want to see only calls, return values irrelevant.
	    $mylogger $mylabel {*}$args
	    return [uplevel 1 [list {*}$mytarget {*}$args]]
	}
	$mylogger $mylabel C $args
	set result [uplevel 1 [list {*}$mytarget {*}$args]]
	$mylogger $mylabel R $args = $result
	return $result
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Recorder class (importable), act on interception, forward, outside log

oo::class create Marpa::Testing::Jack {
    variable mylogger
    variable mytarget
    variable mylabel
    variable mytrace
    variable mymethod
    variable mylambda

    constructor {label method lambda logger args} {
	set mylabel  $label
	set mylogger $logger
	set mytarget $args
	set mytrace  0
	set mymethod $method
	set mylambda $lambda
	return
    }

    method /trace {} {
	set mytrace 1
	return
    }
    export /trace

    # # -- --- ----- -------- -------------
    ## Record all methods. Forward to actual destination.
    ## Recording is handled by a separate outside logger.
    ## Which can be fed by multiple interceptors

    method unknown {args} {
	if {$mytrace} {
	    # Tracing is a shorter log. Want to see only calls, return values irrelevant.
	    $mylogger $mylabel {*}$args
	    return [uplevel 1 [list {*}$mytarget {*}$args]]
	}
	if {[lindex $args 0] eq $mymethod} {
	    # Invoke the lambda for the hijacked method
	    $mylogger $mylabel C $args
	    set result [uplevel 1 [list apply $mylambda {*}$args]]
	    $mylogger $mylabel R $args = $result
	} else {
	    # Forward anything else to target
	    set result [uplevel 1 [list {*}$mytarget {*}$args]]
	}
	return $result
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
