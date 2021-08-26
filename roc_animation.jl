### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ b17843a0-05ae-11ec-1825-8b2b03bd5811
begin
using Pkg
Pkg.activate(".")
using Revise
using Javis
using JUtils
using Colors
using Random
using ROCAnalysis
using GLM
using DataFrames
using StatsPlots
import Luxor
import MLJ:make_regression
end

# ╔═╡ 5e3a6b7d-f15d-4541-9b48-7c3c3ce5ddd4
begin
X, y = make_regression(100, 1, noise=0.0, sparse=0.0, outliers=0.0, binary=true, as_table=false)
df = DataFrame(x=(X[:,1]), y=y)
log = glm(@formula(y ~ x), df, Binomial())
preds = predict(log)
tar = preds[df.y .== 1.0]
nontar = preds[df.y .== 0.0]
myroc = roc(tar, nontar)

myplot = plot(myroc.pmiss, 1 .- myroc.pfa, label="")
plot!(myplot, [0,1], [0,1], label="")
# @df df scatter(:x, :y,)
end

# ╔═╡ 13324258-d4a0-407e-afb1-0e30f14ae4aa
methodswith(BoundingBox)

# ╔═╡ 7e88dce8-d4c6-479d-a4da-db073386f80c
function draw_roc(myroc, p; c1=colorant"red", c2=colorant"blue", margin=10)
	Luxor.@layer begin
		Luxor.setline(2)
		rocpoints = Point.(myroc.pmiss .* 300, (myroc.pfa) * 300)
		Javis.translate(- midpoint(rocpoints[1], rocpoints[end]))
		
		sethue(c1)
		first_half = rocpoints[myroc.pmiss .<= p]
		second_half = rocpoints[myroc.pmiss .>= p]
		poly([first_half; second_half[1]], :stroke)
		
		sethue(c2)
		poly(second_half, :stroke)		
		sethue("black")
		
		Luxor.setline(1)
		line(rocpoints[1], rocpoints[end], :stroke)
		
		tickline(
			rocpoints[1] + (0, margin), 
			Point(rocpoints[end].x, rocpoints[1].y) + (0, margin)
		)
		tickline(
			 
			Point(rocpoints[1].x, rocpoints[end].y) + (-margin,0),
			rocpoints[1] + (-margin, 0),
			startnumber=1,
			finishnumber=0
		)
		
		Luxor.setline(10)
		sethue(c1)
		linex = rocpoints[1].x - margin - 50
		line(
			Point(linex, rocpoints[1].y),
			Point(linex, first_half[end].y),
			:stroke
		)
		label("Specificity", :N, Point(linex, second_half[end].y), offset=10)
		
		sethue(c2)
		line(
			Point(linex, first_half[end].y),
			Point(linex, second_half[end].y),
			:stroke
		)
		label("Sensitivity", :S, Point(linex, first_half[1].y), offset=10)
		
	end
end

# ╔═╡ e0bd9a55-5e4b-4d13-adf6-24ccd11a0384
@draw begin
	draw_roc(myroc, 0.2)
end

# ╔═╡ f9061057-61fd-492f-9624-4aa44db95cdd
begin
function ground(args...)
	background("white")
	sethue("black")
end
end

# ╔═╡ 54de45e1-f204-4521-a31c-3ce5e2e76a7d
begin
n_frames = 200
n_steps = 20
step_size = n_frames ÷ n_steps
	
my_video = Video(500, 500)

Background(1:n_frames, ground)

for (frame_n, p) in zip(1:step_size:n_frames, range(0.0, 1.0, length=n_steps))
	Object(
		frame_n : (frame_n + step_size - 1),
		# 1:10,
		(args...) -> draw_roc(myroc, p)
	)
end
	
render(my_video, pathname="output/roc_animation.gif")
end

# ╔═╡ Cell order:
# ╠═b17843a0-05ae-11ec-1825-8b2b03bd5811
# ╠═5e3a6b7d-f15d-4541-9b48-7c3c3ce5ddd4
# ╠═13324258-d4a0-407e-afb1-0e30f14ae4aa
# ╠═7e88dce8-d4c6-479d-a4da-db073386f80c
# ╠═e0bd9a55-5e4b-4d13-adf6-24ccd11a0384
# ╠═f9061057-61fd-492f-9624-4aa44db95cdd
# ╠═54de45e1-f204-4521-a31c-3ce5e2e76a7d
