### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
begin
using Pkg
Pkg.activate("..")
using Javis, JUtils, Animations, PlutoUI, Plots
end

# ╔═╡ b3c04a1d-41d3-458f-8624-3cb6c114f210
function ground(args...)
	background("black")
	sethue("white")
end

# ╔═╡ 42d0c661-344f-4358-869d-cf5929056392
begin
n_frames = 100
pendulum_video = Video(800, 800)
Background(1:n_frames, ground)

shift = Point(0, 0)
basepoint = shift + O
radius = 300
Object(JCircle(basepoint, 300, action=:stroke, color="white"))
	
motion(t) = 0.5 * ℯ^(-2*(t)/2) * cos(10t)
	
coords = map(1:n_frames) do i
	 shift + radius * Point(sin(motion(i/n_frames)), cos(motion(i/n_frames)))
end
	
	
	
points = map(enumerate(coords)) do (idx, p)
	Object(idx:idx, JLine(basepoint, shift + p, color="white", linewidth=3))
	endpoint = shift + p
	
	
	Object(idx:idx, JLine(endpoint, Point(endpoint.x, 0), color="orange"))
	Object(idx:idx, (args...)-> begin
		fontsize(25)
		label("Sin(θ)", :W, Point(endpoint.x, midpoint(basepoint, endpoint).y), offset=5)
	end)
	
	Object(idx:idx, JLine(endpoint, Point(0, endpoint.y), color="orange"))
	Object(idx:idx, (args...)-> begin
		fontsize(25)
				label("Cos(θ)", :S, Point(midpoint(basepoint, endpoint).x, endpoint.y), offset=5)
	end)
	Object(idx:idx,(args...)->begin
		@layer begin
			newpath()
			mypoint = Point(sin(motion(idx/n_frames)), cos(motion(idx/n_frames)))
			move(40 * mypoint)
			arc(basepoint, 40, π/2 - motion(idx/n_frames), π, :stroke)
			strokepath()
			fontsize(25)
			label("θ", :W, basepoint + (-10, 15), offset=0)
		end
	end)
	Object(idx:idx, JCircle(endpoint, 20,action=:fill, color="red"))
end

Object(1:n_frames, JLine(basepoint - (radius, 0), basepoint + (radius, 0), color="white"))
Object(1:n_frames, JLine(basepoint, basepoint + (0, radius), color="white"))
	
Object(1:n_frames, JCircle(basepoint, 10, action=:fill, color="blue"))
	
v = render(pendulum_video, pathname="../output/pendulum.gif", framerate=15)
end

# ╔═╡ e4d49656-5ebb-4b51-b6cc-b2a5209a904b
plot(0:0.01:2, motion.(0:0.01:2))

# ╔═╡ Cell order:
# ╟─8ff88bf0-14cb-11ec-2f1c-8f7745e8a6b2
# ╟─b3c04a1d-41d3-458f-8624-3cb6c114f210
# ╟─42d0c661-344f-4358-869d-cf5929056392
# ╟─e4d49656-5ebb-4b51-b6cc-b2a5209a904b
