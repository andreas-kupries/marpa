
Entities the lexer and parser can be decomposed into.


1. Stream converter - Characters to (char, token-info) = token stream
   Unconditional.

   Could have the token store (store of token values) as a separate 

   a. Allow handling of multiple chars at once (string)
   b. Allow reading from a channel.

   System is synchronous driven from the character input.


2. Stream converter CCI stream into a stream (set of symbols +
   token-info) = symbol stream Conditional: For each element pushed
   into the symbol stream the upstream processor returns a set of
   acceptable symbols for the next element, and the converter is
   responsible for sending only symbols in that set, or, if no such is
   possible, a fail signal.

   Upstream is responsible for how it handles this fail.

3. Lexer is upstream of an instance of (2.), and in itself an instance
   of (2.), with the parser upstream.

   Where the basic stream converter translates chars/tokens 1:1 the
   lexer aggregates its tokens, and may even discard some.

1. SC new X $handler
   X enter $char  => {*}$handler enter token vref
   X enter $string (multiple chars)
   X read $chan
   X eof	 => {*}$handler eof

   Example:
   = Character processor,
     token data is location,
     or location range (Example: [first, last])	(*)

   This type of handler generates token information of some kind.


2. SC new X $handler
   X enter $token $vref  => {*}$handler enter $symbols $vrefb
     	   	  	 => Empty set of symbols => Nothing acceptable
     	   	  	    available.

	Downstream token generator, see 1.

	NOTE: The symbols share token value, as they (currently) are
	all of the same length - model 4.1.6 ambiguous input - lexer, parser.

   X eof

	Downstream signal,

   X acceptable $symbols

     	Upstream signaling.
     		Called with no token waiting => Remember.
		With a token waiting, reprocess as if just entered.

   X rewind $n

		Rewind n tokens into the input, re-process them as if
		newly entered. Tokens before that set can be flushed
		from the history.

		Rewind 0 flushes entire history.

		Called from upstream when it has completed part of the
		input sequence in some way.

   X clear
		Clear the token history.

   State: const: set of tokens to discard, prevent from reaching the
   	  	  output.  Useful for the char processor as well,
   	  	  actually, to remove unwanted characters ... (Ex:
   	  	  base64 coding across lines, drop the \r\n chars

		 => Set of discards could be dynamic...

   State, const:  token -> symbol map.
   State, fluid:  set of acceptable tokens

   This type of handler extends and filters the token stream.
