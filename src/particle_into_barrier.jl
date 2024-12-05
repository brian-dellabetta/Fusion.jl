# https://docs.qojulia.org/examples/particle-into-barrier/

using QuantumOptics
using CairoMakie
using Makie

function create_plot(;
    xmin::Integer=-30,
    xmax::Integer=30,
    n_points::Integer=200,
    m::Real=1.0,
    p0s::Vector{<:Real}=[sqrt(0.1), 1, sqrt(2), sqrt(3), 2],
    V0::Real=1.0, # Height of Barrier
)
    CairoMakie.activate!()

    b_position = PositionBasis(xmin, xmax, n_points)
    b_momentum = MomentumBasis(b_position)

    #TODO Coulomb repulsion of 2 charged particles, 1/r 
    function V_coulomb(x)
        if x < -d / 2 || x > d / 2
            return 0.0
        else
            return V0
        end
    end
    V = potentialoperator(b_position, V_coulomb)

    Txp = transform(b_position, b_momentum)
    Tpx = transform(b_momentum, b_position)

    #Momentum operator p̂
    p̂ = m > 1e-15 ? momentum(b_momentum)^2 / (2 * m) : momentum(b_momentum)

    Hkin = LazyProduct(Txp, p̂, Tpx)
    H = LazySum(Hkin, V)

    xpoints = samplepoints(b_position)

    x0 = -15
    sigma0 = 4
    timecuts = 20

    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin=(0.1, 0.1), xautolimitmargin=(0.1, 0.1))
    colors = Makie.wong_colors()

    for i_p in eachindex(p0s)
        p0 = p0s[i_p]
        Ψ₀ = gaussianstate(b_position, x0, p0, sigma0)
        scaling = 1.0 / maximum(abs.(Ψ₀.data))^2 / 5
        n0 = abs.(Ψ₀.data) .^ 2 .* scaling

        tmax = 2 * abs(x0) / (p0 + 0.2)
        T = collect(range(0.0, stop=tmax, length=timecuts))
        tout, Ψt = timeevolution.schroedinger(T, Ψ₀, H)

        offset = real.(expect(Hkin, Ψ₀))
        #plot initial state
        lines!(ax, xpoints, n0 .+ offset, linestyle=:dash, color=colors[i_p])
        #plot intermediate states
        for i = 1:length(T)
            Ψ = Ψt[i]
            n = abs.(Ψ.data) .^ 2 .* scaling
            lines!(ax, xpoints, n .+ offset, alpha=0.3, color=colors[i_p])
        end
        #plot final state
        nt = abs.(Ψt[timecuts].data) .^ 2 * scaling
        lines!(ax, xpoints, nt .+ offset, color=colors[i_p])
    end
    y = V_barrier.(xpoints)
    lines!(ax, xpoints, y, color=:black)

    fig
end