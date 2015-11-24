Q	Each character class is passed to Perl to interpret exactly
	once and the result is memoized in a C language structure for
	future use.

	How does that work exactly ?

	To be interpreted truly once the char class would have to be
	applied to the totality of unicode characters and the
	resulting bitfield stored.

	Is the class possibly compiled to a Perl regex structure, and
	this is what is memoized ? In that case the compiled regex would
	still be applied whenever an unknown character appears.

	It could fully pre-computed for a small subset of all unicode,
	i.e. the ASCII characters,  without requiring too much memory.

X	Masking

	Hide pieces of rule RHS from the semantics.

	Masking vector which lists what to take/ignore

		Boolean, all RHS ? 	easier filter
		Indices, only masked	short, often empty
		Indices, only taken

	Is that a core feature outside of any user-semantics?
	Yes.
