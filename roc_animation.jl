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
# import Luxor
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
end

# ╔═╡ e0bd9a55-5e4b-4d13-adf6-24ccd11a0384
@draw begin
	draw_roc(Point(100, 0), tar, nontar, 0.05)
end 700 500

# ╔═╡ f9061057-61fd-492f-9624-4aa44db95cdd
begin
function ground(args...)
	background("white")
	sethue("black")
end
end

# ╔═╡ 61a37185-92fe-4b31-b609-43167b9c3f76
begin
scatter(sort(nontar), bins=100)
scatter!(sort(tar), bins=100)
end

# ╔═╡ 54de45e1-f204-4521-a31c-3ce5e2e76a7d
begin
n_frames = 200
n_steps = 20
step_size = n_frames ÷ n_steps

size = 300
global_shift = Point(100, 50)
	
my_video = Video(800, 800)

Background(1:n_frames, ground)


for (frame_n, p) in zip(1:step_size:n_frames, range(0.0, 1.0, length=n_steps))
	Object(
		frame_n : (frame_n + step_size - 1),
		@JShape begin
			draw_roc(global_shift, tar, nontar, p)
		end
	)
end

margin = 50
	
Object(
	1:n_frames,
	@JShape begin
		rocpoints = Point.(myroc.pmiss .* 300, myroc.pfa .* 300)
		# bottomleft = Point(rocpoints[1].x, rocpoints[end].y - margin)
		Javis.translate(-midpoint(rocpoints[1], rocpoints[end]))
		bottomleft = Point(rocpoints[1].x - margin - 200, rocpoints[end].y - margin)
		topright = Point(rocpoints[end].x, bottomleft.y - maximum(preds .* 300))
		Javis.translate(global_shift)
		newidxs = sortperm(preds)
		barchart(
			preds[newidxs],
			boundingbox = Luxor.BoundingBox([bottomleft, topright]),
			# border=true,
			margin=0,
			barfunction = (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
            @layer begin
				height = (topright.y - bottomleft.y) / 2
				y[newidxs][i] ? sethue("red") : sethue("blue")
                # circle(highpos, 3, :fill)
				circle(
					Point(lowpos.x, lowpos.y + values[i] * height),
					3, 
					:fill
				)
            end
        end
		)
	end
)
	
for (frame_n, p) in zip(1:step_size:n_frames, range(0.0, 1.0, length=n_steps))
	Object(
		frame_n : (frame_n + step_size - 1),
		@JShape begin
			rocpoints = Point.(myroc.pmiss .* 300, myroc.pfa .* 300)
			# bottomleft = Point(rocpoints[1].x, rocpoints[end].y - margin)
			Javis.translate(-midpoint(rocpoints[1], rocpoints[end]))
			Javis.translate(global_shift)
			bottomleft = Point(rocpoints[1].x - margin - 200, rocpoints[end].y - margin)
			topright = Point(rocpoints[end].x, bottomleft.y - maximum(preds .* 300))
			
			bottomright = Point(topright.x, bottomleft.y)
			
			line(
				bottomleft, 
				Point(bottomleft.x, midpoint(bottomleft, topright).y - margin)
			)
			line(bottomleft, Point(topright.x + margin, bottomleft.y))
				
			height = (topright.y - bottomleft.y) / 2
			shift = p * height
			line(
				bottomleft + (0, shift) - (0,3), 
				bottomright + (0, shift) - (0,3), :stroke
			)
			setcolor(sethue("red")..., 0.4)
			box(bottomleft, bottomright + (0, shift) - (0, 3), :fill)
			setcolor(sethue("blue")..., 0.4)
			box(bottomleft + (0, shift) - (0, 3), bottomright + (0, height) - (0, 3), :fill)
		end
	)
end
	
render(my_video, pathname="output/roc_animation.gif")
end

# ╔═╡ Cell order:
# ╠═b17843a0-05ae-11ec-1825-8b2b03bd5811
# ╠═5e3a6b7d-f15d-4541-9b48-7c3c3ce5ddd4
# ╠═e0bd9a55-5e4b-4d13-adf6-24ccd11a0384
# ╟─f9061057-61fd-492f-9624-4aa44db95cdd
# ╠═61a37185-92fe-4b31-b609-43167b9c3f76
# ╠═54de45e1-f204-4521-a31c-3ce5e2e76a7d
