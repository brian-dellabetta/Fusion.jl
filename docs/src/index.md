````@raw html
---
layout: home

hero:
  name: (Ultra-)Cold Fusion?
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

This post is designed to support the above claim approachably and with some graphical aid. It involves some esoteric terms (namely ["topological phases of matter"](https://topocondmat.org/index.html) and ["ultracold atoms"](https://en.wikipedia.org/wiki/Ultracold_atom)) but it should hopefully show the main idea is rather straightforward. Please post [here](https://github.com/brian-dellabetta/Fusion.jl/issues) if you find that not to be the case anywhere along the way. *For those looking for more technical rigor, please check out [the white paper](https://github.com/brian-dellabetta/Fusion.jl/paper/paper.pdf).*

# Introduction 

Physicists have recently realized a new topological phase of matter by careful preparation of an optical lattice (i.e. a lattice formed of laser light).[^a] One signature of this topological phase is the presence of conductive modes along the boundary of the topological phase, known as "topological edge modes". If an ultra cold atom were placed into that edge mode, it would propagate along the boundary:


```@setup
using Fusion

plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 4.0), v=Point3f(0.0, 0.0, -0.1), tail_length=5)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_up.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_up.mp4" style="max-height: 40vh;"/>
```

Atoms in these edge modes have some interesting properties. They behave as if they are massless, allowing for high velocity at low or even zero energy[^c], and are confined along the one-dimensional boundary of the topological phase.

Optical lattices provide a tremendous amount of freedom to tune the properties of these topological phases. We need to introduce two of those before reaching the punch line. 


### 1) Edge Mode Velocity

The velocity ``v`` of an atom in these edge modes is determined by the wavelength ``\lambda`` of the laser used to construct the optical lattice[^b], and scales very favorably for our purposes:

```math
v \sim \frac{1}{\lambda^3}
```

That is, the velocity increases 8-fold every time we cut the wavelength in half (note that the honeycomb lattice spacing is defined by the wavelength of the laser used, all animations are using the same length scale):

```@setup
using Fusion

#n_steps_per_frame should be 16x higher than a0=4 case (8x for velocity increase, 2x for smaller lattice spacing), 
#but use prime number so edge_idx is always different after one revolution
n_steps_per_frame=15
plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 3.0), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), tail_length=32)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 2.0f0),
  "single_spin_up_a02.mp4";
  n_steps_per_frame=n_steps_per_frame 
)
#should be (16*16)x higher than a0=4 case
n_steps_per_frame=257
plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 3.0), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), tail_length=64)],
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

### 2) Edge Mode Number and Orientation

The topological phase determines the number and orientation of the edge modes. In another phase, the "chirality" of the conductive band can be flipped, so that an the atoms spin and velocity flip (here cyan color is used to denote that this atom is spin-down, its spin points in the opposite direction of the magenta spin-up atoms shown above):

```@setup
using Fusion

plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 4.0), v=Point3f(0.0, 0.0, -0.1), tail_length=5, is_spin_up=false)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_down.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_down.mp4" style="max-height: 40vh;"/>
```

Other topological phases allows for mulitple edge modes simultaneously. We are interested in a "helical" topological phase, as opposed to the chiral phases above, which allows for atoms of opposite spin to counterpropagate along the boundary of the topological phase[^d]:

```@setup
using Fusion

plot_record(
  [
    Atom(r=Point3f(-20.0, -20.0, 2.0), v=Point3f(0.0, 0.0, -0.1), tail_length=5), 
    Atom(r=Point3f(-20.0, -20.0, 3.0), v=Point3f(0.0, 0.0, -0.1), tail_length=5, is_spin_up=false)
  ],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "qsh.mp4";
  n_steps_per_frame=1
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./qsh.mp4" style="max-height: 40vh;"/>
```

We all have the necessary ingredients, now for the punch line -- in the helical phase, above a threshold velocity, the counterpropagating atoms have a chance to collide and fuse[^e]:

```@setup
using Fusion

n_steps_per_frame=257
plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 3.0), v=Point3f(0.0, 0.0, -0.1/n_steps_per_frame), tail_length=64)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 1.0f0),
  "qsh_a01.mp4";
  n_steps_per_frame=n_steps_per_frame 
)
```
```@raw html
<table width="100%">
<tr>
<td align="left" valign="top" width="50%">
<video class="marginauto" autoplay loop muted playsinline controls src="./qsh_a02.mp4" style="max-height: 40vh;"/>
</td>
<td align="left" valign="top" width="50%">
<video class="marginauto" autoplay loop muted playsinline controls src="./qsh_a01.mp4" style="max-height: 40vh;"/>
</td>
</tr>
</table>
```

This is a new twist on an old, long-dormant fusion power concept called [colliding beam fusion](https://en.wikipedia.org/wiki/Colliding_beam_fusion) (CBF). In the following section, we will provide a brief history of it -- why it is preferable to current leading candidates but why it ultimately failed to work -- and argue:

1. The topological twist is uniquely suited to overcome each of the fatal flaws of CBF.
2. We can achieve the same threshold velocity with current technology, though it would likely be a very difficult technological feat requiring rare [Free Electron Lasers] (https://en.wikipedia.org/wiki/Free-electron_laser) emitting in the X-ray spectrum (wavelength of 0.1-1 nanometers).
3. Atoms in the edge modes can fuse at a much lower velocity relative to atoms in free space. While it is difficult to say definitively, it could reasonably be achieved with much more common and [commercially available](https://www.kmlabs.com/core-technology) lasers in the extreme Ultraviolet or soft X-ray part of the spectrum (wavelength of 1-10 nanometers).
4. Even in the worst-case scenario, this is significantly cheaper to build and easier to sustain than any of the leading "thermodynamic" candidates for nuclear fusion.






## Citations

[^a]: https://arxiv.org/abs/2304.01980
[^b]: Other properties, like the frequency at which lasers are turned on and off, have to be likewise tuned to maintain the topological phase.
[^c]: This may sound like science fiction -- how could a massive particle behave as though it has no mass? It is what makes condensed matter physics such a fascinating field. Electrons can similarly behave as though they are massless in [graphene](https://en.wikipedia.org/wiki/Graphene#Electronic_spectrum) (the honeycomb structure of graphene and the optical lattices above is not a coincidence.)
[^d]: While this topological phase has yet to be realized experimentally, several proposals exist involving the same building blocks as in the chiral phases.
[^e]: [Nuclear Fusion in a Nutshell](#Nuclear-Fusion-in-a-Nutshell), everything you need to know about fusion to understand the argument.
