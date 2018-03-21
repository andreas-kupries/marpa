
[subsection CriTcl]

To build Marpa/Tcl the tool [syscmd critcl] is required.

[para] Marpa/Tcl's build system (based on [sectref Kettle]) accepts it
either as an application found in the PATH (be it starkit or
starpack), or as a Tcl package available to the [syscmd tclsh] used to
run their build & installation processes.

[para] Marpa/Tcl requires version 3 or higher.

[para] The github repository providing releases of version 3 and
higher, and the associated sources, can be found at
[uri http://andreas-kupries.github.com/critcl].

[para] Any branch of the repository can be used (if not using the
prebuild starkit or starpack), although the use of the stable branch
[emph master] is recommended.

[para] At the above url is also an explanation on how to build and
install CriTcl, including a list of its dependencies.

[para] Its instructions will not be repeated here. If there are
problems with their directions please file a bug against the critcl
project, and not Marpa/Tcl.
