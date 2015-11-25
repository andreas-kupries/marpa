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

debug on marpa/grammar

# # ## ### ##### ######## #############
## Semantic procedures based on the G1 symbols.
## Variant 2: Create a proper grammar container.

# # ## ### ##### ######## #############
## Read parse result, AST, print

proc B {method args} {
    switch -exact -- $method {
	enter {
	    marpa::grammar create CONTAINER [lindex $args 0]
	    # TODO: Dump for bulk load (integrated/native generator)
	}
	eof {}
    }
}

proc EOF {} {}

source [lindex $argv 0]
exit
