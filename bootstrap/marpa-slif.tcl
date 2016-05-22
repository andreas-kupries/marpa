#!/usr/bin/env tclsh
## -*- tcl -*-
# # ## ### ##### ######## #############
## Test parsing application

## Bootstrapping.
## Parsing the L0 grammar, i.e. lexemes and their rules.
## Manually extracted, per
## -- Marpa--R2/cpan/lib/Marpa/R2/meta/metag.bnf
##    -- Artifact as of commit 15fdfc349167808b356c0c2680a54358658318c6.
## See also
## -- Marpa--R2/cpan/lib/Marpa/R2/MetaG.pm

package require marpa
package require char ;# quoting

set input_slif_grammar_file \
    [file join [file dirname [info script]] \
	 marpa-metag-slif-2015.bnf.for-tcl]

# # ## ### ##### ######## #############
## Full debug ...

# debug on marpa/engine
# debug on marpa/gate
# debug on marpa/grammar
# debug on marpa/inbound
# debug on marpa/lexer
# debug on marpa/location
# debug on marpa/parser
# debug on marpa/semcore
# debug on marpa/semstd
# debug on marpa/semstore
# debug on marpa/support
# debug on marpa/slif/parser

# # ## ### ##### ######## #############
## Create recognizer

marpa::slif::parser create SLIF

##
# # ## ### ##### ######## #############

set ast [SLIF process-file $input_slif_grammar_file]

puts [list B $ast]
puts EOF

# TODO: Reaching eof while the recognizer is not exhausted is some
# type of error I would think. Except if we have already completed
# lexemes, then we should simply return these to G0!

# TODO: Should we have a specific symbol/token for EOF we could push
# to G0 ?  That might make handling this case easier. Especially as it
# would also allow us to know when EOF is acceptable or not.

# # ## ### ##### ######## #############
exit


# TODO: inverted input regime ... coroutine ... pass characters one by
# one, get tokens via callback ...
