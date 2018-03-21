
[subsection Tcllib]

To use Marpa/Tcl a few packages found in the bundle Tcllib are
required. These packages are:

[list_begin enumerated]
[enum]	debug
[enum]	debug::caller
[enum]	oo::util
[enum]	lambda
[enum]	try
[enum]	fileutil
[list_end]

[para] Assuming that ActiveTcl is installed, or some other Tcl
installation with [syscmd teacup] available, these packages can
be installed via

[example {
    teacup install $packagename
}]

[para] The [syscmd teacup] command above assumes that ActiveState's
TEApot repository at [uri http://teapot.activestate.com] is in the
list of repositories accessible to [syscmd teacup]. This is automatically
ensured for the ActiveTcl distribution. Others may have to run

[example {
    teacup archive add http://teapot.activestate.com
}]

to make this happen.

[para] Now, for those wishing to install the packages from source, the
fossil repository for the bundle can be found at
[uri https://core.tcl.tk/tcllib].

[para] Releases of Tcllib can be found there as well, or
[syscmd fossil] can be used to check out specific revisions.

[para] Tcllib comes with its own installation instructions.  These
will not be repeated here. If there are problems with its directions
please file a bug against the Tcllib project at the above url, and not
Marpa/Tcl.
