# https://docs.qojulia.org/examples/particle-into-barrier/

using QuantumOptics
using CairoMakie
using Makie

function create_plot(;
    xmin::Real=0,
    xmax::Real=4000.0,
    x0::Real=15,
    n_points::Integer=2000,
    m::Real=1.0,
    p0s::Vector{<:Real}=[0.0, sqrt(0.1), 1, sqrt(2), sqrt(3), 2],
    V0::Real=500.0, # Max height of Coulomb Barrier
    d::Real=2000.0, #Width of Coulomb Barrier
)
    CairoMakie.activate!()

    b_position = PositionBasis(xmin, xmax, n_points)
    b_momentum = MomentumBasis(b_position)
    Txp = transform(b_position, b_momentum)
    Tpx = transform(b_momentum, b_position)
    xpoints = samplepoints(b_position)

    #Hamiltonian kinetic term is either parabolic (p^2/2m) or linear (p)
    Hkin = begin
        op = m > 1e-15 ? (momentum(b_momentum)^2 / (2 * m)) : momentum(b_momentum)
        LazyProduct(Txp, op, Tpx)
    end

    #Coulomb repulsion of 2 charged particles, 1/r 
    function V_Coulomb(x)
        if abs(x - xmax) > d
            return V0 / abs(x - (xmax - d))
        else
            return 0.0 #-V0 * 2
        end
    end
    V = potentialoperator(b_position, V_Coulomb)

    H = LazySum(Hkin, V)

    sigma0 = 4
    timecuts = 20
    tmax = 2400

    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin=(0.1, 0.1), xautolimitmargin=(0.1, 0.1))
    colors = Makie.wong_colors()

    for (i_p, p0) in enumerate(p0s)
        Ψ₀ = gaussianstate(b_position, x0, p0, sigma0)
        scaling = 1.0 / maximum(abs.(Ψ₀.data))^2 / 5
        n0 = abs.(Ψ₀.data) .^ 2 .* scaling

        T = collect(range(0.0, stop=tmax, length=timecuts))
        tout, Ψt = timeevolution.schroedinger(T, Ψ₀, H; maxiters=1e8)

        offset = real.(expect(Hkin, Ψ₀))
        #plot initial state
        lines!(ax, xpoints, n0 .+ offset, linestyle=:dash, color=colors[i_p])
        #plot intermediate states
        for (i, Ψ) in enumerate(Ψt)
            n = abs.(Ψ.data) .^ 2 .* scaling
            lines!(ax, xpoints, n .+ offset, alpha=(i / timecuts), color=colors[i_p])
        end
        #plot final state
        nt = abs.(Ψt[timecuts].data) .^ 2 * scaling
        lines!(ax, xpoints, nt .+ offset, color=colors[i_p])
    end
    y = V_Coulomb.(xpoints) ./ 1e3
    lines!(ax, xpoints, y, color=:black)

    fig
end