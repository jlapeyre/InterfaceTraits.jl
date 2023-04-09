module InterfaceTraits
using InteractiveUtils: InteractiveUtils

import Random
import SharedArrays
import SparseArrays
import LinearAlgebra
import Test
import OrderedCollections

# TODO: Need to handle availability in diferent versions of Julia
# This is easiest to handle knowing what is available
# using Base.Iterators
import Base.Iterators: Accumulate, Filter, Reverse, Stateful, Count, IterationCutShort, Take,
    Cycle, PartitionIterator, TakeWhile, Drop, ProductIterator, Zip, DropWhile, Repeated,
Enumerate, Rest

export InterfaceTrait, HasIterateMeth, HasLengthMeth, HasSizeMeth, HasGetIndexMeth, HasO1GetIndexMeth,
    HasSetIndex!Meth

abstract type InterfaceTrait end
struct HasIterateMeth <: InterfaceTrait end  # Has method for `iterate`
struct HasLengthMeth <: InterfaceTrait end   # Has method ...
struct HasSizeMeth <: InterfaceTrait end
struct HasGetIndexMeth <: InterfaceTrait end
struct HasSetIndex!Meth <: InterfaceTrait end
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
    iterators = (Accumulate, Filter, Reverse, Stateful, Count, IterationCutShort, Take,
    Cycle, PartitionIterator, TakeWhile, Drop, ProductIterator, Zip, DropWhile, Repeated,
    Enumerate, Rest)
    toptypes = (AbstractArray, AbstractDict, Base.Generator, AbstractString, Tuple,
                iterators...)
    for _type in toptypes
        _get_leaf_types!(_type, leaf_types)
    end
    return leaf_types
end

function make_has_method_exprs(type_list, exprs::Vector{Expr} = Expr[])
    funcpairs = ((:HasIterateMeth, iterate), (:HasLengthMeth, length), (:HasSizeMeth, size),
                 (:HasGetIndexMeth, getindex), (:HasSetIndex!Meth, setindex!))
    for _type in type_list
        for (hasmeth, func) in funcpairs
            if func == getindex
                result = hasmethod(func, (_type, Int))
            elseif func == setindex!
                result = hasmethod(func, (_type, Int, Int))
            else
                result = hasmethod(func, (_type,))
            end
            push!(exprs, :($hasmeth(::Type{<:$_type}) = $result))
        end
    end
    return exprs
end

let _types = _get_several_leaf_types()
    allexpr = make_has_method_exprs(_types)
    for expr in allexpr
        eval(expr)
    end
end

for _type in (:AbstractRange, :Array, :Tuple)
    @eval HasO1GetIndexMeth(::Type{<:$_type}) = true
end

for _type in (:String, :LazyString, :SubString, :SubstitutionString)
    @eval HasO1GetIndexMeth(::Type{<:$_type}) = false
end

end # module InterfaceTraits
