
The currently available output types are

[list_begin definitions]

[def clex-critcl]

Generate a lexer written in C and embedded into Tcl via [package critcl].

The grammar is rewritten to handle charactres beyond the unicode BMP
via CESU-8, i.e. UTF-8 encoded pairs of surrogate characters, to match
Tcl.

The structural rules of the input grammar are ignored.

See also [const tlex].

[def cparse-critcl]

Generate a parser written in C and embedded into Tcl via [package critcl].

The grammar is rewritten to handle charactres beyond the unicode BMP
via CESU-8, i.e. UTF-8 encoded pairs of surrogate characters, to match
Tcl.

[def cparse-raw]

Generate a parser written in C, without any embedding.

The grammar is rewritten to handle the unicode SMP via normal UTF-8
encoding, i.e. as sequences of 4 bytes.

[def gc]

Generates Tcl code which initializes a
[package marpa::slif::container] with the serialization of the input
grammar.

[def gc-c]

As [const gc] above, with the grammar rewritten like is done for
[const cparse-critcl], and [const clex-critcl].

[def gc-compact]

As [const gc] above, with all superfluous whitespace removed.

[def gc-tcl]

As [const gc] above, with the grammar rewritten like is done for
[const tparse] and [const tlex].

[def slif]

Generate a SLIF grammar.

Defaults from the input are resolved.

Rules are sorted, and reformatted (pretty printed).

[def tlex]

Generate a lexer written in Tcl.

The structural rules of the input grammar are ignored.

See also [const clex-critcl].

[def tparse]

Generate a parser written in Tcl.

[list_end]
