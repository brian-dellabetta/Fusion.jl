using GLMakie


Line3f = Tuple{Point3f,Point3f}

Base.@kwdef mutable struct Atom
    r::Point3f = Point3f(0.0, 0.0, 0.0)
    edge_idx::Integer = 1
    is_spin_up::Bool = true
end

struct Lattice
    points::Vector{Vector{Point3f}}
    edge_points::Vector{Point3f}
    lines::Vector{Line3f}

    function Lattice(
        #domain
        domain::Line3f,
        #lattice constant
        a0::Float32=4.0f0,
    )
        X = (domain[1][1], domain[2][1])
        Y = (domain[1][2], domain[2][2])
        Z = (domain[1][3], domain[2][3])

        #unit cell vectors
        # https://pmc.ncbi.nlm.nih.gov/articles/PMC6116708/
        a = a0 * sqrt(3)
        d1 = Point3f(0, a0, 0)
        d2 = Point3f(a0 * sqrt(3) / 2, -a0 / 2, 0)
        d3 = Point3f(-a0 * sqrt(3) / 2, -a0 / 2, 0)

        a1 = Point3f(a0 / 2, a0 * sqrt(3) / 2, 0)
        a2 = Point3f(a0 / 2, -a0 * sqrt(3) / 2, 0)

        #size
        ny = ceil(Int, (Y[2] - Y[1]) / (a0 * 3)) #(a * sqrt(3))
        nx = ceil(Int, (X[2] - X[1]) / a)

        lines::Vector{Line3f} = []
        points::Vector{Vector{Point3f}} = []
        top_points::Vector{Point3f} = []
        right_points::Vector{Point3f} = []
        left_points::Vector{Point3f} = []
        bottom_points::Vector{Point3f} = []

        for x_idx in 0:nx-1
            odd_points::Vector{Point3f} = []
            even_points::Vector{Point3f} = []
            for y_idx in 0:ny-1
                #odd rows
                p1 = Point3f(
                    X[1] + (x_idx * a0 * sqrt(3)),
                    Y[1] + (y_idx * a0 * (1 + sqrt(3))),
                    (Z[2] - Z[1]) / 2,
                )
                push!(odd_points, p1)
                if y_idx != ny - 1
                    push!(lines, (p1, p1 + d1))
                end
                if y_idx != ny - 1 || x_idx != 0
                    push!(lines, (p1, p1 + d2))
                end
                if x_idx != 0
                    push!(lines, (p1, p1 + d3))
                end

                #even rows
                p2 = p1 - (d1 .* (sqrt(3) / 2)) + d2
                push!(even_points, p2)
                push!(lines, (p2, p2 + d1))
                if (x_idx != nx - 1)
                    push!(lines, (p2, p2 + d2))
                end
                if (x_idx != 0 || y_idx != 0)
                    push!(lines, (p2, p2 + d3))
                end

                #edge points
                if x_idx == 0
                    push!(top_points, p2)
                    push!(top_points, p2 + d1)
                    if y_idx != ny - 1
                        push!(top_points, p1)
                        push!(top_points, p1 + d1)
                    end
                elseif y_idx == ny - 1
                    push!(right_points, p1)
                    push!(right_points, p1 + d2)
                end
                if x_idx == nx - 1
                    push!(bottom_points, p2 + d3)
                    push!(bottom_points, p2)
                    if y_idx != ny - 1
                        push!(bottom_points, p1 + d2)
                        push!(bottom_points, p1)
                    end
                elseif y_idx == 0
                    push!(left_points, p2)
                    push!(left_points, p2 + d2)
                end
            end
            push!(points, odd_points)
            push!(points, even_points)
        end

        new(
            points,
            vcat(top_points, right_points, bottom_points[end:-1:1], left_points[end:-1:1]),
            lines
        )
    end
end

function step!(a::Atom, l::Lattice)
    if a.is_spin_up
        if a.edge_idx == length(l.edge_points)
            a.edge_idx = 1
        else
            a.edge_idx += 1
        end
    else
        if a.edge_idx == 1
            a.edge_idx = length(l.edge_points)
        else
            a.edge_idx -= 1
        end
    end

    a.r = l.edge_points[a.edge_idx]
end


spin_up_atom = Atom()
spin_down_atom = Atom(is_spin_up=false)
tails = Observable(Point3f[])
atoms = Observable(Point3f[])

domain = (Point3f(-30.0, -30.0, -10.0), Point3f(30.0, 30.0, 10.0))
lattice_domain = (Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0))
lattice = Lattice(lattice_domain)

colors = Observable(Int[])
set_theme!(theme_black())

fig, ax, l = linesegments(
    lattice.lines,
    color=:grey95,
    linewidth=0.5,
    transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(domain[1][1], domain[2][1], domain[1][2], domain[2][2], domain[1][3], domain[2][3]))
)
# ax.xticklabelsvisible = ax.yticklabelsvisible = ax.zticklabelsvisible = false
# ax.xlabel = ax.ylabel = ax.zlabel = ""

lines!(tails, color=colors, transparency=true)
scatter!(atoms, color=:yellow, markersize=10)

record(fig, "lorenz.mp4", 1:120) do frame_idx
    for i in 1:50
        step!(spin_up_atom, lattice)
        push!(tails[], spin_up_atom.r)
        atoms[] = [spin_up_atom.r]
        step!(spin_down_atom, lattice)
        push!(colors[], i)
    end
    ax.azimuth[] = 1.7pi + 0.5 * sin(2pi * frame_idx / 120)
    ax.elevation[] = pi / 6
    notify(tails)
    notify(colors)
    # l.colorrange = (0, frame_idx / 1000)
end
