# -*- tcl -*-
##
# (c) 2016-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Build configuration utilities

proc generate-tables {{urange bmp}} {
    set selfdir [file dirname [file normalize [info script]]]
    
    set generator  $selfdir/tools/unidata.tcl
    set unitables  $selfdir/unidata/UnicodeData.txt
    set uniscripts $selfdir/unidata/Scripts.txt

    set outdir     $selfdir/generated
    set codefortcl $selfdir/generated/unidata-${urange}.tcl ;# Data, commands in Tcl
    set codeforc   $selfdir/generated/unidata-${urange}.h   ;# Declarations: Constants, data structures
    #set codeforc   $selfdir/generated/unidata-${urange}.c  ;# Definitions --TODO--

    if {
	[file exists $codefortcl] &&
	([file mtime $codefortcl] >= [file mtime $generator]) &&
	([file mtime $codefortcl] >= [file mtime $unitables]) &&
	([file mtime $codefortcl] >= [file mtime $uniscripts]) &&
	[file exists $codeforc] &&
	([file mtime $codeforc] >= [file mtime $generator]) &&
	([file mtime $codeforc] >= [file mtime $unitables]) &&
	([file mtime $codeforc] >= [file mtime $uniscripts]) &&
	1
    } {
	set m [string toupper $urange]
	critcl::msg -nonewline " (Up-to-date unicode $m data tables available, skipping generation)"
    } else {
	set delay [switch -exact -- $urange { bmp { expr 10 } full { expr 30 } }]
	critcl::msg -nonewline " (Generating unicode data tables, please wait (about $delay sec) ..."

	# It usually takes about 30 seconds and change to process the
	# unidata files for mode 'full'. And about 10 seconds for mode
	# 'bmp'. The majority of that time is taken by the conversion
	# of unicode char classes to ASBR form, with the majority of
	# that centered on a few large categories like the various
	# type of Letters (Ll, Lo, Lu), and the derived categories
	# including them. This is the price of a Tcl implementation
	# for 2asbr in the generator. We cannot use the C
	# implementation in marpa itself, marpa does not exist yet,
	# and even if so it might not match the chosen mode either.

	set start [clock seconds]
	file mkdir $outdir
	exec {*}[info nameofexecutable] $generator $urange $codefortcl $codeforc 0
	set delta [expr { [clock seconds] - $start}]
	critcl::msg -nonewline " Done in $delta seconds: Tcl: [file size $codefortcl] bytes, C: [file size $codeforc] bytes)"
    }

    # Last, make the generated data available.

    critcl::tsources generated/unidata-${urange}.tcl
    critcl::cheaders generated/unidata-${urange}.h
    critcl::include  unidata-${urange}.h
    return
}

# # ## ### ##### ######## #############
return
