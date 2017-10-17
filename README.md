# Setup

All the various blocks of related files are collected in their own
directories.

   * Low-level wrapper around libmarpa, bringing the API into the
     script level as is. See `c/`.

   * A parsing runtime implemented in Tcl, on top of the low-level
     wrapper. See `runtime-tcl/`.

   * A parsing runtime implemented in C, on top of libmarpa. This and
     the other runtime share the general architecture, making problems
     in one a problem for the other, and fixes apply to both too. See
     `runtime-c/`.

   * A parser implementing the SLIF meta grammar. See
     `slif-parser`. Generated from the SLIF meta grammar. Currently
     based on the C runtime. Basing it on the Tcl runtime works as
     well, just runs slower. See `slif-parser/`.

   * A container to hold grammars specified via SLIF. See
     `slif-container/`.

   * The semantics to translate a SLIF AST coming out of the
     `slif-parser` into a series of instructions for a
     `slif-container` which stores the grammar encoded in the AST in
     the container. See `slif-semantics/`.

   * Support for generators, technically still part of the SLIF
     support, a package to rewrite a set of precedenced priority rules
     into a new set where the precedences are encoded in the structure
     of the new rules. See `slif-precedence.tcl`.

   * Support for generators, technically still part of the SLIF
     support, a package to rewrite literals into simpler forms
     (normalization and reduction). Former keeps literal-ness, latter
     can break literals apart into sets of rules. See
     `slif-literal.tcl`.

   * Configuration and dispatcher core for code generators. See
     `gen.tcl`.

   * Several code generator packages accessible from the generator
     core. See `gen-formats/`. The code generators are able to
     generate parsers and lexers using either Tcl or C runtime, and
     pre-loaded containers, readable and compact.

   * Several packages shared between code generators. See
     `gen-common/`.

   * General utility package. See `util/`.

   * Utility package specific to unicode functionality. See
     `unicode/`.

   * Supporting code to ingest unicode data tables, and the tables we
     use. See `tools/` and `unidata/`.

   * The SLIF meta grammar and tools to regenerate the
     `marpa-slif-parser/`. See `bootstrap/`.

   * A generator application using all the pieces. See `bin/`.

   * Tests. See `tests/`.

   * Documentation. See `doc/` and `doc.1/`. This part is in need of
     cleanup and proper writeup.

   * Manual benchmarks in `bench/` (Not based on tclbench, tough they
     should be made to).

After building the marpa package a directory `generated` will contain
the output of the `tools` on the `unidata` tables. This is a cache
directory which can be blown away, the build will regenerate it as
needed. The information in the files becomes part of the `unicode`
package.

