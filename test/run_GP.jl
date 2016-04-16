using COMBO
using PyCall
using Base.Test


function load()
    A = readcsv("../data/s5-210.csv")
    X = Array{Float64,2}(A[2:end,1:3])
    t = Array{Float64,1}(A[2:end,4])
    return X,t
end

@pydef type Simulator
    load() = begin
        A = readcsv("../data/s5-210.csv")
        X = A[:,0:3]
        t = A[:,3]
        return X, t
    end
    __init__(self) = begin
        X,t = load()
        self[:X] = X
        self[:t] = t
    end
    __call__(self, action) = begin
        return -self[:t][action]
    end
end

X, t = load()
fm = fmean_const(COMBO.GP, 0)
fc = fcov_gauss(COMBO.GP, 3)
fl = flik_gauss(COMBO.GP)
gp = GPModel(fm,fc,fl)

config = combo[:misc][:set_config]()
config[:load]("../data/config.ini")

config[:search][:score] = "TS"
config[:search][:dir_name] = "res"
config[:predict][:is_rand_expans] = false
config[:predict][:num_basis] = 0
config[:learning][:is_hyparams_learning] = false

config[:show]()

simu = Simulator()
search = BayesPolicy(simu, X, config)
set_seed(search, 2)

run(search, gp)


# ComboGP
# fm = x->0
# fc = ((x,y)->exp(-(x-y)^2))
# fl = flik{ComboGP}()
# gp = ComboGP(fmean, fcov, flik)

