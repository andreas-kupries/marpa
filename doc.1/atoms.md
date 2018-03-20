# Lexical and structural atoms in Marpa/Tcl

## G1, structural

 1. Terminals are the atoms of the G1 grammar.
 1. Terminals do not have any arguments.

## L0, lexical

The SLIF grammar supports two forms of literals, strings and character
classes, both in regular and case-insensitive forms. Regarding
character classes it further supports normal and negated classes.

Unfortunately the [SLIF description](https://metacpan.org/pod/Marpa::R2::Scanless::DSL#Character-classes) then only says 

```
	Marpa character classes may contain anything acceptable to
	Perl, and follow the same escaping conventions as Perl's
	character classes.
```

which is not really useful to a Tcl binding, nor to a generator for an
engine which does not have the Perl or Tcl or other language runtime
available to implement character classes.

The meta-grammar found in the Marpa::R2 repository provides a bit more
clarity, allowing for positive and negative posix charclasses, and a
set of safe characters which are all but

\n, \v, \f, \r , ], \u0085, \u2028, \u2029
(lf, vt, ff, cr, closing bracket, ...)

As `^` is a safe character, plus the description we can assume that megated character-classes are supported as well.

This allows for [^[:^foo:]]:i, i.e. a negated char-class of a
case-insensitive negated posix class. Well, if Perl's RE engine allows
that.

It feels to complicated to me.

Decision: Marpa/Tcl's SLIF grammar excludes negated named
classes. Only one negation is possible, at the outer level of a class
itself. Element negation is not supported.

Regardless, the SLIF grammar itself gives rise to six atom types (2
string, 4 class), and their elements give rise to another six
(characters, ranges, named classes times regular and
case-insensitive).

Which of these particular engine implements is another matter. At
worst only character (or byte) is supported, and all other types have
to be reduced to that, using priority rules for sequencing (strings)
and alternation (classes).

Implied in the above description, it was decided to encode the
information about negation and case-insensitivity in the type
names. The prefix `%` is used to denote case-insensitivity, whereas
the prefix `^` denotes class negation. Where both apply `^%` is used.

| Id  | Type          | Description                                                           |
|-----|---------------|-----------------------------------------------------------------------|
| L00 | %character    | A set of case-equivalent characters, a special form of class          |
| L01 | %charclass    | As above, using case-equivalent elements                              |
| L02 | %named-class  | Ditto, expanded by case-equivalence                                   |
| L03 | %range        | Range of case-equivalent characters                                   |
| L04 | %string       | Sequence of case-equivalent characters                                |
| L05 | ^%character   | A negated set of case-equivalent characters, a special form of class  |
| L06 | ^%charclass   | Negated form of %charclass                                            |
| L07 | ^%named-class | Negated form of ^%charclass                                           |
| L08 | ^%range       | Negated range of case-equivalent character                            |
| L09 | ^character    | A negated character, a special form of class                          |
| L10 | ^charclass    | Negated form of charclass                                             |
| L11 | ^named-class  | Negated form of ^charclass                                            |
| L12 | ^range        | Negated range of characters                                           |
| L13 | character     | A single character (unicode codepoint)                                |
| L14 | charclass     | A set of characters, character ranges, and named classes              |
| L15 | named-class   | Name of a predefined (unicode) character class                        |
| L16 | range         | Range of characters (2 codepoints, low to high, inclusive)            |
| L17 | string        | Sequence of characters                                                |

Note how the description given in the table is useful as a guide on
how the various composites can be deconstructed and converted to smaller types.


For some of these it does not make sense to store them, like
`%character`. Others however may be supported by directly by an
engine, and should therefore be stored as is. An example of this are
all the forms of `named-class`.

### Symbols and normalization of literals

The symbols used to name literals are derived from their internal
representions. To ensure that equivalent literals have the same symbol
the internal representations of literals are normalized before
computing the symbol.

Both representations and normalization will be described in detail in
the next two sections.

Here we will note that the literal type is coded as a prefix of the
full symbol name, using a shorter label for the type in general, and
the same tag prefixes for case-insensitivity and class negation.

| Type          | Symbol |
|---------------|--------|
| character     | @CHR   |
| charclass     | @CLS   |
| named-class   | @NCC   |
| range         | @RAN   |
| string        | @STR   |

## Literal representations

This sections describes the representations for the various literal types in detail.

Note that the representations do not differ between the various forms
of a base type. In other words, the modifiers for case-insensitivity
and class negation have (mostly) no effect on the representation. They
are important during normalization however.

| Type          | Representation                                                                    |
|---------------|-----------------------------------------------------------------------------------|
| character     | The unicode codepoint of the character, as decimal integer. (1)                   |
| charclass     | A list of codepoints, 2-element lists of codepoints (ranges), and class names (2) |
| named-class   | The name of the predefined class                                                  |
| range         | Two unicode codepoints, for the low and high borders of the range (inclusive)     |
| string        | A list of unicode codepoints, as decimal integers (1)                             |

Footnote 1: For case-equivalence the primary codepoint is used, which
	    is the codepoint with minimal numeric value in the set of
	    characters equivalent to the user-chosen character.

Footnote 2: The representation has codepoints and ranges maximally
	    merged, i.e overlapping and adjacent ranges become one,
	    with singular codepoints treated as a 1-element range for
	    this purpose.

	    While this could be treated as part of normalization it is
	    done before, as part of creating the representation. This
	    makes normalization easier to specify.

### Normalization of literal representations.

The following table describes the normalization rules for literal
representations. Note that application of a rule may create a
representation to which more rules can be applied. Normalization ends
when encountering a rule with action STOP, or no rule can be applied
anymore.

Note, the action `TO x` means to convert the representation to the new
type, using the existing information. This __creates__ a new
representation of the new type which then is normalized further. This
is important with regard to footnote 2 of the previous section.

Note further that all of the transformations do not increase the
number of literals we are dealing with. We begin and end with a single
literal. The transformations actually breaking a literal into several
simpler pieces glued back together by priority rules are not part of
the normalization. They are invoked by generators to ensure that a
grammar contains only the type of literal directly supported by the
engine they are emitting code for. See next section for details.

| Type          | Rule  | Activation conditions | Action, Result        | More |
|---------------|-------|-----------------------|-----------------------|------|
| string        | N01   | length == 1           | TO character          | N21
| string        | N02   | *                     | STOP                  |
| %string       | N03   | length == 1           | TO %character         | N22
| %string       | N04   | *                     | STOP                  |
| charclass     | N05   | size==1, character    | TO character          | N21
| charclass     | N06   | size==1, range        | TO range              | N26
| charclass     | N07   | size==1, named-class  | TO named-class        | name/N31, %name/N32
| charclass     | N08   | *                     | STOP                  |
| %charclass    | N09   | size==1, character    | TO %character         | N22
| %charclass    | N10   | size==1, range        | TO %range             | N28
| %charclass    | N11   | size==1, named-class  | TO %named-class       | N35
| %charclass    | N12   | *                     | TO charclass (1)      | N05,N06,N08(%name)
| ^charclass    | N13   | size==1, character    | TO ^character         | N23
| ^charclass    | N14   | size==1, range        | TO ^range             | N29
| ^charclass    | N15   | size==1, named-class  | TO ^named-class       | N39
| ^charclass    | N16   | *                     | STOP                  |
| ^%charclass   | N17   | size==1, character    | TO ^%character        | N24
| ^%charclass   | N18   | size==1, range        | TO ^%range            | N30
| ^%charclass   | N19   | size==1, named-class  | TO ^%named-class      | name/N43
| ^%charclass   | N20   | *                     | TO ^charclass (1)     | N16

| character     | N21   | *                     | STOP                  |
| %character    | N22   | *                     | TO charclass          | N07,08
| ^character    | N23   | *                     | STOP                  |
| ^%character   | N24   | *                     | TO ^charclass (chars-only) |
| range         | N25   | size==1               | TO character          |
| range         | N26   | *                     | STOP                  |

| %range        | N28   | *                     | TO charclass (1)      |
| ^range        | N29   | *                     | STOP                  |
| ^%range       | N30   | *                     | TO ^charclass (1)     |
| named-class   | N31   | name                  | STOP                  |
| named-class   | N32   | %name                 | TO %named-class/name  |
| named-class   | N33   | ^name                 | FAIL                  |
| named-class   | N34   | ^%name                | FAIL                  |
| %named-class  | N35   | name                  | STOP                  |
| %named-class  | N36   | %name                 | TO %named-class/name  |
| %named-class  | N37   | ^name                 | FAIL                  |
| %named-class  | N38   | ^%name                | FAIL                  |
| ^named-class  | N39   | name                  | STOP                  |
| ^named-class  | N40   | %name                 | TO ^%named-class/name |
| ^named-class  | N41   | ^name                 | FAIL                  |
| ^named-class  | N42   | ^%name                | FAIL                  |
| ^%named-class | N43   | name                  | STOP                  |
| ^%named-class | N44   | %name                 | TO ^%named-class/name |
| ^%named-class | N45   | ^name                 | FAIL                  |
| ^%named-class | N46   | ^%name                | FAIL                  |

| byte          | N47   | *                     | STOP                  |
| brange        | N48   | *                     | STOP                  |

(N27 removed, redundant, charclass will handle it)

Footnote 1: While using a primary codepoint to store single characters
	    is good enough this does not hold water for
	    ranges. I.e. we cannot be sure that case-expanding the
	    range as specified gives us the same set as case-expanding
	    the range from the primary codepoints of the original
	    borders.

	    Instead we fully case-expand and store as plain
	    charclass. As we don't (2) expand the named classes we
	    push the %-tag into them instead as normalization.

Footnote 2: We want to keep at least these as highlevel definitions,
	    should the backend support them directly in some way.


## Reduction

This can be thought of as normalization phase II.

Where phase I rewrites a literal while keeping it as a single entity
this phase is allowed and expected to break a literal into pieces and
glue them back together using priority rules to keep the semantics of
it.

It is a separate phase because the decision for or against breaking a
literal is very much dependent on what types of literals are supported
by the engine which we have chosen to generate code for from the
grammar. For example, if the target engine supports the direct
matching of strings then there is no need to break them into a
sequences of characters. Otherwise we have to.

Now, while strings are usually not directly supported, char classes
can be. An example of that is the Tcl lexer engine currently used in
the boot strap, as likely is the Perl engine in Marpa::R2. With some
limitations however, because Tcl does not support the majority of
named unicode character classes, only a small subset. That means that
the decision for or against reduction is not just type- but also
content-dependent, i.e. depends on the literal as a whole. The same
can be true of other engines. Even more complex, the choice of machine
not only determines which literals to break, it may also determine how
to break it. For example a byte-based engine is better served with
handling all char-classes as an ASBR or derived grammar, whereas a
character based engine has no other way than using a large alternation
of such. And an engine supporting classes only in part should only
break off the unsupported pieces, and for these work towards
constructing pieces which are supported, to keep things at as high a
level as possible.

On the other end of the spectrum is the planned C engine to wrap
around libmarpa. This engine would support only bytes and therefore
everything, including all char classes will have to be rendered down
to that level.

As such, matching of single `bytes` is the absolute minimum any engine
must support, with a secondary of supporting only single `characters`.

In the rules following note that we can presume normalized literals,
i.e. we will not see a `string` of length of 1, we will see
`character`, etc. That simplifies the rule-set. We can further presume
that the newly created smaller literals are normalized as well, before
being checked for further reduction. Multiple rules for a type
indicate alternative ways of breaking the literal, with the generator
having to choose which fits it best.

Lastly, the table gives the full set of deconstruction rules,
independent of engines and possible conflicts. Each generator has to
choose the applicable subset, and is its responsibility to choose
something sensible. Note, every type has a __`K`__ rule, keeping the
literals of that type as they are. These are not listed explicitly.

| Type          | Rule     | Action, Result |
|---------------|----------|-------------------------------------------------------|
| string        | D-STR1   | Sequence of `character`                               |
| string        | D-STR2   | Sequence of `byte`                                    |
| %string       | D-%STR   | Sequence of `%character`                              |
| charclass     | D-CLS1   | Alternation of elements                               |
| charclass     | D-CLS2   | ASBR                                                  |
| charclass     | D-CLS3   | Alternation non-Tcl NCC split of, remainder direct    |
| ^charclass    | D-^CLS1  | `charclass` (expanded named-classes, merged, negated) |
| ^charclass    | D-^CLS2  | See D-CLS3, for negated		  	  	   |
| named-class   | D-NCC1   | Alternation of `range` (one!, or more)                |
| named-class   | D-NCC2   | ASBR                                                  |
| named-class   | D-NCC3   | Tcl supported KEEP, else charclass of ranges          |
| %named-class  | D-%NCC1  | `charclass` (definition expanded)                     |
| %named-class  | D-%NCC2  | ASBR (definition expanded)                            |
| ^named-class  | D-^NCC1  | `charclass` (negated definition)                      |
| ^named-class  | D-^NCC2  | See D-NCC3, for negated                               |
| ^%named-class | D-^%NCC1 | `charclass` (def expanded negated)                    |
| ^%named-class | D-^%NCC2 | ASBR (definition expanded, negated (1))               |
| range         | D-RAN1   | Alternation of `character`                            |
| range         | D-RAN2   | ASBR                                                  |
| %range        | D-%RAN   | `charclass` (expanded)                                |
| ^range        | D-^RAN1  | `charclass` (two sub ranges)                          |
| ^range        | D-^RAN2  | ASBR                                                  |
| character     | D-CHR    | Sequence of `byte`                                    |
| ^character    | D-^CHR   | `charclass` (two sub ranges)                          |

Footnote 1: Does it make sense to precompute these ? (p_unidata is
	    already 740K, adding the three other combinations should
	    quadruple it, roughly (have not checked how much of the
	    file is CC, vs the case-equivalence information))

| #  | Rule 1  | Rule 2   | Rule 3   | Rule 4  | Rule 5	 |
|---:|---------|----------|----------|---------|---------|
|  1 | K-STR   | D-STR1   | D-STR2   |         |	 |
|  2 | K-%STR  | D-%STR	  |	     |	       |	 |
|  3 | K-CLS   | D-CLS1	  | D-CLS2   | D-CLS3  |	 |
|  4 | K-^CLS  | D-^CLS1  | D-^CLS2  |	       |	 |
|  5 | K-NCC   | D-NCC1	  | D-NCC2   | D-NCC3  |         |
|  6 | K-%NCC  | D-%NCC1  | D-%NCC2  |	       |	 |
|  7 | K-^NCC  | D-^NCC1  | D-^NCC2  |	       |	 |
|  8 | K-^%NCC | D-^%NCC1 | D-^%NCC2 | 	       |	 |
|  9 | K-RAN   | D-RAN1   | D-RAN2   |	       |	 |
| 10 | K-%RAN  | D-%RAN	  |	     |	       |	 |
| 11 | K-^RAN  | D-^RAN1  | D-^RAN2  |	       |	 |
| 12 | K-CHR   | D-CHR	  |	     |	       |	 |
| 13 | K-^CHR  | D-^CHR	  |	     |	       |	 |
