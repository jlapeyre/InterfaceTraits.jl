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

@testset "Generator" begin
    gen = (x for x in 1:3)
    @test HasIterateMeth(gen)
    @test HasLengthMeth(gen)
    @test HasSizeMeth(gen)
    @test !HasGetIndexMeth(gen)
    @test !HasSetIndex!Meth(gen)
    @test !HasO1GetIndexMeth(gen)
end

@testset "AbstractRange" begin
    r = 1:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test !HasSetIndex!Meth(r)
    @test HasO1GetIndexMeth(r)

    r = 1:2:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test !HasSetIndex!Meth(r)
    @test HasO1GetIndexMeth(r)
end
