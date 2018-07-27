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

critcl::argtype posint = {int > 0}
critcl::argtype posint0 = {int >= 0}

# Technically an {int >= 0}. However needed a changed error message.
critcl::argtype location {
    if (Tcl_GetIntFromObj(interp, @@, &@A) != TCL_OK) return TCL_ERROR;
    if (@A < 0) {
	Tcl_AppendResult (interp, "expected location (>= 0), but got \"",
			  Tcl_GetString (@@), "\"", NULL);
	return TCL_ERROR;
    }
    /* Cannot check for max location without pre-scanning to have a full clindex.
    */
} int int

critcl::class def marpa::runtime::c::pedesc {
    support {
	#include <lexer.h>
	#include <inbound.h>
	#include <symset.h>
	#include <sem_tcl.h>

#define M_PERMIT  if (!marpatcl_rtc_pe_access (ip, instance->state)) return 0
#define M_BA_EV   if (!marpatcl_rtc_pe_ba_event (ip, instance->state)) return 0
#define M_DBA_EV  if (!marpatcl_rtc_pe_dba_event (ip, instance->state)) return 0
#define M_SDBA_EV if (!marpatcl_rtc_pe_sdba_event (ip, instance->state)) return 0
#define NIL      return instance->class->nil
#define INT(x)   Tcl_NewIntObj (x)
#define STR(x)   Tcl_NewStringObj (x, -1)
#define CHK(x)   if (!x) return 0; NIL
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

    classvariable Tcl_Obj* nil {
	Standard result for empty string/list, i.e nothing
    } {
	class->nil = Tcl_NewListObj (0, 0);
	Tcl_IncrRefCount (class->nil);
    } {
	Tcl_DecrRefCount (class->nil);
	class->nil = 0;
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

    method location proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	return INT (marpatcl_rtc_inbound_location (instance->state));
    }

    method stop proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	int pos = marpatcl_rtc_inbound_stoploc (instance->state);
	if (pos < 0) NIL;
	return INT (pos);
    }

    method from proc {Tcl_Interp* ip location pos int args} object0 {
	M_PERMIT;
	M_SDBA_EV;

	int k;
	for (k = 0; k < args.c; k++) { pos += args.v [k]; }
	marpatcl_rtc_inbound_moveto (instance->state, pos);
	NIL;
    }

    method relative proc {Tcl_Interp* ip int delta} object0 {
	M_PERMIT;
	M_SDBA_EV;
	marpatcl_rtc_inbound_moveby (instance->state, delta);
	NIL;
    }

    method rewind proc {Tcl_Interp* ip int delta} object0 {
	M_PERMIT;
	M_SDBA_EV;
	marpatcl_rtc_inbound_moveby (instance->state, -delta);
	NIL;
    }

    method to proc {Tcl_Interp* ip location pos} object0 {
	M_PERMIT;
	M_SDBA_EV;
	marpatcl_rtc_inbound_set_stop (instance->state, pos);
	NIL;
    }

    method limit proc {Tcl_Interp* ip posint limit} object0 {
	M_PERMIT;
	M_SDBA_EV;
	marpatcl_rtc_inbound_set_limit (instance->state, limit);
	NIL;
    }

    method dont-stop proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_SDBA_EV;
	marpatcl_rtc_inbound_no_stop (instance->state);
	NIL;
    }

    method symbols proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_SDBA_EV;
	return marpatcl_rtc_pe_get_symbols (ip, instance->state);
    }

    method sv proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_SDBA_EV;
	return marpatcl_rtc_pe_get_semvalues (ip, instance->state);
    }

    method start proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_DBA_EV;
	return INT (marpatcl_rtc_lexer_pe_get_lexeme_start (instance->state));
    }

    method length proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_DBA_EV;
	return INT (marpatcl_rtc_lexer_pe_get_lexeme_length (instance->state));
    }

    method value proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_DBA_EV;
	return STR (marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state));
    }

    method values proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_DBA_EV;
	return STR (marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state));
    }

    method symbols: proc {Tcl_Interp* ip list syms} object0 {
	M_PERMIT;
	M_BA_EV;
	CHK (marpatcl_rtc_pe_set_symbols (ip, instance->state, syms.c, syms.v));
    }

    method sv: proc {Tcl_Interp* ip list svs} object0 {
	M_PERMIT;
	M_BA_EV;
	marpatcl_rtc_pe_set_semvalues (instance->state, svs.c, svs.v);
	NIL;
    }

    method start: proc {Tcl_Interp* ip location start} object0 {
	M_PERMIT;
	M_BA_EV;
	marpatcl_rtc_lexer_pe_set_lexeme_start (instance->state, start);
	NIL;
    }

    method length: proc {Tcl_Interp* ip posint0 length} object0 {
	M_PERMIT;
	M_BA_EV;
	marpatcl_rtc_lexer_pe_set_lexeme_length (instance->state, length);
	NIL;
    }

    method value: proc {Tcl_Interp* ip pstring value} object0 {
	M_PERMIT;
	M_BA_EV;
	marpatcl_rtc_lexer_pe_set_lexeme_value (instance->state, value.s);
	NIL;
    }

    method values: proc {Tcl_Interp* ip pstring value} object0 {
	M_PERMIT;
	M_BA_EV;
	marpatcl_rtc_lexer_pe_set_lexeme_value (instance->state, value.s);
	NIL;
    }

    method alternate proc {Tcl_Interp* ip pstring symbol pstring sv} object0 {
	M_PERMIT;
	M_BA_EV;

	CHK (marpatcl_rtc_pe_alternate (ip, instance->state, symbol.s, sv.s));
    }

    method view proc {Tcl_Interp* ip} object0 {
	M_PERMIT;
	M_SDBA_EV;

#define TLOAE Tcl_ListObjAppendElement
#define TOP   Tcl_ObjPrintf
#define ADD(format, ...) if (TCL_OK != TLOAE (ip, list, TOP (format, __VA_ARGS__))) goto error;

	Tcl_Obj* list = Tcl_NewListObj (0, 0);

	ADD ("length = ((%d))",    marpatcl_rtc_lexer_pe_get_lexeme_length (instance->state));
	ADD ("start = ((%d))",     marpatcl_rtc_lexer_pe_get_lexeme_start (instance->state));

	Tcl_Obj* sv = marpatcl_rtc_pe_get_semvalues (ip, instance->state);
	if (sv) {
	    ADD ("sv = ((%s))", Tcl_GetString (sv));
	    Tcl_DecrRefCount (sv);
	}

	Tcl_Obj* names = marpatcl_rtc_pe_get_symbols (ip, instance->state);
	ADD ("symbols = ((%s))", Tcl_GetString (names));
	Tcl_DecrRefCount (names);

	ADD ("value = ((%s))", marpatcl_rtc_lexer_pe_get_lexeme_value (instance->state));
	ADD ("@location = %d", marpatcl_rtc_inbound_location (instance->state));

	return list;
    error:
	Tcl_DecrRefCount (list);
	return 0;
    }
}

# # ## ### ##### ######## #############
return
