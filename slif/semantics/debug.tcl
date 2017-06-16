# -*- tcl -*-
##
# (c) 2015-2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                               http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Semantics.
##
# # ## ### ##### ######## #############
## Debugging helper class for the semantics.
## This is only mixed into the class when needed.
## Provides supporting methods, and a filter adding debug narrative.

oo::class create marpa::slif::semantics::Debug {

    method AT {} {
	return [my DEDENT]<[lindex [info level -2] 1]>
    }

    method DEDENT {} {
	my variable __indent
	if {[info exist __indent]} {
	    return $__indent
	} else {
	    return {}
	}
    }

    method INDENT {} {
	my variable __indent
	upvar 1 __predent save
	if {[info exist __indent]} {
	    set save $__indent
	} else {
	    set save {}
	}
	append __indent {  }
	return
    }

    method UNDENT {} {
	my variable __indent
	upvar 1 __predent save
	set __indent $save
	return
    }
}
