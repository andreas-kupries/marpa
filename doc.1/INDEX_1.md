# Indexing the input for fast access to any character in the the presence of of multi-bytes

## Structure

A single array S of ints (64 bit = 8 byte).

## Operations

### Building

Record the byte location of all characters whose character location L
satisfies `0 == L % N` at `S[L/N]`.

Note, this can be done incrementally, treating the array as stack.

### Use

To find the byte location for a character location L retrieve and then
move to the byte location S[floor(L/N)] for the character position
`N*floor(L/N) == L - L%N`. Then move `L%N` characters forward to L,
incrementing the byte location by the lengths of the `L%N` characters
we step over.

## Discussion

Theoretically moving to any position is O(1). Because the number of
step operations after the array access is bounded by N and thus we can
lump it under a fixed contant.

However the larger an N we use, the higher that constant. On the other
side, the smaller an N we use, the higher the memory overhead. See the
table below. A denser index has less step overhead for the price of
higher memory requirements, and vice versa.

This structure looks to be best for input with a large amount of
multi-byte characters, reducing the overhead relative to the input
size. For near-pure ASCII it is worst, large relative memory overhead
plus access overhead because of stepping.


### Memory requirements

8 bytes per N characters.

For an input of K characters we need ceil(K*(8/N)) bytes. The largest
overhead occurs for plain ASCII, were we have bytes == characters.

Overhead as function of gap N (density 1/N)

|N   |Space     |Percent|Factor  |
|---:|----------|-------|--------|
|1   |K + K*8	|+800%  | x9	 |
|2   |K + K*4	|+400%  | x5	 |
|4   |K + K*2	|+200%  | x3	 |
|8   |K + K*1	|+100%  | x2	 |
|16  |K + K/2	|+50%   | x1.5	 |
|32  |K + K/4	|+25%   | x1.25	 |
|64  |K + K/8	|+12.5% | x1.125 |
|128 |K + K/16	|+6.25% | x1.0625|
