# InterfaceTraits

[![Build Status](https://github.com/jlapeyre/InterfaceTraits.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jlapeyre/InterfaceTraits.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jlapeyre/InterfaceTraits.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jlapeyre/InterfaceTraits.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![JET QA](https://img.shields.io/badge/JET.jl-%E2%9C%88%EF%B8%8F-%23aa4444)](https://github.com/aviatesk/JET.jl)

This package implements the ability to get statically determined information on whether there is a method for
a particular combination of type and function. Non in general, but for specific functions with well defined semantics that are used in
Julia to characterize an interface. It also adds a trait for supporting O(1) indexing.
As an example, suppose I need to have fast indexing (or indexing at all) into an vector-like input. This could be for example a `Vector`
or a `Generator`. The following function will materialize `v` only if it needs to.
```julia
maybecollect(v) = HasO1GetIndexMeth(v) ? v : collect(v)
```
Of course this is not foolproof (for example it might try to collect a generator with an infinite number of items.)
But it's a good start for many situations.

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

Each trait can be called on types or instances of types and returns one of `true`, `false` or `nothing`,
with `nothing` signifying "unknown". For example
```julia
julia> HasIterateMeth([1, 2, 3])
true

julia> HasIterateMeth(Vector)
true

julia> HasSetIndex!Meth(1:3)
false

julia> struct A end;

julia> isnothing(HasIterateMeth(A))
true

julia> InterfaceTraits.HasIterateMeth(::Type{A}) = false;

julia> HasIterateMeth(A)
false

julia> HasIterateMeth(A())
false
```

### How it is implemented

Most of the methods for subtypes of `InterfaceTrait` are constructed by calling `hasmethod` on the
corresponding function at the time `InterfaceTraits` is compiled. The presence or absence of a method
is recorded at a compile time. If an absent method is added later then the trait information will be
wrong. So this is package is meant to be used for situations in which the interface of a type is stable.
For example, a method for `setindex!(::Tuple, val, i)` should never by defined


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

It has to be this way because of the dynamic nature of Julia. However, for the traits here to
disagree with `hasmethod` someone would have to be committing egregious type piracy.

### Limitations

The methods defined by this packge may depend on what other packages are loaded at the time this package is compiled.

Most types for which methods are compiled are subtypes of `UnionAll`, so concrete type parameters are not filled in.
We check for instance for `setindex(x::Vector, ind::Int, val::Int)`. This gives the correct result for
`Vector{Float64}` because our assumption that `setindex` is sensibly defined for `Vector{Int}` means that it
likely is sensibly defined for `Vector{Float64}`. This is correct in this case, and often a good assumtpion. But
there are likely cases where it will fail.

Methods for `HasO1GetIndexMeth` have to be written more or less by hand. As a result the number of types with
method for this function is limited.

Some methods are probably incorrect.

Fixed. ~~For example `HasSetIndex!Meth(1:10)` is `true`, but it should be false.
This is because a method *is* defined, but it just throws an error.~~
