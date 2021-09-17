### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
begin
using Pkg
Pkg.activate("..")
using Javis, JUtils, Animations, PlutoUI, Plots, LaTeXStrings
import Luxor
end

# ╔═╡ b3c04a1d-41d3-458f-8624-3cb6c114f210
function ground(args...)
	background("black")
	sethue("white")
end

# ╔═╡ 7ac8f5b3-fa39-4e15-841b-5093437afbce
L"\huge{\theta(t) = \pi e^{-\frac{t}{\tau}} \cos(t\omega)}"

# ╔═╡ 42d0c661-344f-4358-869d-cf5929056392
begin

## Constants
shift = Point(0, 0)
basepoint = shift + O
radius = 300
margin = 10
k = 0.7 * π
n_frames = 500
speed_up = 3
	
pendulum_video = Video(800, 800)
Background(1:n_frames, ground)
	
## Constant shapes
Object((args...)->arc(O, radius, 0, π, :stroke))
Object((args...)->Javis.latex(L"\Huge{\theta(t) = \pi e^{-\frac{t}{\tau}} \cos(\omega t)}", Point(150, -300), :middle, :center))
Object(JLine(basepoint - (radius, 0), basepoint + (radius, 0), color="white"))
Object(JLine(basepoint, basepoint + (0, radius), color="white"))
Object(
		JLine(
			Point(-radius, -radius/2 - margin), 
			Point(radius, -radius/2 - margin), 
			linewidth=1, 
			color="white"
			))

Object(@JShape begin
			setline(2)
			tickline(
				Point(-radius, -radius - margin), 
				Point(-radius, -margin), 
				startnumber=k, 
				finishnumber=-k)
		end)
	
	
motion(t) = k * ℯ^(-3*(t)/2) * cos(10t)
	
points = map(1:n_frames) do idx
		# Frame constants
		t = speed_up * idx/n_frames
		p = shift + radius * Point(sin(motion(t)), cos(motion(t)))
		endpoint = shift + p
		
		# Lines
		Object(
			idx:idx, 
			@JShape begin
				setline(3)
				sethue("white")
				line(basepoint, shift + p, :stroke)
				setline(1)
				sethue("orange")
				line(endpoint, Point(endpoint.x, 0), :stroke)
				line(endpoint, Point(0, endpoint.y), :stroke)
			end
		)
		Object(idx:idx, JCircle(endpoint, 20,action=:fill, color="red"))
		
		# Labels
		Object(idx:idx, (args...)-> begin
				fontsize(25)
				cos_x_val = midpoint(basepoint, endpoint).x
				# label("Cos(θ)", :N, Point(cos_x_val, endpoint.y), offset=5)
				Javis.latex(L"\sin(\theta)", Point(cos_x_val, endpoint.y) + (0, -10), :middle, :center)
				sin_y_val = midpoint(basepoint, endpoint).y
				# label("Sin(θ)", :W, Point(endpoint.x, sin_y_val), offset=5)
				Javis.latex(L"\cos(\theta)", Point(endpoint.x, sin_y_val) + (-4, 0), :middle, :center)
			end
		)
		
		# Arcs
		Object(idx:idx,(args...) -> begin
				mypoint = Point(sin(motion(t)), cos(motion(t)))
				if motion(t) < 0
					move(Point(0, 40))
					arc(basepoint, 40, π/2, π/2 - motion(t), :stroke)
				else
					move(40 * mypoint)
					arc(basepoint, 40, π/2 - motion(t), π/2, :stroke)
				end
				fontsize(25)
				# label("θ", :W, basepoint + (-margin, margin), offset=0)
				Javis.latex(
					L"\theta", 
					basepoint + (-2margin, 2margin), 
					:middle, 
					:center
				)				
			end
		)

		
		Object(
			idx:idx,
			(args...) -> begin
				# Tangent component
				Luxor.arrow(endpoint, endpoint + 100 * cos(motion(t) - π/2) * Point(sin(motion(t) - π/2), cos(motion(t) - π/2)), linewidth=2)
				
				# Perpendicular component
				Luxor.arrow(endpoint, endpoint + radius/3 * sin(motion(t) - π/2) * Point(-cos(motion(t) - π/2), sin(motion(t) - π/2)), linewidth=2)
				
				# Full force
				sethue("grey")
				Luxor.arrow(endpoint, endpoint + radius/3 * Point(0, 1))
			end
		)
		
		# Plot
		Object(
			idx:n_frames, 
			JCircle(Point(
					- radius + margin + idx * (2*radius - margin) / n_frames , 
					- radius/2 - margin - radius * motion(t)/2k
					), 2, action=:fill, color="red")
		)
	end
	

	Object((args...) -> Javis.latex(L"\frac{2}{3}"))
	Object(1:n_frames, JCircle(basepoint, 10, action=:fill, color="blue"))
	v = render(pendulum_video, pathname="../output/pendulum.gif", framerate=30)
end

# ╔═╡ Cell order:
# ╠═8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
# ╟─b3c04a1d-41d3-458f-8624-3cb6c114f210
# ╠═7ac8f5b3-fa39-4e15-841b-5093437afbce
# ╠═42d0c661-344f-4358-869d-cf5929056392
