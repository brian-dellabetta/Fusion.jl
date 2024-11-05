using GLMakie


function plot_record(
    atoms::AbstractArray{<:Atom},
    lattice::Lattice,
    filename::String,
    domain=(Point3f(-30.0, -30.0, -10.0), Point3f(30.0, 30.0, 10.0)),
)
    GLMakie.activate!()

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
    step!(atoms, lattice; n_steps=TAIL_LENGTH)
    let
        up_color = to_color(:red)
        down_color = to_color(:blue)
        up_tail_color = [RGBAf(up_color.r, up_color.g, up_color.b, (i / TAIL_LENGTH)^2) for i in 1:TAIL_LENGTH]
        down_tail_col = [RGBAf(down_color.r, down_color.g, down_color.b, (i / TAIL_LENGTH)^2) for i in 1:TAIL_LENGTH]
        for atom in atoms
            scatter!(atom.r, color=atom.is_spin_up ? up_color : down_color, markersize=10)
            lines!(atom.tail, color=atom.is_spin_up ? up_tail_color : down_tail_col, transparency=true, linewidth=4)
        end
    end

    record(fig, filename, 1:120) do frame_idx
        step!(atoms, lattice; n_steps=7)
        ax.azimuth[] = 1.7pi + 0.5 * sin(2pi * frame_idx / 120)
        ax.elevation[] = pi / 6
    end

end