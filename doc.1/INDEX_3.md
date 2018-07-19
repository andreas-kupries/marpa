# Indexing the input for fast access to any character in the the presence of of multi-bytes

## Structure

An array CLB of triples (character location, character length, byte
location).  Implementable as triple of arrays, C, L, and B.

## Operations

### Building

For each character location determine the length of the character at
that location, in bytes, and its byte location.

Store in CLB the character location, byte length, and byte location of
just the characters where the length changes relative to the previous
character.

This means that each entry in the array represents a run of characters
all mapping to the same length of their encoding. In each run the
character and byte locations are coupled by a simple linear equation,
enabling direct access to each location.

Note, this array can be filled incrementally. We have to additionally
keep the maximal character and byte locations visited.

### Use

To find to the byte location for character location L perform a binary
search on CLB to find the maximal character position I less than L,
with associated byte location IB and byte length IL. Then move to byte
location `IB + IL*(L - I)`. I.e. move to the byte location for the
start of the found run/range, then move forward by the difference in
characters scaled by the encoding length for the characters in the
range.

## Discussion

Performance and overhead of thus structure are difficult to
estimate. It depends on the number and length of runs of character
with the same-length UTF-8 encoding.

It is guessed that the number of runs will be low, i.e that most input
will be near-homogenous in terms of the symbol set used, and that the
relevant sets for the various languages are all mostly packed together.


### Performance

O(log X) binary search, X the number of runs found. Assumed to be low.

Also, assuming that most movement happens at the end, a shortcut would
be to check if the last element of CLB applies.

### Memory overhead

17 bytes per run. The two locations are 8 bytes each, and the
character length can be stored in a single byte.
