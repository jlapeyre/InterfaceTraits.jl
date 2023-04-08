# InterfaceTraits

[![Build Status](https://github.com/jlapeyre/InterfaceTraits.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jlapeyre/InterfaceTraits.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jlapeyre/InterfaceTraits.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jlapeyre/InterfaceTraits.jl)

This package introduces the following traits

```julia
struct HasIterateMeth <: InterfaceTrait end  # Has method for `iterate`
struct HasLengthMeth <: InterfaceTrait end   # Has method ...
struct HasSizeMeth <: InterfaceTrait end
struct HasGetIndexMeth <: InterfaceTrait end
struct HasSetIndex!Meth <: InterfaceTrait end
struct HasO1GetIndexMeth <: InterfaceTrait end # Is indexing O(1)
```

As usual we abuse the contstructors to return a `Bool` when these are called with various objects.
Method definitions for several type in `Base` are provided.

### Tests

A handful of tests are provided.

Doing some testing with `hasmethod` would be useful.

### Why are these useful?

One reason is
```julia
julia> @btime hasmethod(length, (Tuple,))
  730.303 ns (4 allocations: 208 bytes)
true

julia> @btime HasLengthMeth(Tuple)
  1.126 ns (0 allocations: 0 bytes)
true
```

Here is a useful function:
```julia
maybecollect(v) = HasO1GetIndexMeth(v) ? v : collect(v)
```
