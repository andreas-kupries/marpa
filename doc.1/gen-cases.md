# Marpa Parser Generator Use Cases

## Tcl

Export `tparse`, `tlex`. Result is a single-file Tcl package requiring the Tcl engine/runtime.

==> Tcl engine runtime has to exist as Tcl package.

## Tcl 2

Export `gc`, `gc-compact`. Result is single file Tcl package declaring
a grammar container holding the grammar in question. Use requires
conversion via `tparse`, `tlex`.

## C - Critcl

Export `cparse-critcl`, `clex-critcl`. Result is a single
(critcl-based) Tcl+C package using the C engine/runtime.

The generated file currently accesses the RTC directly
(critcl::{cheaders,csources}).

==> Put the RTC engine into a Tcl C extension which exports the
    necessary functions via stubs.

    Have the generated parsers import this package and stubs.

## C - Raw

Export `cparse-raw`. Result is a single C file dependend on the C
runtime but without dependencies on Tcl (with a proper environment.h
header file for the runtime).

=> It either has to be compiled with the runtime statically built into
   it, or link to a shared library form of the runtime without Tcl
   dependencies.
