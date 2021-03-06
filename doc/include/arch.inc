
The system can be split into roughly six sections, as seen in the
figure below. The seventh, highlighted in green, is [package libmarpa]
itself, which is technically outside of the system.

[para][image architecture][para]

In more detail:

[list_begin definitions]
[def Applications]

At the top we have the [cmd marpa-gen] application. It integrates and
uses all of the packages to provide a parser generator reading
grammars specified using SLIF and producing results in a variety of
formats.

[def SLIF]

The packages supporting the SLIF language for grammar specifications.
This is a very close sibling to the SLIF language used by
[vset marpa.r2], the current stable version of the Perl binding.

[para] It can be further divided into groups for parsing SLIF, the
semantics for translating a parse into a container, a container for
SLIF grammars, and the processing of literals (strings and character
classes).

[def Generators]

The packages for producing a variety of formats from a SLIF grammar
container. Further divided into serialization of containers as Tcl
code, parsers and lexers based on the Tcl and C runtimes, and
reconstruction of SLIF from a container.

[def rt-Tcl]

The package [package marpa::runtime::tcl]. It implements a parse
engine in Tcl. This uses [package marpa::c], which is a thin wrapper
around [package libmarpa].

[def rt-C]

The package [package marpa::runtime::c]. It implements a parse engine
in C, directly on top of [package libmarpa], without wrappers.

[def {Unicode data and utilities}]

The [package marpa::unicode] package. It provides access to named
character classes, case folding, de- and encoding codepoints to
various representations, character class operations, etc.

[def libmarpa]

Jeffrey Kegler's base library implementing an Earley parser which has
the fixes by John Aycock, Nigel Horspool and Joop Leo. This is the
foundation for the rest of the system.

[list_end]

The package dependencies are a bit large, and will be shown
per-section, in the documentation of each section.

[list_begin enum]
[enum] [vset xr:app].
[enum] [vset xr:slif].
[enum] [vset xr:gen].
[enum] [vset xr:rtt].
[enum] [vset xr:rtc].
[enum] [vset xr:uni].
[list_end]
