Hi Jeffrey

I came very recently [1] across Marpa and given my own interest in
parser generators [2] I dug quite a bit more into it over the last few
days.

One of the things I am interested in is a generator producing the
parser as C code, possibly with some type of runtime to support
it. Which I found in libmarpa.

As part of my search for that I came across

	<http://irclog.perlgeek.de/marpa/2014-08-23>

and specifically, to quote:

    jeffreykegler: we'd need to use a non-Perl regex library, for example

That had me a bit surprised. Below is a sketch of an idea which simply
uses libmarpa itself for this.

OTOH, I can't really believe that nobody has had this idea before, and
given that I am only reading through things for a few days, I consider
it likely that I have missed it, and possibly any arguments against
it.

So, the rough idea is that given that (lib)marpa is good and efficient
for all LR-regular languages it will be the same for the subset of
plain regular languages as well, like i.e. the L0 of a SLIF spec as
defined by all the rules declared with the match (~) operator. Based
on us equating tokens with characters.

The earley items are the states of the underlying (implicit) NFA and
the earley sets become the states of the DFA we can derive from
that. Final states are all the states with a completion of a
(toplevel) lexeme.

To handle the L0 will instantiate a grammar based on the
match-definitions where the (toplevel) lexemes are the alternatives of
the start symbol, and recognizer for that.

To recognize a lexeme we

  1. reset the recognizer
  2. feed characters into it (converted to tokens [3])
  3. until the recognizer signals exhaustion or failure.
  4. recognized lexems are signaled to us via completion events
  4a. we only have to remember the highest position with recognized
      lexemes, due to LTM.
  4b. we have to continue feeding (i.e. (2)) due to LTM as well
  5. After (3) triggers we look if we have recognized one or more
     lexemes.
  5a. If not, it is an input failure at the lexical level.
  5b. If so, we drop the :discard lexemes from the set and feed the
      remainder into the G0 recognizer, after converting the lexemes
      into the associated tokens.
  6. Rinse and repeat.

What is missing in the above ? ...

Char classes ... I originally thought that this may require "ruby
slippers", but that would have been complicated and on additional
thought I decided that it this would not be needed. What is critical
for this simplification is Marpa's alternate input model where
multiple tokens are possible at a position.

We already need a conversion table from chars to the symbols for the
L0 recognizer. For char class support this table simply goes from char
to __set__ of symbols, each char class gets its own unique token, and
all chars in the class have that token in their conversion entry (this
can be precomputed). When feeding chars into the recognizer we
actually and simply feed in all tokens found in the table, for regular
character, and the associated classes. The ES calculation then figures
out which apply and go forward.

What else is missing ?

Unicode support. I assumed ASCII so far and that the conversion table
is a C array with direct lookup by character. All the data in the
table is (and can be) pre-computed. [4]

For unicode this array can be replaced with a hash. We can still
pre-fill it with the data for any characters directly mentioned in the
L0 rules, be it in strings, or simple char classes. For any other
character the char-class information has to be lazily computed and
entered into the hash when that character actually occurs in the
input. Entering into the hash is actually optional here, a trade-off
between speed (multiple class checks) vs memmory (cache class
results).

Using a hybrid of array and hash should be possible as well, with the
array serving the ASCII range and the hash handling anything beyond
that. This should gain us speed (array indexing vs hash lookup) given
that even today most of the input is likely predominantly ASCII with a
smattering of actual unicode, trading for more complexity.

Notes on the conversion table:

- Characters which are not listed in the L0 grammar should have no
  'regular' token, although they may have class tokens.

- A character may have an empty set of tokens associated with it.
  Finding such a character in the input is a lexical failure, and must
  be caught in step (2).

Notes on char classes

- The above way of supporting char classes allows us to support any
  class, i.e. not just those with explicit sets and ranges of
  characters, or inverted classes, but also all classes defined by a C
  function. The SLIF language simply needs keywords for such implicit
  classes and in the runtime this causes a call to the C function, be
  it for the pre-calculation of the conversion table, or during its
  lazy extension.

Ok, I am done, feel free to new tell me in detail what I missed which
makes this infeasible or a Bad Idea(tm), etc.

---
[1] http://twit.tv/show/floss-weekly/321, after seeing the fossil-scm
    episode (/320)

[2] https://core.tcl.tk/tcllib/doc/trunk/embedded/www/tcllib/files/modules/pt/pt_introduction.html

[3] As libmarpa does not allow the user to predefine the symbol ids
    for the tokens of a grammar a conversion table will be necessary
    to map from the input character to the L0 symbol before feeding
    them to the recognizer. That is actually not too bad a thing, see
    the notes above about char classes.

[4] The token values would be placeholders for the actual values we
    get when the grammar is initialized. IOW I assumed that the
    conversion table is pretty much a static array with fixed
    data. Needs only a single init pass to rewrite the placeholders to
    symbols. That part would require a mutex and a flag variable for
    thread-safety. Beyond that it is read-only.
