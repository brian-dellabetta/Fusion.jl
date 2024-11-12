using GLMakie


function create_movie(
    atoms::AbstractArray{<:Atom},
    lattice::Lattice,
    filename::String;
    domain=(Point3f(-30.0, -30.0, -10.0), Point3f(30.0, 30.0, 10.0)),
    n_steps_per_frame::Integer=7,
    n_frames::Integer=180
)
    GLMakie.activate!()

    #for simplicity, require all atoms have same tail_length
    tail_length = length(atoms) > 0 ? atoms[1].tail_length : 1
    @assert all(atom -> atom.tail_length == tail_length, atoms)

    set_theme!(theme_black())

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

    #initialize
    step!(atoms, lattice; n_steps=tail_length)
    let
        up_color = to_color(:magenta)
        down_color = to_color(:cyan)
        up_tail_color = [RGBAf(up_color.r, up_color.g, up_color.b, (i / tail_length)^2) for i in 1:tail_length]
        down_tail_col = [RGBAf(down_color.r, down_color.g, down_color.b, (i / tail_length)^2) for i in 1:tail_length]
        for atom in atoms
            scatter!(atom.r, color=atom.is_spin_up ? up_color : down_color, markersize=10)
            lines!(atom.tail, color=atom.is_spin_up ? up_tail_color : down_tail_col, transparency=true, linewidth=4)
        end
    end

    record(fig, filename, 1:n_frames) do frame_idx
        step!(atoms, lattice; n_steps=n_steps_per_frame)
        ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame_idx / n_frames)
        ax.elevation[] = pi / 6
    end

end