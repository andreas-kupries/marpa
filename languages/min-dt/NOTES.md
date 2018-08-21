# Language and parser classes in the example

   1. `mindt::tcl` - Main class based on parsers with Tcl runtime
   1. `mindt::c`   - Ditto, based on parsers with C runtime
   1. `mindt::base` - Shared base class to the above containing the common event handling code.
   1. `mindt::parser::tcl`     - Parser for the main language, Tcl runtime
   1. `mindt::parser::c`       - Ditto, C runtime
   1. `mindt::parser::sf::tcl` - Parser for the special forms, Tcl runtime
   1. `mindt::parser::sf::c`   - Ditto, C runtime

Instances of the last four classes are used as components in the main
classes, configuring the base class with the providers of the ASTs to
process and/or return.
