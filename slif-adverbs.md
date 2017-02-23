Up: [Notes](wiki?name=Notes)

# Reference

[Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod)
as of 2017-02-23

# Notes and questions

1. A close reading of `DSL.pod` is necessary to find that empty rules
   are considered to be a special case of an rhs alternative. See
   [Scanless DSL: empty rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule)

   IMHO this part needs an emphasis of some kind, as it makes reading
   the remainder of the document easier, whenever it talks about RHS
   alternatives.

   The role of quantified rules should be clarified too I believe. In
   some places I believe that an adverb applies to quantified rules
   as well, with this not explicitly stated (See "name", "action", "bless").

1. It should be noted that while some of the descriptions of adverbs
   and context cross-confirm each other, not all them do. I will use
   the marker __XREF__ whereever I put information into a table which
   came from the other description and is thus not cross-confirmed.

1. On another note, while the provided meta-grammer using a single set
   of rules for the adverbs, thus moving validation of their
   applicability past the parser, I see it as possible to give each
   context its own variant of `<adverb list>` which references only
   the allowed adverbs for that context. That way there is no need to
   validate past the parser, the grammar ensured it already. And this
   would be a third cross-check against the human-readable
   descriptions.

   Strongly tempted to make that happen here.

1. "The action adverb is allowed for An RHS alternative, in which the
   action is for the alternative."

   This feels incomplete. Nothing is said about quantified rules.
   While empty rules are not mentioned either 

   Note also that it is explicitly specified to not be allowed for L0
   rules at all.

1. Technically it seems that rules with precedence are possible for
   L0.  It does not really make sense, as the structure of the
   matched lexeme will not be affected by this, but still.

   So, is the "assoc" adverb allowed in L0 priority rule/alternatives ?

1. Is the "name" adverb allowed for quantified rules ?

1. Nothing is said at all about where the "rank" adverb is allowed, or
   not.

# Adverbs

|Adverb		|Notes|
|---		|---|
|action		| [Scanless DSL: action](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#action) |
|association	| [Scanless DSL: assoc](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#assoc) |
|bless		| [Scanless DSL: bless](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#bless) |
|event		| [Scanless DSL: event](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#event) |
|latm		| [Scanless DSL: latm](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#latm) |
|name		| [Scanless DSL: name](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#name) |
|null-ranking	| [Scanless DSL: null-ranking](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#null-ranking) |
|pause		| [Scanless DSL: pause](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#pause) |
|priority	| [Scanless DSL: priority](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#priority) |
|proper		| [Scanless DSL: proper](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#proper) |
|rank		| [Scanless DSL: rank](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#rank) |
|separator	| [Scanless DSL: separator](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#separator) |

# Adverb contexts

|Context	|Notes|
|---		|---|
|\:default	| [Scanless DSL: :default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Default_pseudo-rule) |
|\:discard	| [Scanless DSL: :discard](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_pseudo-rule) |
|\:lexeme	| [Scanless DSL: :lexeme](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_pseudo-rule) |
|discard default| [Scanless DSL: discard default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_default_statement) |
|g1 alternative	| [Scanless DSL: alternative](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|g1 empty rule	| [Scanless DSL: empty rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|g1 quant. rule	| [Scanless DSL: quantified rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|l0 alternative	| [Scanless DSL: alternative](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|l0 empty rule	| [Scanless DSL: empty rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|l0 quant. rule	| [Scanless DSL: quantified rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|lexeme default	| [Scanless DSL: lexeme default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_default_statement) |

# Adverbs versus possible contexts

__Note__ that empty rules are not considered separately here due to
them being a special case of an RHS alternative. That makes the table
a bit shorter.

|Adverb		|Context	|Notes|
|---		|---		|---|
|action		|		| [Scanless DSL: action](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#action) |
|		|\:default	| __yes__ (__XREF__: G1)|
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	| __yes__ - Applies to the alternative|
|		|g1 quant. rule	| __XREF__: yes |
|		|l0 alternative	| __no__ |
|		|l0 quant. rule	| __no__ |
|		|lexeme default	| __yes__ - For all lexemes which do not specifically set their own|
||||
|association	|   		| [Scanless DSL: assoc](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#assoc) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	| __yes__ |
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|bless		|   		| [Scanless DSL: bless](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#bless) |
|		|\:default	| __XREF__: yes, G1|
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	| __?__ __XREF__: yes |
|		|g1 quant. rule	| __?__ |
|		|l0 alternative	| __?__ |
|		|l0 quant. rule	| __?__ |
|		|lexeme default	| __XREF__: yes |
||||
|event		|   		| [Scanless DSL: event](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#event) |
|		|\:default	||
|		|\:discard	| __XREF__: yes, discard event|
|		|\:lexeme	| __yes__ - Names the event for 'pause'. Error if 'pause' is missing. |
|		|discard default| __XREF__: yes|
|		|g1 alternative	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|latm		|   		| [Scanless DSL: latm](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#latm) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	| __yes__ |
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	| __yes__ |
||||
|name		|   		| [Scanless DSL: name](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#name) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	| __yes__ |
|		|g1 quant. rule	||
|		|l0 alternative	| __yes__ |
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|null-ranking	|   		| [Scanless DSL: null-ranking](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#null-ranking) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	| __yes__ |
|		|l0 alternative	| __no__ |
|		|l0 quant. rule	| __no__ |
|		|lexeme default	||
||||
|pause		|   		| [Scanless DSL: pause](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#pause) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	| __yes__ - Declares a parse event. (Self: Warn if "event" is missing, unnamed events are strongly discouraged) |
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|priority	|   		| [Scanless DSL: priority](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#priority) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	| __yes__ |
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|proper		|   		| [Scanless DSL: proper](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#proper) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	| __yes__ - Ignored if there is no "separator". (Self: Add warning) |
|		|l0 alternative	||
|		|l0 quant. rule	| __yes__ - Ignored if there is no "separator". (Self: Add warning) |
|		|lexeme default	||
||||
|rank		|   		| [Scanless DSL: rank](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#rank) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 quant. rule	||
|		|lexeme default	||
||||
|separator	|   		| [Scanless DSL: separator](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#separator) |
|		|\:default	||
|		|\:discard	||
|		|\:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 quant. rule	| __yes__ |
|		|l0 alternative	||
|		|l0 quant. rule	| __yes__ |
|		|lexeme default	||

# Possible contexts versus adverbs

|Context	|Adverb		|Notes|
|---		|---		|---|
|\:default	|		| [Scanless DSL: :default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Default_pseudo-rule) |
|		|action		| __yes__ - Affects G1 rules |
|		|association	||
|		|bless		| __yes__ - Affects G1 rules |
|		|event		||
|		|latm		||
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|\:discard	|		| [Scanless DSL: :discard](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_pseudo-rule) |
|		|action		||
|		|association	||
|		|bless		||
|		|event		| __yes__ - L0 - Implies a __pause__ (discard event only) |
|		|latm		||
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|\:lexeme	|		| [Scanless DSL: :lexeme](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_pseudo-rule) |
|		|action		||
|		|association	||
|		|bless		||
|		|event		| __yes__ - L0 - If specified, __pause__ has to be as well. Error if not |
|		|latm		| __XREF__: yes|
|		|name		||
|		|null-ranking	||
|		|pause		| __yes__ - L0 - If specified, __event__ should be as well. Unnamed events are discouraged |
|		|priority	| __yes__ |
|		|proper		||
|		|rank		||
|		|separator	||
||||
|discard default|		| [Scanless DSL: discard default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_default_statement) |
|		|action		||
|		|association	||
|		|bless		||
|		|event		| __yes__ |
|		|latm		||
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|g1 alternative	|		| [Scanless DSL: Alternatives](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|		|action		| __yes__ |
|		|association	| __yes__ |
|		|bless		| __yes__ |
|		|event		||
|		|latm		||
|		|name		| __XREF__: yes|
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|g1 empty rule	|		| [Scanless DSL: Empty rules](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|		|action		| __yes__ |
|		|association	| __XREF__: yes|
|		|bless		| __yes__ |
|		|event		||
|		|latm		||
|		|name		| __XREF__: yes|
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|g1 quant. rule	|		| [Scanless DSL: Quantified](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|		|action		| __yes__ |
|		|association	||
|		|bless		| __yes__ |
|		|event		||
|		|latm		||
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		| __yes__ |
|		|rank		||
|		|separator	| __yes__ |
||||
|l0 alternative	|		| [Scanless DSL: Alternatives](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|		|action		| __XREF: no__|
|		|association	| yes__?__ |
|		|bless		||
|		|event		||
|		|latm		||
|		|name		| __XREF__: yes |
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|l0 empty rule	|		| [Scanless DSL: Empty rules](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|		|action		| __XREF: no__|
|		|association	| yes__?__|
|		|bless		||
|		|event		||
|		|latm		||
|		|name		| __XREF__: yes |
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
||||
|l0 quant. rule	|		| [Scanless DSL: Quantified](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|		|action		| __XREF: no__|
|		|association	||
|		|bless		||
|		|event		||
|		|latm		||
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		| __yes__ |
|		|rank		||
|		|separator	| __yes__ |
||||
|lexeme default	|		| [Scanless DSL: lexeme default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_default_statement) |
|		|action		| __yes__ - L0 |
|		|association	||
|		|bless		| __yes__ - L0 |
|		|event		||
|		|latm		| __yes__ - L0 |
|		|name		||
|		|null-ranking	||
|		|pause		||
|		|priority	||
|		|proper		||
|		|rank		||
|		|separator	||
