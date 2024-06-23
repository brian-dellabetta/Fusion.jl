using Documenter, DocumenterVitepress

# using YourPackage

makedocs(;
    modules=[YourPackage],
    authors="Brian Dellabetta",
    repo="https://github.com/brian-dellabetta/fusion",
    sitename="Fusion",
    format=DocumenterVitepress.MarkdownVitepress(
        repo = "github.com/brian-dellabetta/fusion",
        devurl = "main",
        devbranch = "main",
        deploy_url = "brian-dellabetta.github.io/fusion",
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly = true,
)

deploydocs(;
    repo="github.com/brian-dellabetta/fusion",
    push_preview=true,
    branch = "gh-pages",
    devbranch = "main"
)
