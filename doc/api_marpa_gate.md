# marpa::gate

## API signatures

1. constructor (-> upstream)
2. = (chars, classes)
3. enter (character, sem-value-id)
4. eof ()
5. acceptable (symbol-dict)
6. redo (n)

The first two methods are construction and configuration. The latter
is separate from the further to prevent us from entangling the
creation of the structure of interlinked processing objects with the
dynamic configuration for a specific grammar.

The next two methods (`enter` and `eof`) are driven from the input
side, for example `marpa::inbound`. They provide data to process, or
signal the end of the input.

The last two methods are for use by the `upstream` instance to signal
to the gate what symbols are currently expected, or to rewind the
input because it overshot.

## API call ordering

Specified via regular expression: `1(2(356?)*)?(46)`

## API expectations on linked objects

   * upstream
     1. gate: (self)
     2. enter (symbol, sem-value-id)
     3. eof ()

     Example: `marpa::lexer`

# Semantic values

The semantic values received from downstream (via `enter`) are passed
through to upstream, unchanged.

# Interaction sequences

* Lifecycle
```
Driver  Gate    Upstream
|               |
+-cons--\       |
|       +-gate:->       (Internal backlinking from upstream to its gate)
|       |       |
~~      ~~      ~~      Driven from input
~~      ~~      ~~
|       |       |
+-eof--->       |
|       +-eof--->
|       <--redo-+       (Always called, even for n == 0)
|       |       |
```

* Operation during scanning of a lexeme
```
Driver  Gate    Upstream
|               |
+-enter->       |
|       +-enter->
|       <---acc-+
|       |       |
```

* Operation at end of a lexeme
```
Driver  Gate    Upstream
|               |
+-enter->       |
|       +-enter->
|       <---acc-+
|       <--redo-+       (Always called, even for n == 0)
|       |       |
```
