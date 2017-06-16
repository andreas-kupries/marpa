# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.
##
# # ## ### ##### ######## #############
## Semantic state - Flag management
## Flags are per symbol or similar.
## A flag can be set, or unset, but not both.
## A flags state may be unknown however.
## This means
## - Setting a flag already known as unset fails
## - Unsetting a flag already known as set fails
## - Both set? and unset? may return false
## - If either set? or unset? returns true the
##   other predicate will return false.
##
## The semantics use instances of this class to track toplevel, use,
## and other state for grammar symbols.
##

oo::class create marpa::slif::semantics::Flag {
    marpa::EP marpa/slif/semantics \
	{Grammar error.} \
	SLIF SEMANTICS FLAG

    variable mymsg  ;# error message prefix
    variable mycode ;# error code prefix
    variable myflag ;# flag dictionary (known information)
    variable mysym  ;# symbol dictionary (superset of myflag, (*))
    #               ;# (*) I.e. includes the maybes

    constructor {container msg args} {
	marpa::import $container Container

	debug.marpa/slif/semantics {}
	#if {$msg ne {}} { append msg { } }
	set mymsg  $msg
	set mycode $args
	set myflag {}
	set mysym  {}
	return
    }

    method def {args} {
	debug.marpa/slif/semantics {}
	foreach key $args { dict set mysym $key . }
	return
    }

    method complete {x v script} {
	debug.marpa/slif/semantics {}
	upvar 1 $v sym

	#Container comment [self] complete _S_($mysym)__
	#Container comment [self] complete _F_($myflag)__

	# all maybes become 'x'
	dict for {sym _} $mysym {
	    if {[my known? $sym]} continue
	    dict set myflag $sym $x
	    # Run the script on the completed symbol
	    uplevel 1 $script
	}
	return
    }

    method foreach {vs script} {
	debug.marpa/slif/semantics {}
	upvar 1 $vs sym

	#Container comment [self] complete _S_($mysym)__
	#Container comment [self] complete _F_($myflag)__

	dict for {sym _} $mysym {
	    uplevel 1 $script
	}
	return
    }

    method set! {args} {
	debug.marpa/slif/semantics {}
	foreach key $args {
	    if {![my unset? $key]} continue
	    my E "Unable to make <$key> a ${mymsg}, already other" \
		{*}$mycode ALREADY UNSET
	}
	foreach key $args {
	    dict set mysym  $key .
	    dict set myflag $key 1
	}
	return
    }

    method unset! {args} {
	debug.marpa/slif/semantics {}
	foreach key $args {
	    if {![my set? $key]} continue
	    my E "<$key> already a ${mymsg}, cannot be undone" \
		{*}$mycode ALREADY SET
	}
	foreach key $args {
	    dict set mysym  $key .
	    dict set myflag $key 0
	}
	return
    }

    method known? {key} {
	debug.marpa/slif/semantics {}
	return [dict exists $myflag $key]
    }

    method set? {key} {
	debug.marpa/slif/semantics {}
	return [expr {[dict exists $myflag $key] && [dict get $myflag $key]}]
    }

    method unset? {key} {
	debug.marpa/slif/semantics {}
	return [expr {[dict exists $myflag $key] && ![dict get $myflag $key]}]
    }
}
