# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Generic access to parse structures from parse event handlers.
## Effectively a facade simulating the presence of a parse event
## descriptor.

## Tripwires:

## Objects of this class are constructed at the C-level, by the
## generated parsers and lexers, see packages
## `marpa::gen::format::c*-critcl`. As part of that construction they
## are given a pointer to the main RTC structure, and the containing
## object has a method delegating to the instance.

critcl::class def marpa::runtime::c::pedesc {
    # This class has no API visible at script level. It has a C api instead, for use
    # by RTC-based parsers/lexers.
    tcl-api off
    c-api   on marpatcl_rtc_pedesc

    classvariable marpatcl_rtc_p rtc {
	The RTC structure to use when constructing an instance.
	This is provided by the parser/lexer creating the object.
	See constructor for usage.
    }

    insvariable marpatcl_rtc_p state {
	C-level engine, RTC structures.
	Provided by the containing parser/lexer.
    } { /* See constructor for setup */ } {}

    constructor {
	/*
	** Setting up our state from the rtc reference handed to us
	** via the class structure.
	*/
	ASSERT (class->rtc, "No rtc parser structure found for use");
	instance->state = class->rtc;
	class->rtc = NULL;
    } {}

    method location? proc {} int {
	return marpatcl_rtc_ped_location (instance->state);
    }

    method moveto proc {int pos int args} void {
	int k;
	marpatcl_rtc_ped_moveto (instance->state, pos);
	for (k = 0; k < args.c; k++) {
	    marpatcl_rtc_ped_moveby (instance->state, args.v[k]);
	}
    }

    method moveby proc {int delta} void {
	marpatcl_rtc_ped_moveby (instance->state, delta);
    }

    method rewind proc {int delta} void {
	marpatcl_rtc_ped_moveby (instance->state, -delta);
    }

    method symbols proc {} void { /* XXX TODO FILL XXX */ }
    method sv proc {} void { /* XXX TODO FILL XXX */ }

    method start proc {} int {
	return marpatcl_rtc_ped_start_get (instance->state);
    }

    method length proc {} int {
	return marpatcl_rtc_ped_length_get (instance->state);
    }

    method value proc {} void { /* XXX TODO FILL XXX */ }
    method values proc {} void { /* XXX TODO FILL XXX */ }

    method symbols: proc {} void { /* XXX TODO FILL XXX */ }
    method sv: proc {} void { /* XXX TODO FILL XXX */ }

    method start: proc {int start} void {
	marpatcl_rtc_ped_start_set (instance->state, start);
    }

    method length: proc {int length} void {
	marpatcl_rtc_ped_length_set (instance->state, length);
    }

    method value: proc {} void { /* XXX TODO FILL XXX */ }
    method values: proc {} void { /* XXX TODO FILL XXX */ }

    method view proc {} object0 {
	return marpatcl_rtc_ped_view (instance->state);
    }

    method alternate proc {object symbol object sv} void { /* XXX TODO FILL XXX */ }
}

# # ## ### ##### ######## #############
return
