# -*- tcl -*-
## (c) 2017-present Andreas Kupries
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
    removeFile      [td]/[cget cl].tcl
    removeDirectory [td]/OUT_[cget cl]
    removeFile      [td]/OUT_[cget cl]_LOG
    removeFile      [td]/GEN_LOG
    return
}

proc ::gen::I {gc args} {
    puts XX_S\t$args
    flush stdout
    #GC {*}$args
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

    exec >& GEN_LOG [top]/bin/i-gen \
	[top] $kt::localprefix \
	$ex $cl $gr [td]/${cl}.tcl

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

    # Source the resulting parser package
    kt local* support marpa::c
    kt local* support marpa::runtime::tcl
    uplevel #0 [list source [td]/${cl}.tcl]
    return
}

proc ::gen::LoadRTC {} {
    upvar 1 cl cl

    # Load the resulting parser package. Required runtime first.
    kt local* support marpa::runtime::c

    # Match the directory used by bin/i-gen for the package
    set dir [glob -directory [td]/OUT_${cl}/L *]
    source $dir/pkgIndex.tcl
    package require $cl
    return
}

proc ::gen::Init {} {
    variable config {
	ex tparse
	gr {}
	cl generated
    }
    variable export {
	tlex   tlex
	tparse tparse
	cparse cparse-critcl
	clex   clex-critcl
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
