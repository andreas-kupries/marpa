[list_begin definitions][comment {___1___}]

[comment =====================================================================]
[def Helpers]

[list_begin definitions]
[def [file tools/]]

	This directory contains helper scripts.

[def [file tools/utf-viewer.tcl]]

	This helper reads a file containing UTF-8 encoded unicode text
	and prints the contents in decoded form, especially showing
	the construction of multi-byte characters.

[def [file tools/unidata.tcl]]

	This helper reads the unicode tables stored in directory
	[file unidata/] and generates a mix of Tcl and C data
	structures for use within [vset p.name].

	The integration point is package [package marpa::unicode]
	(directory [file unicode/]).

[def [file generated/]]

	The directory where [file tools/unidata.tcl] places the
	generated files.

[def [file unidata/]]

	The directory where [file tools/unidata.tcl] reads the unicode
	tables from.

[def [file bootstrap/]]

	This directory contains the specifications for SLIF and
	literal grammars, and the helpers needed to regenerate their
	parsers.

[def [file bootstrap/marpa-tcl-slif/slif]]

	SLIF specification of the SLIF grammar.

[def [file bootstrap/marpa-tcl-slif/literal]]

	SLIF specification of the Literal grammar.

[def [file bootstrap/remeta]]
[def [file bootstrap/remeta-tcl]]

	These helper applications regenerate the SLIF and literal
	parsers from their grammars.  The first variant generates
	C-based parsers, the other Tcl-based parsers.

[list_end]

[comment =====================================================================]
[def Documentation]

[list_begin definitions]
[def [file doc/]]

	This directory contains the documentation sources. The texts
	are written in [term doctools] format, whereas the figures are
	written in tklib's [package dia](gram) package and
	application.

[def [file embedded/]]

	This directory contains the documentation converted to regular
	manpages (nroff) and HTML.

[para]	It is called [term embedded] because these files, while derived, are
	part of the fossil repository, i.e. embedded into it. This
	enables fossil to access and display these files when serving
	the repositories' web interface.  The "Command Reference" link
	at

	[vset repo.main]

	is, for example, accessing the generated HTML.

[list_end]

[comment =====================================================================]
[def Examples]

[list_begin definitions]
[def [file languages/]]

	This directory contains several worked examples of SLIF
	grammars for various languages, parsers generated for them,
	and the infrastructure to build and test them.

[para]	Each example resides in its own subdirectory, named after the
	language it implements a parser for.

[para]	We currently have examples for

	[list_begin enumerated]
	[enum] [uri http://json.org JSON]
	[enum] (Tcllib) doctools
	[enum] heredoc
	[enum] min-dt
	[list_end]

[para]	[term Heredoc] is a general demonstration how `here` documents
	can be implemented using stop markers and post-lexeme events.

[para]	[term min-dt] is a reduced form of [term doctools], used to
	work out the general shape of vset and include processing via
	stop markers and lexeme events

[list_end]

[comment =====================================================================]
[def {Package Code, General structure}]

[list_begin definitions]

[def [file c/]]

	Files for the [package marpa::c] package.

	It provides a very thin class-based wrapper around the data
	structures of [package libmarpa].

	The entrypoint is [file marpa_c.tcl].

[def [file gen-common/]]

	The implementations of

	[list_begin enumerated]
	[enum] [package marpa::gen::runtime::c],
	[enum] [package marpa::gen::runtime::tcl],
	[enum] [package marpa::gen::remask], and
	[enum] [package marpa::gen::reformat]
	[list_end]

	The first two provide the shared code for the main generator
	packages handling creation of parsers and lexers for Tcl and C
	runtimes. The other two are also shared code, at a lower
	level.

[def [file gen-format/]]

	The main generator package, all placed under the namespace
	[const marpa::gen::format].

	[list_begin definitions]
	[def [package clex-critcl]]	Lexer using the C runtime, embedded into Tcl via [package critcl].
	[def [package cparse-critcl]]	Parser using the C runtime, embedded into Tcl via [package critcl].
	[def [package cparse-raw]]	Parser using the C runtime, raw C, no embedding.
	[def [package gc-compact]]	See [package gc], minimal whitespace.
	[def [package gc-c]]		See [package gc], reduced as if targeted at the C runtime.
	[def [package gc-tcl]]		See [package gc], reduced as if targeted at the Tcl runtime.
	[def [package gc]]		Container serialization as nested Tcl dictionary.
	[def [package slif]]		Reconstructed SLIF.
	[def [package tlex]]		Lexer using the Tcl runtime.
	[def [package tparse]]		Parser using the Tcl runtime.
	[list_end]

[def [file runtime-c/]]

	Files for the [package marpa::runtime::c] package.

	The entrypoint is [file marpa_runtime_c.tcl].

[para]	Note that the two runtimes have very similar internal
	architecture.

[def [file runtime-tcl/]]

	Files for the [package marpa::runtime::tcl] package.

	The entrypoint is [file pkg_entry.tcl].

[para]	Note that the two runtimes have very similar internal
	architecture.

[def [file slif-container/]]

	SLIF grammar support.

	Provides the package [package marpa::slif::container], to hold
	parsed grammars.

	The entrypoint is [file pkg_entry.tcl].

[def [file slif-literal/]]

	SLIF grammar support.

	Provides the packages
	[list_begin enumerated]
	[enum] [package marpa::slif::literal::parser]
	[enum] [package marpa::slif::literal::norm]
	[enum] [package marpa::slif::literal::parse]
	[enum] [package marpa::slif::literal::reduce::2c4tcl]
	[enum] [package marpa::slif::literal::reduce::2tcl]
	[enum] [package marpa::slif::literal::redux]
	[enum] [package marpa::slif::literal::util]
	[list_end]

	These are helper packages dealing with literals, from parsing
	over normalization to backend-specific reduction.

	The parser core is generated from a SLIF specification.

[def [file slif-parser/]]

	SLIF grammar support.

	Provides the package [package marpa::slif::parser], to
	translate SLIF text into an abstract syntax tree (AST).

	The entrypoint is [file pkg_entry.tcl].

[para]	[emph Note:] This parser is generated from a SLIF text itself,
	and can be used to bootstrap further changes to the SLIF
	specification.

[def [file slif-precedence.tcl]]

	SLIF grammar support.

	Provides the package [package marpa::slif::precedence].

	This is a helper package containing the algorithm used to
	rewrite a set of grammar rules with precedence into an
	equivalent set of rules without.

[def [file slif-semantics/]]

	SLIF grammar support.

	Provides the package [package marpa::slif::semantics], to
	translate grammars represented by an AST (parse result) into a
	container.

	The entrypoint is [file pkg_entry.tcl].

[def [file unicode/]]

	The files for package [package marpa::unicode].

	This package also includes the files under [file generated/].

	If such files do not exist at build time the
	[file tools/unidata.tcl] helper is automatically invoked to
	generate them.

[def [file util/]]

	Files for the [package marpa::util] package, a set of general
	utilities.

	The entrypoint is [file pkg_entry.tcl].

[list_end]
[list_end]
