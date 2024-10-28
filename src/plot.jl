using GLMakie


Line3f = Tuple{Point3f,Point3f}
Base.@kwdef mutable struct Atom
    r::Point3f = Point3f(0.0, 0.0, 0.0)
    is_spin_up::Bool = true
end

struct Lattice
    points::Vector{Point3f}
    lines::Vector{Line3f}

    function Lattice(
        #domain
        domain::Line3f,
        #lattice constant
        a0::Float32=2.0f0,
    )
        X = (domain[1][1], domain[2][1])
        Y = (domain[1][2], domain[2][2])
        Z = (domain[1][3], domain[2][3])

        #unit cell vectors
        a = a0 * sqrt(3)
        a1 = Point3f(0, a0, 0)
        a2 = Point3f(a0 * sqrt(3) / 2, -a0 / 2, 0)

        #size
        n_rows = ceil(Int, (Y[2] - Y[1]) / (a * sqrt(3)))
        n_cols = ceil(Int, (X[2] - X[1]) / a)

        points::Vector{Point3f} = []
        lines::Vector{Line3f} = []

        for col_idx in 0:n_cols-1, row_idx in 0:n_rows-1
            #odd rows
            p1 = Point3f(
                X[1] + (col_idx * a0 * sqrt(3)),
                Y[1] + (row_idx * a0 * (1 + sqrt(3))),
                (Z[2] - Z[1]) / 2,
            )
            push!(points, p1)
            if row_idx != n_rows - 1
                push!(lines, (p1, p1 + a1))
            end
            if row_idx != n_rows - 1 || col_idx != 0
                push!(lines, (p1, p1 + a2))
            end
            if col_idx != 0
                push!(lines, (p1, p1 + a2 .* (-1, 1, 1)))
            end
            #even rows
            p2 = p1 - a1 + a2
            push!(points, p2)
            push!(lines, (p2, p2 + a1))
            if (col_idx != n_cols - 1)
                push!(lines, (p2, p2 + a2))
            end
            if (col_idx != 0 || row_idx != 0)
                push!(lines, (p2, p2 + a2 .* (-1, 1, 1)))
            end
        end

        new(points, lines)
    end
end

function step!(a::Atom, l::Lattice)
    dr = Point3f(10 * cos(a.r[1] / 10), 10 * cos(a.r[2] / 10), 0.0)
    a.r += dr
end


domain = (Point3f(-30.0, -30.0, -30.0), Point3f(30.0, 30.0, 30.0))
lattice_domain = (Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0))
attractor = Atom()
lattice = Lattice(lattice_domain)
points = Observable(Point3f[])
colors = Observable(Int[])

set_theme!(theme_black())

fig, ax, l = lines(points, color=colors,
    colormap=:inferno, transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(domain[1][1], domain[2][1], domain[1][2], domain[2][2], domain[1][3], domain[2][3])))
ax.xticklabelsvisible = ax.yticklabelsvisible = ax.zticklabelsvisible = false
ax.xlabel = ax.ylabel = ax.zlabel = ""

linesegments!(lattice.lines, color=:grey95, linewidth=0.5)

record(fig, "lorenz.mp4", 1:120) do frame_idx
    for i in 1:50
        step!(attractor, lattice)
        push!(points[], attractor.r)
        push!(colors[], 1)
    end
    ax.azimuth[] = 1.7pi + 0.5 * sin(2pi * frame_idx / 120)
    notify(points)
    notify(colors)
    # l.colorrange = (0, frame_idx)
end
