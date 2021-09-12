### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 83b52b3e-12e2-11ec-050b-0d5b599be67e
begin
using Pkg
Pkg.activate("..")
using Revise, Javis, JUtils, Random, Colors, Animations, PlutoUI
import Luxor
end

# ╔═╡ ecbdf12c-5c52-4325-88ed-192caf0818ea
let
	width = 500
	hwidth = width÷2
	height = 300
	hheight = height÷2
	λ = 0.01
	draw = @draw begin
		points = []
		centers = map(collect(Base.product(-hwidth:hwidth, -hheight:hheight))) do mypoint
			if Random.rand() < λ
				push!(points, mypoint)
			end
		end
		map(points) do c
			# randomcolor()
			circle(Point(c), 1, :fill)
		end
	end width height
end

# ╔═╡ 87e9bdcc-23e5-4d62-93c2-56f94a803f74
function _draw_point_process(λ=0.0002; width = 500, height = 300)
	hwidth = width÷2
	hheight = height÷2

	points = []
	centers = map(
		Base.product(-hwidth:hwidth, -hheight:hheight)
	) do mypoint
		if Random.rand() < λ
			push!(points, Point(mypoint))
		end
	end
	points = shuffle(points)			
end

# ╔═╡ 32f03626-aa06-491d-be0b-4d7ebd7466d0
function make_point_process(λ; n_frames, width=500, height=300)
	points = _draw_point_process(λ, width=width, height=height)
	
	circles = map(points) do c
		color = RGB(randomhue()...)
		JCircle(c, 14, action=:fill, color=color)
	end
	
	map(enumerate(circles)) do (idx, circ)
		Object(idx:n_frames, circ)
	end 
end

# ╔═╡ 1cda21d0-ecb2-4baa-b220-57d976a7f948
function ground(args...)
	background("black")
	sethue("white")
end

# ╔═╡ 461353a2-02de-4201-8f05-4768c619678c
let	
width = 500
height = 300
λ = 0.0002
	
points = _draw_point_process(λ, width=width, height=height)	
n_frames = length(points) + 100
circles_video = Video(width, height)
Background(1:n_frames, ground)
make_point_process(λ, n_frames=n_frames, width=width, height=height)
	
render(circles_video, pathname="../output/poisson_point_process.gif")
end

# ╔═╡ c8d4652e-df15-4c21-88af-14ddd78a9f88
let	
width = 500
height = 300
λ = 0.001
	
points = _draw_point_process(λ, width=width, height=height)	
n_frames = length(points)
circles_video = Video(width, height)
Background(1:n_frames, ground)
final_points = [
		Point(-125, -75),
		Point(125, -75),
		Point(125, 75),
		Point(-125, 75),
	]
for point in final_points
	@JLayer 1:n_frames 250 150 point begin
		sethue("white")
		p = make_point_process(λ, n_frames=n_frames, width=width, height=height)
		Object(1:n_frames, (args...)->begin
			setline(3)
			box(O, 250, 150, :stroke)
		end)
	end
end

render(circles_video, pathname="../output/4_poisson_point_process.gif")
end

# ╔═╡ 5aaec46b-156e-4881-90cb-77e6f84c9e09
begin	
width = 500
height = 300
λ = 0.0005

Random.seed!(1234)
	
points = _draw_point_process(λ, width=width, height=height)	
n_frames = 500
circles_video = Video(width, height)


points = _draw_point_process(λ)
n_points = length(points)	
birth_times = rand(1:n_frames, n_points)
growth_rates = rand(n_points)


radiuses = hcat(map(zip(points, birth_times, growth_rates)) do (p, t₀, growth)
	map(1:n_frames) do t
		if t < t₀
			0
		elseif t == t₀
			1
		else
			growth * (t - t₀) + 1
        end
	end
end...)
	
radiuses_bis = deepcopy(radiuses)
	
radiuses_at_first = deepcopy(radiuses)
	
for i in 1:size(radiuses_bis,1)
	mask = all(map(Base.product(1:n_points, 1:n_points)) do (x, y)
		if x == y 
			true
		else !(intersection2circles(
			points[x], radiuses_bis[i, x], points[y], radiuses_bis[i, y]
		) != 0.0)
		end
	end, dims=1)
	radiuses_bis[i+1:end, :] = radiuses_bis[i+1:end, :] .* mask
end
	
Background(1:n_frames, ground)

map(enumerate(eachcol(radiuses_bis))) do (idx, r_s)
	col = RGB(randomhue()...)
	map(enumerate(r_s)) do (tₙ, r)
		Object(tₙ:tₙ, JCircle(points[idx], r, action=:fill, color=col))
	end
end
	
v = render(circles_video, pathname="../output/matern1_point_process.gif")
end

# ╔═╡ 3d29cbd9-2d4f-45a4-918d-2302822fc593
v_bis = let
width = 500
height = 300
λ = 0.0005

Random.seed!(1234)
	
points = _draw_point_process(λ, width=width, height=height)	
n_frames = 500
circles_video = Video(width, height)


points = _draw_point_process(λ)
n_points = length(points)	
birth_times = rand(1:n_frames, n_points)
growth_rates = rand(n_points)


radiuses = hcat(map(zip(points, birth_times, growth_rates)) do (p, t₀, growth)
	map(1:n_frames) do t
		if t < t₀
			0
		elseif t == t₀
			1
		else
			growth * (t - t₀) + 1
        end
	end
end...)
	
radiuses_bis = deepcopy(radiuses)
	
radiuses_at_first = deepcopy(radiuses)
	
Background(1:n_frames, ground)

map(enumerate(eachcol(radiuses))) do (idx, r_s)
	col = RGB(randomhue()...)
	map(enumerate(r_s)) do (tₙ, r)
		Object(tₙ:tₙ, JCircle(points[idx], r, action=:fill, color=col))
	end
end
	
render(circles_video, pathname="../output/boulean_point_process_with.gif")
end

# ╔═╡ Cell order:
# ╟─83b52b3e-12e2-11ec-050b-0d5b599be67e
# ╟─ecbdf12c-5c52-4325-88ed-192caf0818ea
# ╟─461353a2-02de-4201-8f05-4768c619678c
# ╟─c8d4652e-df15-4c21-88af-14ddd78a9f88
# ╟─5aaec46b-156e-4881-90cb-77e6f84c9e09
# ╟─3d29cbd9-2d4f-45a4-918d-2302822fc593
# ╟─32f03626-aa06-491d-be0b-4d7ebd7466d0
# ╟─87e9bdcc-23e5-4d62-93c2-56f94a803f74
# ╟─1cda21d0-ecb2-4baa-b220-57d976a7f948
