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

# ╔═╡ 42d0c661-344f-4358-869d-cf5929056392
begin

## Constants
shift = Point(0, 0)
basepoint = shift + O
radius = 200
margin = 10
k = 0.7 * π
n_frames = 500
speed_up = 3
	
pendulum_video = Video(800, 800)
Background(1:n_frames, ground)
	
## Constant shapes
Object((args...)->arc(O, radius, 0, π, :stroke))
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
		
		# Labels
		Object(idx:idx, (args...)-> begin
				fontsize(25)
				cos_x_val = midpoint(basepoint, endpoint).x
				label("Cos(θ)", :N, Point(cos_x_val, endpoint.y), offset=5)
				sin_y_val = midpoint(basepoint, endpoint).y
				label("Sin(θ)", :W, Point(endpoint.x, sin_y_val), offset=5)
			end
		)
		
		# Arcs
		Object(idx:idx,(args...) -> begin
				newpath()
				mypoint = Point(sin(motion(t)), cos(motion(t)))
				move(40 * mypoint)
				arc(basepoint, 40, π/2 - motion(t), π, :stroke)
				strokepath()
				fontsize(25)
				label("θ", :W, basepoint + (-margin, margin), offset=0)
			end
		)
		Object(idx:idx, JCircle(endpoint, 20,action=:fill, color="red"))
		
		Object(
			idx:idx,
			(args...) -> begin
				# Tangent
				Luxor.arrow(endpoint, endpoint + 100 * cos(motion(t) - π/2) * Point(sin(motion(t) - π/2), cos(motion(t) - π/2)), linewidth=2)
				
				# Perpendicular
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
					- radius + margin + idx * ((2*radius - margin) / n_frames) , 
					- radius/2 - margin - radius * motion(t)/2k
					), 2, action=:fill, color="red")
		)
	end


Object(1:n_frames, JCircle(basepoint, 10, action=:fill, color="blue"))
v = render(pendulum_video, pathname="../output/pendulum.gif", framerate=30)
end

# ╔═╡ e4d49656-5ebb-4b51-b6cc-b2a5209a904b
plot(0:0.01:2, motion.(0:0.01:2)./k)

# ╔═╡ Cell order:
# ╠═8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
# ╠═b3c04a1d-41d3-458f-8624-3cb6c114f210
# ╠═e4d49656-5ebb-4b51-b6cc-b2a5209a904b
# ╠═42d0c661-344f-4358-869d-cf5929056392
