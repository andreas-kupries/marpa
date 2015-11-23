# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Map from marpa event types to strings, and back.
## The back-conversion (encoding) is not expected to be used.

critcl::emap::def marpatcl_event {
    e-none             MARPA_EVENT_NONE
    e-counted-nullable MARPA_EVENT_COUNTED_NULLABLE
    e-item-threshold   MARPA_EVENT_EARLEY_ITEM_THRESHOLD
    e-exhausted        MARPA_EVENT_EXHAUSTED
    e-loop-rules       MARPA_EVENT_LOOP_RULES
    e-nulling-terminal MARPA_EVENT_NULLING_TERMINAL
    e-symbol-completed MARPA_EVENT_SYMBOL_COMPLETED
    e-symbol-expected  MARPA_EVENT_SYMBOL_EXPECTED
    e-symbol-nulled    MARPA_EVENT_SYMBOL_NULLED
    e-symbol-predicted MARPA_EVENT_SYMBOL_PREDICTED
}

# API pieces
##
# Encoder:     int     marpatcl_event_encode (interp, Tcl_Obj* state, int* result) :: string -> type
# Decoder:     TclObj* marpatcl_event_decode (interp, int      state)              :: type -> string
# Decl Hdr:    marpatcl_event.h
# Arg-Type:    marpatcl_event
# Result-Type: marpatcl_event

# # ## ### ##### ######## #############
return
