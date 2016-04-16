__precompile__()
module COMBO

export combo, BayesPolicy, COMBO_MODEL

using PyCall
import Base

const combo = PyCall.PyNULL()

function __init__()
    copy!(combo, pyimport("combo"))
    pytype_mapping(combo[:gp][:core][:model], GPModel)
    pytype_mapping(combo[:search][:bayes_policy], BayesPolicy)
end

@enum MODEL GP BLM
abstract ComboModel
abstract ComboPolicy

export GPModel
type GPModel <: ComboModel
    o::PyObject
    function GPModel(fmean, fcov, flik)
        new(combo[:gp][:model](fmean, fcov, flik))
    end
end

#####################################

type BayesPolicy <: ComboPolicy
    o::PyObject
    function BayesPolicy(simu, test_X, config)
        new(combo[:search][:bayes_policy](simu, test_X, config))
    end
end

export set_seed
set_seed(bp::BayesPolicy, seed) = bp.o[:set_seed](seed)
Base.run(bp::BayesPolicy, gp::GPModel) = bp.o[:run](gp.o)

#####################################

export fmean_const
function fmean_const(mode::MODEL, c=0)
    if mode == GP
        return combo[:gp][:mean][:const](c)
    else
        error("fmean_const is not implemented for $mode")
    end
end

export fcov_gauss
function fcov_gauss(mode::MODEL, dim)
    if mode == GP
        return combo[:gp][:cov][:gauss](dim)
    else
        error("fcov_gauss is not implemented for $mode")
    end
end

export flik_gauss
function flik_gauss(mode::MODEL)
    if mode == GP
        return combo[:gp][:lik][:gauss]()
    else
        error("flik_gauss is not implemented for $mode")
    end
end

end # module
