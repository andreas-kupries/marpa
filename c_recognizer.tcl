# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Configuration --- Grammar --- [Recognizer] --- Bocage --- Ordering --- Tree --- Value

critcl::class def ::marpa::Recognizer {
    # # ## ### ##### ######## #############
    ## Back reference to grammar. First element across all instance
    ## structures to allow for easy casting (return value conversion
    ## and event processing -- type MarpaTcl_Base  [__MB]).

    insvariable Marpa_Grammar grammar {
	Back reference to the grammar owning the recognizer.
    } {
	instance->grammar = marpatcl_context(interp)->grammar;
	if (!instance->grammar) {
	    Tcl_SetErrorCode (interp, "MARPA", NULL);
	    Tcl_AppendResult (interp, "Unable to construct recognizer without grammar", NULL);
	    goto error;
	}
	marpa_g_ref (instance->grammar);
    } {
	marpa_g_unref (instance->grammar);
    }

    # # ## ### ##### ######## #############

    insvariable Marpa_Recognizer recognizer {
	opaque handle of the libmarpa structure holding the recognizer for us.
    } {
	instance->recognizer = marpa_r_new (instance->grammar);
    } {
	marpa_r_unref (instance->recognizer);
    }

    # # ## ### ##### ######## #############

    insvariable Tcl_Obj* handler {
	Command prefix to call for recognizer-level events.
    } {
	/* The full initialization happens in the main constructor
	// code, when we have access to the arguments.
	*/
	instance->handler = NULL;
    } {
	Tcl_DecrRefCount (instance->handler);
    }

    insvariable Tcl_Interp* interp {
	Interp reference for the handler.
    } {
	instance->interp = interp;
    }

    insvariable Tcl_Obj* self {
	Reference to the fully qualified name of the instance command.
	Remembered internally for use in event callbacks.
    } {
	instance->self = NULL;
    }

    # # ## ### ##### ######## #############

    constructor {
        /*                                      [0]
	 * Syntax:                          ... handler
         * skip == 2: <class> new           ...
         *      == 3: <class> create <name> ...
         */

	if (objc != 1) {
	    Tcl_WrongNumArgs (interp, objcskip, objv-objcskip,
			      "handler");

	    marpa_r_unref (instance->recognizer);
	    goto error;
	}

	instance->handler = objv[0];
	Tcl_IncrRefCount (instance->handler);

	// fprintf(stdout,"XXX/1 %p %d\n",instance->handler,instance->handler->refCount);fflush(stdout);
    } {
	instance->self = fqn;
	Tcl_IncrRefCount (fqn);
    }

    # # ## ### ##### ######## #############
    ## Methods managing the libmarpa handle from the Tcl level, and
    ## other specialities.

    # # ## ### ##### ######## #############
    ## Create bocage from the recognizer

    method forest command {} {
	int res;
	marpatcl_context_data ctx = marpatcl_context (interp);

	/* Make grammar and recognizer available to the bocage constructor */
	ctx->grammar    = instance->grammar;
	ctx->recognizer = instance->recognizer;

	res = BOCAGE (clientdata, interp, objc-1, objv+1);

	/* Clean up */
	ctx->grammar    = NULL;
	ctx->recognizer = NULL;

	return res;
    }

    # # ## ### ##### ######## #############
    ## Recognizer setup and modification.

    method start-input proc {} Marpa_Int {
	int res = marpa_r_start_input (instance->recognizer);
	marpatcl_process_events (instance->grammar, marpatcl_recognizer_event_to_tcl, instance);
	return res;
    }

    method alternative proc {Marpa_Symbol_ID sym int value int length} Marpa_Int {
	return marpa_r_alternative ( instance->recognizer, sym, value, length);
    }

    method earleme-complete proc {} Marpa_Int {
	int res = marpa_r_earleme_complete ( instance->recognizer);
	marpatcl_process_events (instance->grammar, marpatcl_recognizer_event_to_tcl, instance);
	return res;
    }

    # # ## ### ##### ######## #############
    ## 

    method current-earleme   proc {}                        Marpa_Earleme       { return marpa_r_current_earleme   ( instance->recognizer); }
    method earleme           proc {Marpa_Earley_Set_ID set} Marpa_Earleme       { return marpa_r_earleme           ( instance->recognizer, set); }
    method latest-earley-set proc {}                        Marpa_Earley_Set_ID { return marpa_r_latest_earley_set ( instance->recognizer); }
    method furthest-earleme  proc {}                        int                 { return marpa_r_furthest_earleme  ( instance->recognizer); }

    method sym-completion: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_r_completion_symbol_activate (instance->recognizer, sym, enable); }
    method sym-nulled:     proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_r_nulled_symbol_activate     (instance->recognizer, sym, enable); }
    method sym-prediction: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_r_prediction_symbol_activate (instance->recognizer, sym, enable); }

    method warning-threshold  proc {}              int { return marpa_r_earley_item_warning_threshold     (instance->recognizer); }
    method warning-threshold: proc {int threshold} int { return marpa_r_earley_item_warning_threshold_set (instance->recognizer, threshold); }

    # integer and pointer client data, per earley-set
    # - Example: string pointer + length into the input.
    # - Currently not exposed, to raw for Tcl level.
    ##
    # int                 marpa_r_earley_set_value                  ( Marpa_Recognizer r, Marpa_Earley_Set_ID earley_set)
    # int                 marpa_r_earley_set_values                 ( Marpa_Recognizer r, Marpa_Earley_Set_ID earley_set, int* p_value, void** p_pvalue )
    # int                 marpa_r_latest_earley_set_value_set       ( Marpa_Recognizer r, int value)
    # int                 marpa_r_latest_earley_set_values_set      ( Marpa_Recognizer r, int value, void* pvalue)

    method exhausted? proc {} Marpa_Symbol_Boolean { return marpa_r_is_exhausted (instance->recognizer); }

    method expected-terminal-event: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_r_expected_symbol_event_set (instance->recognizer, sym, enable); }
    method terminal-is-expected?    proc {Marpa_Symbol_ID sym}                 Marpa_Symbol_Boolean { return marpa_r_terminal_is_expected      (instance->recognizer, sym); }

    method expected-terminals proc {} ok {
	/* TODO -- Note: In a parser for a fixed grammar this information is constant, and the buffer would be the same.
	//      --> allocate only once, make it an instance variable. Or even a fixed C level variable.
	//      --> Note further, symbols would be fixed, could be mapped via string pool to shared Tcl_Obj* too.
	//      --> grammar instance data - dynamic pool - built on freeze - critcl::pool - extend to c-level interface for dyn pools.
	*/

	int              max = marpa_g_highest_symbol_id (instance->grammar);
	Marpa_Symbol_ID* buf = (Marpa_Symbol_ID*) ckalloc (max * sizeof(Marpa_Symbol_ID));
	int              n   = marpa_r_terminals_expected (instance->recognizer, buf);
	Tcl_Obj**        obuf;
	Tcl_Obj*         res;
	int              i;

	if (n < 0) {
	    return marpatcl_result (interp, (MarpaTcl_Base*) instance, n, NULL);
	}

	/* Consider sorting the ids. Should make access to specific
	** ranges easier (chars, classes)
	*/

	obuf = (Tcl_Obj**) ckalloc (n * sizeof(Tcl_Obj*));
	for (i=0; i < n; i++) { obuf [i] = Tcl_NewIntObj (buf[i]); }

	res = Tcl_NewListObj (n, obuf);
	ckfree ((char*)obuf);
	ckfree ((char*)buf);

	Tcl_SetObjResult (interp, res);
	return TCL_OK;
    }

    method report-start  proc {Marpa_Earley_Set_ID set} Marpa_Int { return marpa_r_progress_report_start  (instance->recognizer, set); }
    method report-reset  proc {}                        Marpa_Int { return marpa_r_progress_report_reset  (instance->recognizer); }
    method report-finish proc {}                        Marpa_Int { return marpa_r_progress_report_finish (instance->recognizer); }
    method report-next   proc {} ok {
	int                 dot;
	Marpa_Earley_Set_ID origin;
	Marpa_Rule_ID       rule = marpa_r_progress_item ( instance->recognizer, &dot, &origin );
	Tcl_Obj*            tuple [3];

	if (rule < 0) {
	    return marpatcl_result (interp, (MarpaTcl_Base*) instance, rule, NULL);
	}

	tuple [0] = Tcl_NewIntObj (rule);
	tuple [1] = Tcl_NewIntObj (dot);
	tuple [2] = Tcl_NewIntObj (origin);
	Tcl_SetObjResult (interp, Tcl_NewListObj (3, tuple));
	return TCL_OK;
    }

    # # ## ### ##### ######## #############
    # Marpa_Earleme       marpa_r_clean ( Marpa_Recognizer r)

    # # ## ### ##### ######## #############
    support {
       /* Stem:  @stem@
	* Pkg:   @package@
	* Class: @class@
	* IType: @instancetype@
	* CType: @classtype@
	*/

#define RECCE @stem@_ClassCommand

	static void
	marpatcl_recognizer_event_to_tcl (ClientData context, Marpa_Grammar g, Marpa_Event_Type t, int v)
	{
	    /* context = Recognizer instance. */
	    @instancetype@ instance = context;
	    /**/
	    Tcl_Interp* interp = instance->interp;
	    int res = TCL_OK;

	    // fprintf(stdout,"XXX/2 %p %d\n",instance->handler,instance->handler->refCount);fflush(stdout);

	    Tcl_Obj* cmd = Tcl_DuplicateObj (instance->handler);


	    Tcl_ListObjAppendElement (interp, cmd, instance->self);
	    Tcl_ListObjAppendElement (interp, cmd, marpatcl_event_decode (interp, t));
	    Tcl_ListObjAppendElement (interp, cmd, Tcl_NewIntObj(v));

	    Tcl_IncrRefCount (cmd);
	    res = Tcl_GlobalEvalObj (interp, cmd);
	    Tcl_DecrRefCount (cmd);

	    // fprintf(stdout,"XXX/3 %p %d\n",instance->handler,instance->handler->refCount);fflush(stdout);

	    if (res != TCL_OK) {
		Tcl_BackgroundError (interp);
	    }
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
