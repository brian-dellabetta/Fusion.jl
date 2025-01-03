using Documenter, DocumenterVitepress

using GLMakie

# remove GLMakie's renderloop completely, because any time `GLMakie.activate!()`
# is called somewhere, it's reactivated and slows down CI needlessly
function GLMakie.renderloop(screen)
    return
end

using Fusion

makedocs(;
    modules=[Fusion],
    authors="Brian Dellabetta",
    repo="https://github.com/brian-dellabetta/Fusion.jl",
    sitename="Fusion",
    format=DocumenterVitepress.MarkdownVitepress(
        repo="github.com/brian-dellabetta/Fusion.jl",
        devbranch="main",
    ),
    draft=false,
    clean=true,
    source="src",
    build="build",
    pages=[
        "Home" => "index.md",
        "Colliding Beam Fusion" => "colliding_beam_fusion.md",
        "Appendices" => [
            "Nuclear Fusion in a Nutshell" => "nuclear_fusion_nutshell.md"
        ]
    ],
    warnonly=true,
)


#Copy static assets, namely whitepaper pdf in src/assets
file_name = "Ultracold_Fusion.pdf"
paper_src_dir = joinpath(@__DIR__, "src", "assets")
paper_dst_dir = joinpath(@__DIR__, "build", "assets")
mkpath(paper_dst_dir)
cp(
    joinpath(paper_src_dir, file_name),
    joinpath(paper_dst_dir, file_name),
)

deploydocs(;
    repo="github.com/brian-dellabetta/Fusion.jl",
    target="build",
    branch="gh-pages",
    devbranch="main"
)
