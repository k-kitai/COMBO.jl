__precompile__()
module COMBO
export combo

using PyCall

const combo = PyCall.PyNULL()

function __init__()
    copy!(combo, pyimport("combo"))
end

end # module
