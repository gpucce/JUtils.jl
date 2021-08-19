### A Pluto.jl notebook ###
# v0.15.1

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
Pkg.activate(".")
using Revise, Javis, Distributions, StatsBase, JUtils, Random, Colors, FileIO, PlutoUI, Plots
import Luxor
end

# ╔═╡ 08925513-6646-48ac-9fa8-2e48b4a40230
@bind n Slider(1:1:100)

# ╔═╡ 4d489509-80c4-40a6-a182-ce785f322684
let
	
d = Pareto(3)
# d = Normal(4,2)
	
to_histogram = [(sum(rand(d,n))/n - mean(d)) * sqrt(n) for i in 1:10000]
hist = fit(Histogram, to_histogram, nbins=1000)

gauss = Normal(mean(to_histogram), std(to_histogram))
gaussplot = (rand(gauss, 10000))
gausshist = fit(Histogram, gaussplot, weights(ones(10000)), hist.edges[1])
	
@draw begin
	Luxor.barchart(
			hist.weights,
	)
end

# plot([pdf(gauss, i) for i in hist.edges[1]])
# bins(hist)

end

# ╔═╡ 47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
JUtils.CLT(Binomial(10, 0.2), boundingbox = BoundingBox(O+(-250, -250),O+(250,250)))

# ╔═╡ 31b29fb2-b52e-4569-96b2-5999b7424bb6
begin
c1 = HSV(colorant"firebrick")
c2 = HSV(colorant"goldenrod1")
# c2 = HSV(colorant"blue")
(c1.h, c1.s, c1.v),(c2.h, c2.s, c2.v)
HSV(260, c2.s, c2.v)
end

# ╔═╡ b1676337-685a-4759-a771-34a770acf72e
typeof(Exponential(10)).name.name

# ╔═╡ 05385a8e-8764-4352-9023-1b126a9c7295
function newbarchart(hist, dist;
    boundingbox = BoundingBox(O + (-250, -120), O + (250, 120)),
    bargap=10,
    margin = 5,
    border=false,
    labels=false,
    labelfunction = (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
        label(string(values[i]), :n, highpos, offset=10)
    end,
    barfunction =  (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
        @layer begin
            Luxor.setline(barwidth)
            line(lowpos, highpos, :stroke)
        end
    end,
    prologfunction = (values, basepoint, minbarrange, maxbarrange, barchartheight) -> ()
    )
    minvalue, maxvalue = extrema(hist.weights)
    barchartwidth  = boxwidth(boundingbox)  - 2bargap - 2margin
    barchartheight = boxheight(boundingbox) - 2margin
    barwidth = (barchartwidth - 2bargap)/length(hist.weights)
    if barwidth < 0.1
        throw(error("barchart() - bars are too small (< 0.1) at $(barwidth)"))
    end
    # if all bars are equal height, this will force a range
    minbarrange = minvalue - abs(minvalue)
    maxbarrange = maxvalue + abs(maxvalue)
    basepoint = boundingbox - (0, margin)
    hpositions = between.(
        boxbottomleft(basepoint),
        boxbottomright(basepoint),
        # skip first and last, then take every other one, which is at halfway
        range(0.0, stop=1.0, length=2length(hist.weights) + 1))[2:2:end-1]
    @layer begin
        if border
            box(boundingbox, :stroke)
        end
        prologfunction(hist.weights, basepoint, minbarrange, maxbarrange, barchartheight)
        for i in 1:length(hist.weights)
            scaledvalue = rescale(hist.weights[i], minbarrange, maxbarrange) * barchartheight
            lowposition = hpositions[i]
            highposition = lowposition - (0, scaledvalue) # -y coord
            barfunction(hist.weights, i, lowposition, highposition, barwidth, scaledvalue)
            labels && labelfunction(hist.weights, i, lowposition, highposition, barwidth, scaledvalue)
			sethue("blue")
			scaledgaussvalue = rescale(pdf(dist, hist.edges[1][i+1] - hist.edges[1].step.hi/2), minbarrange, maxbarrange) * barchartheight
			circle(lowposition - (0, scaledgaussvalue), 2, :fill)
			sethue("black")
        end
    end
    return (positions = hpositions)
end

# ╔═╡ 245f8757-020a-4fe5-b7f4-f87f14fc498a
begin
	
n_frames = 100
n_hists = 50
n_samples = 10000
nbins = 100
	
dist = Geometric(0.1)
# dist = Exponential(10)
# dist = Beta(6, 0.7)
# dist = Cauchy(2,0.2)
# dist = Chernoff()
# dist = Pareto(5)

samples = map(1:n_hists) do n
	to_histogram = map(1:n_samples) do _
		(mean(rand(dist, n)) - mean(dist)) * sqrt(n)
	end
end

steps = map(samples) do sampling
	hist = fit(Histogram, sampling, weights(ones(length(sampling))), range(minimum(samples[end]), maximum(samples[end]), length=100))
	hist = StatsBase.normalize(hist, mode=:pdf)
	hist, sampling
end
	
my_video = Video(600, 600)

function ground(args...)
	background("white")
	sethue("black")
end
	
Background(1:n_frames, ground)

step_size = n_frames ÷ n_hists

frame_brakes = 1:step_size:n_frames

gauss = Normal(0, std(dist))
	
for (frame_n, j) in zip(frame_brakes, steps[1:end-1])
	
	Object(frame_n:frame_n + step_size, @JShape begin
		newbarchart(j[1], gauss)
	end)
		
	Object(frame_n:frame_n+step_size, @JShape begin
		fontsize(20)
		Luxor.text(string(frame_n), Point(100,-100))
	end)
		
	Object(1:n_frames, @JShape begin
		line(Point(-300, 150), Point(300, 150), :stroke)
	end)
end
	
render(my_video, framerate=30, pathname="output/CLT.gif")
	
end

# ╔═╡ 36a83850-2573-434e-8e07-44457f6d42dc
function myCLT(dist;
    boundingbox = BoundingBox(O + (-250, -120), O + (250, 120)),
    bargap=10,
    margin = 5,
    border=false,
    labels=false,
    labelfunction = (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
        label(string(values[i]), :n, highpos, offset=10)
    end,
    barfunction =  (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
        @layer begin
            Luxor.setline(barwidth)
            line(lowpos, highpos, :stroke)
        end
    end,
    prologfunction = (values, basepoint, minbarrange, maxbarrange, barchartheight) -> ()
    )
	
	
	n_frames = 100
	n_hists = 50
	n_samples = 10000
	nbins = 100
	
	samples = map(1:n_hists) do n
		map(1:n_samples) do _
		(mean(rand(dist, n)) - mean(dist)) * sqrt(n)
		end
	end
	
	finalmin, finalmax = extrema(samples[end])
	
	steps = map(samples) do sampling
		hist = fit(Histogram, sampling, 
			weights(ones(length(sampling))), 
			range(finalmin, finalmax,length=100)
		)
		hist = StatsBase.normalize(hist, mode=:pdf)
		hist
	end
	
	final_hist = steps[end]
	
    my_video = Video(600, 600)

	function ground(args...)
		background("white")
		sethue("black")
	end
	
	function mylabelfunction(hist, minbarrange, maxbarrange, barchartheight)
		(values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
		sethue("blue")
		if i <= length(hist.edges[1])
			scaledgaussvalue = rescale(
			pdf(Normal(0, std(dist)), hist.edges[1][i+1] - hist.edges[1].step.hi/2),
			minbarrange, 
			maxbarrange
		) * barchartheight
			circle(lowpos - (0, scaledgaussvalue), 2, :fill)
		end
		sethue("black")
		end
	end
	
	Background(1:n_frames, ground)

	step_size = n_frames ÷ n_hists

	frame_brakes = 1:step_size:n_frames

	gauss = Normal(0, std(dist))
	
	for (frame_n, hist) in zip(frame_brakes, steps[2:end])
		
		minvalue, maxvalue = extrema(hist.weights)
		barchartheight = boxheight(boundingbox) - 2margin
		minbarrange = minvalue - abs(minvalue)
    	maxbarrange = maxvalue + abs(maxvalue)
		
		Object(frame_n:frame_n + step_size, @JShape begin
			barchart(
				hist.weights,
				boundingbox=boundingbox,
				bargap=bargap,
    			margin=margin,
    			border=border,
				labels=true,
				barfunction=barfunction,
				labelfunction = mylabelfunction(
						hist, 
						minbarrange, 
						maxbarrange, 
						barchartheight
				)
			)
			end
		)
		
		Object(frame_n:frame_n+step_size, @JShape begin
			fontsize(20)
			counterpoint = Point(100, 0)
			Luxor.text(string(frame_n ÷ step_size), counterpoint, halign=:center)
			label("Iteration", :N, counterpoint, offset=20)
		end)
		
		Object(frame_n:frame_n+step_size, @JShape begin
			fontsize(40)
			titlepoint = Point(0, -100)
			Luxor.text("Central Limit Theorem", titlepoint, halign=:center)
		end)
	end
	
	render(my_video, framerate=100, pathname="output/CLT.gif")
	
end

# ╔═╡ Cell order:
# ╠═5b918be6-0003-11ec-1e1f-534faed7dfe5
# ╟─08925513-6646-48ac-9fa8-2e48b4a40230
# ╠═4d489509-80c4-40a6-a182-ce785f322684
# ╠═245f8757-020a-4fe5-b7f4-f87f14fc498a
# ╠═47bcc4fe-a44f-4715-8ed3-bbe00c02f30f
# ╠═31b29fb2-b52e-4569-96b2-5999b7424bb6
# ╠═b1676337-685a-4759-a771-34a770acf72e
# ╠═36a83850-2573-434e-8e07-44457f6d42dc
# ╟─05385a8e-8764-4352-9023-1b126a9c7295
