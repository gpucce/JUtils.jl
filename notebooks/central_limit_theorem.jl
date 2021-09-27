### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 5b918be6-0003-11ec-1e1f-534faed7dfe5
begin
    using Pkg
    Pkg.activate("..")
    using Revise,
        Javis, Distributions, StatsBase, JUtils, Random, Colors, FileIO, PlutoUI, Plots
    import Luxor
end

# ╔═╡ 46fd9cf5-eae0-4dec-91df-ebd892cbf4d6
converter = Dict(["bernoulli" => Bernoulli, "pareto" => Pareto]);

# ╔═╡ b6e3b06f-a521-40fb-9d5a-9268302cd17b
md"""
Select the distribution $(@bind dist Select(collect(keys(converter)), default="bernoulli"))
"""

# ╔═╡ d3ed0756-5fdf-4eba-a8ed-7d944acc079d
md"""
Select the distribution Parameters $(@bind param NumberField(0.0:0.1:5.0, default=0.3))
"""

# ╔═╡ e8fef37b-e0a7-42f3-89a7-414d61092c6e
md"""
Check to start rendering gif$(@bind start CheckBox())
"""

# ╔═╡ e725b87f-fb23-472d-84d7-8e6a8dd01aae
param_dist = converter[dist](param)

# ╔═╡ 47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
begin
    start && JUtils.CLT(
        param_dist,
        boundingbox = BoundingBox(O + (-250, -300), O + (250, 200)),
        pathname = "../output/central_limit_theorem.gif",
    )
end

# ╔═╡ Cell order:
# ╟─5b918be6-0003-11ec-1e1f-534faed7dfe5
# ╟─46fd9cf5-eae0-4dec-91df-ebd892cbf4d6
# ╟─b6e3b06f-a521-40fb-9d5a-9268302cd17b
# ╟─d3ed0756-5fdf-4eba-a8ed-7d944acc079d
# ╟─e8fef37b-e0a7-42f3-89a7-414d61092c6e
# ╟─e725b87f-fb23-472d-84d7-8e6a8dd01aae
# ╟─47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
