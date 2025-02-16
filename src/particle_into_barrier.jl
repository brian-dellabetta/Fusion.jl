# https://docs.qojulia.org/examples/particle-into-barrier/

using QuantumOptics
using CairoMakie
using Makie

# Matching model variables as shown in Table 1 of 
# https://journals.aps.org/prc/abstract/10.1103/PhysRevC.110.034614
# Treating Deuterium as projectile at x>0 moving leftward towards Tritium target at x=0

function create_plot(;
    #Toggle to switch between linear and parabolic dispersion
    use_linear_dispersion::Bool,
    #System parameters, 2000fm with step size Δr = 0.5fm, target proton at x=0
    xmin::Real=0,
    xmax::Real=2000e-15,
    n_points::Integer=4000,
    #Position of projectile initial wave packet
    x0::Real=1200e-15,
    #Mass of nucelon in kg, for parabolic dispersion
    m0::Real=1.675e-27,
    #Fermi velocity in m/s, for linear dispersion
    vF::Real=1.0e-3,
    #Initial wavepacket spatial width, set to very high for linear dispersion
    σ0::Real=300e-15,
    #Initial momenta of wavepacket, should be <= 0 as particle is moving right to left
    p0s::Vector{<:Real}=[0.0, -sqrt(0.1), -1, -sqrt(2), -sqrt(3), -2],
    #Time step of 0.1 zs, run for ~100s of zs
    Δt::Real=0.1e-21,
    tmax::Real=300e-21,
    #Proton numbers
    ZD::Integer=1,
    ZT::Integer=1,
    #Mass numbers
    AD::Integer=2,
    AT::Integer=3,
    #Potential operator variables
    R0::Real=0.95e-15, #Nuclear radius
    a0::Real=0.55e-15, #Nucelar diffuseness
    V0::Real=40.4e6, #Wood-Saxon potential depth (40.4 MeV)
    Ri::Real=0.9e-15, #Absorption radius
    ai::Real=0.3e-15, #Absorption diffuseness
    W0::Real=500e6, #Absorption potential depth (500 MeV)
)
    CairoMakie.activate!()

    #Both the nuclear and absorption radius parameters, 𝑅0 and 𝑅𝑖, should be multiplied by the dimensionless factor
    R0 = R0 * (AD^(1 / 3) + AT^(1 / 3))
    Ri = Ri * (AD^(1 / 3) + AT^(1 / 3))

    b_position = PositionBasis(xmin, xmax, n_points)
    b_momentum = MomentumBasis(b_position)
    Txp = transform(b_position, b_momentum)
    Tpx = transform(b_momentum, b_position)
    xpoints = samplepoints(b_position)

    #Hamiltonian kinetic term is either parabolic (-ħ^2/2μ ∂^2/∂x^2) or linear (-ħ*vF ∂/∂x)
    Hkin = begin
        hbar = 6.5821e-16 #units of eV⋅s
        op = begin
            if use_linear_dispersion
                -hbar * vF * momentum(b_momentum)
            else
                μ = m0 * AT * AD / (AT + AD)
                -hbar^2 / (2 * μ) * (momentum(b_momentum)^2)
            end
        end
        LazyProduct(Txp, op, Tpx)
    end

    #Potential term, Eqs. 5-7
    function Vx(x)
        #Coulomb energy between two charged particles = ZT*ZD*k*e^2 / x
        #k = 8.99e9
        #e = 1.602e-19
        #divide by e again to get in units of eV
        # julia> 8.99e9*(1.602e-19)
        # 1.4401524897432e-9
        V_Coulomb = ZT * ZD * 1.44015e-9 / x
        V_Nuclear = V0 / (1 + exp((x - R0) / a0))
        V_Absorption = W0 / (1 + exp((x - Ri) / ai))

        return V_Coulomb - V_Nuclear + im * (-V_Absorption)
    end
    Hpot = potentialoperator(b_position, Vx)

    H = LazySum(Hkin, Hpot)

    n_timeintervals = Int(floor(tmax / Δt))

    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin=(0.1, 0.1), xautolimitmargin=(0.1, 0.1))
    colors = Makie.wong_colors()

    for (i_p, p0) in enumerate(p0s)
        Ψ₀ = gaussianstate(b_position, x0, p0, σ0)
        scaling = 1.0 / maximum(abs.(Ψ₀.data))^2 / 5
        n0 = abs.(Ψ₀.data) .^ 2 .* scaling

        T = collect(range(0.0, stop=tmax, length=n_timeintervals))
        tout, Ψt = timeevolution.schroedinger(T, Ψ₀, H) #; maxiters=1e8

        offset = real.(expect(Hkin, Ψ₀))
        #plot initial state
        lines!(ax, xpoints, n0 .+ offset, linestyle=:dash, color=colors[i_p])
        #plot intermediate states
        for (i, Ψ) in enumerate(Ψt)
            n = abs.(Ψ.data) .^ 2 .* scaling
            lines!(ax, xpoints, n .+ offset, alpha=(i / n_timeintervals), color=colors[i_p])
        end
        #plot final state
        nt = abs.(Ψt[end].data) .^ 2 * scaling
        lines!(ax, xpoints, nt .+ offset, color=colors[i_p])
    end
    y = Real(Vx.(xpoints) ./ 1e3)
    lines!(ax, xpoints, y, color=:black)

    fig
end