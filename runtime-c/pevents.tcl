# -*- tcl -*-
##
# (c) 2018-present Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Map from RTC parse event types to Tcl strings.
#
# Attention:
# - `::marpa::gen::runtime::c::Events2Table` in `gen-common/runtime-c.tcl` has to match.
# - See also enum `marpatcl_rtc_eventtype` in `marpa_runtime_c.h`
##

critcl::emap::def marpatcl_rtc_eventtype {
    "stop"	marpatcl_rtc_event_stop
    "ovrerun"	marpatcl_rtc_event_over

    "before"    marpatcl_rtc_event_before
    "after"	marpatcl_rtc_event_after
    "discard"	marpatcl_rtc_event_discard

    "predicted"	marpatcl_rtc_event_predicted
    "completed"	marpatcl_rtc_event_completed
    "nulled"	marpatcl_rtc_event_nulled
} -mode {+list c}

# API pieces
##
# Tcl_Obj* marpatcl_rtc_eventtype_decode       (interp, literal)
# char*    marpatcl_rtc_eventtype_decode_cstr  (interp, literal)
# Tcl_Obj* marpatcl_rtc_eventtype_decode_list  (interp, n, literal[])
# int      marpatcl_rtc_eventtype_encode       (interp, obj, &result)
#
# Decl Hdr:    marpatcl_rtc_eventtype.h
# Enum:        marpatcl_rtc_eventtype_names
#
# Arg-Type:    marpatcl_rtc_eventtype
# Result-Type: marpatcl_rtc_eventtype

# # ## ### ##### ######## #############
return
