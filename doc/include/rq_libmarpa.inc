[subsection Libmarpa]
[comment {
    Expected variables
    - p.name      : Name of the project dependent on libmarpa.
}]

This C library is the foundation of [vset p.name], providing the parser
engine we bind to.

[para] The instructions for its installation, including the retrieval
of its sources, can be found at [vset marpa.lib].

[para] As we are only interested in the library itself installation of
the [package Marpa::R2] Perl binding is not necessary. [vset p.name]
also comes with its own testsuite.

[para] Regarding packages for the various Linux distributions which
would make installation more convenient, I have currently only
found/seen:

[list_begin definitions]
[def Ubuntu]
	[package libmarpa-r2-perl] is the Perl binding I mentioned
	above. Based on the set of installed files I believe that
	libmarpa is part of the shared library for the binding itself,
	and not installed as a separate binary.
[list_end]
