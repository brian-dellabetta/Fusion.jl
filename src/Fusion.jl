module Fusion
using GeometryBasics, Observables
import GeometryBasics: Point3f

Line3f = Tuple{Point3f,Point3f}

include("lattice.jl")
include("atom.jl")
include("plot.jl")

export Atom, Lattice, create_movie, step!, Point3f, Line3f

end