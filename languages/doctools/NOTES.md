# Language and parser classes in the example

   1. `doctools::tcl`  - Main class based on parsers with Tcl runtime
   1. `doctools::c`    - Ditto, based on parsers with C runtime
   1. `doctools::base` - Shared base class to the above containing the common event handling code.

   1. `doctools::parser::tcl`     - Parser for the main language, Tcl runtime
   1. `doctools::parser::c`       - Ditto, C runtime
   1. `doctools::parser::sf::tcl` - Parser for the special forms, Tcl runtime
   1. `doctools::parser::sf::c`   - Ditto, C runtime

Instances of the last four classes are used as components in the main
classes, configuring the base class with the providers of the ASTs to
process and/or return.
