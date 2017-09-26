# System architecture

Layering diagram.

```
       ....marpa-gen.........
       |  |       |         |
semantics | container ~~~~ exporter gc
          |                exporter gc-compact
          |
       parser   ~~~~~~~~~~ exporter tparse
         |     .           exporter tlex
         |    .
         Tcl-RT   RT-C ~~~ exporter rtc-raw
          |   |     |      exporter rtc-critcl
   utilities C-wrap |       |
              |     |       |
              libmarpa     exporter core
```

Currently 5 groups:

* Tcl runtime and support
* C runtime
* SLIF container, sermantics, builtin parser
* Exporter core
* Exporter packages

In diagrams:

* Tcl runtime and support
```
       Tcl-RT
       |   |
utilities C-wrap
```

* C runtime
```
RT-C
```

* SLIF container, sermantics, builtin parser
```
semantics parser container
```

* Exporter core
```
exporter core
```

* Exporter packages
```
exporter gc
exporter gc-compact
exporter tparse
exporter tlex
exporter rtc-raw
exporter rtc-critcl
```

