# Ideas and notes for C-level data structures usable to the various components

* For a first draft of a C-level parser use of 'Tcl_HashTable's should be ok.

  However the final product should use hashtables not coupled to a
  specific (scripting) language. Where we have kept hash-tables.

  (Given that Tcl is under a BSD license it might be possible to take
  Tcl_HashTable and rewrite to suit (int and string keys).

* Note however that the regex handling is still done by Tcl.

  A possible solution might be to engineer call-outs to a regex engine
  into the generated parser.

  Another solution might be somehow translate char-classes into

  (a) basic lexer rules which we can integrate with the user-specified rules
  (b) function calls which due the membership testing (! named char classes)
  (c) function calls again for negative classes.
      These might be able to use a subordinate grammar+recognizer for the positive class.
  (d) Basic function to test finite positive/negative classes given as
      array of characters.

_______________________________________________________________________________
inbound
	int:	location

	Keep as-is. Maybe add additional counters for line/column and
	store that in the SV.

_______________________________________________________________________________
gate

(1)	dict: character       -> set (symbol ID)   (__allocated in lexer__)
(2)	dict: symbol id	      -> char(class) 	   (inverse map, readable debugging)
(3)	dict: char-class name -> tuple (string, symbol id)
(4)	set:  sym ids	      	       		   (acceptable symbols)	

(ad 1)	int symbol[N]	per character, offset into symid O
    	int symcount[N]	per character, number of symbols K
	int symid[N']	K symbols at offset O for a character

	+ Hashtable ->  struct {
	  	       	      int	count
			      int	sym[.]
			}

		On demand fill with symbols unknown characters.

	xxx [] (char class) definitions for on-deman above.
	       Note the intro notes about possible implementations
	       decoupled from any scripting language.

(ad 2)	       Assuming that symbol ids are contiguous, use an
    	       array [N], N = MAX-MIN+1, indexing by symbol-MIN

(ad 3)


(ad 4)	Easy to use:

	(a)	bool/bit? array

			indexed by all possible symbols, acceptable
			have corresponding flag set.

			Transfer issue: Must clear entire array before
			setting new content.

			<= 256 ascii symbols + char classes
			(slif: 12 classes)

			Est 300 bit avg ~ 38 byte ~ 10 longs
			How fast is memset ?

	Easy to transfer

	(b)	int array

			contains just ids of the acceptable symbols
			plus a count

			Issue of use: Test requires search of the array.
			Simple search O(n), but a small constant?
			Sorted, binary search: O(log(n))

			Instrument gate to record size of sets for the
			slif grammar.

	Suspect that I should implement both and test which is faster ?
	Likely also dependent on number of symbols to handle

	For a 1st run (b) looks to be easier to implement.

_______________________________________________________________________________
engine

_______________________________________________________________________________
lexer

_______________________________________________________________________________
parser

_______________________________________________________________________________
