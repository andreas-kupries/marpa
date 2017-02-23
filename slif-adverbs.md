
# Reference

[Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod)
as of 2017-02-23

# Questions

1. "The action adverb is allowed for An RHS alternative, in which the action is for the alternative."

   This feels incomplete. Nothing is said about quantified rules.
   While empty rules are not mentioned either close reading finds them
   under Statements, which declares them to be a special case of an
   rhs alternative.

   Note also that it is explicitly specified to not be allowed for L0
   rules at all.

1. Technically it seems that rules with precedence are possible for
   L0.  It does not really make sense, as the structure of the
   matched lexeme will not be affected but this, but still.

   Is the "assoc" adverb allowed in a L0 priority rule/alternative ?

1. Is the "name" adverb allowed for quantified and empty rules ?

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
|:default	| [Scanless DSL: :default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Default_pseudo-rule) |
|:discard	| [Scanless DSL: :discard](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_pseudo-rule) |
|:lexeme	| [Scanless DSL: :lexeme](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_pseudo-rule) |
|discard default| [Scanless DSL: discard default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_default_statement) |
|g1 alternative	| [Scanless DSL: alternative](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|g1 empty rule	| [Scanless DSL: empty rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|g1 quant. rule	| [Scanless DSL: quantified rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|l0 alternative	| [Scanless DSL: alternative](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|l0 empty rule	| [Scanless DSL: empty rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|l0 quant. rule	| [Scanless DSL: quantified rule](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|lexeme default	| [Scanless DSL: lexeme default](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_default_statement) |

# Adverbs versus possible contexts

|Adverb		|Context	|Notes|
|---		|---		|---|
|action		|		| [Scanless DSL: action](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#action) |
|		|:default	| yes|
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	| yes - Applies to the alternative|
|		|g1 empty rule	| yes - Applies to the (empty) alternative |
|		|g1 quant. rule	||
|		|l0 alternative	| no |
|		|l0 empty rule	| no |
|		|l0 quant. rule	| no |
|		|lexeme default	| yes - For all lexemes which do not specifically set their own|
|association	|   		| [Scanless DSL: assoc](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#assoc) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	| yes |
|		|g1 empty rule	| yes |
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|bless		|   		| [Scanless DSL: bless](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#bless) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	| ? |
|		|g1 empty rule	| ? |
|		|g1 quant. rule	| ? |
|		|l0 alternative	| ? |
|		|l0 empty rule	| ? |
|		|l0 quant. rule	| ? |
|		|lexeme default	||
|event		|   		| [Scanless DSL: event](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#event) |
|		|:default	||
|		|:discard	||
|		|:lexeme	| yes - Names the event for 'pause'. Error if 'pause' is missing. |
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|latm		|   		| [Scanless DSL: latm](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#latm) |
|		|:default	||
|		|:discard	||
|		|:lexeme	| yes |
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	| yes |
|name		|   		| [Scanless DSL: name](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#name) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	| yes |
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	| yes |
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|null-ranking	|   		| [Scanless DSL: null-ranking](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#null-ranking) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	| yes |
|		|l0 alternative	| no |
|		|l0 empty rule	| no |
|		|l0 quant. rule	| no |
|		|lexeme default	||
|pause		|   		| [Scanless DSL: pause](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#pause) |
|		|:default	||
|		|:discard	||
|		|:lexeme	| yes - Declares parse event. Warn if "event" is missing, unnamed events are strongly discouraged |
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|priority	|   		| [Scanless DSL: priority](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#priority) |
|		|:default	||
|		|:discard	||
|		|:lexeme	| yes |
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|proper		|   		| [Scanless DSL: proper](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#proper) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	| yes - Ignored if there is no "separator", warn |
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	| yes - Ignored if there is no "separator", warn |
|		|lexeme default	||
|rank		|   		| [Scanless DSL: rank](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#rank) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	||
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	||
|		|lexeme default	||
|separator	|   		| [Scanless DSL: separator](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#separator) |
|		|:default	||
|		|:discard	||
|		|:lexeme	||
|		|discard default||
|		|g1 alternative	||
|		|g1 empty rule	||
|		|g1 quant. rule	| yes |
|		|l0 alternative	||
|		|l0 empty rule	||
|		|l0 quant. rule	| yes |
|		|lexeme default	||

# Possible contexts versus adverbs

|Context	|Adverb		|Notes|
|---		|---		|---|
|:default	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Default_pseudo-rule) |
|		|action		| yes - G1 level rules |
|		|association	| |
|		|bless		| yes |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|:discard	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_pseudo-rule) |
|		|action		| |
|		|association	| |
|		|bless		| |
|		|event		| yes - L0 - Implies a "pause" (discard event only) |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|:lexeme	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_pseudo-rule) |
|		|action		| |
|		|association	| |
|		|bless		| |
|		|event		| yes - L0 - If specified, "pause" has to be as well |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| yes - L0 - If specified, "event" should be as well |
|		|priority	| yes |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|discard default|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Discard_default_statement) |
|		|action		| |
|		|association	| |
|		|bless		| |
|		|event		| yes |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|g1 alternative	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|		|action		| yes |
|		|association	| yes |
|		|bless		| yes |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|g1 empty rule	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|		|action		| yes |
|		|association	| |
|		|bless		| yes |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|g1 quant. rule	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|		|action		| yes |
|		|association	| |
|		|bless		| yes |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| yes |
|		|rank		| |
|		|separator	| yes |
|l0 alternative	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#RHS_alternatives) |
|		|action		| |
|		|association	| yes? |
|		|bless		| |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|l0 empty rule	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Empty_rule) |
|		|action		| |
|		|association	| |
|		|bless		| |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
|l0 quant. rule	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Quantified_rule) |
|		|action		| |
|		|association	| |
|		|bless		| |
|		|event		| |
|		|latm		| |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| yes |
|		|rank		| |
|		|separator	| yes |
|lexeme default	|		| [Scanless DSL](http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Lexeme_default_statement) |
|		|action		| yes - L0 |
|		|association	| |
		|bless		| yes - L0 |
|		|event		| |
|		|latm		| yes - L0 |
|		|name		| |
|		|null-ranking	| |
|		|pause		| |
|		|priority	| |
|		|proper		| |
|		|rank		| |
|		|separator	| |
