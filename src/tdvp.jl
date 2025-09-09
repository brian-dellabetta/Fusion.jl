using ITensors: ITensors, MPO, OpSum, inner, randomMPS, siteinds, MPS, expect
using ITensorTDVP: ITensorTDVP, tdvp
using Observers: observer

function ITensors.state(::ITensors.StateName"+", ::ITensors.SiteType"Electron")
    return [0, 1 / sqrt(2), im / sqrt(2), 0]
end
function ITensors.state(::ITensors.StateName"-", ::ITensors.SiteType"Electron")
    return [0, 1 / sqrt(2), -im / sqrt(2), 0]
end

#Number of sites
n_sites = 64
#left state will start at x_init, right state will start at (N-(x_init-1))
x_init = 24
cutoff = 1E-8
#time step
t_step = 0.02
#stop at this time
t_total = 6.0
#nearest neighbor hopping energy
t_hop = -3.0
#scattering energy
t_scatt = 1.0
#on-site coulomb potential ("Ntot")
U = 10
use_topological = false

s = siteinds("Electron", n_sites)

os = OpSum()
#on-site coulomb interaction
if U != 0.0
    for j in 1:n_sites
        for i in j:n_sites
            global os += U / (1 + abs(j - i)), "Ntot", j, "Ntot", i
        end
    end
end
#nearest-neighbor hopping
if use_topological
    for j in 1:(n_sites-1)
        #attempt #1 with "Up" and "Dn" states
        # global os += (-im * t_hop / 2), "Cdagup", j + 1, "Cup", j
        # global os += (-im * t_hop / 2), "Cdagdn", j, "Cdn", j + 1

        #attempt #2 with "+" and "-" states
        global os += (t_hop / (2 * sqrt(2))), "Cdagup", j, "Cup", j + 1
        global os += (-im * t_hop / (2 * sqrt(2))), "Cdagup", j, "Cdn", j + 1
        global os += (im * t_hop / (2 * sqrt(2))), "Cdagdn", j, "Cup", j + 1
        global os += (t_hop / (2 * sqrt(2))), "Cdagdn", j, "Cdn", j + 1

        global os += (t_hop / (2 * sqrt(2))), "Cdagup", j + 1, "Cup", j
        global os += (im * t_hop / (2 * sqrt(2))), "Cdagup", j + 1, "Cdn", j
        global os += (-im * t_hop / (2 * sqrt(2))), "Cdagdn", j + 1, "Cup", j
        global os += (t_hop / (2 * sqrt(2))), "Cdagdn", j + 1, "Cdn", j
    end
else
    for j in 1:(n_sites-1)
        global os += t_hop / 2, "Cdagup", j, "Cup", j + 1
        global os += t_hop / 2, "Cdagdn", j, "Cdn", j + 1
        global os += t_hop / 2, "Cdagup", j + 1, "Cup", j
        global os += t_hop / 2, "Cdagdn", j + 1, "Cdn", j
    end
end
#scattering into bulk states
if t_scatt != 0.0
    #TODO AutoMPO doesn't support odd-parity operators
    for j in 1:(n_sites-1)
        global os += -t_scatt, "Cup", j
        global os += -t_scatt, "Cdn", j
    end
end

H = MPO(os, s)
ψ = MPS(ComplexF64, s, n -> begin
    if n == x_init
        "-" #"Up"
    elseif n == n_sites - (x_init - 1)
        "+" #"Dn"
    else
        "Emp"
    end
end)

function measure_nupdn(; psi, bond, half_sweep)
    if bond == 1 && half_sweep == 2
        return expect(psi, "Nupdn")
    end
    return nothing
end

function measure_ntot(; psi, bond, half_sweep)
    if bond == 1 && half_sweep == 2
        return expect(psi, "Ntot")
    end
    return nothing
end

obs = observer("nupdn" => measure_nupdn, "ntot" => measure_ntot)

ϕ = tdvp(
    H,
    -im * t_total,
    ψ;
    #TODO topological Hamiltonian is not hermitian?
    ishermitian=false,
    time_step=-im * t_step,
    normalize=true,
    maxdim=16,
    cutoff=cutoff,
    outputlevel=1,
    (observer!)=obs,
)

#reduce(vcat,transpose.(x)) converts Vector{Vector{Float64}} to Matrix{Float64}
nupdn = transpose(reduce(vcat, transpose.(obs.nupdn)))
ntot = transpose(reduce(vcat, transpose.(obs.ntot)))

using Plots
heatmap(ntot)