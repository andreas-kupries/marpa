# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# SLIF support. Semantics. Processing of literals.

# Literals are compiled into tagged tuple structures, simplified and
# then entered into the container associated with the semantics the
# processor is part of. The internal forms are:
#
# - "string" (codepoint...) nocase
# - "character" codepoint
# - "charclass" (cc-element) nocase
# where
#    cc-element = A: codepoint             - character
#               | B: (codepoint codepoint) - range
#               | C: name                  - named-cc
#               | D: ^name                 - named-cc
#
# D is technically the same as C, just treat ^ as part of the name.
#
# The rules for simplification are
#
# | Id | Type     | Nocase | Other     | Result                    | Note |
# |---:|----------|--------|-----------|---------------------------|------|
# |  1 | string   | 0      | len==1    | character                 |      |
# |  2 | string   | 0      | len>1     | sequence (character)      |      |
# |  3 | string   | 1      | len==1    | charclass/case            |      |
# |  4 | string   | 1      | len>1     | sequence (cc/case)        |      |
# |  5 | cclass   | 0      | len==1    | cc-elem itself            |      |
# |  6 | cclass   | 0      | *         | alternation (cc-elem)     |      |
# |  7 | cclass   | 1      | *         | alternation(cc-el/nocase) |      |
# |  8 | char     | -      | -         | nothing to do, simplest   |      |
# |  9 | range    | -      | -         | alternation(char)         | [1]  |
# | 10 | named-cc | -      | -         | Inline definition         | [1]  |
#
# [1] Reducing this one early/eager is likely not a good idea
#     (large ranges, classes) Better to defer the decision on this to
#     the generator consuming the grammar as it knows what the engine
#     itself will support.
#
# Important point of the simplification: After it is done we do not have a
# nocase-flag anywhere. (Except implied in the name of a named-cc).

# Type-coding used in the symbols for literals and literal-composites:
#
# | Type      | Coding    | Note     |
# |-----------|-----------|----------|
# | character | @chr<...> |          |
# | namedcc   | @ncc<...> |          |
# | range     | @int<...> | INTerval |

# | Type      | Coding    | Note     |
# |-----------|-----------|----------|
# | string    | @str<...> |          |
# | charclass | @cls<...> |          |
#

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require char          ;# quoting cstring - debugging narrative
package require oo::util      ;# mymethod

debug define marpa/slif/semantics/literal
#debug prefix marpa/slif/semantics/literal {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::slif::semantics::literal {
    marpa::E marpa/slif/semantics::literal SLIF SEMANTICS LITERAL








}
