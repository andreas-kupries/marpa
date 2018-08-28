[subsection Tcllib]
[vset repo.tcllib  [uri https://core.tcl.tk/tcllib/]]
[comment {
    Expected variables
    - repo.tcllib : `[uri ...]` of the tcllib sources.
    - as.teapot   : `[uri ...]` of the ActiveState TEApot
    - p.name      : Name of the project dependent on Tcllib.

    `as.teapot` is resolved easiest by placing the inclusion of this
    file after the inclusion of `rq_tcl.inc`.
}]

To use [vset p.name] a few packages found in the bundle Tcllib are
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
TEApot repository at [vset as.teapot] is in the list of repositories
accessible to [syscmd teacup]. This is automatically ensured for the
ActiveTcl distribution. Others may have to run

[example_begin]
teacup archive add [vset as.teapot]
[example_end]

to make this happen.

[para] Now, for those wishing to install the packages from source, the
fossil repository for the bundle can be found at [vset repo.tcllib].

[para] Releases of Tcllib can be found there as well, or
[syscmd fossil] can be used to check out specific revisions.

[para] Tcllib comes with its own installation instructions.  These
will not be repeated here. If there are problems with its directions
please file a bug against the Tcllib project at the above url, and not
[vset p.name].
