#!/usr/bin/env tclsh
## -*- tcl -*-
# # ## ### ##### ######## #############
## Bootstrapping.
## Parsing the L0 grammar, i.e. lexemes and their rules.
## Manually extracted, per
## -- Marpa--R2/cpan/lib/Marpa/R2/meta/metag.bnf
##    -- Artifact as of commit 15fdfc349167808b356c0c2680a54358658318c6.
## See also
## -- Marpa--R2/cpan/lib/Marpa/R2/MetaG.pm

package require marpa
package require char ;# quoting

debug on marpa/slif/symbol
debug on marpa/slif/grammar
debug on marpa/slif/g1/grammar
debug on marpa/slif/l0/grammar
debug on marpa/slif/container
debug on marpa/slif/semantics

# # ## ### ##### ######## #############
## Semantic procedures based on the G1 symbols.
## Variant 2: Create a proper grammar container.

# # ## ### ##### ######## #############
## Read parse result, AST, print

proc B {ast} {
    marpa::slif::container create CONTAINER
    [marpa::slif::semantics new CONTAINER] enter $ast
    # TODO: Dump for bulk load (integrated/native generator)
}

proc EOF {} {}

source [lindex $argv 0]
exit
