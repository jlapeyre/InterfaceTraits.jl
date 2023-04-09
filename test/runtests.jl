using InterfaceTraits
using Test

@testset "Array" begin
    v = [1,2]
    @test HasIterateMeth(v)
    @test HasLengthMeth(v)
    @test HasSizeMeth(v)
    @test HasGetIndexMeth(v)
    @test HasSetIndex!Meth(v)
    @test HasO1GetIndexMeth(v)
end

@testset "AbstractRange" begin
    r = 1:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test_broken !HasSetIndex!Meth(r)
    @test HasO1GetIndexMeth(r)

    r = 1:2:10
    @test HasIterateMeth(r)
    @test HasLengthMeth(r)
    @test HasSizeMeth(r)
    @test HasGetIndexMeth(r)
    @test_broken !HasSetIndex!Meth(r)
    @test HasO1GetIndexMeth(r)
end
