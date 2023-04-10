module InterfaceTraits
using InteractiveUtils: InteractiveUtils

import Random
import SharedArrays
import SparseArrays
import LinearAlgebra
import Test
import OrderedCollections

# TODO: Need to handle availability in diferent versions of Julia This is
# easiest to handle knowing what is available using Base.Iterators
import Base.Iterators: Filter, Reverse, Stateful, Count, IterationCutShort, Take,
    Cycle, PartitionIterator, Drop, ProductIterator, Zip, Repeated, Enumerate, Rest

const _ITERATORS = [Filter, Reverse, Stateful, Count, IterationCutShort, Take,
                    Cycle, PartitionIterator, Drop, ProductIterator, Zip, Repeated, Enumerate, Rest]

if VERSION < v"1.1"
    import Base.Iterators: Zip2
    push!(_ITERATORS, Zip2)
end

if VERSION >= v"1.4"
    import Base.Iterators: Accumulate, TakeWhile, DropWhile
    append!(_ITERATORS, [Accumulate, TakeWhile, DropWhile])
end

export InterfaceTrait, HasIterateMeth, HasLengthMeth, HasSizeMeth, HasGetIndexMeth, HasO1GetIndexMeth,
    HasSetIndex!Meth

"""
    type InterfaceTrait

Abstract type whose subtypes give statically determined information on which methods
in the "Interfaces" section of the Julia documentation are implemented for types.
"""
abstract type InterfaceTrait end

"""
    HasIterateMeth(x::T) where T
    HasIterateMeth(::Type{T}) where T

Returns `true` if a method for `iterate` is implemented for type `T`.
"""
struct HasIterateMeth <: InterfaceTrait end  # Has method for `iterate`

"""
    HasLengthMeth(x::T) where T
    HasLengthMeth(::Type{T}) where T

Returns `true` if a method for `length` is implemented for type `T`.
"""
struct HasLengthMeth <: InterfaceTrait end   # Has method ...

"""
    HasSizeMeth(x::T) where T
    HasSizeMeth(::Type{T}) where T

Returns `true` if a method for `size` is implemented for type `T`.
"""
struct HasSizeMeth <: InterfaceTrait end

"""
    HasGetIndexMeth(x::T) where T
    HasGetIndexMeth(::Type{T}) where T

Returns `true` if a method for `getindex(::T, ::Int)` is implemented for type `T`.

This really should be testing if reasonable methods for `getindex` are defined for `T`.
But using a single `Int` is a proxy for the more fine grained information.
"""
struct HasGetIndexMeth <: InterfaceTrait end

"""
    HasSetindex!Meth(x::T) where T
    HasSetindex!Meth(::Type{T}) where T

Returns `true` if a method for `setindex!(::T, ::Int, ::Int)` is implemented for type `T`.

This really should be testing if reasonable methods for `setindex!` are defined for `T`.
But using a two `Int`s is a proxy for the more fine grained information.
"""
struct HasSetIndex!Meth <: InterfaceTrait end

"""
    HasO1GetIndexMeth(x::T) where T
    HasO1GetIndexMeth(::Type{T}) where T

Returns `true` if a method for `getindex(::T, ::Int)` is implemented for type `T` and
fetches the value in O(1) time.
"""
struct HasO1GetIndexMeth <: InterfaceTrait end # Is indexing O(1)

for trait in (:HasIterateMeth, :HasLengthMeth, :HasSizeMeth, :HasGetIndexMeth, :HasSetIndex!Meth, :HasO1GetIndexMeth)
    @eval function $trait(x)
        if x isa Type
            return nothing # means "unknown"
        else
            $trait(typeof(x))
        end
    end
end

function _get_leaf_types!(_type::Type, leaf_types::Vector = Any[])
    stypes = InteractiveUtils.subtypes(_type)
    if isempty(stypes)
        push!(leaf_types, _type)
        return leaf_types
    end
    for ssubtype in stypes
        _get_leaf_types!(ssubtype, leaf_types)
    end
    return leaf_types
end

function _get_several_leaf_types()
    leaf_types = Any[]
    # iterators = [Filter, Reverse, Stateful, Count, IterationCutShort, Take,
    # Cycle, PartitionIterator, Drop, ProductIterator, Zip, Repeated, Enumerate, Rest]
    # if VERSION >= v"1.4"
    #     append!(iterators, [Accumulate, DropWhile, TakeWhile])
    # end
    toptypes = (AbstractArray, AbstractDict, Base.Generator, AbstractString, Tuple,
                _ITERATORS...)
    for _type in toptypes
        _get_leaf_types!(_type, leaf_types)
    end
    return leaf_types
end

# Add methods for `funcpairs` for all types in `type_list`.
function _makehas_method_exprs(type_list, exprs::Vector{Expr} = Expr[])
    funcpairs = ((:HasIterateMeth, iterate), (:HasLengthMeth, length), (:HasSizeMeth, size),
                 (:HasGetIndexMeth, getindex), (:HasSetIndex!Meth, setindex!))
    for _type in type_list
        for (hasmeth, func) in funcpairs
            if func == getindex
                result = hasmethod(func, (_type, Int))
            elseif func == setindex!
                if ! (_type <: AbstractRange)
                    result = hasmethod(func, (_type, Int, Int))
                else
                    continue
                end
            else
                result = hasmethod(func, (_type,))
            end
            push!(exprs, :($hasmeth(::Type{<:$_type}) = $result))
        end
    end
    return exprs
end

let _types = _get_several_leaf_types()
    allexpr = _makehas_method_exprs(_types)
    for expr in allexpr
        eval(expr)
    end
end

# I think AbstractArray does not require O1 access. So we have to do some individually.
# We can exclude those that don't support O1 access with a conditional here.
let type_list = InteractiveUtils.subtypes(AbstractArray)
    append!(type_list, [Tuple, Dict])
    for the_type in type_list
        @eval HasO1GetIndexMeth(::Type{<:$the_type}) = true
    end
end

HasSetIndex!Meth(::Type{<:AbstractRange}) = false

# Types with no O1 getindex.
let type_list = [:String, :SubString, :SubstitutionString, :(Base.Generator)]
    VERSION >= v"1.8" && push!(type_list, :LazyString)
    append!(type_list, _ITERATORS)
    for _type in type_list
        @eval HasO1GetIndexMeth(::Type{<:$_type}) = false
    end
end

end # module InterfaceTraits
