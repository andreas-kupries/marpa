[subsection Kettle]
[vset repo.kettle  [uri http://core.tcl.tk/akupries/kettle]]
[vset repo.kettleb [uri https://chiselapp.com/user/andreas_kupries/repository/Kettle]]
[comment {
    Expected variables
    - repo.kettle  : `[uri ...]` of the fossil kettle sources.
    - repo.kettleb : `[uri ...]` of the git kettle sources.
    - p.name       : Name of the project dependent on Kettle.
}]

To build [vset p.name] the tool [syscmd kettle] is required.

[para] [vset p.name]'s build system requires it as an application
found in the [var PATH].

[para] [vset p.name] requires version 1 or higher.

[para] Releases of this tool (and its associated package) can be found
at [vset repo.kettle]. This is a fossil repository.

[para] A mirror of the above repository can be found at
[vset repo.kettleb].  Note that this mirror is also a conversion from
Fossil to Git.

[para] Use of either releases or of the head of the main branch is
recommended. Usage of branches is strongly discouraged as these are
used to work on experimental features and bugfixes of the tool. As
such their stability is not guaranteed.

[para] At the above url is also an explanation on how to build and
install Kettle, including a list of its dependencies.

[para] Its instructions will not be repeated here. If there are
problems with their directions please file a bug against the Kettle
project, and not [vset p.name].
