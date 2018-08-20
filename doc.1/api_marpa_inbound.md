# marpa::inbound

## API signatures

 1. constructor (-> upstream)

 2. enter (string ?from to?)	/-1, -2/
 3. read  (chan   ?from to?)	/-1, -2/
 4. enter-more (string)
 5. read-more  (chan)
 6. last
 7. location
 8. stop
 9. from     (pos ...)
10. rewind   (delta)
11. relative (delta)
12. to       (pos)
13. dont-stop
14. limit    (delta)

After the constructor we have 4 driver methods to provide initial and
additional data to process. The drivers for the initial data further
set up the stage's state with respect to start and stop locations.
The remaining operations are accessors and modifiers for start and
stop location to be called by event handlers during processing.

# Start and stop locations

These are engine internal location values which are not directly
visible to the user. Other parts of the engine perform translations
between thesen and the user-visible values, in either direction.

Start location:

	Initial location of the cursor to process characters. As the
	loop invariant at loop entry is to have the cursor pointing to
	the _last_ processed character the default value of -1 means
	that processing will start with the first character of the
	input, at index 0.

	The start location can range from -1 to input.size-1. The last
	value means that no character will be processed at all because
	the character to process is after the end of the input,
	i.e. does not exist.

Stop location:

	The index of the character to stop the engine at, after
	processing that character. A value of -1 thus means to stop
	engine after processing the non-existent character before the
	first character, and thus equivalently before processing the
	first character of the input at index 0.

	Furthermore the default value of -2 thus means to stop before
	processing the non-existing character before the first
	character. As that index is never reached in regular operation
	the engine will actually not stop. This value therefore is the
	in-band signal for a non-stopping engine.

	The stop location can range from -2 to input.size-1. The
	latter means that the engine stops just after the last
	character, before attempting to process the non-existing
	character after the end of the input.

Limit semantics:

	Limit X says to stop the engine after processing the next X
	characters, relative to the current cursor location.

	As the current cursor C is just before the first next
	character to process, the new stop location S is `C + X`,
	stopping the engine just before `C + X + 1`.

	Example:
	ix = 0 1 2 3 4 5 6 7 8 9 ...
	IN = a l p h a n u m e r i c
	C  = 3 ----^ | | | | |
	L  = 5 ------/-/-/-/-/
	S  = 8, stop before 9.

## API call ordering

Specified via regular expression: `1[23][45,9-14]*`.
The APIs 6-8 may occur anywhere after `1`.

## API expectations on linked objects

   * upstream
     1. enter (char, sem-value-id)
     2. eof ()

     Example: `marpa::gate`

# Semantic values

Per character, one 3-tuple holding
* start location
* end location (identical to start)
* character itself (its literal)

Both start and end location are stored, despite being identical,
because upstream will usually combine characters into larger literals
which do have a length > 1, and this way avoids the need to special
case literals of length 1.

# Interaction sequences

* Supplication of text via `enter`
```
Driver  Inbound SemStore        Upstream
|               |               |
+-cons--\       |               |
|       |       |               |
+-enter->       |               |
|       +-put--->               |
|       +-enter----------------->
|       *       |               |
|       |       |               |
|       +-eof------------------->
|       |       |               |
```

* Supplication of text via `read`
```
Driver  Inbound SemStore        Upstream
|               |               |
+-cons--\       |               |
|       |       |               |
+-read-->       |               |
|       --\     |               |
|       | enter |               |
|       <-/     |               |
|       +-put--->               |
|       +-enter----------------->
|       *       |               |
|       |       |               |
|       +-eof------------------->
|       |       |               |
```

__Note__, both `enter` and `read` can be mixed between `constructor`
and `eof`.
