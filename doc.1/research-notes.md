
* S/R <statement group> - Closing brace (lexeme) is not hidden from semantics - Why ?
* S/R <default rule>    - First two children (lexemes) are not hidden from the semantics

  Locally fixed.

* Adverb name         | Claim to be usable with alternatives and quantified
* Adverb rank         | ditto
* Adverb null-ranking | Claim to be usable with alternatives
  	 	      |
                      | Converse references as allowed in the
                      | alt/quant descriptions are missing


Terminal symbols are symbols which are not in the set of LHS.
For SLIF terminal symbols must have lexeme definitions.

Unused symbols are lhs which do no appear in a RHS and are not the
start symbol.

Used symbols are all symbols in the transitive closure of the start
symbol, where a symbol Z is directly reachable from A if Z is on the
RHS of a rule for Z.

In the NAIF grammars have a keep flag which tells the engine whether
to hide (keep false), or show (keep true) QR separator from the
semantics. The default is false, hide separators -- Check if the SLIF
supports that.
