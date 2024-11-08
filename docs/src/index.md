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
  [Atom(r=Point3f(-20.0, -20.0, 10.0))],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_up.mp4"
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_up.mp4" style="max-height: 40vh;"/>
```

Atoms in these edge modes have some interesting properties. They behave as if they are massless, allowing for high velocity at low or even zero energy[^c], and are confined to the one-dimensional boundary of the topological phase.

Optical lattices provide a tremendous amount of freedom to tune the properties of these topological phases. For example, the velocity of an atom in these edge modes is determined by the wavelength of the laser used to construct the optical lattice[^b]:


```@setup
using Fusion

plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 10.0))],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 2.0f0),
  "single_spin_up_a02.mp4"
)
plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 10.0))],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 1.0f0),
  "single_spin_up_a01.mp4"
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

(Note that the lattice spacing is defined by the wavelength of the laser used, all animations are using the same length scale.) 

Different topological phases can yield conductive bands with different behavior. By flipping the dynamics of the optical lattice, we can flip the "chirality" (i.e. the orientation) of the conductive band:

```@setup
using Fusion

plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 10.0), is_spin_up=false)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "single_spin_down.mp4"
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./single_spin_down.mp4" style="max-height: 40vh;"/>
```

(Note that the cyan color is used to denote that this atom is spin-down, its spin points in the opposite direction of the magenta spin-up atoms shown above).

We need one last piece before the punch line -- another topological phase[^d] allows for two edge modes simultaneously:

```@setup
using Fusion

plot_record(
  [Atom(r=Point3f(-20.0, -20.0, 10.0)), Atom(r=Point3f(-20.0, -20.0, 20.0), is_spin_up=false)],
  Lattice((Point3f(-20.0, -20.0, 0.0), Point3f(20.0, 20.0, 0.0)), 4.0f0),
  "quantum_spin_hall.mp4"
)
```
```@raw html
<video class="marginauto" autoplay loop muted playsinline controls src="./quantum_spin_hall.mp4" style="max-height: 40vh;"/>
```

In this "helical" topological phase, as opposed to the chiral phases above, atoms of opposite spin counterpropagate along the edge of the topological phase. 

Now for the punch line -- above a threshold velocity, there should be some chance for these counterpropagating atoms to collide and trigger nuclear fusion:


This is a new twist on an old, long-dormant fusion power concept called [colliding beam fusion](https://en.wikipedia.org/wiki/Colliding_beam_fusion) (CBF). In the following section, we will provide a brief history of it and argue:

1. The topological twist is uniquely suited to overcome each of the fatal flaws of CBF.
2. We can achieve the same threshold velocity with current technology, though it would likely be a very difficult technological feat requiring rare [Free Electron Lasers] (https://en.wikipedia.org/wiki/Free-electron_laser) emitting in the X-ray spectrum (wavelength of 0.1-1 nanometers).
3. Atoms in the edge modes can fuse at a much lower velocity relative to atoms in free space. While it is difficult to say definitively, it could reasonably be achieved with much more common and [commercially available](https://www.kmlabs.com/core-technology) lasers in the extreme Ultraviolet or soft X-ray part of the spectrum (wavelength of 1-10 nanometers).
4. Even in the worst-case scenario, this is significantly cheaper to build and easier to sustain than any of the leading "thermodynamic" candidates for nuclear fusion.



The velocity of this edge mode scales very favorably for our goal,

```math
v = \frac{1}{\lambda^3}
```






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

The caveat, of course, is that this is really difficult to achieve. In order to bring atomic nuclei (which are positively charged and repel one another) close enough together to fuse, the current leading designs aim to compress and heat fusible atoms to immense pressures and temperatures (~100 million degrees Kelvin) to trigger fusion.[^2] It is reasonable to consdier this class of fusion reactor -- this is, after all, how fusion occurs in stars. However, in spite of exciting recent breakthroughs, the challenges associated with creating an "artifical sun on earth" abound:

- The International Thermonuclear Experimental Reactor (ITER), a multi-country initiative to build a test reactor in France by 2035, has [an expected cost of \$22B that could swell up to \$65B](https://pubs.aip.org/physicstoday/Online/4990/ITER-disputes-DOE-s-cost-estimate-of-fusion), according to the U.S. Department of Energy.
- In the U.S., the National Ignition Facility (NIF) [recently achieved fusion ignition](https://www.llnl.gov/article/49306/lawrence-livermore-national-laboratory-achieves-fusion-ignition) and generated more energy than it required to operate, but [at a total cost of \$3.5B](https://lasers.llnl.gov/about/faqs#nif_cost) its path to a sustainable nuclear reactor with a net-positive harvested energy remains unclear. 

Hundreds of millions of degrees, tens of billions of dollars *for an experiment*. The numbers are eye-watering. Thermonuclear fusion is a brute-force approach rife with challenges, but it's not the only option. A more elegant design exists, and has for some time.


# The 50-Year-Old Idea

The alternative is rather simple -- fusion is a reaction between two individual atoms, just collide them together. If they are travelling towards one another fast enough, they can overcome their electrostatic repulsion and fuse. This class of fusion power designs is known as [Colliding Beam Fusion](https://en.wikipedia.org/wiki/Colliding_beam_fusion)

Colliding Beam Fusion dates back to at least the 



# The New State of Matter

Lorem ipsum

## Some Caveats

Lorem ipsum

## Open Questions

## Citations

[^a]: https://arxiv.org/abs/2304.01980
[^b]: Other properties, like the frequency at which lasers are turned on and off, have to be likewise tuned to maintain the topological phase.
[^c]: This may sound like science fiction -- how could a massive particle behave as though it has no mass? It is what makes condensed matter physics such a fascinating field. Electrons can similarly behave as though they are massless in [graphene](https://en.wikipedia.org/wiki/Graphene#Electronic_spectrum) (the honeycomb structure of graphene and the optical lattices above is not a coincidence.)
[^d]: While this topological phase has yet to be realized experimentally, several proposals exist involving the same building blocks as in the chiral phases.

[^1]: [Per kg, the combustion of hydrogen and oxygen yields 13 MJ, whereas the fusion of deuterium and tritium yields 3.6 x 10^8 MJ](https://ntrs.nasa.gov/api/citations/20160010608/downloads/20160010608.pdf)
[^2]: [Inertial confinement fusion](https://en.wikipedia.org/wiki/Inertial_confinement_fusion), [magnetized target fusion](https://en.wikipedia.org/wiki/Magnetized_target_fusion), [inertial electrostatic confinement](https://en.wikipedia.org/wiki/Inertial_electrostatic_confinement) and the [Tokamak](https://en.wikipedia.org/wiki/Tokamak) design all reside in the family of thermonuclear fusion reactors. The NIF project uses inertial confinement fusion, the ITER project is a Tokamak design.