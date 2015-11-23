# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## General supporting declarations and definitions.

# # ## ### ##### ######## #############
## Implied base inherited by all instance structures.
## [__MB]

critcl::ccode {
    typedef struct MarpaTcl_Base {
	Tcl_Command   cmd; /* Automatic instance field, for "destroy" */
	Marpa_Grammar grammar;
    } MarpaTcl_Base;

    /* Aliases for some of the coming result- and argument-types.
     * See "marpa_typeconv.tcl". TODO: Look into re-ordering things
     * across files.
     */
}

# # ## ### ##### ######## #############
## Utility functions to process marpa error results.
## Many marpa API functions return this information in-band, requiring
## this function to separate the regular result from errors.

critcl::ccode {
    static int
    marpatcl_throw (Tcl_Interp*    interp,
		    MarpaTcl_Base* base,
		    int            status)
    {
	// fprintf(stdout,"MTT: %d = \"%s\"\n", status, Tcl_GetString(marpatcl_error_decode (interp, status)));fflush(stdout);

	// if ((status < 0) || (status > MARPA_ERRCODE_COUNT)) Tcl_Panic ("marpa error status out of range");

	/* *** TODO :: Set a detailed Tcl error code */
	Tcl_SetErrorCode (interp, "MARPA", NULL);
	Tcl_SetObjResult (interp, marpatcl_error_decode (interp, status));
	return TCL_ERROR;
    }

    static int
    marpatcl_error (Tcl_Interp*    interp,
		    MarpaTcl_Base* base,
		    int            rv)
    {
	int status = marpa_g_error (base->grammar, NULL);

	// fprintf(stdout,"MTE: %d = \"%s\"\n", status, Tcl_GetString(marpatcl_error_decode (interp, status)));fflush(stdout);

	if (status == MARPA_ERR_NONE) {
	    /* Actually not an error (rank functions) */
	    Tcl_SetObjResult (interp, Tcl_NewIntObj (rv));
	    return TCL_OK;
	}

	return marpatcl_throw (interp, base, status);
    }

    static int
    marpatcl_result (Tcl_Interp*    interp,
		     MarpaTcl_Base* base,
		     int            rv,
		     char*          notfound)
    {
	if (rv < -1) {
	    /* -2 :: General failure */
	    return marpatcl_error (interp, base, rv);
	} else if (notfound && (rv < 0)) {
	    /* -1 :: symbol not found */
	    Tcl_AppendResult (interp, notfound, NULL);
	    return TCL_ERROR;
	} else {
	    Tcl_SetObjResult (interp, Tcl_NewIntObj (rv));
	    return TCL_OK;
	}
    }
}

# # ## ### ##### ######## #############
## Declare event handler callback type, and utility function to
## process accumlated events.

critcl::ccode {
    typedef void (*marpatcl_event_handler) (ClientData       c,
					    Marpa_Grammar    g,
					    Marpa_Event_Type t,
					    int              v);

    static void
    marpatcl_process_events (Marpa_Grammar          g,
			     marpatcl_event_handler f,
			     ClientData             context)
    {
	Marpa_Event_Type t;
	Marpa_Event      event;

	int v, i, n = marpa_g_event_count (g);

	for (i = 0; i < n; i++)
	{
	    // fprintf(stdout,"/E(%d of %d)\n",i,n);fflush(stdout);

	    t = marpa_g_event ( g, &event, i);
	    /* assert (t >= 0): */
	    v = marpa_g_event_value (&event);
	    (*f) (context, g, t, v);
	}
    }
}

# # ## ### ##### ######## #############
return
