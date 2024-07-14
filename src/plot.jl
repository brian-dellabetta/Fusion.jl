using GLMakie

include("utils.jl")

Base.@kwdef mutable struct Lorenz
    dt::Float64 = 0.01
    σ::Float64 = 10
    ρ::Float64 = 28
    β::Float64 = 8 / 3
    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1
end

function step!(l::Lorenz)
    dx = l.σ * (l.y - l.x)
    dy = l.x * (l.ρ - l.z) - l.y
    dz = l.x * l.y - l.β * l.z
    l.x += l.dt * dx
    l.y += l.dt * dy
    l.z += l.dt * dz
    Point3f(l.x, l.y, l.z)
end

attractor = Lorenz()

points = Observable(Point3f[])
colors = Observable(Int[])

set_theme!(theme_black())

#domains
X::NTuple{2,Float32} = (-30.0, 30.0)
Y::NTuple{2,Float32} = (-30.0, 30.0)
Z::NTuple{2,Float32} = (0.0, 50.0)
origin = Point3f((X[2] - X[1]) / 2, (Y[2] - Y[1]) / 2, (Z[2] - Z[1]) / 2)

fig, ax, l = lines(points, color=colors,
    colormap=:inferno, transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(X[1], X[2], Y[1], Y[2], Z[1], Z[2])))
ax.xticklabelsvisible = ax.yticklabelsvisible = ax.zticklabelsvisible = false
ax.xlabel = ax.ylabel = ax.zlabel = ""

#plot hexagonal lattice
let
    #lattice constant
    a0 = 2.0
    #unit cell vectors
    a1 = Point3f(0, a0, 0)
    a2 = Point3f(a0 * sqrt(3) / 2, -a0 / 2, 0)

    ps::Array{NTuple{2,Point3f}} = []
    n_rows = 5
    n_cols = 7
    for col_idx in 0:n_cols-1, row_idx in 0:n_rows-1
        #odd rows
        p1 = Point3f(col_idx * a0 * sqrt(3), row_idx * a0 * (1 + sqrt(3)), origin[2])
        push!(ps, (p1, p1 + a1))
        push!(ps, (p1, p1 + a2))
        push!(ps, (p1, p1 + a2 .* (-1, 1, 1)))
        #even rows
        p2 = p1 - a1 + a2
        push!(ps, (p2, p2 + a1))
        push!(ps, (p2, p2 + a2))
        push!(ps, (p2, p2 + a2 .* (-1, 1, 1)))
    end

    linesegments!(ps, color=:white)
end




record(fig, "lorenz.mp4", 1:120) do frame_idx
    for i in 1:50
        push!(points[], step!(attractor))
        push!(colors[], 1)
    end
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame_idx / 120)
    notify(points)
    notify(colors)
    # l.colorrange = (0, frame_idx)
end