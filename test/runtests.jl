using InterfaceTraits
using Test

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
    @test_throws CanonicalIndexError r[1] = 1
    @test HasO1GetIndexMeth(r)

    r = 1:2:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test !HasSetIndex!Meth(r)
    @test_throws CanonicalIndexError r[1] = 1
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

    sstr = view(str, 1:4)
    @test HasIterateMeth(str)
    @test HasLengthMeth(str)
    @test !HasSizeMeth(str)
    @test HasGetIndexMeth(str)
    @test !HasSetIndex!Meth(str)
    @test !HasO1GetIndexMeth(str)
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
