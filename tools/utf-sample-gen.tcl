#!/usr/bin/env tclsh
package require Tcl 8.5

# Print a sample text containing a variety of multi-byte characters in
# a sea of ASCII. The text is actually a SLIF. The multi-byte
# characters will be in the comments. The point of their presence is
# their effect on lexeme locations, i.e. that both runtimes track
# characters properly.

lappend lines "# See [info script] for the code which generated this file"
lappend lines "lexeme default = latm => 1 action => \[value]"
lappend lines "# Plain ASCII: A"
lappend lines ":default ::= action => \[values]"
lappend lines "# UTF-8 2 byte: \u00A9 (extended latin - copyright sign)"
lappend lines "Code ::= A B"
lappend lines "# UTF-8 3 byte: \u21BA (arrows - ccw)"
lappend lines "A ~ 'A'"
lappend lines "B ~ 'B'"

puts [join $lines \n]
exit
