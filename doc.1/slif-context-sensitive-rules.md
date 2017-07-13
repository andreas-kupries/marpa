The rules listed here are based on the official SLIF grammar.

A number of them are actually not context-sensitive and could be
encoded into the context-free grammar. Primary example are the adverb
lists, where the single generic symbol with CS-rules can be split into
several grammar rules, specialized by context, without any CS-rules.

Onward

Ref document:

http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod

1	Whitespace in bracketed symbol names is normalized.
	Leading and trailing whitespace is discarded.
	Any sequence of WS is reduced to a single ASCII space char
	(hex 20).

2	Whitespace in single-quoted event names is normalized as in (1).


3	The only event pseudo-name known is :symbol

4	The pseudo-event :symbol is only allowed in :discard and 'discard default'
	rules.

5	The actual name of an event defined with :symbol is based on the RHS

5a	single symbol => event name is that symbol
5b	char-class    => event name is the string literal of the char-class spec

6	Events without an explicit initialization are 'on'.
