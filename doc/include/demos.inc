[comment { XXX --- Within the marpa/tcl source directory run it as

[section "Playing with [vset p.name]"]

For a demonstration of [vset p.name]'s current abilities see ... XXX.

[example {
    tclsh8.5 demos.tcl
}]

or

[example {
    tclsh8.5 demos.tcl /path/to/marpatcl/packages ...
}]

XXX description of the demo

--- }]

[comment { XXX --- ---

[comment =====================================================================]
[def {Demonstration Application and Framework}]

[list_begin definitions]
[def [file demos.tcl]]

This is the demo application & framework.

[def [file demos/]]

This directory is searched by [file demos.tcl] for the demonstrations to make
available to its user. See [sectref {Writing a new demo}] for information on the
structure of a demonstration.

[def [file images/]]

This directory is searched by [file demos.tcl] for the images to make
available to its user and the demos. See [sectref {Adding a new demo image}]
for more information.

[list_end]

}]
