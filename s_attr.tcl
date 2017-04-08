# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Generic attribute container.
##
# Container instances are configured with a map of legal keys, and
# associated validation types. Derived classes encapsulate specific
# attribute sets.

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller

debug define marpa/slif/attribute
#debug prefix marpa/slif/attribute {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::attribute {
    marpa::E marpa/slif/attribute SLIF ATTRIBUTE

    variable myspec  ;# :: dict (name -> dict (...))
    #                            ?default  -> value?
    #                            ?validate -> cmd?
    variable myattr  ;# :: dict (name -> value)

    constructor {args} {
	debug.marpa/slif/attribute {}
	# args = dict (name -> dict(...))
	set myspec $args

	# Fill the ground state (defaults) from the specification
	set myattr {}
	dict for {a def} $myspec {
	    if {![dict exists $def default]} continue
	    dict set myattr $a [dict get $def default]
	}
	debug.marpa/slif/attribute {/ok}
	return
    }

    # # -- --- ----- -------- -------------
    ## Public API - Manipulate and query attributes

    method set {args} {
	debug.marpa/slif/attribute {}
	foreach {attribute value} $args {
	    my ValidateA $attribute
	    lappend norm $attribute [my ValidateV $attribute $value]
	}
	foreach {attribute value} $norm {
	    dict set myattr $attribute $value
	}
	return
    }

    method get {attribute} {
	debug.marpa/slif/attribute {}
	my ValidateA $attribute
	return [dict get $myattr $attribute]
    }

    # # -- --- ----- -------- -------------
    ## Public API - (de)serialization, assignment, copying

    method serialize {} {
	debug.marpa/slif/attribute {}
	return $myattr
    }

    method deserialize {blob} {
	debug.marpa/slif/attribute {}
	# No simple assignment, have to validate structure (dict),
	# attribute legality, and value validity => We are going
	# through the proper API method for all of that.
	set myattr {}
	my set {*}$blob
	return
    }

    method := {origin} {
	debug.marpa/slif/attribute {}
	my deserialize [$origin serialize]
	return
    }
    export :=

    method --> {destination} {
	debug.marpa/slif/attribute {}
	$destination deserialize [my serialize]
	return
    }
    export -->

    # # -- --- ----- -------- -------------
    ## Internal methods

    method ValidateA {attribute} {
	debug.marpa/slif/attribute {}
	if {[dict exists $myspec $attribute]} return
	my E "Illegal attribute '$attribute'" \
	    ILLEGAL ATTRIBUTE $attribute
    }

    method ValidateV {attribute value} {
	debug.marpa/slif/attribute {}
	set def [dict get $myspec $attribute]
	if {![dict exists $def validate]} {
	    return $value
	}
	set vt [dict get $def validate]
	if {$vt eq {}} {
	    return $value
	}
	return [{*}$vt validate $value]
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
