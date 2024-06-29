````@raw html
---
layout: home

hero:
  name: Fusion
  text: 
  tagline: Why a brand new state of matter provides the perfect environment to realize a 50-year-old idea for cold fusion -- one that promises to be far easier to sustain than <b>any</b> of the current leading candidates for fusion power.
  image:
    src: logo.png
    alt: Fusion
  actions:
    - theme: brand
      text: Getting started
      link: /tutorials/getting-started
    - theme: alt
      text: View on Github
      link: https://github.com/brian-dellabetta/Fusion.jl
---
````

# Introduction 

This post is designed to support the above claim approachably and with some graphical aid. It involves some esoteric terms, but the graphical aids should hopefully show the key points are rather straightforward. Please post [here](https://github.com/brian-dellabetta/Fusion.jl/issues) if you find that not to be the case anywhere along the way. *For those looking for more technical rigor, please check out [the white paper](https://github.com/brian-dellabetta/Fusion.jl/paper/paper.pdf).*

The key points are covered in the following sections:

1. [Basics of Nuclear Fusion](#Basics-of-Nuclear-Fusion)
2. [The 50-Year-Old Idea](#The-50-Year-Old-Idea) for nuclear fusion, why it is preferable to current leading candidates, and why it ultimately failed to work.
3. [The New State of Matter](#The-New-State-of-Matter) and why it is well-suited to succeed.
4. [Some Caveats](#Some-Caveats)
5. [Open Questions](#Open-Questions)

## Basics of Nuclear Fusion

Fusion occurs when two atoms come close enough together for the strong nuclear force

## The 50-Year-Old Idea

() that the The idea is called "Colliding Beam Fusion"


::: details Show me the code

```@example
using GLMakie
GLMakie.activate!() # hide

Base.@kwdef mutable struct Lorenz
    dt::Float64 = 0.01
    σ::Float64 = 10
    ρ::Float64 = 28
    β::Float64 = 8/3
    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1
end

function step!(l::Lorenz)
    dx = l.σ * (l.y - l.x)
    dy = l.x * (l.ρ - l.z) - l.y
    dz = l.x * l.y - l.β * l.z
    l.x += l.dt * dx
    l.y += l.dt * dy
    l.z += l.dt * dz
    Point3f(l.x, l.y, l.z)
end

attractor = Lorenz()

points = Observable(Point3f[])
colors = Observable(Int[])

set_theme!(theme_black())

fig, ax, l = lines(points, color = colors,
    colormap = :inferno, transparency = true, 
    axis = (; type = Axis3, protrusions = (0, 0, 0, 0), 
              viewmode = :fit, limits = (-30, 30, -30, 30, 0, 50)))

record(fig, "lorenz.mp4", 1:120) do frame
    for i in 1:50
        push!(points[], step!(attractor))
        push!(colors[], frame)
    end
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)
    notify(points)
    notify(colors)
    l.colorrange = (0, frame)
end
set_theme!() # hide
```
:::

```@raw html
<video autoplay loop muted playsinline controls src="./lorenz.mp4" style="max-height: 40vh;"/>
```

## The New State of Matter

Lorem ipsum

## Some Caveats

Lorem ipsum

## Open Questions