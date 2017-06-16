# -*- tcl -*-
# Generic reader for unicode datafiles
# Influenced by the python code at
#   https://github.com/google/re2/blob/master/re2/unicode.py
#
# Copyright 2017 Andreas Kupries

package require lambda

proc listmap {f list} {
    set res {}
    foreach x $list {
	lappend res [{*}$f $x]
    }
    return $res
}

namespace eval unireader {}

proc unireader::continuation {name} {
    if {[regexp {^<(.*), (First|Last)>$} $name -> n c]} {
	list $n $c
    } else {
	list $name {}
    }
}

proc unireader::process {data nfields percode} {
    # data    - data file wholly in memory.
    # nfields - expected number of fields (>=2 required)
    # percode - command prefix invoked per line (range of codepoints)

    set expect_last {}
    set first_code  {}

    foreach line [split $data \n] {
	# Remove comments, and outer whitespace
	regsub "#.*\$" $line {} line
	set line [string trim $line]

	# ignore empty lines
	if {$line eq {}} continue

	# extract fields
	set fields [split $line \;]
	if {[llength $fields] != $nfields} {
	    error "Field mismatch, expected $nfields, have [llength $fields]"
	}

	# strip inside whitespace
	set fields [listmap [lambda {field} {
	    string trim $field
	}] $fields]

	# First field is codepoint, or range

	set fields [lassign $fields code]
	if {[regexp {^(.*)\.\.(.*)$} $code -> first last]} {
	    {*}$percode 0x$first 0x$last {*}$fields
	    continue
	}

	# An alternate way of specifying a range is via two
	# consecutive lines, one tagged "<Name, First>" in the name, the
	# other "<Name, Last>".

	lassign [continuation [lindex $fields 0]] name cont

	if {($expect_last ne {}) && (($cont ne "Last") || ($expect_last ne $name))} {
	    error "Expected completion: ($expect_last), ($cont), ($name), $code"
	}
	if {$cont eq "First"} {
	    set expect_last $name
	    set first_code $code
	    continue
	}
	if {$cont eq "Last"} {
	    set expect_last {}
	    {*}$percode 0x$first_code 0x$code {*}$fields
	    continue
	}

	# Not a range, single code point
	{*}$percode 0x$code 0x$code {*}$fields
    }
    return
}
