# -*- tcl -*-
##
# (c) 2017-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                                  http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Support for exporters/generators.
# - Common configuration information.
# - Plugin / package search/listing.

# # ## ### ##### ######## #############
## Administrivia

# @@ Meta Begin
# Package marpa::gen 0
# Meta author      {Andreas Kupries}
# Meta category    {Parser/Lexer Generator}
# Meta description Part of TclMarpa. Configuration data for generators.
# Meta description Plus support for finding and executing the proper
# Meta description plugin generator packages doing the actual formatting.
# Meta location    http:/core.tcl.tk/akupries/marpa
# Meta platform    tcl
# Meta require     {Tcl 8.5}
# Meta require     debug
# Meta require     debug::caller
# Meta require     marpa::util
# Meta subject     marpa {generator configuration} {generator search}
# Meta subject     {plugin listing} {listing plugin packages}
# Meta subject     {search generator packages}
# @@ Meta End

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require debug
package require debug::caller
package require marpa::util ;# marpa::X

debug define marpa/gen

# # ## ### ##### ######## #############

namespace eval ::marpa::gen {
    namespace export formats do
    namespace export config config! config-reset config?
    namespace ensemble create
    namespace import ::marpa::X

    # Configuration information. Initialized at the bottom.
    variable data {}
}

# # ## ### ##### ######## #############
## Public API

proc ::marpa::gen::do {format container} {
    debug.marpa/gen {}
    package require marpa::gen::format::${format}
    return [marpa::gen::format::${format} container $container]
}

proc ::marpa::gen::formats {} {
    debug.marpa/gen {}
    # I.  Force look for general packages
    catch { package require __\001bogus }
    # II. Force look for specific Tcl modules
    catch { package require marpa::gen::format::__\001bogus }
    # Look for marpa::gen::format::*
    return [lmap p [package names] {
	if {![string match marpa::gen::format::* $p]} continue
	namespace tail $p
    }]
}

proc ::marpa::gen::config-reset {} {
    debug.marpa/gen {}
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

proc ::marpa::gen::config {} {
    debug.marpa/gen {}
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

proc ::marpa::gen::config! {key value} {
    debug.marpa/gen {}
    variable data
    if {![dict exists $data $key]} {
	set e [linsert [join [lsort -dict [dict keys $data]] {, }] end-1 or]
	X "Bad configuration key \"$key\", expected one of $e" \
	    EXPORT CONFIG BAD-KEY
    }
    dict set data $key $value
    return
}

proc ::marpa::gen::config? {key} {
    debug.marpa/gen {}
    variable data
    if {![dict exists $data $key]} {
	set e [linsert [join [lsort -dict [dict keys $data]] {, }] end-1 or]
	X "Bad configuration key \"$key\", expected one of $e" \
	    EXPORT CONFIG BAD-KEY
    }
    return [dict get $data $key]
}

# # ## ### ##### ######## #############
## Initialization
::marpa::gen::config-reset

# # ## ### ##### ######## #############
package provide marpa::gen 0
return
