module gmm

using InferGMM, Distributions
using PyPlot
import ..utils: gaussian_2D_level_curve_pts
export plot_gmm

function plot_gmm(dGMM::GMM; figsize=(10,10), alpha=0.5, bins=50, fill=false, axs=nothing) where T <: AbstractFloat
    d, k = size(dGMM), ncomponents(dGMM)
    (d > 20) && throw("will not plot for d > 20")

    # d == 2 fits on a single axis: deal with this case first
    if d == 2
        if axs == nothing
            fig, axs = PyPlot.subplots(1, 1, figsize=figsize)
        end
        _plot = fill ? axs.fill : axs.plot
        for j in 1:k
            levcurv = gaussian_2D_level_curve_pts(dGMM.mus[j,:], dGMM.sigmas[:,:,j])
            _plot(levcurv[:,1], levcurv[:,2], alpha=alpha*dGMM.pis[j]/maximum(dGMM.pis))
        end
        return axs
    end

    # d > 2:
    if axs == nothing
        fig, axs = PyPlot.subplots(d, d, figsize=figsize)
    end
    rsmp = rand(dGMM, 5000)

    for ix = 1:d, iy = 1:d
        if ix != iy
            for j in 1:k
                _plot = fill ? axs[iy, ix].fill : axs[iy, ix].plot
                levcurv = gaussian_2D_level_curve_pts(dGMM.mus[j,:][[ix,iy]], dGMM.sigmas[[ix,iy],[ix,iy],j])
                _plot(levcurv[:,1], levcurv[:,2], alpha=alpha*dGMM.pis[j]/maximum(dGMM.pis))
            end
        else
            axs[iy, ix].hist(rsmp[ix, :], bins=bins)
        end
    end
    return axs
end




end
