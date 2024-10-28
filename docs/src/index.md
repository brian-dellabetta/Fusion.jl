````@raw html
---
layout: home

hero:
  name: (Ultra-)Cold Fusion?
  text: 
  tagline: Why a new state of matter is the perfect environment to realize a 50-year-old idea for cold fusion -- one that promises to be far cheaper and easier to sustain than <b>any</b> of the current leading fusion reactor designs.
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

This post is designed to support the above claim approachably and with some graphical aid. It involves some esoteric terms, but it should hopefully show the key points are rather straightforward. Please post [here](https://github.com/brian-dellabetta/Fusion.jl/issues) if you find that not to be the case anywhere along the way. *For those looking for more technical rigor, please check out [the white paper](https://github.com/brian-dellabetta/Fusion.jl/paper/paper.pdf).*

The key points are covered in the following sections:

1. [Nuclear Fusion in a Nutshell](#Nuclear-Fusion-in-a-Nutshell), everything you need to know about fusion to understand the argument.
2. [The 50-Year-Old Idea](#The-50-Year-Old-Idea) for nuclear fusion, why it is preferable to current leading candidates, and why it ultimately failed to work.
3. [The New State of Matter](#The-New-State-of-Matter) and why it is well-suited to succeed where previous attempts failed.
4. [Some Caveats](#Some-Caveats)
5. [Open Questions](#Open-Questions)

# Nuclear Fusion in a Nutshell

Fusion occurs when two atoms come in close enough proximity to combine. The most commonly considered case is Hydrogen fusion, where two Hydrogen atoms (one with one neutron, the other with two) fuse to output one Helium atom and a neutron at high velocity:

```@raw html
<img class="marginauto" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Deuterium-tritium_fusion.svg/400px-Deuterium-tritium_fusion.svg.png" />
```

This reaction, if efficiently achievable, is the holy grail of clean energy. Helium is not a greenhouse gas, not radioactive, and escapes from Earth's atmosphere over time. Output yield is *ten million times* larger than combustion.[^1] Deuterium is abundant, and (if fusion were efficiently achievable) can be fused to create tritium, which is otherwise rare.

The caveat, of course, is that this is really difficult to achieve. In order to bring deterium and tritium (which are positively charged and repel one another) close enough together to fuse, the current leading designs aim to compress and heat fuel pellets to immense pressures and temperatures (~100 million degrees Kelvin).[^2] It is reasonable to focus on this class of fusion reactor -- this is, after all, how fusion occurs in stars. But in spite of exciting recent breakthroughs, the challenges associated with creating an "artifical sun on earth" abound:

- The International Thermonuclear Experimental Reactor (ITER), a multi-country initiative to build a test reactor in France by 2035, has [an expected cost of \$22B that could swell up to \$65B](https://pubs.aip.org/physicstoday/Online/4990/ITER-disputes-DOE-s-cost-estimate-of-fusion), according to the U.S. Department of Energy.
- In the U.S., the National Ignition Facility (NIF) [achieved fusion ignition](https://www.llnl.gov/article/49306/lawrence-livermore-national-laboratory-achieves-fusion-ignition), but [at a total cost of \$3.5B](https://lasers.llnl.gov/about/faqs#nif_cost) its path to a sustainable nuclear reactor with a net-positive harvested energy remains unclear. 

These numbers are eye-watering. Hundreds of millions of degrees, tens of billions of dollars *for an experiment*. Thermonuclear fusion is a brute force approach, but it's not the only game in town. A more elegant proposal for fusion exists, and has for some time.


# The 50-Year-Old Idea

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
<video class="marginauto" autoplay loop muted playsinline controls src="./lorenz.mp4" style="max-height: 40vh;"/>
```

# The New State of Matter

Lorem ipsum

## Some Caveats

Lorem ipsum

## Open Questions

## Citations

[^1]: [Per kg, the combustion of hydrogen and oxygen yields 13 MJ, whereas the fusion of deuterium and tritium yields 3.6 x 10^8 MJ](https://ntrs.nasa.gov/api/citations/20160010608/downloads/20160010608.pdf)
[^2]: [Inertial confinement fusion](https://en.wikipedia.org/wiki/Inertial_confinement_fusion), [magnetized target fusion](https://en.wikipedia.org/wiki/Magnetized_target_fusion), [inertial electrostatic confinement](https://en.wikipedia.org/wiki/Inertial_electrostatic_confinement) and the [Tokamak](https://en.wikipedia.org/wiki/Tokamak) design all reside in the family of thermonuclear fusion reactors. The NIF project uses inertial confinement fusion, the ITER project is a Tokamak design.