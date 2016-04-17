export Kernel
export GaussianKernel
export calc_kernel, get_cov

#######################################
# Kernel and required functions
#######################################

abstract Kernel

"""
    calc_kernel{K<:Kernel}(
        k::K      --- kernel
        xs...     --- remaining arguments
                      At least, two data points should
                      be included.
    )

Compute kernel function between two data points.
"""
function calc_kernel{K<:Kernel}(k::K, xs...)
    error("calc_kernel() not implemeted for $(K.name)")
end

"""
    get_cov{K<:Kernel}(
        k::K       --- Kernel
        X::Matrix  --- Columnwise vector
    )

Compute the gramm matrix.
"""
function get_cov{K<:Kernel}(k::K, X::Matrix)
    n = size(X)[2]
    G = zeros(n,n)
    for i=1:n, j=i:n
        G[i,j] = calc_kernel(k, X[:,i], X[:,j])
        G[j,i] = G[i,j]
    end
    return G
end

get_cov{K<:Kernel}(k::K, Xs::Vector) = begin
    n = length(Xs)
    G = zeros(n,n)
    for i=1:n, j=1:n
        G[i,j] = calc_kernel(k, Xs[i], Xs[j])
        G[j,i] = G[i,j]
    end
    return G
end

#-------------------------------
# Gaussian Kernel
#-------------------------------

immutable GaussianKernel{T<:AbstractFloat} <: Kernel
    width::T
    scale::T
end

calc_kernel(gk::GaussianKernel, x::Vector, y::Vector) = begin
    d = (x - y)/gk.width
    return (gk.scale * exp(-0.5*d'*d))[1]
end

