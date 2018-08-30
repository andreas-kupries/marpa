[subsection Tcl]
[vset repo.tcl    [uri http://core.tcl.tk/tcl/]]
[vset as.main     [uri http://www.activestate.com ActiveState]]
[vset as.teapot   [uri http://teapot.activestate.com]]
[vset as.at       [uri http://www.activestate.com/activetcl]]
[comment {
    Expected variables
    - p.name    : Name of the project dependent on Tcl.
    - repo.tcl  : `[uri ...]` of the Tcl sources.
    - as.teapot : `[uri ...]` of the ActiveState TEApot
    - as.main   : `[uri ...]` of the ActiveState main site.
    - as.at     : `[uri ...]` of the ActiveState ActiveTcl site.
}]

As we are building a set of Tcl packages it should be pretty much
obvious that a working Tcl installation is needed, and I will not
belabor the point.

[para] Out of the many use whatever you are comfortable with, as long
as it provides Tcl 8.5, or higher.

[para] This may be a Tcl installation provided by your operating
system distribution, from a distribution-independent vendor, or built
by yourself.

[para] Myself, I used [vset as.main]'s ActiveTcl 8.5 distribution
during development of the binding, as I am most familiar with it.

[para] [emph {(Disclosure: I, Andreas Kupries, worked for ActiveState, and maintained ActiveTcl and TclDevKit for them).}]

[para] This distribution can be found at [vset as.at]. Retrieve the
archive of ActiveTcl 8.5 for your platform and install it as directed
by ActiveState.

[para] Assuming that ActiveTcl got installed I usually run the command

[example {
    teacup update
}]

to install all packages ActiveState provides, and the kitchensink, as
the distribution itself usually contains only the most important set
of packages. This ensures that the dependencies for [sectref CriTcl],
and [vset p.name] are all present, and more.

[para] If that is not your liking you have to read the sections for
[sectref CriTcl], and [vset p.name] to determine the exact set of
packages required, and install only these using

[example {
    teacup install $packagename
}]

[para] Both [syscmd teacup] commands above assume that ActiveState's
TEApot repository at [vset as.teapot] is in the list of repositories
accessible to [syscmd teacup]. This is automatically ensured for the
ActiveTcl distribution. Others may have to run

[example_begin]
    teacup archive add [vset as.teapot]
[example_end]

to make this happen.

[para] For those wishing to build Tcl on their own, its sources can be
found at

[list_begin definitions]
[def Tcl] [vset repo.tcl]
[list_end]
