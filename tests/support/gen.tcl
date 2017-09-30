# -*- tcl -*-
## (c) 2017 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## A variant of `marpa-gen` built into the test suite.
## Enables dynamic creation of parsers and lexers to test.

namespace eval ::gen {
    namespace export {[a-z]*}
    namespace ensemble create
}

proc ::gen::cget {k} {
    variable config
    set v [dict get $config $k]
    if {$k eq "gr" && $v eq {}} {
	set v [td]/grammars/z-marpa-tcl/slif
	dict set config $k $v
    }
    return $v
}

proc ::gen::configure {args} {
    variable config
    foreach {k v} $args {
	if {![dict exists $config $k]} {
	    return -code error "Bad configuration option \"$k\""
	}
	dict set config $k $v
    }
    return
}

proc ::gen::cleanup {} {
    removeFile [td]/[cget cl].tcl
    removeDir  [td]/OUT_[cget cl]
    return
}

proc ::gen::setup {args} {
    variable export
    variable load
    configure {*}$args

    set ex [dict get $export [gen cget ex]]
    set gr [gen cget gr]
    set cl [gen cget cl]
    
    # _ __ ___ _____ ________ _____________ _____________________
    # The builtin lexer, parser and uncore are used to process a
    # grammar (SLIF meta by default) and create an engine for it (via
    # the proper exporter). This engine is used, in turn, in test
    # cases.
    
    # _ __ ___ _____ ________ _____________ _____________________
    # I. Create the processor
    marpa::slif::container create GC
    #puts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    marpa::slif::semantics create SEMX GC
    marpa::slif::parser    create BOOT

    # _ __ ___ _____ ________ _____________ _____________________
    # II. Process the slif meta grammar
    SEMX process [BOOT process-file $gr]
    # GC now holds the grammar
    BOOT destroy
    # Note: SEMX auto-destroys itself at the end of 'process'.

    # _ __ ___ _____ ________ _____________ _____________________
    # III. Generate a tcl-based parser class
    marpa::export config! version  1
    marpa::export config! writer   {TclMarpa Testsuite}
    marpa::export config! year     2017
    marpa::export config! name     $cl
    marpa::export config! operator $::tcl_platform(user)@[info hostname]
    marpa::export config! tool     [info script]

    set engine [$ex container GC]
    GC destroy

    # Write to file for debugging.
    fileutil::writeFile [td]/${cl}.tcl $engine

    # _ __ ___ _____ ________ _____________ _____________________
    # IV. Load and activate the new class.

    #puts XXX|[dict get $load [gen cget ex]]||
    eval [dict get $load [gen cget ex]]

    # _ __ ___ _____ ________ _____________ _____________________
    return
}

# # ## ### ##### ######## ############# #####################

proc ::gen::LoadTcl {} {
    upvar 1 cl cl
    uplevel #0 [list source [td]/${cl}.tcl]
    return
}

proc ::gen::LoadRTC {} {
    upvar 1 cl cl

    # Run an external critcl process to compile the new
    # parser. This avoids issues with multiple definitions of
    # various custom arg/result types interfering with each
    # other.

    set out [td]/OUT_${cl}
    file mkdir $out/C $out/L

    exec ln -s [file normalize [td]/../rtc] rtc
    exec ln -s [file normalize [td]/../c] c

    exec >& $out/LOG critcl -pkg -keep \
	-cache  $out/C \
	-libdir $out/L \
	[td]/${cl}.tcl
    
    file delete rtc c

    # At last load the resulting parser package
    
    set dir [glob -directory $out/L *]
    source $dir/pkgIndex.tcl
    package require [string map {- _} $cl]
    
    # Actual compile to and loading of shlib happens on first use.
    ::exit 2
    return
}

proc ::gen::Init {} {
    variable config {
	ex tparse
	gr {}
	cl generated
    }
    variable export {
	tlex   marpa::export::tlex
	tparse marpa::export::tparse
	cparse marpa::export::cparse-critcl
	clex   marpa::export::clex-critcl
    }
    variable load {
	tlex   { LoadTcl }
	tparse { LoadTcl }
	cparse { LoadRTC }
	clex   { LoadRTC }
    }
    return
}

# # ## ### ##### ######## ############# #####################
gen::Init

# # ## ### ##### ######## ############# #####################
return
