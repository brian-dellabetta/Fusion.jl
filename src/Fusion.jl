module Fusion
using GeometryBasics, Observables
import GeometryBasics: Point3f

Line3f = Tuple{Point3f,Point3f}

TAIL_LENGTH = 10

include("lattice.jl")
include("atom.jl")
include("plot.jl")

export Atom, Lattice, plot_record, step!, Point3f, Line3f

end