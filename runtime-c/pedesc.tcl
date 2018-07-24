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
    support {
	#include <lexer.h>
	#include <inbound.h>
	#include <symset.h>
	#include <sem_tcl.h>
    }
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
	return marpatcl_rtc_inbound_location (instance->state);
    }

    method moveto proc {int pos int args} void {
	int k;
	for (k = 0; k < args.c; k++) { pos += args.v [k]; }
	marpatcl_rtc_inbound_moveto (instance->state, pos);
    }

    method moveby proc {int delta} void {
	marpatcl_rtc_inbound_moveby (instance->state, delta);
    }

    method rewind proc {int delta} void {
	marpatcl_rtc_inbound_moveby (instance->state, -delta);
    }

    method symbols proc {Tcl_Interp* interp} object0 {
	return marpatcl_rtc_pe_get_symbols (interp, instance->state);
    }

    method sv proc {Tcl_Interp* interp} object0 {
	return marpatcl_rtc_pe_get_semvalues (interp, instance->state);
    }

    method start proc {} int {
	return marpatcl_rtc_lexer_pe_get_lexeme_start (instance->state);
    }

    method length proc {} int {
	return marpatcl_rtc_lexer_pe_get_lexeme_length (instance->state);
    }

    method value proc {} string {
	// TODO: grammar parse events - AST ?!
	return (char*) marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state);
    }

    method values proc {} string {
	// TODO: grammar parse events - AST ?!
	return (char*) marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state);
    }

    method symbols: proc {Tcl_Interp* ip list syms} ok {
	return marpatcl_rtc_pe_set_symbols (ip, instance->state, syms.c, syms.v);
    }

    method sv: proc {list svs} void {
	marpatcl_rtc_pe_set_semvalues (instance->state, svs.c, svs.v);
    }

    method start: proc {int start} void {
	marpatcl_rtc_lexer_pe_set_lexeme_start (instance->state, start);
    }

    method length: proc {int length} void {
	marpatcl_rtc_lexer_pe_set_lexeme_length (instance->state, length);
    }

    method value: proc {pstring value} void {
	marpatcl_rtc_lexer_pe_set_lexeme_value (instance->state, value.s);
    }

    method values: proc {pstring value} void {
	marpatcl_rtc_lexer_pe_set_lexeme_value (instance->state, value.s);
    }

    method view proc {Tcl_Interp* interp} object0 {
#define TLOAE Tcl_ListObjAppendElement
#define TOP   Tcl_ObjPrintf
#define ADD(format, ...) if (TCL_OK != TLOAE (interp, list, TOP (format, __VA_ARGS__))) goto error;

	Tcl_Obj* list = Tcl_NewListObj (0, 0);

	ADD ("length = ((%d))",    marpatcl_rtc_lexer_pe_get_lexeme_length (instance->state));
	ADD ("start = ((%d))",     marpatcl_rtc_lexer_pe_get_lexeme_start (instance->state));

	Tcl_Obj* sv = marpatcl_rtc_pe_get_semvalues (interp, instance->state);
	if (sv) {
	    ADD ("sv = ((%s))", Tcl_GetString (sv));
	    Tcl_DecrRefCount (sv);
	}

	Tcl_Obj* names = marpatcl_rtc_pe_get_symbols (interp, instance->state);
	ADD ("symbols = ((%s))", Tcl_GetString (names));
	Tcl_DecrRefCount (names);

	ADD ("value = ((%s))", marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state));
	ADD ("@location = %d", marpatcl_rtc_inbound_location (instance->state));

	return list;
    error:
	Tcl_DecrRefCount (list);
	return 0;
    }

    method alternate proc {Tcl_Interp* ip pstring symbol pstring sv} ok {
	return marpatcl_rtc_pe_alternate (ip, instance->state, symbol.s, sv.s);
    }
}

# # ## ### ##### ######## #############
return
