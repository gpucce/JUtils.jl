### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 5b918be6-0003-11ec-1e1f-534faed7dfe5
begin
using Pkg
Pkg.activate(".")
using Revise, Javis, Distributions, StatsBase, JUtils, Random, Colors, FileIO, PlutoUI, Plots
import Luxor
end

# ╔═╡ 47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
JUtils.CLT(Bernoulli(0.3), boundingbox = BoundingBox(O+(-250, -300),O+(250,200)))

# ╔═╡ Cell order:
# ╠═5b918be6-0003-11ec-1e1f-534faed7dfe5
# ╠═47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
