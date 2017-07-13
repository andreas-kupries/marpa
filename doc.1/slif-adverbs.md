				Adverbs		Adverb list
Contexts		Short	A/BEFNzP^&RS
--------		-----	------------	-----------
G1 :default		:D	* *		action, bless
G1 alternative		Al	***  **   *	action, assoc, bless, name, null-ranking, rank
G1 quantified		Qu      * *   *  * *	action, bless, null-ranking, proper, separator
--------		-----	------------	-----------
L0 :discard		:-	   *            event
L0 :lexeme		:L         *   **       event, pause, priority
L0 discard default	DD         *            event
L0 lexeme default	LD      * * *		action, bless, forgiving
--------		-----	------------	-----------

Adverb		Short	Acceptable contexts
------		-----	--------------------
action		A	:D       LD    Al Qu
assoc		/	               Al
bless		B	:D       LD    Al Qu
event		E	   :L :-    DD
forgiving	F	         LD
name		N	               Al    --
null-ranking	z	               Al Qu --
pause		P	   :L
priority	^	   :L
proper		&	                  Qu
rank		R	               Al    --
separator	S	                  Qu
------		-----	--------------------
		Short	:D :L :- LD DD Al Qu

http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#name
http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#null-ranking
http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#rank
