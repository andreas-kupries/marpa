# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Map from marpa error codes to strings, and back.
## The back-conversion (encoding) is not expected to be used.

## Only the public error codes are handled here.

critcl::emap::def marpatcl_error {
    "No error"                                       MARPA_ERR_NONE
    "Separator has invalid symbol ID"                MARPA_ERR_BAD_SEPARATOR
    "Tree iterator is before first tree"             MARPA_ERR_BEFORE_FIRST_TREE
    "Nullable symbol on RHS of a sequence rule"      MARPA_ERR_COUNTED_NULLABLE
    "Duplicate rule"                                 MARPA_ERR_DUPLICATE_RULE
    "Duplicate token"                                MARPA_ERR_DUPLICATE_TOKEN
    "Maximum number of Earley items exceeded"        MARPA_ERR_YIM_COUNT
    "Negative event index"                           MARPA_ERR_EVENT_IX_NEGATIVE
    "No event at that index"                         MARPA_ERR_EVENT_IX_OOB
    "Grammar has cycle"                              MARPA_ERR_GRAMMAR_HAS_CYCLE
    "Internal error: Libmarpa was built incorrectly" MARPA_ERR_HEADERS_DO_NOT_MATCH
    "Marpa is in a not OK state"                     MARPA_ERR_I_AM_NOT_OK
    "Token symbol is inaccessible"                   MARPA_ERR_INACCESSIBLE_TOKEN
    "Argument is not boolean"                        MARPA_ERR_INVALID_BOOLEAN
    "Location is not valid"                          MARPA_ERR_INVALID_LOCATION
    "Specified start symbol is not valid"            MARPA_ERR_INVALID_START_SYMBOL
    "Assertion ID is malformed"                      MARPA_ERR_INVALID_ASSERTION_ID
    "Rule ID is malformed"                           MARPA_ERR_INVALID_RULE_ID
    "Symbol ID is malformed"                         MARPA_ERR_INVALID_SYMBOL_ID
    "Libmarpa major version number is a mismatch"    MARPA_ERR_MAJOR_VERSION_MISMATCH
    "Libmarpa micro version number is a mismatch"    MARPA_ERR_MICRO_VERSION_MISMATCH
    "Libmarpa minor version number is a mismatch"    MARPA_ERR_MINOR_VERSION_MISMATCH
    "Earley set ID is after latest Earley set"       MARPA_ERR_NO_EARLEY_SET_AT_LOCATION
    "This grammar is not precomputed"                MARPA_ERR_NOT_PRECOMPUTED
    "No parse"                                       MARPA_ERR_NO_PARSE
    "This grammar does not have any rules"           MARPA_ERR_NO_RULES
    "This grammar has no start symbol"               MARPA_ERR_NO_START_SYMBOL
    "No assertion with this ID exists"               MARPA_ERR_NO_SUCH_ASSERTION_ID
    "No rule with this ID exists"                    MARPA_ERR_NO_SUCH_RULE_ID
    "No symbol with this ID exists"                  MARPA_ERR_NO_SUCH_SYMBOL_ID
    "No token is expected at this earleme location"  MARPA_ERR_NO_TOKEN_EXPECTED_HERE
    "Rule is not a sequence"                         MARPA_ERR_NOT_A_SEQUENCE
    "A symbol is both terminal and nulling"          MARPA_ERR_NULLING_TERMINAL
    "The ordering is frozen"                         MARPA_ERR_ORDER_FROZEN
    "The parse is exhausted"                         MARPA_ERR_PARSE_EXHAUSTED
    "This input would make the parse too long"       MARPA_ERR_PARSE_TOO_LONG
    "An argument is null when it should not be"      MARPA_ERR_POINTER_ARG_NULL
    "This grammar is precomputed"                    MARPA_ERR_PRECOMPUTED
    "No progress report has been started"            MARPA_ERR_PROGRESS_REPORT_NOT_STARTED
    "The progress report is exhausted"               MARPA_ERR_PROGRESS_REPORT_EXHAUSTED
    "Rule or symbol rank too low"                    MARPA_ERR_RANK_TOO_LOW
    "Rule or symbol rank too high"                   MARPA_ERR_RANK_TOO_HIGH
    "The recognizer is inconsistent"                 MARPA_ERR_RECCE_IS_INCONSISTENT
    "The recognizer is not accepting input"          MARPA_ERR_RECCE_NOT_ACCEPTING_INPUT
    "The recognizer has not been started"            MARPA_ERR_RECCE_NOT_STARTED
    "The recognizer has been started"                MARPA_ERR_RECCE_STARTED
    "RHS index cannot be negative"                   MARPA_ERR_RHS_IX_NEGATIVE
    "RHS index must be less than rule length"        MARPA_ERR_RHS_IX_OOB
    "The RHS is too long"                            MARPA_ERR_RHS_TOO_LONG
    "LHS of sequence rule would not be unique"       MARPA_ERR_SEQUENCE_LHS_NOT_UNIQUE
    "Start symbol not on LHS of any rule"            MARPA_ERR_START_NOT_LHS
    "Symbol is not set up for completion events"     MARPA_ERR_SYMBOL_IS_NOT_COMPLETION_EVENT
    "Symbol is not set up for nulled events"         MARPA_ERR_SYMBOL_IS_NOT_NULLED_EVENT
    "Symbol is not set up for prediction events"     MARPA_ERR_SYMBOL_IS_NOT_PREDICTION_EVENT
    "Symbol is treated both as valued and unvalued"  MARPA_ERR_SYMBOL_VALUED_CONFLICT
    "The terminal status of the symbol is locked"    MARPA_ERR_TERMINAL_IS_LOCKED
    "Token symbol must be a terminal"                MARPA_ERR_TOKEN_IS_NOT_TERMINAL
    "Token length must greater than zero"            MARPA_ERR_TOKEN_LENGTH_LE_ZERO
    "Token is too long"                              MARPA_ERR_TOKEN_TOO_LONG
    "Tree iterator is exhausted"                     MARPA_ERR_TREE_EXHAUSTED
    "Tree iterator is paused"                        MARPA_ERR_TREE_PAUSED
    "Unexpected token"                               MARPA_ERR_UNEXPECTED_TOKEN_ID
    "Unproductive start symbol"                      MARPA_ERR_UNPRODUCTIVE_START
    "Valuator inactive"                              MARPA_ERR_VALUATOR_INACTIVE
    "The valued status of the symbol is locked"      MARPA_ERR_VALUED_IS_LOCKED
    "Symbol is nulling"                              MARPA_ERR_SYMBOL_IS_NULLING
    "Symbol is not used"                             MARPA_ERR_SYMBOL_IS_UNUSED
}

# API pieces
##
# Encoder:     int     marpatcl_error_encode (interp, Tcl_Obj* state, int* result) :: string -> type
# Decoder:     TclObj* marpatcl_error_decode (interp, int      state)              :: type -> string
# Decl Hdr:    marpatcl_error.h
# Arg-Type:    marpatcl_error   | Not used.
# Result-Type: marpatcl_error   | Hidden away in the 'int' result of most libmarpa APIs.
#                                 See "marpatcl_result" for code handling this in-band signaling.

# # ## ### ##### ######## #############
return
