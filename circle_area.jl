### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 08d32844-010a-11ec-1ccf-2359999874d2
begin
using Pkg
Pkg.activate(".")
using Revise, Javis, Distributions, StatsBase, JUtils, Random, Colors, FileIO, PlutoUI, Plots
import Luxor
end

# ╔═╡ 5f34a9e3-4970-4871-beb2-9554d00bd43c
begin
	
n_frames = 200
n_poly = 20
radius = 200
	
my_video = Video(450, 450)

step_size = n_frames ÷ n_poly
	
function ground(args...)
	background("white")
	sethue("black")
end
colors = range(colorant"red", colorant"yellow", length=4)
	
Background(1:n_frames, ground)

function myfunc(args...; nsides)
	sethue("blue")
	
end
	
for i in 1:n_poly-1
	Object(
		i*step_size : (i+1) * step_size,
		@JShape begin
			for (idx, r) in enumerate(range(radius, 1, length=4))
				sethue(colors[idx])
				ngon(O, r, i, 0, :fill)
			end
			sethue("red")
			ngon(O, radius, i, 0, :stroke)
		end
		)
end

Object(
		1:n_frames,
		@JShape begin
			sethue("red")
			setline(3)
			circle(O, radius,:stroke)
		end
		)
	
render(my_video, pathname="output/circle_area.gif")
end

# ╔═╡ 08d5a47a-dee2-47ef-8fc4-7162de9af6df
[i for i in n_poly:step_size:n_frames-step_size]

# ╔═╡ Cell order:
# ╠═08d32844-010a-11ec-1ccf-2359999874d2
# ╠═5f34a9e3-4970-4871-beb2-9554d00bd43c
# ╠═08d5a47a-dee2-47ef-8fc4-7162de9af6df
