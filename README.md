# Fusion.jl
Animations for fusion concept idea, check out https://brian-dellabetta.github.io/Fusion.jl for end result.

## To Build Locally

### Initialize
First Install [Julia](https://github.com/JuliaLang/juliaup) and [Node/NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

Clone repo, and run from project root 
```
julia --project=docs
```
```julia
] instantiate .
```

### Build and Serve

```
julia --project=docs docs/make.jl
npm --prefix docs run docs:dev
```

Will serve it on `localhost` until npm is stopped