module InterfaceTraits

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
                throw(ErrorException(string("Trait ", string($trait), " not defined for type $x")))
            else
                $trait(typeof(x))
            end
        end
end

for trait in (:HasIterateMeth, :HasLengthMeth, :HasSizeMeth, :HasGetIndexMeth, :HasSetIndex!Meth)
    for _type in (:AbstractArray, :AbstractDict)
        @eval $trait(::Type{<:$_type}) = true
    end
end

for trait in (:HasO1GetIndexMeth, :HasSetIndex!Meth)
    for _type in (:Array, :Dict)
        @eval $trait(::Type{<:$_type}) = true
    end
end

for _type in (:Tuple, :AbstractRange)
    @eval HasSetIndex!Meth(::Type{<:$_type}) = false
end

HasO1GetIndexMeth(::Type{<:AbstractRange}) = true

for trait in (:HasIterateMeth, :HasLengthMeth,  :HasGetIndexMeth)
    @eval $trait(::Type{<:Tuple}) = true
end

for trait in (:HasSizeMeth,)
    @eval $trait(::Type{<:Tuple}) = false
end

## String
for trait in (:HasIterateMeth, :HasLengthMeth, :HasGetIndexMeth)
    @eval $trait(::Type{<:String}) = true
end

for trait in (:HasSetIndex!Meth, :HasO1GetIndexMeth)
    @eval $trait(::Type{<:String}) = false
end

end # module InterfaceTraits
