# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############

## This file defines the per-intepreter structures collecting
## information relevant to the whole package, i.e. all classes and
## instances. All classes, and instances will have a reference to this
## structure which is initialized at class and instance construction
## time, via marpa_context ().

# # ## ### ##### ######## #############

critcl::buildrequirement {
    package require critcl::iassoc
}

# # ## ### ##### ######## #############

critcl::iassoc::def marpatcl_context {} {
    Marpa_Config     config;
    Marpa_Grammar    grammar;    /* Communication: Grammar -> Recognizer constructor */
    Marpa_Recognizer recognizer; /* Communication: Recognizer -> Bocage constructor */
} {
    data->grammar    = NULL;
    data->recognizer = NULL;
    (void) marpa_c_init (&data->config);
} {
    /* nothing to do */
}

# # ## ### ##### ######## #############

critcl::cproc marpa::check-version {
    Tcl_Interp* interp
    int         required_major
    int         required_minor
    int         required_micro
} ok {
    Marpa_Error_Code status = marpa_check_version (required_major,
						   required_minor,
						   required_micro);
    if (status != MARPA_ERR_NONE) {
	Tcl_SetErrorCode (interp, "MARPA", NULL);
	Tcl_SetObjResult (interp, marpatcl_error_decode (interp, status));
	return TCL_ERROR;
    }
    return TCL_OK;
}

# # ## ### ##### ######## #############

critcl::cproc marpa::version {
    Tcl_Interp* interp
} ok {
    int version[3]; /* major, minor, micro (patch) */
    Tcl_Obj*  v[3];
    int status = marpa_version (version);

    if (status < 0) {
	Tcl_SetErrorCode (interp, "MARPA", NULL);
	Tcl_SetObjResult (interp, Tcl_NewStringObj ("Unable to retrieve libmarpa version",-1));
	return TCL_ERROR;
    }

    v[0] = Tcl_NewIntObj (version[0]);
    v[1] = Tcl_NewIntObj (version[1]);
    v[2] = Tcl_NewIntObj (version[2]);
    Tcl_SetObjResult (interp, Tcl_NewListObj (3, v));
    return TCL_OK;
}

# # ## ### ##### ######## #############
return
