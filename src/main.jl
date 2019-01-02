 #=================================================================================
                                     Utilities
 ==================================================================================#

function subplot_gridsize(num)
    poss = [[x,Int(ceil(num/x))] for x in range(1,stop=Int(floor(sqrt(num)))+1)]
    choice = findmin([sum(x) for x in poss])[2]  # argmin
    return sort(poss[choice])
end


 #=================================================================================
                                   Plotting zoo
 ==================================================================================#

function pairplot(X::AbstractArray{T, 2}; figsize=(10,10), alpha=0.5, bins=50, axs=nothing, kwargs...) where T <: AbstractFloat
    n, d = size(X)
    (d > 20) && throw("will not plot for d > 20")

    (axs == nothing) && ((fig, axs) = PyPlot.subplots(d, d, figsize=figsize))
    for ix = 1:d, iy = 1:d
        if ix != iy
            if alpha isa Number
                axs[iy, ix][:scatter](X[:, ix], X[:, iy], alpha=alpha, kwargs...)
            elseif alpha isa AbstractArray
                scatter_alpha(X[:,ix], X[:,iy], alpha, ax=axs[iy,ix], kwargs...)
            end
        else
            axs[ix, iy][:hist](X[:, ix], bins=bins)
        end
    end
    return axs
end


function scatter_arrays(xs...)
    n = length(xs)
    sz = subplot_gridsize(n)
    f, axs = PyPlot.subplots(sz..., figsize=(5 + (sz[2]>1), sz[1]*3))
    if n == 1   # axs is not an array!
        axs[:scatter](unpack_arr(xs[1])...)
        return
    else
        for i in eachindex(xs)
            ax = axs[i]; x = xs[i]
            ax[:scatter](unpack_arr(x)...)
        end
    end
end


function scatter_alpha(x1::Vector{T}, x2::Vector{T}, alpha::Vector{T2}; cmap_ix::Int=0, cmap::String="tab10",
        rescale_alpha::Bool=true, ax=nothing) where T <: Real where T2 <: AbstractFloat
    n = length(alpha)
    ax = something(ax, gca())
    cols = repeat(collect(ColorMap(cmap)(cmap_ix))', n, 1)
    rescale_alpha ? (alpha /= maximum(alpha)) : nothing
    cols[:,4] = alpha
    ax[:scatter](x1, x2, color=cols)
end



 #=================================================================================
                                  Axis manipulation
 ==================================================================================#

function ax_lim_one_side(ax, xy; limstart=nothing, limend=nothing, type="constant")
    #=
    Ported from pyalexutil. Manipulates one current axis limit without changing others.
    The interfaces `x_lim_one_side`, `y_lim_one_side` use this functionality and may
    be preferred to this function as they read better.
    :param ax           - axis object to manipulate
    :param xy           - either "x", "y", the dimension of the axis to manipulate
    :param limstart     - the argument for changing the start number (nothing = no change)
    :param limend       - the     "     "     "      "   end    "
    :param type         - what to do with the start/end axis: "constant" specifies
                          overriding current value with limstart/limend, "multiply"/"*"
                          and "add"/"+" also accepted which multiply/add curr. number.
    =#
    if xy == "x"
        lims = ax[:get_xlim]()
    else
        lims = ax[:get_ylim]()
    end
    lims = collect(lims)  # make mutable (is tuple typed)

    if type == "m" || type == "multiply" || type == "*"
        f = *
    elseif type == "a" || type == "add" || type == "+"
        f = +
    elseif type == "c" || type == "constant"
        f = (x, y) -> y
    else
        throw("Unexpected limtype (expecting 'constant', 'add', 'multiply')")
    end

    if limstart != nothing; lims[1] = f(lims[1], limstart); end
    if limend != nothing; lims[2] = f(lims[2], limend); end

    if xy == "x"
        ax[:set_xlim](lims)
    else
        ax[:set_ylim](lims)
    end
end


# convenience wrappers for clean code
function x_lim_one_side(ax; s=nothing, e=nothing, type="constant")
    #=
    Change either the start or end of the specified x-axis. See `ax_lim_one_side`.
    =#
    ax_lim_one_side(ax, "x", limstart=s, limend=e, type=type)
end


function y_lim_one_side(ax; s=nothing, e=nothing, type="constant")
    #=
    Change either the start or end of the specified y-axis. See `ax_lim_one_side`.
    =#
    ax_lim_one_side(ax, "y", limstart=s, limend=e, type=type)
end


x_lim_start_zero(ax) = x_lim_one_side(ax; s=0.)
y_lim_start_zero(ax) = y_lim_one_side(ax; s=0.)
