# Indexing the input for fast access to any character in the the presence of of multi-bytes

## Structure

An array CO of pairs (character location, offset).
Implementable as pair of arrays C and O.

## Operations

### Building

For each character location determine the difference between byte
location and character location. This difference is called
`offset`. It is a cumulative value, growing as we move towards the end
of the input.

Note: The offset is always positive (including zero) as we will always
have at most the same number of characters as we have bytes (plain
ASCII). With multi-byte characters present we have definitely less
characters than bytes, causing byte locations to become larger than
character locations.

Store in CO the character locations and their offset where the offset
changes relative to the offset used by the previous character.

This happens for each and every multi-byte character.

Note, this array can be filled incrementally. We have to additionally
keep the maximal character and byte locations visited.

### Use

To find the byte location for character location L perform a binary
search on CO to find the maximal character position I less than
L. Retrieve the associated offset O. The byte location is `L + O`, by
definition of CO.

## Discussion

This structure performs best for pure ASCII, or near-pure ASCII, with
a low amount of multi-byte characters, i.e. array entries.

On the other side, for a pure multi-byte input the array becomes a
full index with one entry per character for a factor 16 memory
overhead, and O(log N) time to move to a random location of the input.

At that point of the spectrum the array would be better used as direct
index instead of searching, simply combine char location and offset to
full byte location. Of course, while this halves the memory overhead
it would still be a factor 8.


### Performance

O(log X) binary search, X the number of inflection points. Assumed to
be low.

Also, assuming that most movement happens at the end, a shortcut would
be to check if the last element of CO applies.

### Memory overhead

16 bytes per multi-byte character

It is assumed that most inputs have no to a very low number of
multi-byte character.

In other words, it is assumed that most inputs are either for a
specific language, where all characters are in a small set of code
pages which encode to the same length in UTF-8, or a small mix of
languages and symbols with a majority of the input characters encoding
to a small set of lengths and large runs of the same length with only
few short runs mixed between them.
