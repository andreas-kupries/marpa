# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Configuration --- [Grammar] --- Recognizer --- Bocage (Ordering + Tree + Value)

critcl::class def ::marpa::Grammar {
    # # ## ### ##### ######## #############
    ## Self-reference to grammar. First element across all instance
    ## structures to allow for easy casting (return value conversion
    ## and event processing -- type Marpa_Base  [__MB]).

    insvariable Marpa_Grammar grammar {
	Opaque handle of the libmarpa structure holding the grammar for us.
    } {
	instance->grammar = marpa_g_new (&marpatcl_context(interp)->config);
	if (!instance->grammar) goto error;
	(void) marpa_g_force_valued (instance->grammar);
    } {
	marpa_g_unref (instance->grammar);
    }

    # # ## ### ##### ######## #############
    ## Back reference to grammar. First element across all class
    ## structures to allow for easy casting (return value conversion
    ## and event processing -- type Marpa_Base).

    insvariable Tcl_Obj* handler {
	Command prefix to call for grammar-level events.
    } {
	/* Full initialization later, by the main constructor
	 * code, when we have access to the arguments
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
	    goto error;
	}

	instance->handler = objv[0];
	Tcl_IncrRefCount (instance->handler);
    } {
	instance->self = fqn;
	Tcl_IncrRefCount (fqn);
    }

    # # ## ### ##### ######## #############
    ## Methods managing the libmarpa handle from the Tcl level, and
    ## other specialities.

    # # ## ### ##### ######## #############
    ## Create recognizer from the grammar. Delegate to the actual
    ## class command, skip the method name, and prepare the proper
    ## ... of the grammar information.

    method recognizer command {} {
	int res;
	marpatcl_context_data ctx = marpatcl_context (interp);

	/* Make grammar available to the recognizer constructor */
	ctx->grammar = instance->grammar;

	res = RECCE (clientdata, interp, objc-1, objv+1);

	/* Clean up */
	ctx->grammar = NULL;

	return res;
    }

    # # ## ### ##### ######## #############
    ## Grammar setup and modification.

    # Q's
    # * What is the difference between   marpa_g_symbol_is_completion_event_set
    #   and                              marpa_g_completion_symbol_activate
    #   ?

    method default-rank: proc {Marpa_Rank rank} Marpa_Rank { return marpa_g_default_rank_set (instance->grammar, rank); }
    method default-rank  proc {Marpa_Rank rank} Marpa_Rank { return marpa_g_default_rank     (instance->grammar);       }

    # # ## ### symbol methods ### ## # #

    method sym-start    proc {}                    Marpa_StartSymbol_ID { return marpa_g_start_symbol      (instance->grammar);      }
    method sym-start:   proc {Marpa_Symbol_ID sym} Marpa_Symbol_ID      { return marpa_g_start_symbol_set  (instance->grammar, sym); }
    method sym-new      proc {}                    Marpa_Symbol_ID      { return marpa_g_symbol_new        (instance->grammar); } 
    method sym-highest  proc {}                    Marpa_Symbol_ID      { return marpa_g_highest_symbol_id (instance->grammar); }

    method sym-rank:    proc {Marpa_Symbol_ID sym   Marpa_Rank rank} Marpa_Rank { return marpa_g_symbol_rank_set (instance->grammar, sym, rank); }
    method sym-rank     proc {Marpa_Symbol_ID sym}                   Marpa_Rank { return marpa_g_symbol_rank     (instance->grammar, sym);       }

    method sym-terminal:   proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_symbol_is_terminal_set     (instance->grammar, sym, enable); }
    method sym-completion: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_completion_symbol_activate (instance->grammar, sym, enable); }
    method sym-nulled:     proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_nulled_symbol_activate     (instance->grammar, sym, enable); }
    method sym-prediction: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_prediction_symbol_activate (instance->grammar, sym, enable); }

    # -- Query various symbol properties.

    method sym-accessible? proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_accessible (instance->grammar, sym); }
    method sym-nullable?   proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_nullable   (instance->grammar, sym); }
    method sym-nulling?    proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_nulling    (instance->grammar, sym); }
    method sym-productive? proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_productive (instance->grammar, sym); }
    method sym-start?      proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_start      (instance->grammar, sym); }
    method sym-terminal?   proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_terminal   (instance->grammar, sym); }
    method sym-counted?    proc {Marpa_Symbol_ID sym} Marpa_Symbol_Boolean { return marpa_g_symbol_is_counted    (instance->grammar, sym); }

    # -- Query and modify (completion, nulled, prediction) event generation status for the given symbol.

    method sym-completion-event  proc {Marpa_Symbol_ID sym}                 Marpa_Symbol_Boolean { return marpa_g_symbol_is_completion_event     (instance->grammar, sym); }
    method sym-completion-event: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_symbol_is_completion_event_set (instance->grammar, sym, enable); }
    method sym-nulled-event      proc {Marpa_Symbol_ID sym}                 Marpa_Symbol_Boolean { return marpa_g_symbol_is_nulled_event         (instance->grammar, sym); }
    method sym-nulled-event:     proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_symbol_is_nulled_event_set     (instance->grammar, sym, enable); }
    method sym-prediction-event  proc {Marpa_Symbol_ID sym}                 Marpa_Symbol_Boolean { return marpa_g_symbol_is_prediction_event     (instance->grammar, sym); }
    method sym-prediction-event: proc {Marpa_Symbol_ID sym  boolean enable} Marpa_Symbol_Boolean { return marpa_g_symbol_is_prediction_event_set (instance->grammar, sym, enable); }

    # # ## ### rule methods ### ## # #

    method rule-new proc {
	Marpa_Symbol_ID lhs
	Marpa_Symbol_ID args
    } Marpa_Rule_ID {
	/* args as last argument is variadic, of auto-gen'd type critcl_variadic_int */
	return marpa_g_rule_new (instance->grammar, lhs, args.v, args.c);
    }

    method rule-highest     proc {}                             Marpa_Rule_ID      { return marpa_g_highest_rule_id    (instance->grammar); }
    method rule-accessible? proc {Marpa_Rule_ID rule}           Marpa_Rule_Boolean { return marpa_g_rule_is_accessible (instance->grammar, rule); }
    method rule-nullable?   proc {Marpa_Rule_ID rule}           Marpa_Rule_Boolean { return marpa_g_rule_is_nullable   (instance->grammar, rule); }
    method rule-nulling?    proc {Marpa_Rule_ID rule}           Marpa_Rule_Boolean { return marpa_g_rule_is_nulling    (instance->grammar, rule); }
    method rule-loop?       proc {Marpa_Rule_ID rule}           Marpa_Rule_Boolean { return marpa_g_rule_is_loop       (instance->grammar, rule); }
    method rule-productive? proc {Marpa_Rule_ID rule}           Marpa_Rule_Boolean { return marpa_g_rule_is_productive (instance->grammar, rule); }
    method rule-length      proc {Marpa_Rule_ID rule}           Marpa_Rule_Int     { return marpa_g_rule_length        (instance->grammar, rule); }
    method rule-lhs         proc {Marpa_Rule_ID rule}           Marpa_Symbol_ID    { return marpa_g_rule_lhs           (instance->grammar, rule); }
    method rule-rhs         proc {Marpa_Rule_ID rule int index} Marpa_Symbol_ID    { return marpa_g_rule_rhs           (instance->grammar, rule, index); }

    method rule-sequence-new proc {
	Marpa_Symbol_ID lhs
	Marpa_Symbol_ID rhs
	Marpa_Symbol_ID separator
	boolean         positive
	boolean         proper
    } Marpa_Rule_ID {
	int min = (positive ? 1 : 0);
	int flags = (proper
		     ? MARPA_PROPER_SEPARATION
		     : 0);
	return marpa_g_sequence_new (instance->grammar, lhs, rhs, separator, min, flags );
    }

    method rule-sequence-min       proc {Marpa_Rule_ID rule} int                { return marpa_g_sequence_min              (instance->grammar, rule); }
    method rule-sequence-separator proc {Marpa_Rule_ID rule} Marpa_Symbol_ID    { return marpa_g_sequence_separator        (instance->grammar, rule); }
    method rule-proper-separation? proc {Marpa_Rule_ID rule} Marpa_Rule_Boolean { return marpa_g_rule_is_proper_separation (instance->grammar, rule); }

    method rule-rank:      proc {Marpa_Rule_ID rule   Marpa_Rank rank} Marpa_Rank         { return marpa_g_rule_rank_set      (instance->grammar, rule, rank); }
    method rule-rank       proc {Marpa_Rule_ID rule}                   Marpa_Rank         { return marpa_g_rule_rank          (instance->grammar, rule);       }
    method rule-null-high: proc {Marpa_Rule_ID rule   boolean    high} Marpa_Rule_Boolean { return marpa_g_rule_null_high_set (instance->grammar, rule, high); }
    method rule-null-high  proc {Marpa_Rule_ID rule}                   Marpa_Rule_Boolean { return marpa_g_rule_null_high     (instance->grammar, rule);       }

    # # ## ### finalization/freezing ### ## # #

    method freeze proc {} Marpa_Boolean {
	int res = marpa_g_precompute (instance->grammar);
	marpatcl_process_events (instance->grammar, marpatcl_grammar_event_to_tcl, instance);
	return res;
    }
    method frozen? proc {} Marpa_Boolean { return marpa_g_is_precomputed (instance->grammar); }
    method cycle?  proc {} Marpa_Boolean { return marpa_g_has_cycle      (instance->grammar); }

    # # ## ### ##### ######## #############
    ## 

    # # ## ### ##### ######## #############
    ## zero-width assertions -- not exposing these

    ## <> Marpa_Error_Code    marpa_g_error                          ( Marpa_Grammar g, const char** p_error_string)
    ## <> Marpa_Error_Code    marpa_g_error_clear                    ( Marpa_Grammar g )
    #
    ## <> Marpa_Assertion_ID  marpa_g_zwa_new                        ( Marpa_Grammar g, int default_value)
    ## <> int                 marpa_g_zwa_place                      ( Marpa_Grammar g, Marpa_Assertion_ID zwaid, Marpa_Rule_ID xrl_id, int rhs_ix)
    ## <> Marpa_Assertion_ID  marpa_g_highest_zwa_id                 ( Marpa_Grammar g )
    ## <> int                 marpa_g_symbol_is_valued_set           ( Marpa_Grammar g, Marpa_Symbol_ID symbol_id, int value)
    ## <> int                 marpa_g_symbol_is_valued               ( Marpa_Grammar g, Marpa_Symbol_ID symbol_id)

    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    support {
       /* Stem:  @stem@
	* Pkg:   @package@
	* Class: @class@
	* IType: @instancetype@
	* CType: @classtype@
	*/
	static void
	marpatcl_grammar_event_to_tcl (ClientData context, Marpa_Grammar g, Marpa_Event_Type t, int v)
	{
	    /* context = Grammar instance. */
	    @instancetype@ instance = context;
	    /**/
	    Tcl_Interp* interp = instance->interp;
	    int res = TCL_OK;
	    Tcl_Obj* cmd = Tcl_DuplicateObj (instance->handler);

	    Tcl_ListObjAppendElement (interp, cmd, instance->self);
	    Tcl_ListObjAppendElement (interp, cmd, marpatcl_event_decode (interp, t));
	    Tcl_ListObjAppendElement (interp, cmd, Tcl_NewIntObj(v));

	    Tcl_IncrRefCount (cmd);
	    res = Tcl_GlobalEvalObj (interp, cmd);
	    Tcl_DecrRefCount (cmd);

	    if (res != TCL_OK) {
		Tcl_BackgroundError (interp);
	    }
	}
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
