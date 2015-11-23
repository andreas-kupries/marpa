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
	dict: symbol id	      -> char(class) (reverse mapping for readable debugging)
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
