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
			labels=true,
			labelfunction = (values, i, lowpos, highpos, barwidth, scaledvalue) -> begin
				sethue("blue")
				circle(
					Point(
						lowpos.x, 
						lowpos.y - abs(maximum(values) - lowpos.y) * pdf(gauss, hist.edges[1][i])
						), 
					2, 
					:fill
				)
				
				sethue("black")
          end
	)	
end
# plot([pdf(gauss, i) for i in hist.edges[1]])
# bins(hist)
end

# ╔═╡ 245f8757-020a-4fe5-b7f4-f87f14fc498a
begin
	
n_frames = 100
n_hists = 100
n_samples = 10000
nbins = 100
	
# dist = Geometric(0.1)
# dist = Exponential(10)
# dist = Beta(6, 0.7)
# dist = Cauchy(2,0.2)
# dist = Chernoff()
dist = Pareto(5)

steps = map(1:n_hists) do n
	to_histogram = [
			(mean(rand(dist, n)) - mean(dist)) * sqrt(n)
			for i in 1:n_samples
		]
	hist = fit(Histogram, to_histogram, nbins=100)
	# hist.weights ./ n_samples, collect(hist.edges[1]), to_histogram
	hist, to_histogram
end
my_video = Video(600, 600)

function ground(args...)
	background("white")
	sethue("black")
end
	
Background(1:n_frames, ground)

step_size = n_frames ÷ n_hists

frame_brakes = 1:step_size:n_frames

gauss = Normal(0, var(dist))
	
for (frame_n, j) in zip(frame_brakes, steps[1:end-1])
	
	Object(frame_n:frame_n + step_size, @JShape begin
		barchart(j[1].weights,labels=true,
			boundingbox = BoundingBox(O + (-250, -120), O + (250, 120)),
			labelfunction = (values, i, lowpos, highpos, barwidth, scaledvalue) -> 					begin
					
					minvalue, maxvalue = extrema(values)
					minbarrange = minvalue - abs(minvalue)
					maxbarrange = maxvalue + abs(maxvalue)
						
					shift = Point(
						0, 
						rescale(pdf(gauss, j[1].edges[1][i+1]), minbarrange, maxbarrange) * 230
						)
					sethue("blue")
					circle(
					lowpos - shift,
					2, 
					:fill
				)
						
				sethue("black")
			end
				)
	end)
		
	Object(frame_n:frame_n+step_size, @JShape begin
		fontsize(20)
		Luxor.text(string(frame_n), Point(100,-100))
	end)
		
	Object(1:n_frames, @JShape begin
		line(Point(-300, 150), Point(300, 150), :stroke)
	end)
end
	
render(my_video, framerate=100, pathname="output/CLT.gif")
	
end

# ╔═╡ 47055172-57dd-4e66-98c6-28b3da2b40ce
begin

plo = plot()
	histogram!(plo, steps[end][2], bins=100, normalize=:probability)
	plot!(plo, steps[end][1].edges, [0; steps[end][1].weights]./n_samples, lw=4)
	plot!(plo, steps[end][1].edges, pdf.(gauss, steps[end][1].edges[1]), lw=10)

# scatter!(plo, pdf(Normal(0, std(dist)), steps[end][2][2:end]))
# 	std(steps[end][3]), std(dist)
end

# ╔═╡ 05385a8e-8764-4352-9023-1b126a9c7295
function newbarchart(values;
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
    minvalue, maxvalue = extrema(values)
    barchartwidth  = boxwidth(boundingbox)  - 2bargap - 2margin
    barchartheight = boxheight(boundingbox) - 2margin
    barwidth = (barchartwidth - 2bargap)/length(values)
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
        range(0.0, stop=1.0, length=2length(values) + 1))[2:2:end-1]
    @layer begin
        if border
            box(boundingbox, :stroke)
        end
        prologfunction(values, basepoint, minbarrange, maxbarrange, barchartheight)
        for i in 1:length(values)
            scaledvalue = rescale(values[i], minbarrange, maxbarrange) * barchartheight
			scaledvalue = values[i]
            lowposition = hpositions[i]
            highposition = lowposition - (0, scaledvalue) # -y coord
            barfunction(values, i, lowposition, highposition, barwidth, scaledvalue)
            labels && labelfunction(values, i, lowposition, highposition, barwidth, scaledvalue)
			sethue("blue")
			circle(lowposition - Point(0, pdf(gauss, steps[end][1].edges[1][i]) * barchartheight), 2, :fill)
			sethue("black")
        end
    end
    return (positions = hpositions)
end

# ╔═╡ d136e0d3-27c5-49d2-bfb4-ffb0dd6128cd
@draw begin
	newbarchart(steps[end][1].weights)
end

# ╔═╡ Cell order:
# ╠═5b918be6-0003-11ec-1e1f-534faed7dfe5
# ╟─08925513-6646-48ac-9fa8-2e48b4a40230
# ╠═4d489509-80c4-40a6-a182-ce785f322684
# ╠═245f8757-020a-4fe5-b7f4-f87f14fc498a
# ╠═47055172-57dd-4e66-98c6-28b3da2b40ce
# ╠═d136e0d3-27c5-49d2-bfb4-ffb0dd6128cd
# ╠═05385a8e-8764-4352-9023-1b126a9c7295
