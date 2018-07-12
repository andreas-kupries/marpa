/* Runtime for C-engine (RTC). Parse Event Descriptor API
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
 *
 * Requirements - Note, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <rtc.h>
#include <rtc_int.h>

TRACE_OFF;

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

void
marpatcl_rtc_ped_view (marpatcl_rtc_p p, int fake)
{
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
