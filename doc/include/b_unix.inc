[subsection {Build & Installation (Unix)}]

This section describes the actions required to install Marpa/Tcl on
Unix systems (Linux, BSD, and related, including OS X).

If you have to install Marpa/Tcl on a Windows machine see section
[sectref {Build & Installation (Windows)}] instead.

[para] To install Marpa/Tcl simply run

[example {
    /path/to/tclsh8.5 /path/to/marpatcl/build.tcl install
}]

where [file /path/to/tclsh8.5] is the tclsh of your Tcl installation,
and [file /path/to/marpatcl] the location of the Marpa/Tcl sources on
your system.

[comment { -- Check dependency on working directory!
	-- -- Can we do this inside and outside the Marpa/Tcl sources ?
}]

[para]

This builds all packages and then places them in a directory where the
[cmd tclsh8.5] will find them. 

[para]

The build system provides a small GUI for those not comfortable with
the command line.

This GUI is accessible by invoking [file build.tcl] without any
arguments.

[para]

To get help about the methods of [file build.tcl], and their complete
syntax, invoke [file build.tcl] with the argument [method help], i.e.,
like

[example {
    /path/to/tclsh8.5 /path/to/marpa/tcl/build.tcl help
}]
