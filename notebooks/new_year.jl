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
begin
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
	
	nn = Object(@JShape begin
			for layer in layers
				for neuron in layer
					setcolor(sethue("blue")..., 0.3)
					circle(neuron, 15, :fill)
					sethue("black")
					setline(2)
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

# ╔═╡ f429a061-3ed7-41df-b39d-0989bf477da9
let
	n_frames = 200
	width = 700
	height = 300
	margin = 50
	time_steps = floor.(Int, range(1, n_frames, length = 10))
	
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
			arrow(Point(-width÷4, 0), Point(width÷5, 0))	
		end
	)
	
	act!(
		myarrow, 
		[
			Action(1:time_steps[2], appear(:fade)),
			Action(time_steps[2]:time_steps[3], disappear(:fade))
		]
	)
	
	latexvec = @JLayer time_steps[4]:n_frames 300 300 Point(width÷3, 0) begin
		texvec = Object(
			1:n_frames,
			@JShape begin
				Javis.latex(
					L"[w_1, w_2, \dots, w_{308}, \dots, w_n]",
					O,
					:stroke,
					valign=:middle, 
					halign=:center
				)
			end
		)
		act!(texvec, Action(time_steps[2]:time_steps[3], anim_scale(2.5)))
	end
	
	vecendpoint = Point(0, -height÷3)
	act!(
		latexvec, 
		Action(time_steps[2]:time_steps[3], anim_translate(Point(width÷3, 0), vecendpoint))
	)
	plot_points = Point.(
		[rand(-height÷4:height÷4) for i in 1:30], 
		[rand(-height÷8:height÷8) for i in 1:30]
	)
	linear_regression = @JLayer time_steps[6]:time_steps[7] begin
		Object(
			1:n_frames,
			@JShape begin
				box(O, height÷2, height÷2, :stoke)
				rotate(π/4)
				line(Point(-height÷4, 0), Point(height÷4, 0), :stroke)
				for p in plot_points
					circle(p, 3, :fill)
				end
			end
		)
	end
	Object(time_steps[6]:time_steps[7], 
		@JShape begin
			arrow(vecendpoint + (-width÷4, 0), Point(-width÷4, height÷3))
		end
	)
	texparam = @JLayer time_steps[6]:time_steps[9] 300 300 Point(0, height÷3) begin
		ob = Object(
		1:n_frames,
		@JShape begin
			Javis.latex(
				L"\alpha_1, \alpha_2, \dots, \alpha_{308}, \dots, \alpha_n",
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
	
	
	render(nn_video, pathname="../output/bert_lasso.gif")
end

# ╔═╡ f749716a-0aaa-4498-b88e-471c25eb5cb3


# ╔═╡ Cell order:
# ╠═1d4d4c0e-1f81-11ec-1e2a-d9eb1f505571
# ╟─9dd75dc1-dff3-4b4c-945c-cc169ca6e555
# ╟─82c29842-f1e7-4357-a187-8c75a0714681
# ╟─4bfea714-7fdd-47cf-8e54-bb30bc2a625c
# ╟─21e78860-f28b-4475-b38f-01e4ee7d802e
# ╟─553312d1-74ef-4edc-b293-caf06a65b71b
# ╠═c12aff7b-e936-4e8e-98e4-7f8acde3cf35
# ╠═f429a061-3ed7-41df-b39d-0989bf477da9
# ╠═f749716a-0aaa-4498-b88e-471c25eb5cb3
