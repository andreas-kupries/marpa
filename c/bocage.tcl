# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Configuration --- Grammar --- Recognizer --- [Bocage] (Ordering + Tree + Value)

critcl::class def ::marpa::Bocage {
    # # ## ### ##### ######## #############
    ## Back reference to the grammar. First element across all instance
    ## structures to allow for easy casting (return value conversion
    ## and event processing -- type MarpaTcl_Base  [__MB]).

    insvariable Marpa_Grammar grammar {
	Back reference to the grammar owning (the recognizer owning) the bocage.
    } {
	instance->grammar = marpatcl_context(interp)->grammar;
	if (!instance->grammar) {
	    Tcl_SetErrorCode (interp, "MARPA", NULL);
	    Tcl_AppendResult (interp, "Unable to construct bocage without grammar", NULL);
	    goto error;
	}
	marpa_g_ref (instance->grammar);
    } {
	marpa_g_unref (instance->grammar);
    }

    insvariable Marpa_Recognizer recognizer {
	Back reference to the recognizer owning the bocage.
    } {
	instance->recognizer = marpatcl_context(interp)->recognizer;
	if (!instance->recognizer) {
	    Tcl_SetErrorCode (interp, "MARPA", NULL);
	    Tcl_AppendResult (interp, "Unable to construct bocage without recognizer", NULL);
	    goto error;
	}
	marpa_r_ref (instance->recognizer);
    } {
	marpa_r_unref (instance->recognizer);
    }

    # # ## ### ##### ######## #############

    insvariable Marpa_Bocage bocage {
	opaque handle of the libmarpa structure holding the bocage for us.
    } {
	/* Actual initialization in main constructor, when we have additional arguments */
	instance->bocage = NULL;
    } {
	marpa_b_unref (instance->bocage);
    }

    insvariable Marpa_Order order {
	opaque handle of the libmarpa structure holding the bocage's ordering for us.
    } {
	/* Actual initialization on demand */
	instance->order = NULL;
    } {
	if (instance->order) marpa_o_unref (instance->order);
    }

    insvariable Marpa_Tree tree {
	opaque handle of the libmarpa structure holding the bocage's tree iterator for us
    } {
	/* Actual initialization on demand */
	instance->tree = NULL;
    } {
	if (instance->tree) marpa_t_unref (instance->tree);
    }

    # # ## ### ##### ######## #############

    constructor {
        /*                                      [0]
	 * Syntax:                          ... earley-set-id
         * skip == 2: <class> new           ...
         *      == 3: <class> create <name> ...
         */

	int esid;

	if (objc != 1) {
	    Tcl_WrongNumArgs (interp, objcskip, objv-objcskip,
			      "earley-set-id");

	    goto error;
	}

	if (Tcl_GetIntFromObj(interp, objv[0], &esid) != TCL_OK) {
	    goto error;
	}

	instance->bocage = marpa_b_new (instance->recognizer, esid);
	if (!instance->bocage) {
	    marpatcl_error (interp, (MarpaTcl_Base*) instance, 0);
	    goto error;
	}
    }

    # # ## ### ##### ######## #############
    ## Methods managing the libmarpa handle from the Tcl level, and
    ## other specialities.

    # # ## ### ##### ######## #############
    ## Create bocage from the recognizer

    # # ## ### ##### ######## #############
    ## Bocage setup and modification.

    method ambiguity proc {} Marpa_Int     { return marpa_b_ambiguity_metric (instance->bocage); }
    method null?     proc {} Marpa_Boolean { return marpa_b_is_null          (instance->bocage); }

    # # ## ### ##### ######## #############
    ## Ordering is generated on demand (settings changed, tree iteration)

    method high-rank-only-set proc {boolean enable} Marpa_Boolean {
	return marpa_o_high_rank_only_set (@stem@_order (instance), enable);
    }

    method high-rank-only proc {} Marpa_Boolean {
	return marpa_o_high_rank_only (@stem@_order (instance));
    }

    # # ## ### ##### ######## #############
    # Iterate trees and values from the bocage.

    method get-parse proc {} ok {
	Marpa_Tree      t      = @stem@_tree (instance);
	int             status = marpa_t_next (t);
	Marpa_Value     v;
	Tcl_Obj*        steps;
	Tcl_Obj*        step;
	int             stop;
#ifdef CRITCL_TRACER
	int k = -1;
#endif
	TRACE_TAG_FUNC (parse, "self.Marpa_Tree %p = status %d", t, status);
	
	if (status == -1) {
	    /* Done with tree iterator */
	    marpa_t_unref (t);
	    instance->tree = NULL;
	    status = marpatcl_throw (interp, (MarpaTcl_Base*) instance,
				     MARPA_ERR_TREE_EXHAUSTED);
	    TRACE_TAG_RETURN (parse, "%d", status);
	} else if (status < -1) {
	    /* Some failure */
	    status = marpatcl_error (interp, (MarpaTcl_Base*) instance, 0);
	    TRACE_TAG_RETURN (parse, "%d", status);
	}

	v = marpa_v_new (t);
	TRACE_TAG (parse, "Marpa_Value %p", v);
	
	steps = Tcl_NewListObj (0,0);
	stop  = 0;
	while (!stop) {
	    Marpa_Step_Type stype = marpa_v_step (v);
#ifdef CRITCL_TRACER
	    const char* sts = marpatcl_steptype_decode_cstr (stype);
	    k++;
#endif
	    TRACE_TAG_HEADER (parse, 1);
	    TRACE_TAG_ADD (parse, "Marpa_Value %p step[%4d] %d %s",
			   v, k, stype, sts ? sts : "<<null>>");

	    switch (stype) {
	    case MARPA_STEP_INITIAL:
		/* Nothing to do */
		break;
	    case MARPA_STEP_INACTIVE:
		/* Done */
		stop = 1;
		break;
	    case MARPA_STEP_RULE:
		/* The semantics of a rule should be performed.
		** The application can find the value of the rule's children in the stack locations
		** from marpa_v_arg_0(v)
		** to   marpa_v_arg_n(v).
		** The semantics for the rule whose ID
		** is   marpa_v_rule(v)
		** should be executed on these child values, and the result placed
		** in   marpa_v_result(v).
		** In the case of a MARPA_STEP_RULE step, the stack location of marpa_v_result(v)
		** is guaranteed to be equal to marpa_v_arg_0(v).
		*/

		TRACE_TAG_ADD (parse, "    -- rule  %3d, span (%d-%d), %d := (%d-%d)",
			       marpa_v_rule(v),
			       marpa_v_rule_start_es_id(v),
			       marpa_v_es_id(v),
			       marpa_v_result(v),
			       marpa_v_arg_0(v),
			       marpa_v_arg_n(v));

		step = Tcl_NewDictObj ();
		Tcl_DictObjPut (interp, step, MT_S_ID,       Tcl_NewIntObj (marpa_v_rule(v)));
		Tcl_DictObjPut (interp, step, MT_S_START_ES, Tcl_NewIntObj (marpa_v_rule_start_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_END_ES,   Tcl_NewIntObj (marpa_v_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_RES,      Tcl_NewIntObj (marpa_v_result(v)));
		Tcl_DictObjPut (interp, step, MT_S_0,        Tcl_NewIntObj (marpa_v_arg_0(v)));
		Tcl_DictObjPut (interp, step, MT_S_N,        Tcl_NewIntObj (marpa_v_arg_n(v)));

		Tcl_ListObjAppendElement (interp, steps, MT_S_RULE);
		Tcl_ListObjAppendElement (interp, steps, step);

		break;
	    case MARPA_STEP_TOKEN:
		/* The semantics of a non-null token should be performed.
		** The application's value for the token whose ID
		** is       marpa_v_token(v)
		** should be placed in stack
		** location marpa_v_result(v).
		** Its value according to Libmarpa will be
		** in       marpa_v_token_value(v).
		*/

		TRACE_TAG_ADD (parse, "   -- token %3d, span (%d-%d), %d := <%d>",
			       marpa_v_token(v),
			       marpa_v_token_start_es_id(v),
			       marpa_v_es_id(v),
			       marpa_v_result(v),
			       marpa_v_token_value(v));

		step = Tcl_NewDictObj ();
		Tcl_DictObjPut (interp, step, MT_S_ID,       Tcl_NewIntObj (marpa_v_token(v)));
		Tcl_DictObjPut (interp, step, MT_S_START_ES, Tcl_NewIntObj (marpa_v_token_start_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_END_ES,   Tcl_NewIntObj (marpa_v_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_RES,      Tcl_NewIntObj (marpa_v_result(v)));
		Tcl_DictObjPut (interp, step, MT_S_VALUE,    Tcl_NewIntObj (marpa_v_token_value(v)));

		Tcl_ListObjAppendElement (interp, steps, MT_S_TOKEN);
		Tcl_ListObjAppendElement (interp, steps, step);
		break;
	    case MARPA_STEP_NULLING_SYMBOL:
		/* The semantics for a nulling symbol should be performed. The ID of the symbol
		** is       marpa_v_symbol(v)
		** and its value should be placed in stack
		** location marpa_v_result(v).
		*/

		TRACE_TAG_ADD (parse, " -- sym     %3d, span (%d-%d), %d := NULL",
			       marpa_v_symbol(v),
			       marpa_v_token_start_es_id(v),
			       marpa_v_es_id(v),
			       marpa_v_result(v));

		step = Tcl_NewDictObj ();
		Tcl_DictObjPut (interp, step, MT_S_ID,       Tcl_NewIntObj (marpa_v_symbol(v)));
		Tcl_DictObjPut (interp, step, MT_S_START_ES, Tcl_NewIntObj (marpa_v_token_start_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_END_ES,   Tcl_NewIntObj (marpa_v_es_id(v)));
		Tcl_DictObjPut (interp, step, MT_S_RES,      Tcl_NewIntObj (marpa_v_result(v)));

		Tcl_ListObjAppendElement (interp, steps, MT_S_NULLING);
		Tcl_ListObjAppendElement (interp, steps, step);
		break;
	    case MARPA_STEP_INTERNAL1:
	    case MARPA_STEP_INTERNAL2:
	    case MARPA_STEP_TRACE:
		/* Internal, ignore */
		/* Under debug we might wish to see them */
		break;
	    }
	    TRACE_TAG_CLOSER (parse);
	}

	marpa_v_unref (v);
	Tcl_SetObjResult (interp, steps);

	TRACE_TAG_RETURN (parse, "OK", TCL_OK);
    }


    # # ## ### ##### ######## #############
    support {
	// tree evaluation
	TRACE_TAG_OFF (parse);

	/* Stem:  @stem@
	* Pkg:   @package@
	* Class: @class@
	* IType: @instancetype@
	* CType: @classtype@
	*/

#define BOCAGE @stem@_ClassCommand

	/* ** Create bocage ordering object on demand ** */

	static Marpa_Order
	@stem@_order (@instancetype@ instance)
	{
	    // fprintf(stdout,"XXX/OO %p\n",instance->order);fflush(stdout);

	    if (!instance->order) {
		instance->order = marpa_o_new (instance->bocage);
	    }

	    // fprintf(stdout,"XXX/O= %p\n",instance->order);fflush(stdout);
	    return instance->order;
	}

	/* ** Create bocage tree iterator object on demand ** */

	static Marpa_Tree
	@stem@_tree (@instancetype@ instance)
	{
	    // fprintf(stdout,"XXX/TT %p\n",instance->tree);fflush(stdout);

	    if (!instance->tree) {
		Marpa_Order order = @stem@_order (instance);
		instance->tree = marpa_t_new (order);
	    }

	    // fprintf(stdout,"XXX/T= %p\n",instance->tree);fflush(stdout);
	    return instance->tree;
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
