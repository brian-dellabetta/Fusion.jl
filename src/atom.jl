using DataStructures: CircularBuffer

mutable struct Atom
    #if >0, the atom is in a topological mode and r==lattice.edge_points[edge_idx]
    #if <0, the atom is in free space, outside of a topological mode, at location r
    edge_idx::Integer
    is_spin_up::Bool
    r::Observable{Point3f}
    tail_length::Integer
    tail::Observable{CircularBuffer{Point3f}}

    function Atom(;
        edge_idx::Integer=-1,
        is_spin_up::Bool=true,
        r::Point3f=Point3f(0.0, 0.0, 0.0),
        tail_length::Integer=10)

        tail::Observable{CircularBuffer{Point3f}} = begin
            t = CircularBuffer{Point3f}(tail_length)
            fill!(t, r)
            Observable(t)
        end
        new(edge_idx, is_spin_up, Observable(r), tail_length, tail)
    end
end


function step!(a::Atom, l::Lattice; clip_distance::Real=0.5)
    #if not in edge state, slowly moved it towards the lattice
    if a.edge_idx < 0
        x, y, z = a.r[]
        if abs(z) < clip_distance
            a.edge_idx = 1
        else
            a.r[] = Point3f(x, y, z - sign(z) * (clip_distance / 5))
        end
    else
        #rotate around edge mode, based on spin
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
    end

    push!(a.tail[], a.r[])
    a.tail[] = a.tail[] #to trigger notify
end
function step!(atoms::AbstractArray{<:Atom}, l::Lattice; clip_distance::Real=0.5, n_steps::Integer=1)
    for _ = 1:n_steps
        [step!(a, l; clip_distance) for a in atoms]
    end
end