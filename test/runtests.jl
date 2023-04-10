using InterfaceTraits
using Test

if VERSION > v"1.7"
    include("jet_test.jl")
end
include("interface_traits_test.jl")
include("aqua_test.jl")
