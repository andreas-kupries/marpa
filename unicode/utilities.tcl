# -*- tcl -*-
##
# (c) 2016-2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Build configuration utilities

proc generate-tables {} {
    set topdir [file dirname [file dirname [file normalize [info script]]]]

    set generator  $topdir/tools/unidata.tcl
    set unitables  $topdir/unidata/UnicodeData.txt
    set uniscripts $topdir/unidata/Scripts.txt

    set outdir     $topdir/generated
    set codefortcl $topdir/generated/unidata.tcl ;# Data, commands in Tcl
    set codeforc   $topdir/generated/unidata.c   ;# C Data and accessor functions
    set codeforh   $topdir/generated/unidata.h   ;# Declarations: Constants, data structures
    #set codeforc   $topdir/generated/unidata.c  ;# Definitions --TODO--

    if {
	[file exists $codefortcl] &&
	([file mtime $codefortcl] >= [file mtime $generator]) &&
	([file mtime $codefortcl] >= [file mtime $unitables]) &&
	([file mtime $codefortcl] >= [file mtime $uniscripts]) &&
	[file exists $codeforc] &&
	([file mtime $codeforc] >= [file mtime $generator]) &&
	([file mtime $codeforc] >= [file mtime $unitables]) &&
	([file mtime $codeforc] >= [file mtime $uniscripts]) &&
	[file exists $codeforh] &&
	([file mtime $codeforh] >= [file mtime $generator]) &&
	([file mtime $codeforh] >= [file mtime $unitables]) &&
	([file mtime $codeforh] >= [file mtime $uniscripts]) &&
	1
    } {
	critcl::msg -nonewline " (Up-to-date unicode data tables available, skipping generation)"
    } else {
	critcl::msg -nonewline " (Generating unicode data tables, please wait (about 2 sec) ..."

	# It usually takes about 2 seconds and change to process the
	# unidata files.

	set start [clock seconds]
	file mkdir $outdir
	exec {*}[info nameofexecutable] $generator $codefortcl $codeforh $codeforc 0
	set delta [expr { [clock seconds] - $start}]
	critcl::msg -nonewline " Done in $delta seconds: Tcl: [file size $codefortcl] bytes, C: [file size $codeforc] bytes, Chdr: [file size $codeforh] bytes)"
    }

    # Last, make the generated data available.

    critcl::tsources $topdir/generated/unidata.tcl
    critcl::cheaders $topdir/generated/unidata.h
    critcl::include  unidata.h
    critcl::csources $topdir/generated/unidata.c
    return
}

# # ## ### ##### ######## #############
return
