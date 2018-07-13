/* Runtime for C-engine (RTC). Parse Event Descriptor API
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
 *
 * Requirements - Note, allocations and tracing via an external environment header.
 *
 * This is effectively part of the C/Tcl glue, see sem_tcl.*
 * May move over.
 */

#include <environment.h>
#include <rtc.h>
#include <rtc_int.h>
#include <tcl.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands for the various pieces of the match state
 */

#define M_START    LEX.cstart
#define M_LENGTH   LEX.clength	// TODO
// #define M_G1START  . not exported
// #define M_G1LENGTH . s.a
// #define M_SYMBOL   . s.a
// #define M_LHS      . s.a
// #define M_RULE     . s.a
#define M_VALUE    LEX.m_lexeme  // see get_lexeme
#define M_CLR1ST   LEX.m_clearfirst
#define M_SV       LEX.m_sv
#define M_SYMBOLS  LEX.m_event == ...discard... ? DISCARDS : FOUND


/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

int
marpatcl_rtc_ped_location (marpatcl_rtc_p p)
{
    return IN.location; // XXX wrap into gate/input functions
}

void
marpatcl_rtc_ped_moveto (marpatcl_rtc_p p, int location)
{
    IN.location = location; // XXX wrap into gate/input functions
}

void
marpatcl_rtc_ped_moveby (marpatcl_rtc_p p, int delta)
{
    IN.location += delta; // XXX wrap into gate/input functions
}

int
marpatcl_rtc_ped_length_get (marpatcl_rtc_p p)
{
}

void
marpatcl_rtc_ped_length_set (marpatcl_rtc_p p, int length)
{
}

int
marpatcl_rtc_ped_start_get (marpatcl_rtc_p p)
{
}

void
marpatcl_rtc_ped_start_set (marpatcl_rtc_p p, int start)
{
}

void
marpatcl_rtc_ped_sv_get (marpatcl_rtc_p p)
{
}

void
marpatcl_rtc_ped_sv_set (marpatcl_rtc_p p, int fake)
{
}

void
marpatcl_rtc_ped_syms_get (marpatcl_rtc_p p)
{
}

void
marpatcl_rtc_ped_syms_set (marpatcl_rtc_p p, int fake)
{
}

void
marpatcl_rtc_ped_value_get (marpatcl_rtc_p p)
{
}

void
marpatcl_rtc_ped_value_set (marpatcl_rtc_p p, int fake)
{
}

void
marpatcl_rtc_ped_alternate (marpatcl_rtc_p p, int fake)
{
}

#define ADD(format, ...) \
    if (TCL_OK != Tcl_ListObjAppendElement(interp, list, Tcl_ObjPrintf(format, __VA_ARGS__))) goto error;

Tcl_Obj*
marpatcl_rtc_ped_view (Tcl_Interp* interp, marpatcl_rtc_p p)
{
    Tcl_Obj* list = Tcl_NewListObj (0,0);

    // keys in (
    //   length --- 
    //   start  --- 
    //   sv     --- 
    //   value  --\
    //   values --/ value
    // )
    // "$key = partof(key)"
    // 

    ADD ("symbols = %", );
    // ADD ("sv = %", );	conditional (undef for discard)
    ADD ("start = %", );
    ADD ("length = %", );
    ADD ("value = %", );
    ADD ("@location = %d", );

    // "@location = [Gate location?]"

    return list;
 error:
    Tcl_DecrRefCount (list);
    return 0;
}


/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
