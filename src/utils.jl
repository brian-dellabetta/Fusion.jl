using GLMakie

function dist(p1::Point3f, p2::Point3f)
    sqrt((p2[1] - p1[1])^2 + (p2[2] - p1[2])^2 + (p2[3] - p1[3])^2)
end