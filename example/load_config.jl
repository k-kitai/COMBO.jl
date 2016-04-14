using COMBO
using ArgParse

function load()
    A = readcsv("data/s5-210.csv")
    X = Array{Float64,2}(A[2:end,1:3])
    t = Array{Float64,1}(A[2:end,4])
    return X,t
end

s = ArgParseSettings(description = "This script is to evaluate the performance of COMBO")

@add_arg_table s begin
    "--seed"
        default = 0
        arg_type = Int
        help = "seed parameter"
    "--score"
        default = "TS"
        arg_type = AbstractString
        help = "score function"
    "--dir_name"
        default = "res"
        arg_type = AbstractString
        help = "directory name"
    "--num_basis"
        default = 0
        arg_type = Int
        help = "number of basis functions"
end


parsed_args = parse_args(s)
X, t = load()
mean_val = combo[:gp][:mean][:const]()
covar    = combo[:gp][:cov][:gauss](size(X)[2])
lik      = combo[:gp][:lik][:gauss]()
gp = combo[:gp][:model](mean_val, covar, lik)

config = combo[:misc][:set_config]()
config[:load]("config.ini")

config[:search][:score] = parsed_args["score"]
config[:search][:dir_name] = parsed_args["dir_name"]

if parsed_args["num_basis"] == 0
    config[:predict][:is_rand_expans] = false
else
    config[:predict][:id_rand_expans] = true
    config[:predict][:num_basis] = parsed_args["num_basis"]
end

config[:show]()

