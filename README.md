# Setup

The main file is "marpa.tcl", which includes all the other
marpa-related files in one way or other.

# File groups

* "c_*.tcl" - Direct low-level wrappers around the libmarpa
  functionality.

* "p_*.tcl" - Pieces of higher-level runtime, for assembly into an
  actual parsing engine.

* "s_*.tcl" - Parsing, semantics and support for SLIF grammars.
