# Structures in the engine.

## Static configuration - Initialized at construction time

inbound
gate
	myrmap	D	symbol-id -> char|class-name)
	myclass	D	name      -> L (spec, symbol-id)

engine
	mymap	D	name -> id
	myrmap	D	id -> name
	myrule	D	rule id -> L (lhs id, L (rhs id))

engine/lexer
	mypublic	D	local id (lexeme|ACS) -> parser id
			/constructor	initialize
			/export		fill
			/discard	fill
			/Complete	query (ACS to matched symbol)

	myacs		D	parser id -> local id (ACS)
			/constructor   initialize
			/export	       fill
			/discard       fill
			/acceptable    query (parser -> ACS translation)
			/FromParser    ditto (DEBUG)

	mylex		D	parser id -> local id (lexeme)
			/constructor	initialize
			/export		fill
			/GetSemValue	query (parser -> lexeme -> name)

	myalways	L	ACS ids of always active toplevel symbols
				(discards, LTM mode lexemes)
				(discards have no parser symbols)
			/constructor	initialize
			/export		fill
			/discard	fill
			/acceptable	query (list concat, sort)
			/ExtendContext	query, FAIL

	myparts		L	keys to actions	\ dynamic, strictly limited to setup
	mynull

engine/parser
	myparts		L	keys to actions	\ dynamic, strictly
	myname		string	     		. limited to setup
	mypreviouslhs	ID			.
	myplhscount	INT			/

## Dynamic state - Tracking the system while processing input

inbound
	mylocation	INT	offset in the input, for the current character
				/location?, enter (increment)/

gate
	myclass		DICT (name -> LIST(spec, symbol-id))
			     	      	extended during runtime for characters
					outside of the predefined set.

	myhistory	LIST ({char semvalue-id}...)
	mylastchar	CHAR
	mylastvalue	semvalue-id

	myacceptable	DICT (id -> .)	set of acceptable char/class symbols
	/LEXER API/	LIST -> DICT conversion

engine
engine/lexer
	myacceptable	L	parser symbol ids
	mystart
	mylexeme
	myrecce	

engine/parser
