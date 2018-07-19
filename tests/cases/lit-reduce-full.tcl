# -*- tcl -*-
##
# (c) 2018 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# Test suite support.
# # ## ### ##### ######## #############
# Test cases for full literal reduction

proc lit-reduce-full {} {
    # XXX TODO: Add border cases BMP / FULL, middle, high FULL

    # Incrementally fill the table with cases.  The basic flow is
    # covered by what we have now. Extending this is not about
    # coverage anymore, but about seeing the whole deconstruction for
    # all literal types and possible rule-sets.

    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    L string

    +C {} error RIL

    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    L {string 65 66 300}

    +C {} error RT

    +C K-STR  ok    {<symbol> {string 65 66 300}}

    +C D-STR1 error {RX (character (300))}

    +C {D-STR1 K-CHR} ok {
	@CHR:<A> {character 65}
	@CHR:<B> {character 66}
	{@CHR:<\u012c>} {character 300}
	<symbol> {composite {@CHR:<A> @CHR:<B> {@CHR:<\u012c>}}}
    }

    +C {D-STR1 D-CHR} ok {
	@CHR:<A> {byte 65}
	@CHR:<B> {byte 66}
	{@BYTE:<\u00c4>} {byte 196}
	{@BYTE:<\u00ac>} {byte 172}
	{@CHR:<\u012c>} {composite {{@BYTE:<\u00c4>} {@BYTE:<\u00ac>}}}
	<symbol> {composite {@CHR:<A> @CHR:<B> {@CHR:<\u012c>}}}
    }

    +C D-STR2 ok {
	@BYTE:<A> {byte 65}
	@BYTE:<B> {byte 66}
	{@BYTE:<\u00c4>} {byte 196}
	{@BYTE:<\u00ac>} {byte 172}
	<symbol> {composite {@BYTE:<A> @BYTE:<B> {@BYTE:<\u00c4>} {@BYTE:<\u00ac>}}}
    }

    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    L {charclass 65 67}

    +C {}     error RT

    +C K-CLS  ok    {<symbol> {charclass 65 67}}

    +C D-CLS1 error {RX (character (67))}

    +C {D-CLS1 K-CHR} ok {
	@CHR:<A> {character 65}
	@CHR:<C> {character 67}
	<symbol> {composite @CHR:<A> @CHR:<C>}
    }

    +C {D-CLS1 D-CHR} ok {
	@CHR:<A> {byte 65}
	@CHR:<C> {byte 67}
	<symbol> {composite @CHR:<A> @CHR:<C>}
    }

    +C D-CLS2 ok {
	@BYTE:<A> {byte 65}
	@BYTE:<C> {byte 67}
	<symbol> {composite @BYTE:<A> @BYTE:<C>}
    }

    # % %% %%% %%%%% %%%%%%%% %%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
    //
}

# # ## ### ##### ######## #############
return
