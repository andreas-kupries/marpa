# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## String pool for valuation steps

critcl::literals::def marpatcl_step {
    mt_s_rule     "rule"
    mt_s_token    "token"
    mt_s_nulling  "null"
    mt_s_0        "first"
    mt_s_n        "last"
    mt_s_id       "id"
    mt_s_res      "dst"
    mt_s_value    "value"
    mt_s_end_es   "end-es"
    mt_s_start_es "start-es"
}

# API pieces
##
# Mapper:      TclObj* marpatcl_step (interp, int) :: code -> string
# Decl Hdr:    marpatcl_step.h

# Helper macros for quick access to the pool contents. Implied interp argument.
critcl::ccode {
    #define MT_S_RULE     (marpatcl_step (interp, mt_s_rule))
    #define MT_S_TOKEN    (marpatcl_step (interp, mt_s_token))
    #define MT_S_NULLING  (marpatcl_step (interp, mt_s_nulling))
    #define MT_S_0        (marpatcl_step (interp, mt_s_0))
    #define MT_S_N        (marpatcl_step (interp, mt_s_n))
    #define MT_S_ID       (marpatcl_step (interp, mt_s_id))
    #define MT_S_RES      (marpatcl_step (interp, mt_s_res))
    #define MT_S_VALUE    (marpatcl_step (interp, mt_s_value))
    #define MT_S_START_ES (marpatcl_step (interp, mt_s_start_es))
    #define MT_S_END_ES   (marpatcl_step (interp, mt_s_end_es))
}

# # ## ### ##### ######## #############
## Map from marpa step-types to strings, and back.
## The back-conversion (encoding) is not expected to be used.
## This mapping is for debugging only.

critcl::emap::def marpatcl_steptype {
    step-rule      MARPA_STEP_RULE           
    step-token     MARPA_STEP_TOKEN          
    step-nulling   MARPA_STEP_NULLING_SYMBOL 
    step-inactive  MARPA_STEP_INACTIVE       
    step-initial   MARPA_STEP_INITIAL        
    step-internal1 MARPA_STEP_INTERNAL1      
    step-internal2 MARPA_STEP_INTERNAL2      
    step-trace     MARPA_STEP_TRACE          
}

# API pieces
##
# Encoder:     int     marpatcl_steptype_encode (interp, Tcl_Obj* state, int* result) :: string -> type
# Decoder:     TclObj* marpatcl_steptype_decode (interp, int      state)              :: type -> string
# Decl Hdr:    marpatcl_steptype.h
# Arg-Type:    marpatcl_steptype
# Result-Type: marpatcl_steptype


# # ## ### ##### ######## #############
return
