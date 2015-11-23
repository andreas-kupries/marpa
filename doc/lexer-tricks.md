Marpa lexer tricks
====

Jeffrey:

	Currently uses zero-width assertions (ZWA) to conditionally
	exclude specific lexemes from recognition.

	Uses information from the G1 recognizer about acceptable
	tokens to determine the set of acceptable lexemes and
	constrains the lexer to return only such, or nothing.

	Effect:

	- After a parser step an empty set of acceptable lexemes
  	  indicates parse failure.

	- The lexer is unable to feed a bad token into the parser.  If
  	  it can't find an acceptable lexeme we have a parse failure,
  	  detected before the parser gets hold of things.

Alternate implementation:

- Start each top-level lexeme with a special token not associated with
  any character => For each acceptable lexeme feed their special token
  into the recognizer before feeding tokens for characters. - Not
  acceptable lexemes cannot be recognized as the required special
  token was not fed in, effectively disabling this part of the rules.

/Question: Can such tokens be zero-length ?

	   /I made a quick try and it did not seem to work

	   /Of course, it is much more likely that I did something
	    wrong, not understanding the advanced input models.
