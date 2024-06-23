using GLMakie

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

fig, ax, l = lines(points, color=colors,
    colormap=:inferno, transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(-30, 30, -30, 30, 0, 50)))

ax.xticklabelsvisible = ax.yticklabelsvisible = ax.zticklabelsvisible = false
ax.xlabel = ax.ylabel = ax.zlabel = ""

x, y = collect(-30:5:30), collect(-30:5:30)
# z = [100 * sinc(√(X^2 + Y^2) / π) for X ∈ x, Y ∈ y]
z = [25 for X ∈ x, Y ∈ y]
wireframe!(x, y, z, color=:white)


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