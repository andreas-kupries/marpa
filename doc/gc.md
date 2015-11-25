# grammar container ...

* side note -- With a bit of engineering this might also be a good
  candidate for the main parser class wrapping around the pieces made
  so far. On the other hand, this would conflate two roles, passive
  container, versus active engine. So more likely not. Onn the third
  hand, this maps very well to the perl binding which reads a SLIF,
  builds a grammar from that, and then runs it immediately. If we
  retain enough data in the container, plus proper accessor methods
  then it should be possible to write generators attaching to it as
  well.

* setup -> Simply let it evaluate the semantic value, with one method
  per structural symbol. The instance data is the global state getting
  updated by the effect-ful statements and used by others.

Data to keep:

* L0
** characters in use
** char classes in use
** symbols
** per-symbol information:
*** rules (alternatives)
*** action - array descriptor only
*** events
*** matching discipline (LATM / LTM) - irrelevant to internals - maybe error
*** internal/exported aka internal/G1

* G1
** symbols
** per-symbol
*** rules
** per rule
*** action
*** mask

* global
** current discipline
** current adverb state
** defaults
