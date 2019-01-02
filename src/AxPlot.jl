module AxPlot

using PyPlot
using LinearAlgebra
using Flux: Tracker
using Requires

include("main.jl")
include("utils.jl")

function __init__()
    @require InferGMM="e4654f38-ff99-11e8-3938-77f3ff3d0ead" include("gmm.jl")
end


end