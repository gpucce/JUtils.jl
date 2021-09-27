### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 1d4d4c0e-1f81-11ec-1e2a-d9eb1f505571
begin
	using Pkg
	Pkg.activate("..")
	using Revise, Javis, JUtils, Colors, Distributions, Animations, LaTeXStrings
	import Luxor
end

# ╔═╡ 9dd75dc1-dff3-4b4c-945c-cc169ca6e555
mywhite = RGB(254/255, 252/255, 244/255)

# ╔═╡ 82c29842-f1e7-4357-a187-8c75a0714681
function ground(color)
	(args...) -> begin
		background(color)
		sethue("black")
	end
end

# ╔═╡ 4bfea714-7fdd-47cf-8e54-bb30bc2a625c
let
	height = 250
	width = 700
	margin = 50
	n_frames = 200
	
	prelearn_video = Video(width, height)
	Background(1:n_frames, ground(mywhite))
	mypoints = make_prelearn(n_frames=n_frames, height=height, width=width, margin=margin)
	render(prelearn_video, pathname="../output/prelearn_animation.gif")
end

# ╔═╡ 21e78860-f28b-4475-b38f-01e4ee7d802e
let
	n_frames = 200
	time_steps = range(1, n_frames, length = 6)
	width = 500
	height = 500
	
	v = Video(500, 500)
	Background(1:n_frames, ground(mywhite))
	make_ner(
		n_frames = n_frames, 
		width = width, 
		height = height, 
		words_in = ["anybody"],
		words_out = ["driver", "golf player", "dog", "astronaut", "rider"],
		margin=50
	)
	render(v, pathname="../output/paper_user.gif")
end

# ╔═╡ 553312d1-74ef-4edc-b293-caf06a65b71b
let
	n_frames = 200
	time_steps = range(1, n_frames, length = 6)
	width = 500
	height = 500
	
	v = Video(500, 500)
	Background(1:n_frames, ground(mywhite))
	make_ner(
		n_frames=n_frames, 
		width=width, 
		height=height, 
		words_in=["machine"],
		words_out = [
			"coating machine", "coating device", "point scores", "computer", "car"
		],
		margin=50
	)
	render(v, pathname="../output/TechNER.gif")
end

# ╔═╡ 67328dd2-4a0b-428c-a4ff-687d76498b69
function postprocess_frame(frame_image, frame, frames)
	g(x) = RGB(1 - x.r, 1 - x.g, 1 - x.b)
	g.(frame_image)
end

# ╔═╡ c12aff7b-e936-4e8e-98e4-7f8acde3cf35
function make_neural_net(; n_frames, width, height, margin, n_layers, maxneurons)
	
	marg_width = width ÷ 2 - margin
	marg_height = height ÷ 2 - margin
	xpos = range(-marg_width, marg_width, length = n_layers)
	ypos = range(-marg_height, marg_height, length = maxneurons)
	neurons_per_layers = [maxneurons - idx for idx in 0:n_layers-1]
	dist = Normal(0, 50)
	
	layers = [
		[Point(x, y) for y in 
				range(
					-(marg_height - 3marg_height/2n_neurons), 
					(marg_height - 3marg_height/2n_neurons), 
					length=n_neurons
				)
			] 
		for (n_neurons, x) in zip(neurons_per_layers, xpos)
	]
	
	Object(@JShape begin
			for layer in layers
				for neuron in layer
					sethue("red")
					circle(neuron, 15, :fill)
					setcolor("black")
					setline(1)
					circle(neuron, 15, :stroke)
				end
			end
			for i in 1:length(layers) - 1
				for (p1, p2) in Base.product(layers[i], layers[i+1])
					if p1 != p2
						(n1, i1, i2) = intersectionlinecircle(
							p1, p2, p1, 15
						)
						(n2, j1, j2) = intersectionlinecircle(
							p1, p2, p2, 15
						)
						p1 = i1
						p2 = j2
						arrow(p1, p2)
					end
				end
			end
		end
	)
end

# ╔═╡ 60b49d2c-e5cd-44d0-a1f4-a842236ff189
function logistic(x)
	ℯ^x/(1 + ℯ^x)
end

# ╔═╡ f429a061-3ed7-41df-b39d-0989bf477da9
begin
	n_frames = 2000
	width = 1600
	height = 900
	margin = 50
	time_steps = floor.(Int, range(1, n_frames, length = 12))
	
	nn_video = Video(width, height)
	Background(
		1:n_frames,
		ground(mywhite)
	)
	nn = @JLayer 1:n_frames begin
		make_neural_net(
			n_frames = n_frames,
			width=400, 
			height=height, 
			margin=margin, 
			n_layers=3, 
			maxneurons=6
		)
	end
	act!(nn, Action(time_steps[2]:time_steps[3], anim_scale(0.5)))
	act!(nn, Action(time_steps[2]:time_steps[3], anim_translate(Point(-width÷3, 0))))
	act!(nn, Action(time_steps[2]:time_steps[3], anim_rotate(-π/2)))
	act!(nn, Action(time_steps[4]:time_steps[5], disappear(:fade)))
	
	myarrow = Object(
		time_steps[3]:time_steps[5], 
		@JShape begin
			arrow(Point(-width ÷ 6, 0), Point(width ÷ 6, 0))	
		end
	)
	
	act!(
		myarrow, 
		[
			Action(1:time_steps[2], appear(:fade)),
			Action(time_steps[2]:time_steps[3], disappear(:fade))
		]
	)
	
	wlstartpoints = [Point(i + width÷3, 0) for i in [-150, -90, -30, 30, 90, 150]] 
	wlendpoints = [Point(i, -height÷3) for i in [-180, -105, -35, 35, 105, 180]]
	wlstrings = [
		L"\Large{w_1}", 
		L"\Large{w_2}", 
		L"\Large{w_i}", 
		L"\Large{w_{308}}", 
		L"\Large{w_j}", 
		L"\Large{w_n}"
		]
	
	latexvecs = [@JLayer time_steps[4]:time_steps[end] 500 500 wlstartpoint begin
		texvec = Object(
			1:n_frames,
			@JShape begin
				Javis.latex(
						wlstring,
						O,
						:stroke,
						valign=:middle, 
						halign=:center
					)
				end
			)
			act!(texvec, Action(1:1, anim_scale(2.0)))
			act!(texvec, Action(time_steps[2]:time_steps[3], anim_scale(2.5)))
		end for (wlstartpoint, wlstring) in zip(wlstartpoints, wlstrings)]
	
	vecendpoint = Point(0, -height÷3)
	for (idx, latexvec) in enumerate(latexvecs)
		act!(
			latexvec, 
			Action(time_steps[2]:time_steps[3], anim_translate(wlstartpoints[idx], wlendpoints[idx] ))
		)
	end
	plots_points = [Point.(
		[rand(-width÷4:width÷4) for i in 1:30], 
		[rand(-height÷4:height÷4) for i in 1:30]
	) for i in 1:5]
	plots_rotations = rand(range(0, π/4, length=20), 5)
	plots_colors = [randomhue() for _ in 1:5]
	linear_regressions = @JLayer time_steps[6]:time_steps[end] begin
		for (θ, plot_points, color) in zip(plots_rotations, plots_points, plots_colors)
			Object( 
				1:n_frames,
				(args...) -> begin
					bb = box(O, width÷2, height÷2, :stroke)
					rotate(-θ)
					sethue(color)
					# sethue("red")
					line(
						Point(-width÷5, -height÷5), 
						Point(width÷5, height÷5),
						:stroke
					)
					# sethue("black")
					for p in plot_points
						rotate(θ)
						if (abs(p.x) > width÷4) || (abs(p.y) > height÷4)
							continue
						else
							circle(p, 3, :fill)
						end
						rotate(-θ)
					end
				end
			)
		end
	end
	
	act!(linear_regressions, Action(time_steps[2]:time_steps[3], anim_scale(0.5)))
	act!(linear_regressions, Action(time_steps[2]:time_steps[3], anim_translate(Point(width÷3, 0))))
	
	central_arr = Object(time_steps[7]:time_steps[9], 
		@JShape begin
			arrow(vecendpoint + (0, 20), Point(0, height÷3 - 20))
		end
	)
	act!(central_arr, Action(1:time_steps[2], appear(:fade)))
	
	barpoints = [Point(i, height÷3) for i in [-180, -105, -35, 35, 105, 180]]
	lstrings = [
		L"$\Large{\alpha_{1}}$", 
		L"$\Large{\alpha_{2}}$",
		L"$\Large{\alpha_{i}}$",
		L"$\Large{\alpha_{308}}$",
		L"$\Large{\alpha_{j}}$",
		L"$\Large{\alpha_{n}}$"
	]
	texparams = [@JLayer time_steps[6]:time_steps[end] 300 300 p begin
		ob = Object(
		1:n_frames,
		@JShape begin
			Javis.latex(
				Lstr,
				O,
				:stroke,
				valign=:middle,
				halign=:center
			)
		end
	)
		act!(ob, Action(1:1, anim_scale(2.5), keep=true))
		act!(ob, Action(1:time_steps[2], appear(:fade)))
		end 
			for (Lstr, p) in zip(lstrings, barpoints)
			]
	
	[Object(
		time_steps[9]:time_steps[12], 
		JLine(x - (0, 10), x - (0, y), linewidth=5, color="red")
	) for (x, y) in zip(barpoints, [80, 40, 12, 200, 60, 20])]
	
	
	render(nn_video, pathname="../output/bert_lasso.gif")
end

# ╔═╡ Cell order:
# ╠═1d4d4c0e-1f81-11ec-1e2a-d9eb1f505571
# ╟─9dd75dc1-dff3-4b4c-945c-cc169ca6e555
# ╟─82c29842-f1e7-4357-a187-8c75a0714681
# ╟─4bfea714-7fdd-47cf-8e54-bb30bc2a625c
# ╟─21e78860-f28b-4475-b38f-01e4ee7d802e
# ╟─553312d1-74ef-4edc-b293-caf06a65b71b
# ╠═67328dd2-4a0b-428c-a4ff-687d76498b69
# ╠═c12aff7b-e936-4e8e-98e4-7f8acde3cf35
# ╠═60b49d2c-e5cd-44d0-a1f4-a842236ff189
# ╠═f429a061-3ed7-41df-b39d-0989bf477da9
