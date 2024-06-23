using Documenter, DocumenterVitepress

using Fusion

makedocs(;
    modules=[Fusion],
    authors="Brian Dellabetta",
    repo="https://github.com/brian-dellabetta/Fusion.jl",
    sitename="Fusion",
    format=DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/brian-dellabetta/Fusion.jl",
        devurl = "main",
        devbranch = "main",
        deploy_url = "brian-dellabetta.github.io/Fusion.jl",
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly = true,
)

deploydocs(;
    repo="github.com/brian-dellabetta/Fusion.jl",
    push_preview=true,
    branch = "gh-pages",
    devbranch = "main"
)
