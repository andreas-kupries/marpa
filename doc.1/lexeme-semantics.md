# Array type - Lexeme semantics

 'start'	Add offset where lexeme starts

 'length'	Add length of the lexeme

 'g1start'	Add G1 offset of the lexeme
 		(Get from parser (Forward ...))

 'g1length'	Add G1 length of the lexeme (fixed: 1)

 'name'		Symbol name of the lexeme, i.e. rule LHS
	Pre-computable

 'lhs'		LHS symbol id of the rule.
 		Lexeme symbol (parser symbol)

 'symbol'	Alias of 'name'

 'rule'		Rule id of the matched lexeme

 'value'	Token value of the lexeme, i.e.
 		the matched string.
 'values'	Alias of 'value'

# Special actions

::array <=> [value]
