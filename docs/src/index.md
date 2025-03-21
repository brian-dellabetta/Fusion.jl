````@raw html
---
layout: home

hero:
  name: Ultracold Fusion?
  text: 
  tagline: Why a new state of matter is the perfect environment to realize a 50-year-old idea for cold fusion -- one that promises to be far cheaper and easier to sustain than <b>any</b> of the current leading candidates.
  image:
    src: logo.png
    alt: Fusion
  <!-- actions:
    - theme: brand
      text: Getting started
      link: /tutorials/getting-started
    - theme: alt
      text: View on Github
      link: https://github.com/brian-dellabetta/Fusion.jl -->
---
````

This post is designed to support the above claim approachably and with some graphical aid. It involves some esoteric physics (both new and old) but it should hopefully show the main idea is rather straightforward. Please post [here](https://github.com/brian-dellabetta/Fusion.jl/issues) if you find that not to be the case anywhere along the way. *For those looking for more technical rigor, please check out [the white paper](assets/Ultracold_Fusion.pdf).*

# Introduction 

[Ultracold atoms](https://en.wikipedia.org/wiki/Ultracold_atom) are one of the most fascinating emerging technologies in physics today. Using lasers to trap and cool atoms to within a millionth of a degree of absolute zero, scientists can manipulate them into exotic states of matter or even use them as quantum computers[^qc].

We will focus on one class of these exotic states, namely *topological* states of matter, which have recently been realized for ultracold atoms in a carefully designed hexagonal optical lattice (i.e. a honeycomb-shaped lattice formed of laser light)[^a]. Entire courses are dedicated to the rich history of topological phases of matter[^topcondmat], but for our purposes we only need to know about one signature -- the presence of conductive modes along the boundary of the topological phase, known as "topological edge modes". If a few ultracold atoms were placed into that edge mode, they would propagate along the boundary:

```@setup
using Fusion

create_movie(
  [Atom(r=Point3f(-20.0, -20.0, z), v=Point3f(0.0, 0.0, -0.1), tail_length=5) for z in (3.0, 6.0, 9.0)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_up.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_up.mp4" style="max-height: 60vh;"/>
```

The number and orientation of these edge modes depends on the specific topological phase. In another phase, the "chirality" of the conductive band can be flipped, flipping the spin and velocity of the atom (here cyan color is used to denote that this atom is spin-down, its spin points in the opposite direction of the magenta spin-up atoms shown above):

```@setup
using Fusion

create_movie(
  [Atom(r=Point3f(-20.0, -20.0, z), v=Point3f(0.0, 0.0, -0.1), tail_length=5, is_spin_up=false) for z in (3.0, 6.0, 9.0)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_down.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_down.mp4" style="max-height: 40vh;"/>
```

Other topological phases allows for mulitple edge modes simultaneously. We are interested in a "helical" topological phase, effectively a combination of the two chiral phases above. In this phase, atoms of opposite spin counter-propagate along the boundary of the topological phase simultaneously[^helical]:

```@setup
using Fusion

create_movie(
  [
    Atom(r=Point3f(-20.0, -20.0 + (is_spin_up ? 1.0 : 0.0), z), v=Point3f(0.0, 0.0, -0.1), tail_length=5, is_spin_up=is_spin_up)
    for z in (3.0, 6.0, 9.0) for is_spin_up in (true, false)
  ],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "qsh.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./qsh.mp4" style="max-height: 40vh;"/>
```

Atoms will move along these one-dimensional loops, some going clockwise and some going counter-clockwise. A single clockwise atom will pass by each counter-clockwise atom exactly once per revolution around the loop.

One might already see things coming together, but we need to provide a bit more detail before reaching the punch line. 

### Edge Mode Properties

Atoms in these edge modes behave as if they are massless, allowing for high velocity at low or even zero energy[^quasiparticle], and are confined along the one-dimensional boundary of the topological phase.

Optical lattices offer a tremendous amount of freedom to tune the properties of atoms in these edge modes. 

The velocity ``v`` of an atom in these edge modes is determined by the wavelength ``\lambda`` of the laser used to construct the optical lattice[^b], and scales very favorably:

```math
v \propto \frac{1}{\lambda^3}
```

That is, the velocity increases 8-fold every time the wavelength is halved:

```@setup
using Fusion

#n_steps_per_frame should be 16x higher than a0=4 case (8x for velocity increase, 2x for smaller lattice spacing), 
#but use prime number so edge_idx is always different after one revolution
n_steps_per_frame=15
create_movie(
  [
    Atom(r=Point3f(-20.0, -20.0 + (is_spin_up ? 1.0 : 0.0), z), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), is_spin_up=is_spin_up, tail_length=32)
    for z in (3.0, 6.0, 9.0) for is_spin_up in (true, false)
  ],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 2.0f0),
  "single_spin_up_a02.mp4";
  n_steps_per_frame=n_steps_per_frame 
)
#should be (16*16)x higher than a0=4 case
n_steps_per_frame=257
create_movie(
  [
    Atom(r=Point3f(-20.0, -20.0 + (is_spin_up ? 1.0 : 0.0), z), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), is_spin_up=is_spin_up, tail_length=64)
    for z in (3.0, 6.0, 9.0) for is_spin_up in (true, false)
  ],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 1.0f0),
  "single_spin_up_a01.mp4";
  n_steps_per_frame=n_steps_per_frame 
)
```
```@raw html
<table width="100%">
<tr>
<td align="left" valign="top" width="50%">
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_up_a02.mp4" style="max-height: 40vh;"/>
</td>
<td align="left" valign="top" width="50%">
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_up_a01.mp4" style="max-height: 40vh;"/>
</td>
</tr>
</table>
```

# The Claim

Everything up to this point can be found in the research literature, we have not introduced anything new so far. The claim -- **below a certain laser wavelength, counter-propagating ultracold atoms will be moving fast enough to occasionally collide and fuse**[^nutshell]:

!!! todo "Video Under Construction"

```@setup
using Fusion

n_steps_per_frame=257
create_movie(
  [Atom(r=Point3f(-20.0, -20.0, 3.0), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), tail_length=64)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 1.0f0),
  "qsh_fuse.mp4";
  n_steps_per_frame=n_steps_per_frame 
)
```
```@raw html
<!--
<video class="marginauto" autoplay loop muted playsinline controls src="./qsh_fuse.mp4" style="max-height: 60vh;"/>
-->
```

Any atoms and neutrons resulting from the fusion event will shoot out at extremely high speed. The kinetic energy could be harvested to generate energy[^harvest]. This is a new twist on an old, long-dormant fusion power concept called [colliding beam fusion](https://en.wikipedia.org/wiki/Colliding_beam_fusion) (CBF), which basically attempted to do thet same thing with atoms shot towards one another in free space. The following section will provide a brief history of it -- why it is preferable to current leading candidates but ultimately failed to work -- and argue:

1. Our new twist naturally resolves the critical flaws preventing CBF from ever yielding a net-positive energy.
2. Current technology can reach edge mode velocities already known to trigger colliding beam fusion. However, it would likely be a very difficult technological feat requiring rare [Free Electron Lasers] (https://en.wikipedia.org/wiki/Free-electron_laser) emitting in the X-ray spectrum (wavelength of 0.1-1 nanometers).
3. Atoms in the edge modes can fuse at a much lower velocity relative to atoms in free space. While it is difficult to say definitively, it could reasonably be achieved with much more common and [commercially available](https://www.kmlabs.com/core-technology) lasers in the extreme Ultraviolet / soft X-ray part of the spectrum (wavelength of 1-10 nanometers).
4. Even the worst-case scenario is significantly cheaper and simpler than any of the currently leading [thermonuclear fusion](https://en.wikipedia.org/wiki/Nuclear_fusion#Thermonuclear_fusion) candidates, which try to create an ["artificial sun"](https://www.ans.org/news/article-5668/china-launches-fusion-consortium-to-build-artificial-sun/) on earth.



# Footnotes

[^qc]: [QuEra](https://www.quera.com/about), [Infleqtion](https://www.infleqtion.com/quantum-computing), and [IonQ](https://ionq.com/technology) are three examples of atom-based quantum computing companies.
[^topcondmat]: For an excellent open online course featuring snippets from some of the most prominent researchers, see https://topocondmat.org/index.html. Please note this course is self-described as complex, intended for graduate students or above.
[^a]: https://arxiv.org/abs/2304.01980
[^b]: Other properties, like the frequency at which lasers are turned on and off, have to be likewise tuned to maintain the topological phase.
[^helical]: While this helical topological phase has yet to be realized experimentally, several proposals exist involving the same building blocks as in the chiral phases.
[^quasiparticle]: This may sound like science fiction -- how could a massive particle behave as though it has no mass? It is what makes condensed matter physics such a fascinating field. Electrons can likewise have zero effective mass in [graphene](https://en.wikipedia.org/wiki/Graphene#Electronic_spectrum), a two-dimensional hexagonal lattice of Carbon atoms (in both cases, the honeycomb structure is essential).
[^nutshell]: Check out the [Nuclear Fusion in a Nutshell](nuclear_fusion_nutshell.md#Nuclear-Fusion-in-a-Nutshell) page for a quick primer on everything you need to know about fusion to understand the argument, or [this nice explanation from the EIA](https://www.eia.gov/energyexplained/nuclear/).
[^harvest]: If fusion occurs, this part should be fairly simple. Similar to [nuclear fission reactors](https://www.energy.gov/science/doe-explainsnuclear-fission), the high energy particles or radiation could be absorbed as heat, boil water, and drive steam turbines. It appears this is compatible as well with prior proposals for fusion-based [Space Propulsion Systems](https://web.archive.org/web/20060331033513id_/http://fusion.ps.uci.edu:80/artan/Papers/CBFRforSpacePropulsion.pdf).
