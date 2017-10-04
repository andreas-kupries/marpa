# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for exporters/generators.
# - Common configuration information.
# - Plugin / package search/listing.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::export::config 1
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Configuration data for generators, exporters.
# Meta description Plus support for finding proper plugin packages.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     TclOO
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta subject     marpa {generator config} {generator search} {plugin listing}
# Meta subject     {listing plugin packages} {search generator packages}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require marpa::util

debug define marpa/export/config

# # ## ### ##### ######## #############

namespace eval ::marpa::export {
    namespace export config config! config-reset config? list-plugins
    namespace ensemble create
    namespace import ::marpa::X

    variable data {
	version  {}
	writer   {}
	year     {}
	name     {}
	operator {}
	tool     {}
	gentime  {}
    }
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::export::list-plugins {} {

}

proc ::marpa::export::config-reset {} {
    debug.marpa/export/config {}
    variable data {
	version  {}
	writer   {}
	year     {}
	name     {}
	operator {}
	tool     {}
	gentime  {}
    }
    return
}

proc ::marpa::export::config {} {
    debug.marpa/export/config {}
    variable data
    dict with data {}

    # Use standard timestamp only if the user has not overridden us.
    if {$gentime eq {}} {
	set gentime [clock format [clock seconds]]
    }

    set tag [string map {:: /} $name]

    lappend map @slif-version@    $version
    lappend map @slif-writer@     $writer
    lappend map @slif-year@       $year
    lappend map @slif-name@       $name
    lappend map @slif-name-tag@   $tag
    lappend map @tool-operator@   $operator
    lappend map @tool@            $tool
    lappend map @generation-time@ $gentime

    return $map
}

proc ::marpa::export::config! {key value} {
    debug.marpa/export/config {}
    variable data
    if {![dict exists $data $key]} {
	set e [linsert [join [lsort -dict [dict keys $data]] {, }] end-1 or]
	X "Bad configuration key \"$key\", expected one of $e" \
	    EXPORT CONFIG BAD-KEY
    }
    dict set data $key $value
    return
}

proc ::marpa::export::config? {key} {
    debug.marpa/export/config {}
    variable data
    if {![dict exists $data $key]} {
	set e [linsert [join [lsort -dict [dict keys $data]] {, }] end-1 or]
	X "Bad configuration key \"$key\", expected one of $e" \
	    EXPORT CONFIG BAD-KEY
    }
    return [dict get $data $key]
}

# # ## ### ##### ######## #############
## Helpers

# # ## ### ##### ######## #############
package provide marpa::export::config 1
return
