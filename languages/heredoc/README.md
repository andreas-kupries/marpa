# Marpa Heredoc

A grammar demonstrating parse events (after, stop) and match location
control.

# References

The grammar and the additional code wrapping the core parser to handle
the various events are derived from
[gist jeffreykegler/5431739](https://gist.github.com/jeffreykegler/5431739),
the canonical Marpa::R2 demonstration/example of heredoc processing.

# Installation

   * Install the main marpa packages

   * Invoke `bash tools/make-parser` to generate the heredoc parser
     packages from the SLIF grammar (See `g/`).

   * Use `build.tcl install` to compile and install the parser
     packages.

# Tests
