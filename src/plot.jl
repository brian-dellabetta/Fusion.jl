using GLMakie
using DataStructures: CircularBuffer

Line3f = Tuple{Point3f,Point3f}

TAIL_LENGTH = 10

Base.@kwdef mutable struct Atom
    edge_idx::Integer = 1
    is_spin_up::Bool = true
    r::Observable{Point3f} = Observable(Point3f(0.0, 0.0, 0.0))
    tail::Observable{CircularBuffer{Point3f}} = begin
        t = CircularBuffer{Point3f}(TAIL_LENGTH)
        fill!(t, r[])
        Observable(t)
    end
end

struct Lattice
    a0::Float32
    points::Vector{Vector{Point3f}}
    edge_points::Vector{Point3f}
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
            a0,
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

    a.r[] = l.edge_points[a.edge_idx]
    push!(a.tail[], a.r[])
    a.tail[] = a.tail[] #to trigger notify
end
function step!(as::AbstractArray{<:Atom}, l::Lattice; n_steps::Integer=1)
    for _ = 1:n_steps
        [step!(a, l) for a in as]
    end
end

## Main run
set_theme!(theme_black())


domain = (Point3f(-30.0, -30.0, -10.0), Point3f(30.0, 30.0, 10.0))
lattice_domain = (Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0))
lattice = Lattice(lattice_domain)


fig, ax, l = linesegments(
    lattice.lines,
    color=:grey95,
    linewidth=0.5,
    transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(domain[1][1], domain[2][1], domain[1][2], domain[2][2], domain[1][3], domain[2][3]))
)
ax.xticklabelsvisible = ax.yticklabelsvisible = ax.zticklabelsvisible = false
# ax.xlabel = ax.ylabel = ax.zlabel = ""

# spin up atoms
up_atoms = [Atom()]
up_color = to_color(:red)
# spin down atoms
down_atoms = [Atom(is_spin_up=false)]
down_color = to_color(:blue)

#initialize
for idx = 1:TAIL_LENGTH
    step!(vcat(up_atoms, down_atoms), lattice)
end
let
    tailcol = [RGBAf(up_color.r, up_color.g, up_color.b, (i / TAIL_LENGTH)^2) for i in 1:TAIL_LENGTH]
    for atom in up_atoms
        scatter!(atom.r, color=up_color, markersize=10)
        lines!(atom.tail, color=tailcol, transparency=true, linewidth=4)
    end
end
let
    tailcol = [RGBAf(down_color.r, down_color.g, down_color.b, (i / TAIL_LENGTH)^2) for i in 1:TAIL_LENGTH]
    for atom in down_atoms
        scatter!(atom.r, color=down_color, markersize=10)
        lines!(atom.tail, color=tailcol, transparency=true, linewidth=4)
    end
end

record(fig, "lorenz.mp4", 1:120) do frame_idx
    step!(vcat(up_atoms, down_atoms), lattice; n_steps=7)
    ax.azimuth[] = 1.7pi + 0.5 * sin(2pi * frame_idx / 120)
    ax.elevation[] = pi / 6
end
