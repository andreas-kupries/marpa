Collection of the data structures currently used in the various
classes, and their connections.


_______________________________________________________________________________
semstore	(Semantic Value Store)
		String interning, in a thin disguise.

	dict: id -> string

	*	Integer indexed for easy interfacing with the libmarpa
	   	structures.

_______________________________________________________________________________
inbound		(Entrypoint for characters from strings an channels
	  	 into the processing pipeline)

	int: location

	*	Tracks character location, plain counter.

	*	Semantic values are 3-tuples of the form

			(int, int, string)

		describing a range of input. The elements re, in
		order:

	    	- start offset of the range covered by the string
	    	- end offset of the range covered by the string
	    	- text of the string

		The offsets are meant inclusive.

		The tuple ({{}, {}, {}) is the null element for range
		merges, returning the other input.

		inbound generates tuples where the string is a single
		character, and the two offsets are identical, the
		location of that character.

_______________________________________________________________________________
gate		(Filter, mapper in front of the lexer. Feedback from
		the lexer determines which characters (actually
		symbols) are passed to the lexer)

	dict: character       -> set (symbol ID)   (__allocated in lexer__)
	dict: symbol id	      -> char(class) 	   (inverse map, readable debugging)
	dict: char-class name -> tuple (string, symbol id)

	*      	The character mapping delivers the __set__ of symbols
	      	associated with a character.

		This set contains a symbol for the character itself,
	      	if the grammar contains a lexeme explicitly mentioning
	      	it, plus the symbols for any character classes the
	      	character is a member of.

		Note: The slots for characters not mentioned in the
		lexeme are dynamically added when encoutered in the
		input, with the membership in classes computed on the
		fly.

		As a side note, it might make sense to precompute the
		mapping for the entire set of ASCII characters instead
		of just the directly recognized ones. This should cut
		the majority of the extension operations othrwise
		needed at runtime.

		IMPORTANT: The part about __allocated in lexer__ means
			   that the exact symbol ids are actually
			   something which cannot be statically
			   assigned, not even in C. Best we can is to
			   have placeholders which get filled during
			   setup once.

	*	The reverse mapping is for debugging, delivering the
		name of the symbol, which is either name of a
		character class, or the character itself (** TODO **
		suitably quoted)

	*	The last mapping contains the data necessary for the
		dynamic expansion of the character mapping, i.e. all
		the character classes a character may be a member of,
		plus the associated symbol.

		** NOTE ** This could actually be reduced to a list.

_______________________________________________________________________________
engine		(Base class for lexer and parser, holding data which
		is common to both, i.e. the basic grammar
		information).

	dict: symbol name -> id/local	(local naming of symbols)
	dict: id/local -> symbol name	(invers map, readable debugging)
	dict: rule id -> lhs sym id	(map rules to generated symbol)

	*	The base symbol mapping delivers the symbol id for its
		name.  This is used to translate rules from symbolic
		to low-level numeric representation used in libmarpa.

	*	The inverse mapping is used by the code for the debug
		narrative to make id's delivered by libmarpa readable
		again.

	*	The last mapping is generally for use in the debug
		narrative of semantics, to make rule ids readable by
		identifying them with their LHS symbol. Note that
		multiple rules can and will have the same LHS
		(priorities, alternatives).

		It can also be used in the semantics themselves. The
		lexer semantics for example do so.

	GRAMMAR	libmarpa grammar (instance (command))

_______________________________________________________________________________
lexer		(Engine-derived custom class for lexing)

	dict: id/local -> id/up		(lex/parse interface, translation)
	dict: id/up -> id/acs/local	(ditto, lexeme gating)
	set:  id/acs/local		(ACS for :discard lexemes)
	set:  id/up			(Upstream acceptable)

	*	In the interface between lexer and parser, L0 and G1,
		the lexeme symbols exist in both lexer and parser, and
		thus have two symbol ids. The first mapping is for the
		translation from lexer to parser.

	*	The lexeme's actually have __three__ symbols
		associated with them. The third symbol is the
		"acceptability control symbol", short ACS.

		Each rule for a lexeme in the interface has such an
		ACS to allow the parser to control when the lexeme is
		acceptable in the input, in the same mananer as the
		lexer controls which char(class) symbols are
		acceptable at each point.

		This is part of the infrastructure for "longest
		acceptable token matching", short LATM, versus the
		LTM normally used in lexers and parsers.

		The second mapping translates down from the parser's
		lexeme symbols to the lexer's ACS they control

	RECCE	libmarpa recognizer (instance (command))

		Created for each new lexeme to recognize, and
		destroyed when recognition completed.

	FOREST	libmarpa bocage (instance (command))

		Exists only transiently for the extraction of lexeme
		parse trees.

_______________________________________________________________________________
parser		(Engine-derived custom class for parsing)

	No specific data structures.
	Will have a semantic attached to it however.

	RECCE	libmarpa recognizer (instance (command))

		Created on start of parsing. Destroyed when parsing
		completes.

	FOREST	libmarpa bocage (instance (command))

		Exists only transiently for the extraction of parse
		trees.

_______________________________________________________________________________
semcore		(Base class for the application of semantics to parse
		 trees in the form of marpa step instructions)

	dict: "tok:<id>"      Semantics for lexeme <id>
	      "tok:@default"  Default semantics for any lexeme without a custom entry
	      "rule:<id>"     Semantics for rule <id>
	      "rule:@default" Default semantics for any rule without a custom entry
	      "sym:<id>"      Semantics for nullable symbol <id>
	      "sym:@default"  Default semantics for any nullable without a custom entry

	Setup ...

	The setup is trickier because none of the id's are fixed ahead
	of time. We can guess, but that then makes the code dependent
	on undocumented libmarpa behaviour.

	Currently only the lexer semantics were defined, and they were
	easy, requiring only "*:@default" entries
