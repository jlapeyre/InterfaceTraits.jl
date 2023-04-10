if VERSION < v"1.9"
    import Base: invokelatest
end

if VERSION < v"1.1"
    isnothing(x) = x === nothing
end

# v1.0 requires type def outside of local scope
struct A end

@testset "new type" begin
    @test isnothing(HasIterateMeth(A))
    @test isnothing(HasLengthMeth(A))
    @test isnothing(HasSizeMeth(A))
    @test isnothing(HasGetIndexMeth(A))
    @test isnothing(HasSetIndex!Meth(A))
    @test isnothing(HasO1GetIndexMeth(A))
    InterfaceTraits.HasIterateMeth(::Type{A}) = true
    InterfaceTraits.HasLengthMeth(::Type{A}) = false
    @test invokelatest(HasIterateMeth, A)
    @test !invokelatest(HasLengthMeth, A)
end

@testset "Array" begin
    vint = [1,2]
    @test HasIterateMeth(vint)
    @test HasLengthMeth(vint)
    @test HasSizeMeth(vint)
    @test HasGetIndexMeth(vint)
    @test HasSetIndex!Meth(vint)
    @test HasO1GetIndexMeth(vint)

    vfloat = [1.0, 2.0]
    @test HasIterateMeth(vfloat)
    @test HasLengthMeth(vfloat)
    @test HasSizeMeth(vfloat)
    @test HasGetIndexMeth(vfloat)
    @test HasSetIndex!Meth(vfloat)
    @test HasO1GetIndexMeth(vfloat)
end

@testset "Tuple" begin
    tup = (1, 2, 3)
    @test HasIterateMeth(tup)
    @test HasLengthMeth(tup)
    @test !HasSizeMeth(tup)
    @test HasGetIndexMeth(tup)
    @test !HasSetIndex!Meth(tup)
    @test HasO1GetIndexMeth(tup)
end

@testset "Dict" begin
    dict = Dict(zip([1,2,3], [4,5,6]))
    @test HasIterateMeth(dict)
    @test HasLengthMeth(dict)
    @test !HasSizeMeth(dict)
    @test HasGetIndexMeth(dict)
    @test HasSetIndex!Meth(dict)
    @test HasO1GetIndexMeth(dict)
end

@testset "SubArray" begin
    vint = view(collect(1:4), 1:3)
    @test HasIterateMeth(vint)
    @test HasLengthMeth(vint)
    @test HasSizeMeth(vint)
    @test HasGetIndexMeth(vint)
    @test HasSetIndex!Meth(vint)
    @test HasO1GetIndexMeth(vint)
end

@testset "AbstractRange" begin
    r = 1:10
    @test HasIterateMeth(r)
    @test iterate(r) isa Tuple
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test !HasSetIndex!Meth(r)
    if VERSION < v"1.8"
        @test_throws ErrorException r[1] = 1
    else
        @test_throws CanonicalIndexError r[1] = 1
    end
    @test HasO1GetIndexMeth(r)

    r = 1:2:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test !HasSetIndex!Meth(r)
    if VERSION < v"1.8"
        @test_throws ErrorException r[1] = 1
    else
        @test_throws CanonicalIndexError r[1] = 1
    end
    @test HasO1GetIndexMeth(r)
end

@testset "Generator" begin
    gen = (x for x in 1:3)
    @test HasIterateMeth(gen)
    @test HasLengthMeth(gen)
    @test HasSizeMeth(gen)
    @test !HasGetIndexMeth(gen)
    @test !HasSetIndex!Meth(gen)
    @test !HasO1GetIndexMeth(gen)
end

@testset "String" begin
    str = "abc"
    @test HasIterateMeth(str)
    @test HasLengthMeth(str)
    @test !HasSizeMeth(str)
    @test HasGetIndexMeth(str)
    @test !HasSetIndex!Meth(str)
    @test_throws MethodError str[1] = 1
    @test !HasO1GetIndexMeth(str)
end

@testset "SubString" begin
    str = "zebragiraffe"
    @test HasIterateMeth(str)
    @test HasLengthMeth(str)
    @test !HasSizeMeth(str)
    @test HasGetIndexMeth(str)
    @test !HasSetIndex!Meth(str)
    @test !HasO1GetIndexMeth(str)

    if VERSION >= v"1.6"
        sstr = view(str, 1:4)
        @test HasIterateMeth(sstr)
        @test HasLengthMeth(sstr)
        @test !HasSizeMeth(sstr)
        @test HasGetIndexMeth(sstr)
        @test !HasSetIndex!Meth(sstr)
        @test !HasO1GetIndexMeth(sstr)
    end
end

@testset "Zip" begin
    z = zip([1,2], [3,4])
    @test HasIterateMeth(z)
    @test iterate(z) isa Tuple
    @test HasLengthMeth(z)
    @test length(z) == 2
    @test HasSizeMeth(z)
    @test size(z) == (2,)
    @test !HasGetIndexMeth(z)
    @test_throws MethodError z[1]
    @test !HasSetIndex!Meth(z)
    @test_throws MethodError z[1] = 1
    @test !HasO1GetIndexMeth(z)
end
