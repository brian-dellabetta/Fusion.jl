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
        repo = "github.com/brian-dellabetta/Fusion.jl",
        devbranch = "main",
        deploy_url = "brian-dellabetta.github.io/Fusion.jl",
    ),
    draft = false,
    source = "src",
    build = "build",
    pages=[
        "Home" => "index.md",
    ],
    warnonly = true,
)

deploydocs(;
    repo="github.com/brian-dellabetta/Fusion.jl",
    target="build",
    push_preview=true,
    branch = "gh-pages",
    devbranch = "main"
)
