using DataStructures: CircularBuffer

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