### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 3d1e8af8-16ef-11ec-18d8-e7fe83a40de4
begin
using Pkg
Pkg.activate("..")
using Javis, Colors, Plots
end

# ╔═╡ 985f6ae4-c559-4756-b9d7-98696c7cbf7f
begin
	function ground(args...)
		background("white")
		sethue("black")
	end
end

# ╔═╡ c25e5278-b7fa-4ec4-abcc-08617fa08872
begin
	mutable struct HarmonicSum
		α::Float64
		values::Vector{Point}
	end

	function HarmonicSum(α::Float64, start_pos::Point; scaling=20, n_points=100)
		sequence = map(k->1/k^α, 1:n_points) .* scaling
		return HarmonicSum(
			α,
			map(1:n_points) do k
				start_pos + (0, -reduce(+, sequence[1:k]))
			end
		)
	end
end

# ╔═╡ ef565322-cc4d-4f9d-8558-c722d490c611
function show_sum(S::HarmonicSum, firstframe, lastframe; color=colorant"red")
	points = S.values
	n_frames = lastframe - firstframe + 1
	pointiter = range(1, length(points) - 1, step=(length(points) - 1) ÷ n_frames)
	for idx in 1:n_frames
		Object(
			firstframe+idx:lastframe,
			@JShape begin
				setline(3)
				sethue(color)
				line(points[pointiter[idx]], points[pointiter[idx+1]], :stroke)
			end
		)
	end
end

# ╔═╡ 80489189-55c9-46c3-a665-cb58b8f0152d
function dash_sum(S::HarmonicSum, firstframe, lastframe; color=colorant"red")
	points = S.values
	n_frames = lastframe - firstframe + 1
	pointiter = range(1, length(points) - 1, step=(length(points) - 1) ÷ n_frames)
	for idx in 1:n_frames
		Object(
			firstframe+idx:lastframe,
			@JShape begin
				sethue(color)
				line(
					points[pointiter[idx+1]] - (2, 0),
					points[pointiter[idx+1]] + (2, 0),
					:stroke
				)
			end
		)
	end
end

# ╔═╡ f9c60c0d-9150-42e7-98ed-83d971366292
begin
	function ζ(;
			n_sums = 100, 
			height = 500, 
			width = 500,
			firstframe = 1,
			lastframe = 100, 
			margin = 10, 
			llim = -200, 
			rlim = 200
		)
		
		n_frames = lastframe - firstframe
		colorpalette = range(colorant"red", colorant"blue", length=n_sums)
		Object(@JShape begin
			tickline(
				Point(-200, 200 - margin), 
				Point(200, 200 - margin),
				startnumber = 0.0,
				finishnumber = 2.0
				)
			end
		)
		Object(JLine(
				Point(0, -height÷2), 
				Point(0, 200 - 20), 
				color="black"
				)
		)
	
		Xpoints = range(llim, rlim, length=n_sums)
		sums = map(enumerate(Xpoints)) do (idx, x)
			s = HarmonicSum(1.0 + x/rlim, Point(x, 200), n_points=10000)
			dash_sum(s, firstframe, lastframe, color=colorpalette[idx])
			s
		end		
	end
	series_video = Video(500, 500)
	Background(1:250, (args...)-> begin
			background("white")
			sethue("black")
		end)
	
	mypoint = Point(range(-200, 200, length=100)[50], 200)
	l1 = @JLayer 1:250 begin
		s = HarmonicSum(1.0 + mypoint.x/200, mypoint, n_points=10000)
		dash_sum(s, 1, 250)
	end
	act!(l1, Action(50:100, anim_translate(mypoint, Point(200, 0))))
	act!(l1, Action(150:200, anim_translate(Point(200, 0), mypoint)))
	
	l2 = @JLayer 101:250 begin
		ζ(n_sums=100, firstframe=1, lastframe=150)
	end
	
	act!(l2, Action(1:50, appear(:fade)))
	
	render(series_video, pathname="../output/series_sum.gif")
end

# ╔═╡ Cell order:
# ╟─3d1e8af8-16ef-11ec-18d8-e7fe83a40de4
# ╟─985f6ae4-c559-4756-b9d7-98696c7cbf7f
# ╟─c25e5278-b7fa-4ec4-abcc-08617fa08872
# ╟─ef565322-cc4d-4f9d-8558-c722d490c611
# ╟─80489189-55c9-46c3-a665-cb58b8f0152d
# ╟─f9c60c0d-9150-42e7-98ed-83d971366292
