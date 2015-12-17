
l0-symbol {
    is:       enum (class,char,rule)
    rules:    set
    rtype:    enum (none, bnf, quant)

    discard:  bool
    toplevel: bool

    events:   set
    pause:    enum(no, before, after)
    priority: int (0)
}

g1-symbol {
    rules: set
    rtype: enum (none, bnf, quant)
    leaf:  bool
}

rule {
    type: enum (bnf, quant)
}
rule:bnf {
    rhs:  array symbols
}
rule:qant {
    rhs:       symbol
    proper:    bool
    separator: symbol
}
rule:bnf:g1 {
    mask: array bool
}
