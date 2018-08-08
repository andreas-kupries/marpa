
# Event callbacks

Signature: `(prefix) P|L type list-of-event-names`
(so far)

Access to lexer state via `P match ...`

## Engine access 

   - P match location?
   - P match moveto pos ?delta...?	(Move to pos, then apply any deltas via (inlined) moveby)
   - P match rewind delta (>0 = rewind,  < 0 = forward)
   - P match moveby delta (>0 = forward, < 0 = rewind)
   - P match length
   - P match start
   - P match sv
   - P match symbols
   - P match value
   - P match values
   - P match length: len
   - P match start: pos
   - P match sv: vals
   - P match symbols: syms
   - P match value: x
   - P match values: xs
   - P match alternate sym val
     (nicer api to symbols:/sv: for incremental rebuild)

Debug access:

   - P match view

# Event management

   - P on-event cmdprefix...

# Event generation

Internal

   - P post ... === (*)(on-event) P (*)(...)

Lexer

   - P post before  $list_event_names
   - P post after   $list_event_names
   - P post discard $list_event_names

# Notes

```
lexer -> M (lexer::match, store of matching state)
      -> PED (lexer::ped)
           <- M as Store
           <- Gate
```
