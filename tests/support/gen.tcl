# -*- tcl -*-
## (c) 2017-2018 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## A variant of `marpa-gen` built into the test suite.
## Enables dynamic creation of parsers and lexers to test.

kt local* support marpa::runtime::tcl
kt local* support marpa::runtime::c
kt local* support marpa::slif::container
kt local* support marpa::slif::semantics
kt local* support marpa::slif::parser
kt local* support marpa::gen

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
    removeFile      [td]/[cget cl].tcl
    removeDirectory [td]/OUT_[cget cl]
    removeFile      [td]/OUT_[cget cl]_LOG
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
    marpa::gen config! version  1
    marpa::gen config! writer   {TclMarpa Testsuite}
    marpa::gen config! year     2017
    marpa::gen config! name     $cl
    marpa::gen config! operator $::tcl_platform(user)@[info hostname]
    marpa::gen config! tool     [info script]

    kt local support $ex
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
    kt local* support marpa::c
    kt local* support marpa::runtime::tcl
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

    # NOTE: The kt::localprefix provides us with the location of the
    # main debug installation of marpa packages under test. That is
    # also where we will find the stub decls for the C runtime package
    # needed by the lexer/parser to-be.
    
    if {[catch {
	exec >& ${out}_LOG critcl -pkg -keep \
	    -cache  $out/C \
	    -libdir $out/L \
	    -I ${kt::localprefix}/include \
	    [td]/${cl}.tcl
    }]} {
	file copy ${out}_LOG ${out}_ERRLOG
    }
    
    file delete rtc c

    # At last load the resulting parser package
    kt local* support marpa::runtime::c
    
    set dir [glob -directory $out/L *]
    source $dir/pkgIndex.tcl
    package require $cl
    
    # Actual compile to and loading of shlib happens on first use.
    return
}

proc ::gen::Init {} {
    variable config {
	ex tparse
	gr {}
	cl generated
    }
    variable export {
	tlex   marpa::gen::format::tlex
	tparse marpa::gen::format::tparse
	cparse marpa::gen::format::cparse-critcl
	clex   marpa::gen::format::clex-critcl
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
