# Match state access (control)

## Access methods, argument validation

|Method|Argument types|
|---|---|
|location?	|n/a|
|---||
|moveto		|location	|
|moveby		|int		|
|(rewind)	|int		|
|stop-at	|location	|
|limit		|pos.int	|
|---||
|symbols	|n/a|
|sv		|n/a|
|start		|n/a|
|length		|n/a|
|value		|n/a|
|values		|n/a|
|---||
|symbols:	|lexeme names	|
|sv:		|any		|
|start:		|location	|
|length:	|pos.int	|
|value:		|any		|
|values:	|any		|
|---||
|alternate	|lexeme & any	|
|---||
|view		|n/a|

## Access control

General control: Not allowed to be called outside of an event handler,
i.e. when no event is active.

|Method|Stop|Discard|Before|After|Predicted|Completed|Nulled|
|---|---|---|---|---|---|---|---|
|location	|*|*|*|*|*|*|*|
|stop		|*|*|*|*|*|*|*|
|---|---|---|---|---|---|---|---|
|from		|*|*|*|*|-|-|-|
|relative	|*|*|*|*|-|-|-|
|(rewind)	|*|*|*|*|-|-|-|
|dont-stop	|*|*|*|*|-|-|-|
|to		|*|*|*|*|-|-|-|
|limit		|*|*|*|*|-|-|-|
|---|---|---|---|---|---|---|---|
|symbols	|1|*|*|*|-|-|-|
|sv		|1|1|*|*|-|-|-|
|---|---|---|---|---|---|---|---|
|start		|-|*|*|*|-|-|-|
|length		|-|*|*|*|-|-|-|
|value		|-|*|*|*|-|-|-|
|values		|-|*|*|*|-|-|-|
|---|---|---|---|---|---|---|---|
|symbols:	|-|-|*|*|-|-|-|
|sv:		|-|-|*|*|-|-|-|
|start:		|-|-|*|*|-|-|-|
|length:	|-|-|*|*|-|-|-|
|value:		|-|-|*|*|-|-|-|
|values:	|-|-|*|*|-|-|-|
|---|---|---|---|---|---|---|---|
|alternate	|-|-|*|*|-|-|-|
|---|---|---|---|---|---|---|---|
|view		|2|*|*|2|-|-|-|

(Ad 1) Allowed, empty result/string
(Ad 2) Disallowed data suppressed


Match State

- Keys are the state elements
- Accessors are Set/Get/Clear.
- Facade is Set/Get.

```
    Key         Accessors       Facade          PE/Discard      PE/Before       PE/After
    ---         ---------       ------          ----------      ---------       --------
    start       start           start           lexeme-start    /ditto          /ditto
    length      length          length          lexeme-length   /ditto          /ditto
    g1start     g1start         N/A
    g1length    g1length        N/A
    symbol      name, symbol    N/A
    lhs         lhs             N/A
    rule        rule            N/A
    value       value, values   value, values   lexeme          /ditto          /ditto
    ---         ---------       ------          ----------      ---------       --------
    fresh       fresh                           true            true            /ditto
    sv          sv              sv              undef           (collected sv)  /ditto
    symbols     symbols         symbols         (discards)      (found)         /ditto
    ---         ---------       ------          ----------      ---------       --------
                                view (symbols sv, start, length, value, values)
                                alternate (fresh, symbols, sv)
```
